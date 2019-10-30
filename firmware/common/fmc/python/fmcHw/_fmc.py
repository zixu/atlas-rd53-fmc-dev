#!/usr/bin/env python3
#-----------------------------------------------------------------------------
# This file is part of the 'Camera link gateway'. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the 'Camera link gateway', including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue as pr

import AtlasRd53           as asic
import surf.axi            as axi
import surf.devices.silabs as silabs
import surf.devices.nxp    as nxp
import surf.devices.ti     as ti
       
class Fru(pr.Device):
    def __init__(self,name='Fru',**kwargs):
        super().__init__(name=name,**kwargs)

        self.addRemoteVariables(       
            name        = 'MEM', 
            offset      = 0x0, 
            number      = 2**8, 
            bitSize     = 8, 
            bitOffset   = 0, 
            stride      = 4,
            mode        = 'RW', 
            hidden      = True,
        )

class Fmc(pr.Device):
    def __init__(   self,       
            name        = "Fmc",
            description = "FMC Container",
            simulation  = False,
            fmcFru      = False,
            **kwargs):
        super().__init__(name=name, description=description, **kwargs) 
        
        for i in range(4):
            self.add(asic.Ctrl(      
                name   = f'Ctrl[{i}]', 
                offset = (0x10000*i), 
                expand = False,
            ))        
        
        if not(simulation):
        
            self.add(nxp.Pca9506(      
                name   = 'Gpio', 
                offset = 0x40000, 
                expand = False,
            ))          
            
            self.add(ti.Lmk61e2(      
                name   = 'Lmk', 
                offset = 0x40400,
                expand = False,
            ))           
            
            self.add(silabs.Si5345(      
                name        = 'Pll', 
                description = 'This device contains Jitter cleaner PLL', 
                offset      = 0x80000, 
                expand      = False,
                # hidden      = True, # Hidden in GUI because indented for scripting or YAML load
            ))  
        
        self.add(asic.EmuTimingLut(      
            name   = 'EmuTimingLut', 
            offset = 0x90000, 
            expand = False,
        ))        
        
        self.add(asic.EmuTimingFsm(      
            name   = 'EmuTimingFsm', 
            offset = 0xA0000, 
            expand = False,
        ))
        
        self.add(axi.AxiVersion(
            offset = 0xB0000,
            expand = False,
        ))        

        if (fmcFru):
            self.add(Fru(
                offset = 0xC0000,
                hidden = True,
                expand = False,
            ))  
