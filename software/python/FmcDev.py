#!/usr/bin/env python3
#-----------------------------------------------------------------------------
# This file is part of the 'ATLAS RD53 FMC DEV'. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the 'ATLAS RD53 FMC DEV', including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
import pyrogue as pr

import rogue.hardware.axi
import rogue.protocols
import pyrogue.interfaces.simulation

import RceG3   as rce
import axipcie as pcie
import fmcHw   as hw

import os

class LoadSimConfig(rogue.interfaces.stream.Master):

    # Init method must call the parent class init
    def __init__(self):
        super().__init__()

    # Method for generating a frame
    def myFrameGen(self):
        
        # Set the config file path
        configFile = (os.path.dirname(os.path.realpath(__file__)) + '/../config/txstream_1p28GHz.hex')
        
        # Determine the frame size
        size = len(open(configFile).readlines()) << 2
        
        # First request an empty from from the primary slave
        # The first arg is the size, the second arg is a boolean
        # indicating if we can allow zero copy buffers, usually set to true
        frame = self._reqFrame(size, True)
        
        # Load the configuration into the frame
        with open(configFile, 'r') as f:
            offset = 0
            for line in f.readlines():
                # Convert HEX string to byte array
                ba = bytearray.fromhex(line)
                # Write the data to the frame at offset 
                frame.write(ba,offset)
                # Increment the offset
                offset=offset+4
                
        # Send the frame to the currently attached slaves
        self._sendFrame(frame)
    

class FmcDev(pr.Root):

    def __init__(self,
            name        = 'FmcDev',
            description = 'Container for Fmc Dev',
            hwType      = 'kc705',         # Define whether sim/rce/kc705/kcu105 HW config
            dev         = '/dev/datadev_0',# path to device
            pollEn      = True,            # Enable automatic polling registers
            initRead    = True,            # Read all registers at start of the system
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)
        
        self._dmaSrp  =  None       
        self._dmaCmd  = [None for i in range(4)]
        self._dmaData = [None for i in range(4)]
        
        # Set the timeout
        self._timeout = 1.0 # 1.0 default    

        # Start up flags
        self._pollEn   = pollEn
        self._initRead = initRead        
        
        # Check for sim HW type
        if (hwType == 'sim'): 
            # FW/SW co-simulation
            self.memMap = rogue.interfaces.memory.TcpClient('localhost',8000)  
            
            # Set the timeout
            self._timeout = 100.0 # firmware simulation slow and timeout base on real time (not simulation time)
            
            # Start up flags
            self._pollEn   = False
            self._initRead = False            
            
            # Create arrays to be filled
            self._frameGen = [None for lane in range(4)]            
            
            # SRPv3 on DMA.Lane[1]
            self._dmaSrp = rogue.interfaces.stream.TcpClient('localhost',8002+(512*1)+2*0)
            
            for i in range(4):
                # CMD on DMA.Lane[0].VC[3:0]
                self._dmaCmd[i]  = rogue.interfaces.stream.TcpClient('localhost',8002+(512*0)+2*(i+0))
                
                # DATA on DMA.Lane[0].VC[7:4]
                self._dmaData[i]  = rogue.interfaces.stream.TcpClient('localhost',8002+(512*0)+2*(i+4))
                
                # Create the frame generator
                self._frameGen[i] = LoadSimConfig()
            
                # Connect the frame generator
                pr.streamConnect(self._frameGen[i],self._dmaCmd[i])
                
                # Create a command to execute the frame generator
                self.add(pr.BaseCommand(   
                    name         = f'SimConfig[{i}]',
                    function     = lambda cmd, i=i: self._frameGen[i].myFrameGen(),
                ))                 
            
        elif (hwType == 'kc705') or (hwType == 'kcu105'): 
            # BAR0 access
            self.memMap = rogue.hardware.axi.AxiMemMap(dev)     
            
            # Add the PCIe core device to base
            self.add(pcie.AxiPcieCore(
                memBase     = self.memMap ,
                offset      = 0x00000000, 
                numDmaLanes = 2, 
                expand      = False, 
            ))       

            # Determine the DMA's TDEST stride
            stride = 0x80 if (hwType == 'kc705') else 0x100
            
            # SRPv3 on DMA.Lane[1]
            self._dmaSrp = rogue.hardware.axi.AxiStreamDma(dev,(stride*1)+0,True)
            
            for i in range(4):
                # CMD on DMA.Lane[0].VC[3:0]
                self._dmaCmd[i]  = rogue.hardware.axi.AxiStreamDma(dev,(stride*0)+i+0,True)
                
                # DATA on DMA.Lane[0].VC[7:4]
                self._dmaData[i] = rogue.hardware.axi.AxiStreamDma(dev,(stride*0)+i+4,True)            
            
        
        elif (hwType == 'rce'): 
            # Create the mmap interface
            memMap = rogue.hardware.axi.AxiMemMap('/dev/rce_memmap')
            
            # Add RCE version device
            self.add(rce.RceVersion( 
                memBase = memMap,
                expand  = False,
            ))          
            
            # SRPv3 on DMA.Lane[1]
            self._dmaSrp = rogue.hardware.axi.AxiStreamDma('/dev/axi_stream_dma_1',0,True)
            
            for i in range(4):
                # CMD on DMA.Lane[0].VC[3:0]
                self._dmaCmd[i]  = rogue.hardware.axi.AxiStreamDma('/dev/axi_stream_dma_0',i+0,True)
                
                # DATA on DMA.Lane[0].VC[7:4]
                self._dmaData[i] = rogue.hardware.axi.AxiStreamDma('/dev/axi_stream_dma_0',i+4,True)
            
        else:
            raise ValueError(f'Invalid hwType. Must be either [sim,kc705,kcu105,rce]' )
        
        # Connect the DMA SRPv3 stream
        self._srp = rogue.protocols.srp.SrpV3()
        pr.streamConnectBiDir(self._dmaSrp,self._srp)        

        # FMC Board
        self.add(hw.Fmc(      
            memBase     = self._srp,
            simulation  = (hwType == 'sim'),
            # expand      = False,
        ))         
        
        # Start the system
        self.start(
            pollEn   = self._pollEn,
            initRead = self._initRead,
            timeout  = self._timeout,
        )
        