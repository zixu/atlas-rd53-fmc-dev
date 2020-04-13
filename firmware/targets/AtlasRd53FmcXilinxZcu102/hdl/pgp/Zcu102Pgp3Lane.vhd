-------------------------------------------------------------------------------
-- File       : Zcu102Pgp3Lane.vhd
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
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.Pgp3Pkg.all;

entity Zcu102Pgp3Lane is
   generic (
      TPD_G                : time                        := 1 ns;
      ROGUE_SIM_EN_G       : boolean                     := false;
      ROGUE_SIM_PORT_NUM_G : natural range 1024 to 49151 := 7000;
      DMA_AXIS_CONFIG_G    : AxiStreamConfigType := PGP3_AXIS_CONFIG_C;
      RATE_G               : string                      := "10.3125Gbps";  -- or "6.25Gbps" or "3.125Gbps"
      AXIL_CLK_FREQ_G      : real                        := 156.25E+6;  -- units of Hz
      AXI_BASE_ADDR_G      : slv(31 downto 0)            := (others => '0'));
   port (
      -- Trigger Interface
      trigger         : in  sl := '0';
      -- QPLL Interface
      qpllLock        : in  slv(1 downto 0);
      qpllClk         : in  slv(1 downto 0);
      qpllRefclk      : in  slv(1 downto 0);
      qpllRst         : out slv(1 downto 0);
      -- PGP Serial Ports
      pgpTxP          : out sl;
      pgpTxN          : out sl;
      pgpRxP          : in  sl;
      pgpRxN          : in  sl;
      -- Streaming Interface (axilClk domain)
      pgpIbMaster     : in  AxiStreamMasterType;
      pgpIbSlave      : out AxiStreamSlaveType;
      pgpObMaster     : out AxiStreamMasterType;
      pgpObSlave      : in  AxiStreamSlaveType;
      -- AXI-Lite Interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType);
end Zcu102Pgp3Lane;

architecture mapping of Zcu102Pgp3Lane is

   constant NUM_VC_C : positive := 16;

   signal pgpClk : sl;
   signal pgpRst : sl;
   signal wdtRst : sl;

   signal pgpTxIn      : Pgp3TxInType := PGP3_TX_IN_INIT_C;
   signal pgpTxOut     : Pgp3TxOutType;
   signal pgpTxMasters : AxiStreamMasterArray(NUM_VC_C-1 downto 0);
   signal pgpTxSlaves  : AxiStreamSlaveArray(NUM_VC_C-1 downto 0);

   signal pgpRxIn      : Pgp3RxInType := PGP3_RX_IN_INIT_C;
   signal pgpRxOut     : Pgp3RxOutType;
   signal pgpRxMasters : AxiStreamMasterArray(NUM_VC_C-1 downto 0);
   signal pgpRxCtrl    : AxiStreamCtrlArray(NUM_VC_C-1 downto 0);
   signal pgpRxSlaves  : AxiStreamSlaveArray(NUM_VC_C-1 downto 0);

