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

import numpy as np

import rogue
import rogue.hardware.axi
import rogue.protocols
import pyrogue.protocols
import pyrogue.interfaces.simulation

import RceG3   as rce
import axipcie as pcie
import fmcHw   as hw

import os
import time
import click

rogue.Version.minVersion('4.1.0') 

class LoadSimConfig(rogue.interfaces.stream.Master):

    # Init method must call the parent class init
    def __init__(self, fullRate):
        super().__init__()
        self.fullRate = fullRate

    # Method for generating a frame
    def config(self):
        
        # Set the config file path
        if self.fullRate:
            configFile = (os.path.dirname(os.path.realpath(__file__)) + '/../config/rd53a_config_1280MHz.hex')
        else:
            configFile = (os.path.dirname(os.path.realpath(__file__)) + '/../config/rd53a_config_160MHz.hex')
        
        # Print the config file path
        print (configFile)        
        
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
                ba = bytearray(reversed(ba))
                # Write the data to the frame at offset 
                frame.write(ba,offset)
                # Increment the offset
                offset=offset+4
                
        # Send the frame to the currently attached slaves
        self._sendFrame(frame)
        
    # Method for generating a frame
    def scan(self):
        
        # Set the config file path
        configFile = (os.path.dirname(os.path.realpath(__file__)) + '/../config/tx_scan_multiPix.hex')
        
        # Print the config file path
        print (configFile)        
        
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
                ba = bytearray(reversed(ba))
                # Write the data to the frame at offset 
                frame.write(ba,offset)
                # Increment the offset
                offset=offset+4
                
        # Send the frame to the currently attached slaves
        self._sendFrame(frame)        
    
    
class PrintSlaveStream(rogue.interfaces.stream.Slave):

    # Init method must call the parent class init
    def __init__(self):
        super().__init__()
        self.wrdCnt = 0
        self.datCnt = 0
        self.hdrCnt = 0

    def cntRst(self):
        self.wrdCnt = 0
        self.datCnt = 0
        self.hdrCnt = 0
        
    # Method which is called when a frame is received
    def _acceptFrame(self,frame):

        # First it is good practice to hold a lock on the frame data.
        with frame.lock():

            # Next we can get the size of the frame payload
            size = frame.getPayload()

            # To access the data we need to create a byte array to hold the data
            fullData = bytearray(size)
            
            # Next we read the frame data into the byte array, from offset 0
            frame.read(fullData,0)

            # Fill an array of 32-bit formatted word
            wrdData = [None for i in range(128)]
            wrdData = np.frombuffer(fullData, dtype='uint64', count=(size>>3))
            
            for i in range(len(wrdData)):
                self.wrdCnt = self.wrdCnt + 1
                rawData = hex(wrdData[i])
                
                rawWord = [0,0]
                rawWord[0] = (int(rawData,16) >> 0) & 0xFFFFFFFF
                rawWord[1] = (int(rawData,16) >> 32) & 0xFFFFFFFF
                
                for i in range(2):
                    if (rawWord[i] >> 25) == 1:
                        self.hdrCnt = self.hdrCnt + 1
                    elif rawWord[i] != 0xFFFFFFFF:
                        self.datCnt = self.datCnt + 1
                        # col = (rawWord[i] >> 26) & 0x3F
                        # row = (rawWord[i] >> 17) & 0x1FF                    
                        
                print(f'wrdCnt = {self.wrdCnt}, hdrCnt = {self.hdrCnt}, datCnt = {self.datCnt}, rawData = {rawData}')

