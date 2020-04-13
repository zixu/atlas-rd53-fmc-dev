-------------------------------------------------------------------------------
-- File       : Zcu102PgpLaneTx.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS RD53 FMC DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'ATLAS RD53 FMC DEV', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiStreamPkg.all;

entity Zcu102PgpLaneTx is
   generic (
      TPD_G            : time     := 1 ns;
      NUM_VC_G         : positive := 4;
      APP_AXI_CONFIG_G : AxiStreamConfigType;
      PHY_AXI_CONFIG_G : AxiStreamConfigType);
   port (
      -- AXIS Interface (axisClk domain)
      axisClk      : in  sl;
      axisRst      : in  sl;
      sAxisMaster  : in  AxiStreamMasterType;
      sAxisSlave   : out AxiStreamSlaveType;
      -- PGP Interface (pgpClk domain)
      pgpClk       : in  sl;
      pgpRst       : in  sl;
      rxlinkReady  : in  sl;
      txlinkReady  : in  sl;
      pgpTxMasters : out AxiStreamMasterArray(NUM_VC_G-1 downto 0);
      pgpTxSlaves  : in  AxiStreamSlaveArray(NUM_VC_G-1 downto 0));
end Zcu102PgpLaneTx;

architecture mapping of Zcu102PgpLaneTx is

   signal master : AxiStreamMasterType;
   signal ctrl   : AxiStreamCtrlType;

   signal txMaster : AxiStreamMasterType;
   signal txSlave  : AxiStreamSlaveType;

   signal txMasterSof : AxiStreamMasterType;
   signal txSlaveSof  : AxiStreamSlaveType;

   signal linkReady : sl;
   signal flushEn   : sl;

begin

   linkReady <= txlinkReady and rxlinkReady;

   U_FlushSync : entity surf.Synchronizer
      generic map (
         TPD_G          => TPD_G,
         OUT_POLARITY_G => '0')
      port map (
         clk     => axisClk,
         rst     => axisRst,
         dataIn  => linkReady,
         dataOut => flushEn);

   U_Flush : entity surf.AxiStreamFlush
      generic map (
         TPD_G         => TPD_G,
         AXIS_CONFIG_G => APP_AXI_CONFIG_G,
         SSI_EN_G      => true)
      port map (
         axisClk     => axisClk,
         axisRst     => axisRst,
         flushEn     => flushEn,
         sAxisMaster => sAxisMaster,
         sAxisSlave  => sAxisSlave,
         mAxisMaster => master,
         mAxisCtrl   => ctrl);

   U_RESIZE : entity surf.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 1,
         PIPE_STAGES_G       => 1,
         SLAVE_READY_EN_G    => false,
         VALID_THOLD_G       => 1,
         -- FIFO configurations
         GEN_SYNC_FIFO_G     => false,
         FIFO_ADDR_WIDTH_G   => 5,
         FIFO_PAUSE_THRESH_G => 20,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => APP_AXI_CONFIG_G,
         MASTER_AXI_CONFIG_G => PHY_AXI_CONFIG_G)
      port map (
         -- Slave Port
         sAxisClk    => axisClk,
         sAxisRst    => axisRst,
         sAxisMaster => master,
         sAxisCtrl   => ctrl,
         -- Master Port
         mAxisClk    => pgpClk,
         mAxisRst    => pgpRst,
         mAxisMaster => txMaster,
         mAxisSlave  => txSlave);

   U_SOF : entity surf.SsiInsertSof
      generic map (
         TPD_G               => TPD_G,
         COMMON_CLK_G        => true,
         SLAVE_FIFO_G        => false,
         MASTER_FIFO_G       => false,
         SLAVE_AXI_CONFIG_G  => PHY_AXI_CONFIG_G,
         MASTER_AXI_CONFIG_G => PHY_AXI_CONFIG_G)
      port map (
         -- Slave Port
         sAxisClk    => pgpClk,
         sAxisRst    => pgpRst,
         sAxisMaster => txMaster,
         sAxisSlave  => txSlave,
         -- Master Port
         mAxisClk    => pgpClk,
         mAxisRst    => pgpRst,
         mAxisMaster => txMasterSof,
         mAxisSlave  => txSlaveSof);

   U_DeMux : entity surf.AxiStreamDeMux
      generic map (
         TPD_G         => TPD_G,
         NUM_MASTERS_G => NUM_VC_G,
         MODE_G        => "INDEXED",
         PIPE_STAGES_G => 1,
         TDEST_HIGH_G  => 3,
         TDEST_LOW_G   => 0)
      port map (
         -- Clock and reset
         axisClk      => pgpClk,
         axisRst      => pgpRst,
         -- Slave
         sAxisMaster  => txMasterSof,
         sAxisSlave   => txSlaveSof,
         -- Masters
         mAxisMasters => pgpTxMasters,
         mAxisSlaves  => pgpTxSlaves);

end mapping;