begin

   U_Trig : entity surf.SynchronizerOneShot
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => pgpClk,
         dataIn  => trigger,
         dataOut => pgpTxIn.opCodeEn);

   U_Wtd : entity surf.WatchDogRst
      generic map(
         TPD_G      => TPD_G,
         DURATION_G => getTimeRatio(AXIL_CLK_FREQ_G, 0.2))  -- 5 s timeout
      port map (
         clk    => axilClk,
         monIn  => pgpRxOut.remRxLinkReady,
         rstOut => wdtRst);

   U_PwrUpRst : entity surf.PwrUpRst
      generic map (
         TPD_G         => TPD_G,
         SIM_SPEEDUP_G => ROGUE_SIM_EN_G,
         DURATION_G    => getTimeRatio(AXIL_CLK_FREQ_G, 10.0))  -- 100 ms reset pulse
      port map (
         clk    => axilClk,
         arst   => wdtRst,
         rstOut => pgpRxIn.resetRx);

   -----------
   -- PGP Core
   -----------
   REAL_PGP : if (not ROGUE_SIM_EN_G) generate
      U_Pgp : entity surf.Pgp3GthUs
         generic map (
            TPD_G            => TPD_G,
            EN_PGP_MON_G     => true,
            NUM_VC_G         => NUM_VC_C,
            RATE_G           => RATE_G,
            AXIL_CLK_FREQ_G  => AXIL_CLK_FREQ_G,
            AXIL_BASE_ADDR_G => AXI_BASE_ADDR_G)
         port map (
            -- Stable Clock and Reset
            stableClk       => axilClk,
            stableRst       => axilRst,
            -- QPLL Interface
            qpllLock        => qpllLock,
            qpllClk         => qpllClk,
            qpllRefclk      => qpllRefclk,
            qpllRst         => qpllRst,
            -- Gt Serial IO
            pgpGtTxP        => pgpTxP,
            pgpGtTxN        => pgpTxN,
            pgpGtRxP        => pgpRxP,
            pgpGtRxN        => pgpRxN,
            -- Clocking
            pgpClk          => pgpClk,
            pgpClkRst       => pgpRst,
            -- Non VC Rx Signals
            pgpRxIn         => pgpRxIn,
            pgpRxOut        => pgpRxOut,
            -- Non VC Tx Signals
            pgpTxIn         => pgpTxIn,
            pgpTxOut        => pgpTxOut,
            -- Frame Transmit Interface
            pgpTxMasters    => pgpTxMasters,
            pgpTxSlaves     => pgpTxSlaves,
            -- Frame Receive Interface
            pgpRxMasters    => pgpRxMasters,
            pgpRxCtrl       => pgpRxCtrl,
            -- AXI-Lite Register Interface (axilClk domain)
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => axilReadMaster,
            axilReadSlave   => axilReadSlave,
            axilWriteMaster => axilWriteMaster,
            axilWriteSlave  => axilWriteSlave);
   end generate REAL_PGP;

   SIM_PGP : if (ROGUE_SIM_EN_G) generate

      U_Rogue : entity surf.RoguePgp3Sim
         generic map(
            TPD_G      => TPD_G,
            PORT_NUM_G => ROGUE_SIM_PORT_NUM_G,
            NUM_VC_G   => NUM_VC_C)
         port map(
            -- GT Ports
            pgpRefClk       => axilClk,
            pgpGtTxP        => pgpTxP,
            pgpGtTxN        => pgpTxN,
            pgpGtRxP        => pgpRxP,
            pgpGtRxN        => pgpRxN,
            -- PGP Clock and Reset
            pgpClk          => pgpClk,
            pgpClkRst       => pgpRst,
            -- Non VC Rx Signals
            pgpRxIn         => pgpRxIn,
            pgpRxOut        => pgpRxOut,
            -- Non VC Tx Signals
            pgpTxIn         => pgpTxIn,
            pgpTxOut        => pgpTxOut,
            -- Frame Transmit Interface
            pgpTxMasters    => pgpTxMasters,
            pgpTxSlaves     => pgpTxSlaves,
            -- Frame Receive Interface
            pgpRxMasters    => pgpRxMasters,
            pgpRxSlaves     => pgpRxSlaves,
            -- AXI-Lite Register Interface (axilClk domain)
            axilClk         => axilClk,
            axilRst         => axilRst,
            axilReadMaster  => axilReadMaster,
            axilReadSlave   => axilReadSlave,
            axilWriteMaster => axilWriteMaster,
            axilWriteSlave  => axilWriteSlave);

   end generate SIM_PGP;

   --------------
   -- PGP TX Path
   --------------
   U_Tx : entity work.Zcu102PgpLaneTx
      generic map (
         TPD_G            => TPD_G,
         NUM_VC_G         => NUM_VC_C,
         APP_AXI_CONFIG_G => DMA_AXIS_CONFIG_G,
         PHY_AXI_CONFIG_G => PGP3_AXIS_CONFIG_C)
      port map (
         -- AXIS Interface (axisClk domain)
         axisClk      => axilClk,
         axisRst      => axilRst,
         sAxisMaster  => pgpIbMaster,
         sAxisSlave   => pgpIbSlave,
         -- PGP Interface
         pgpClk       => pgpClk,
         pgpRst       => pgpRst,
         rxlinkReady  => pgpRxOut.linkReady,
         txlinkReady  => pgpTxOut.linkReady,
         pgpTxMasters => pgpTxMasters,
         pgpTxSlaves  => pgpTxSlaves);

   --------------
   -- PGP RX Path
   --------------
   U_Rx : entity work.Zcu102PgpLaneRx
      generic map (
         TPD_G            => TPD_G,
         ROGUE_SIM_EN_G   => ROGUE_SIM_EN_G,
         NUM_VC_G         => NUM_VC_C,
         APP_AXI_CONFIG_G => DMA_AXIS_CONFIG_G,
         PHY_AXI_CONFIG_G => PGP3_AXIS_CONFIG_C)
      port map (
         -- AXIS Interface (axisClk domain)
         axisClk      => axilClk,
         axisRst      => axilRst,
         mAxisMaster  => pgpObMaster,
         mAxisSlave   => pgpObSlave,
         -- PGP RX Interface (pgpRxClk domain)
         pgpClk       => pgpClk,
         pgpRst       => pgpRst,
         rxlinkReady  => pgpRxOut.linkReady,
         pgpRxMasters => pgpRxMasters,
         pgpRxCtrl    => pgpRxCtrl,
         pgpRxSlaves  => pgpRxSlaves);

end mapping;