class FmcDev(pr.Root):

    def __init__(self,
            name        = 'FmcDev',
            description = 'Container for Fmc Dev',
            hwType      = 'eth',         # Define whether sim/rce/pcie/eth HW config
            ip          = '192.168.2.10',
            dev         = '/dev/datadev_0',# path to device
            pllConfig   = 'config/pll-config/Si5345-RevD-Registers-160MHz.csv',
            fullRate    = True,            # For simulation: True=1.28Gb/s, False=160Mb/s
            pollEn      = True,            # Enable automatic polling registers
            initRead    = True,            # Read all registers at start of the system
            fmcFru      = False,           # True if configuring the FMC's FRU
            testPattern = False,      
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)
        
        self._dmaSrp     =  None       
        self._dmaCmd     = [None for i in range(4)]
        self._dmaData    = [None for i in range(4)]
        self._frameGen   = [None for lane in range(5)]            
        self._printFrame = [None for lane in range(4)]    
        
        self.fmcFru      = fmcFru       
        self.pllConfig   = pllConfig
        self.hwType      = hwType
        self.testPattern = True if hwType == 'sim' else testPattern
        
        # Set the timeout
        self._timeout = 1.0 # 1.0 default    

        # Start up flags
        self._pollEn   = pollEn
        self._initRead = initRead        
        
        # Check for HW type
        if (hwType == 'eth'): 
        
            # Connected to FW DMA.Lane[0]
            self.rudpData = pr.protocols.UdpRssiPack(
                host    = ip,
                port    = 8192,
                packVer = 2,
            )                
        
            # Connected to FW DMA.Lane[1]
            self.rudpSrp = pr.protocols.UdpRssiPack(
                host    = ip,
                port    = 8193,
                packVer = 2,
            )         
            
            # SRPv3 on DMA.Lane[1]
            self._dmaSrp  = self.rudpSrp.application(0)
            
            for i in range(4):
                # CMD on DMA.Lane[0].VC[3:0]
                self._dmaCmd[i]  = self.rudpData.application(i+0)
                
                # DATA on DMA.Lane[0].VC[7:4]
                self._dmaData[i] = self.rudpData.application(i+4)            
        
        elif (hwType == 'sim'): 
            # FW/SW co-simulation
            self.memMap = rogue.interfaces.memory.TcpClient('localhost',8000)  
            
            # Set the timeout
            self._timeout = 100.0 # firmware simulation slow and timeout base on real time (not simulation time)
            
            # Start up flags
            self._pollEn   = False
            self._initRead = False            
                        
            # SRPv3 on DMA.Lane[1]
            self._dmaSrp = rogue.interfaces.stream.TcpClient('localhost',8002+(512*1)+2*0)
            
            for i in range(4):
                # CMD on DMA.Lane[0].VC[3:0]
                self._dmaCmd[i]  = rogue.interfaces.stream.TcpClient('localhost',8002+(512*0)+2*(i+0))
                
                # DATA on DMA.Lane[0].VC[7:4]
                self._dmaData[i]  = rogue.interfaces.stream.TcpClient('localhost',8002+(512*0)+2*(i+4))
                           
        elif (hwType == 'pcie'): 
            # BAR0 access
            self.memMap = rogue.hardware.axi.AxiMemMap(dev)     
            
            # Add the PCIe core device to base
            self.add(pcie.AxiPcieCore(
                memBase     = self.memMap ,
                offset      = 0x00000000, 
                numDmaLanes = 2, 
                expand      = False, 
            ))       
            
            # SRPv3 on DMA.Lane[1]
            self._dmaSrp = rogue.hardware.axi.AxiStreamDma(dev,(0x80*1)+0,True)
            
            for i in range(4):
                # CMD on DMA.Lane[0].VC[3:0]
                self._dmaCmd[i]  = rogue.hardware.axi.AxiStreamDma(dev,(0x80*0)+i+0,True)
                
                # DATA on DMA.Lane[0].VC[7:4]
                self._dmaData[i] = rogue.hardware.axi.AxiStreamDma(dev,(0x80*0)+i+4,True)            
            
        
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
            raise ValueError(f'Invalid hwType. Must be either [sim,rce,pcie,eth]' )
        
        # Connect the DMA SRPv3 stream
        self._srp = rogue.protocols.srp.SrpV3()
        pr.streamConnectBiDir(self._dmaSrp,self._srp)        

        # Check if doing test patterns
        if self.testPattern:
        
            # Create the frame generator
            self._frameGen[4] = LoadSimConfig(fullRate)
                
            # Connect the frame generator to "broadcast the Cmd from SW to all the MiniDP ports"
            pr.streamConnect(self._frameGen[4],self._dmaData[0])       # DMA.Lane[0].VC[4].TX
                
            for i in range(4):
                
                # Create the frame generator
                self._frameGen[i] = LoadSimConfig(fullRate)
                self._printFrame[i] = PrintSlaveStream()
            
                # Connect the frame generator
                pr.streamConnect(self._frameGen[i],self._dmaCmd[i])    # DMA.Lane[0].VC[3:0].TX
                pr.streamConnect(self._dmaData[i],self._printFrame[i]) # DMA.Lane[0].VC[7:4].RX
                
                # Create a command to execute the frame generator
                self.add(pr.BaseCommand(   
                    name         = f'SimConfig[{i}]',
                    function     = lambda cmd, i=i: self._frameGen[i].config(),
                ))  
                self.add(pr.BaseCommand(   
                    name         = f'SimScan[{i}]',
                    function     = lambda cmd, i=i: [self.CountReset(), self._printFrame[i].cntRst(), self._frameGen[i].scan()],
                ))  
                # self.add(pr.BaseCommand(   
                    # name         = f'SimCntRst[{i}]',
                    # function     = lambda cmd, i=i: self._printFrame[i].cntRst(),
                # ))                  

        # FMC Board
        self.add(hw.Fmc(      
            memBase     = self._srp,
            simulation  = (hwType == 'sim'),
            fmcFru      = fmcFru,
            expand      = True,
        ))         
        
        # Start the system
        self.start(
            pollEn   = self._pollEn,
            initRead = self._initRead,
            timeout  = self._timeout,
        )
        