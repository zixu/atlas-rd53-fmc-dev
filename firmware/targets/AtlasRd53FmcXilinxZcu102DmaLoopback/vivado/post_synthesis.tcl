##############################################################################
## This file is part of 'RCE Development Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'RCE Development Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

##############################
# Get variables and procedures
##############################
source -quiet $::env(RUCKUS_DIR)/vivado_env_var.tcl
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Bypass the debug chipscope generation
return

############################
## Open the synthesis design
############################
open_run synth_1

###############################
## Set the name of the ILA core
###############################
set ilaName u_ila_0

##################
## Create the core
##################
CreateDebugCore ${ilaName}

#######################
## Set the record depth
#######################
set_property C_DATA_DEPTH 1024 [get_debug_cores ${ilaName}]

#################################
## Set the clock for the ILA core
#################################
SetDebugCoreClk ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaRead/axiClk}

#######################
## Set the debug Probes
#######################

# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaRead/axiReadMaster[arvalid]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaRead/axiReadMaster[rready]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaRead/axiReadSlave[arready]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaRead/axiReadSlave[rlast]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaRead/axiReadSlave[rvalid]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaRead/axiRst}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaRead/axisCtrl[pause]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaRead/axisMaster[tLast]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaRead/axisMaster[tValid]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaRead/dmaRdDescAck}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaRead/dmaRdDescReq[continue]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaRead/dmaRdDescReq[valid]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaRead/dmaRdDescRet[valid]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaRead/dmaRdDescRetAck}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaRead/sSlave[tReady]}

# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/axisMaster[tLast]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/axisMaster[tValid]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/axisSlave[tReady]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/axiWriteCtrl[pause]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/axiWriteMaster[awvalid]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/axiWriteMaster[wlast]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/axiWriteMaster[wvalid]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/dmaWrDescAck[contEn]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/dmaWrDescAck[dropEn]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/dmaWrDescAck[valid]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/dmaWrDescReq[valid]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/dmaWrDescRet[continue]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/dmaWrDescRet[valid]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/dmaWrDescRetAck}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/intAxisMaster[tLast]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/intAxisMaster[tValid]}
# ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_ChanGen[0].U_DmaWrite/intAxisSlave[tReady]}

ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/axilReadMaster[araddr][*]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/axilWriteMaster[awaddr][*]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/axilWriteMaster[wdata][*]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/axiReadSlave_rresp_out[*]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/axiWriteSlave_bresp_out[*]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/dmaRdDescAck[*]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/dmaRdDescRet[0][result][*]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[axilReadSlave][rdata][*]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[axilReadSlave][rresp][*]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[axilWriteSlave][bresp][*]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[buffRdCache][*]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[buffWrCache][*]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[descRetAcks][*]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[descRetList][*]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[descState][*]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[descWrCache][*]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/axilReadMaster[arvalid]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/axilReadMaster[rready]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/axilWriteMaster[awvalid]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/axilWriteMaster[bready]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/axilWriteMaster[wvalid]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/axiRst}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/dmaRdDescRet[0][valid]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/dmaWrDescReq[0][valid]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/dmaWrDescRet[0][continue]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/dmaWrDescRet[0][valid]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/intCompValid}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/intDiffValid}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/intSwAckEn}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/invalidCount}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[acknowledge]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[addrFifoSel]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[axilReadSlave][arready]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[axilReadSlave][rvalid]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[axilWriteSlave][awready]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[axilWriteSlave][bvalid]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[axilWriteSlave][wready]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[contEn]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[descRetCnt]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[descRetNum]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[dmaRdDescReq][0][continue]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[dmaRdDescReq][0][valid]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[dmaRdDescRetAck]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[dmaWrDescAck][0][contEn]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[dmaWrDescAck][0][dropEn]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[dmaWrDescAck][0][valid]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[dmaWrDescRetAck]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[dropEn]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[enable]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[fifoReset]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[forceInt]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[intEnable]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[interrupt]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[intReqEn]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[intSwAckReq]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[online]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[rdAddrValid]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[rdFifoRd]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[wrAddrValid]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[wrFifoRd]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[wrReqAcks]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[wrReqCnt]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[wrReqNum]}
ConfigProbe ${ilaName} {U_Core/U_RceG3Top/U_RceG3Dma/GEN_SYNTH.U_AxisV2DmaGen.U_RceG3DmaAxisV2/U_Gen2Dma[0].U_RceG3DmaAxisChan/U_AxiStreamDmaV2/U_DmaDesc/r[wrReqValid]}


##########################
## Write the port map file
##########################
WriteDebugProbes ${ilaName}
