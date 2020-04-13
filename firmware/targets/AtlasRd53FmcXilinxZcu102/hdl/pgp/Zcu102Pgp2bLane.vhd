-------------------------------------------------------------------------------
-- File       : Zcu102Pgp2bLane.vhd
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
use surf.Pgp2bPkg.all;

library unisim;
use unisim.vcomponents.all;

entity Zcu102Pgp2bLane is
   generic (
      TPD_G                : time                        := 1 ns;
      ROGUE_SIM_EN_G       : boolean                     := false;
      ROGUE_SIM_PORT_NUM_G : natural range 1024 to 49151 := 7000;
      DMA_AXIS_CONFIG_G    : AxiStreamConfigType;
      AXIL_CLK_FREQ_G      : real                        := 156.25E+6;  -- units of Hz
      AXI_BASE_ADDR_G      : slv(31 downto 0)            := (others => '0'));
   port (
      -- Trigger Interface
      trigger         : in  sl := '0';
      -- PGP Serial Ports
      pgpTxP          : out sl;
      pgpTxN          : out sl;
      pgpRxP          : in  sl;
      pgpRxN          : in  sl;
      pgpRefClk       : in  sl;
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
end Zcu102Pgp2bLane;

architecture mapping of Zcu102Pgp2bLane is

   constant NUM_VC_C : positive := 4;

   constant NUM_AXIL_MASTERS_C : positive := 3;

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := genAxiLiteConfig(NUM_AXIL_MASTERS_C, AXI_BASE_ADDR_G, 16, 13);

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);

   signal pgpTxOutClk : sl;
   signal pgpTxClk    : sl;
   signal pgpTxRst    : sl;

   signal pgpRxOutClk : sl;
   signal pgpRxClk    : sl;
   signal pgpRxRst    : sl;
   signal wdtRst      : sl;

   signal locTxIn      : Pgp2bTxInType := PGP2B_TX_IN_INIT_C;
   signal pgpTxIn      : Pgp2bTxInType;
   signal pgpTxOut     : Pgp2bTxOutType;
   signal pgpTxMasters : AxiStreamMasterArray(NUM_VC_C-1 downto 0);
   signal pgpTxSlaves  : AxiStreamSlaveArray(NUM_VC_C-1 downto 0);

   signal locRxIn      : Pgp2bRxInType := PGP2B_RX_IN_INIT_C;
   signal pgpRxIn      : Pgp2bRxInType;
   signal pgpRxOut     : Pgp2bRxOutType;
   signal pgpRxMasters : AxiStreamMasterArray(NUM_VC_C-1 downto 0);
   signal pgpRxCtrl    : AxiStreamCtrlArray(NUM_VC_C-1 downto 0);
   signal pgpRxSlaves  : AxiStreamSlaveArray(NUM_VC_C-1 downto 0);

begin

   U_Trig : entity surf.SynchronizerOneShot
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => pgpTxClk,
         dataIn  => trigger,
         dataOut => locTxIn.opCodeEn);

   U_Wtd : entity surf.WatchDogRst
      generic map(
         TPD_G      => TPD_G,
         DURATION_G => getTimeRatio(AXIL_CLK_FREQ_G, 0.2))  -- 5 s timeout
      port map (
         clk    => axilClk,
         monIn  => pgpRxOut.remLinkReady,
         rstOut => wdtRst);

   U_PwrUpRst : entity surf.PwrUpRst
      generic map (
         TPD_G         => TPD_G,
         SIM_SPEEDUP_G => ROGUE_SIM_EN_G,
         DURATION_G    => getTimeRatio(AXIL_CLK_FREQ_G, 10.0))  -- 100 ms reset pulse
      port map (
         clk    => axilClk,
         arst   => wdtRst,
         rstOut => locRxIn.resetRx);

   ---------------------
   -- AXI-Lite Crossbar
   ---------------------
   U_XBAR : entity surf.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => AXIL_CONFIG_C)
      port map (
         axiClk              => axilClk,
         axiClkRst           => axilRst,
         sAxiWriteMasters(0) => axilWriteMaster,
         sAxiWriteSlaves(0)  => axilWriteSlave,
         sAxiReadMasters(0)  => axilReadMaster,
         sAxiReadSlaves(0)   => axilReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   -----------
   -- PGP Core
   -----------
   REAL_PGP : if (not ROGUE_SIM_EN_G) generate
      U_Pgp : entity surf.Pgp2bGthUltra
         generic map (
            TPD_G           => TPD_G,
            VC_INTERLEAVE_G => 1)       -- AxiStreamDmaV2 supports interleaving
         port map (
            -- GT Clocking
            stableClk       => axilClk,
            stableRst       => axilRst,
            gtRefClk        => pgpRefClk,
            -- Gt Serial IO
            pgpGtTxP        => pgpTxP,
            pgpGtTxN        => pgpTxN,
            pgpGtRxP        => pgpRxP,
            pgpGtRxN        => pgpRxN,
            -- Tx Clocking
            pgpTxReset      => pgpTxRst,
            pgpTxOutClk     => pgpTxOutClk,
            pgpTxClk        => pgpTxClk,
            pgpTxMmcmLocked => '1',
            -- Rx clocking
            pgpRxReset      => pgpRxRst,
            pgpRxOutClk     => pgpRxOutClk,
            pgpRxClk        => pgpRxClk,
            pgpRxMmcmLocked => '1',
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
            -- AXI-Lite Interface
            axilClk         => axilClk,
            axilRst         => axilRst);

      U_BUFG_TX : BUFG_GT
         port map (
            I       => pgpTxOutClk,
            CE      => '1',
            CEMASK  => '1',
            CLR     => '0',
            CLRMASK => '1',
            DIV     => "000",           -- Divide by 1
            O       => pgpTxClk);

      U_BUFG_RX : BUFG_GT
         port map (
            I       => pgpRxOutClk,
            CE      => '1',
            CEMASK  => '1',
            CLR     => '0',
            CLRMASK => '1',
            DIV     => "000",           -- Divide by 1
            O       => pgpRxClk);

   end generate REAL_PGP;

   SIM_PGP : if (ROGUE_SIM_EN_G) generate

      pgpTxP <= '0';
      pgpTxN <= '1';

      pgpRxClk <= axilClk;
      pgpRxRst <= axilRst;
      pgpTxClk <= axilClk;
      pgpTxRst <= axilRst;

      U_Rogue : entity surf.RoguePgp2bSim
         generic map(
            TPD_G      => TPD_G,
            PORT_NUM_G => ROGUE_SIM_PORT_NUM_G,
            NUM_VC_G   => NUM_VC_C)
         port map(
            -- PGP Clock and Reset
            pgpClk       => axilClk,
            pgpClkRst    => axilRst,
            -- Non VC Rx Signals
            pgpRxIn      => pgpRxIn,
            pgpRxOut     => pgpRxOut,
            -- Non VC Tx Signals
            pgpTxIn      => pgpTxIn,
            pgpTxOut     => pgpTxOut,
            -- Frame Transmit Interface
            pgpTxMasters => pgpTxMasters,
            pgpTxSlaves  => pgpTxSlaves,
            -- Frame Receive Interface
            pgpRxMasters => pgpRxMasters,
            pgpRxSlaves  => pgpRxSlaves);

   end generate SIM_PGP;

   --------------
   -- PGP Monitor
   --------------
   U_PgpMon : entity surf.Pgp2bAxi
      generic map (
         TPD_G              => TPD_G,
         COMMON_TX_CLK_G    => false,
         COMMON_RX_CLK_G    => false,
         WRITE_EN_G         => true,
         AXI_CLK_FREQ_G     => AXIL_CLK_FREQ_G,
         STATUS_CNT_WIDTH_G => 16,
         ERROR_CNT_WIDTH_G  => 16)
      port map (
         -- TX PGP Interface (pgpTxClk)
         pgpTxClk        => pgpTxClk,
         pgpTxClkRst     => pgpTxRst,
         pgpTxIn         => pgpTxIn,
         pgpTxOut        => pgpTxOut,
         locTxIn         => locTxIn,
         -- RX PGP Interface (pgpRxClk)
         pgpRxClk        => pgpRxClk,
         pgpRxClkRst     => pgpRxRst,
         pgpRxIn         => pgpRxIn,
         pgpRxOut        => pgpRxOut,
         locRxIn         => locRxIn,
         -- AXI-Lite Register Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMasters(0),
         axilReadSlave   => axilReadSlaves(0),
         axilWriteMaster => axilWriteMasters(0),
         axilWriteSlave  => axilWriteSlaves(0));

   -----------------------------
   -- Monitor the PGP TX streams
   -----------------------------
   U_AXIS_TX_MON : entity surf.AxiStreamMonAxiL
      generic map(
         TPD_G            => TPD_G,
         COMMON_CLK_G     => false,
         AXIS_CLK_FREQ_G  => 156.25E+6,
         AXIS_NUM_SLOTS_G => NUM_VC_C,
         AXIS_CONFIG_G    => SSI_PGP2B_CONFIG_C)
      port map(
         -- AXIS Stream Interface
         axisClk          => pgpTxClk,
         axisRst          => pgpTxRst,
         axisMasters      => pgpTxMasters,
         axisSlaves       => pgpTxSlaves,
         -- AXI lite slave port for register access
         axilClk          => axilClk,
         axilRst          => axilRst,
         sAxilWriteMaster => axilWriteMasters(1),
         sAxilWriteSlave  => axilWriteSlaves(1),
         sAxilReadMaster  => axilReadMasters(1),
         sAxilReadSlave   => axilReadSlaves(1));

   -----------------------------
   -- Monitor the PGP RX streams
   -----------------------------
   U_AXIS_RX_MON : entity surf.AxiStreamMonAxiL
      generic map(
         TPD_G            => TPD_G,
         COMMON_CLK_G     => false,
         AXIS_CLK_FREQ_G  => 156.25E+6,
         AXIS_NUM_SLOTS_G => NUM_VC_C,
         AXIS_CONFIG_G    => SSI_PGP2B_CONFIG_C)
      port map(
         -- AXIS Stream Interface
         axisClk          => pgpRxClk,
         axisRst          => pgpRxRst,
         axisMasters      => pgpRxMasters,
         axisSlaves       => (others => AXI_STREAM_SLAVE_FORCE_C),  -- SLAVE_READY_EN_G=false
         -- AXI lite slave port for register access
         axilClk          => axilClk,
         axilRst          => axilRst,
         sAxilWriteMaster => axilWriteMasters(2),
         sAxilWriteSlave  => axilWriteSlaves(2),
         sAxilReadMaster  => axilReadMasters(2),
         sAxilReadSlave   => axilReadSlaves(2));

   --------------
   -- PGP TX Path
   --------------
   U_Tx : entity work.Zcu102PgpLaneTx
      generic map (
         TPD_G            => TPD_G,
         NUM_VC_G         => NUM_VC_C,
         APP_AXI_CONFIG_G => DMA_AXIS_CONFIG_G,
         PHY_AXI_CONFIG_G => SSI_PGP2B_CONFIG_C)
      port map (
         -- AXIS Interface (axisClk domain)
         axisClk      => axilClk,
         axisRst      => axilRst,
         sAxisMaster  => pgpIbMaster,
         sAxisSlave   => pgpIbSlave,
         -- PGP Interface
         pgpClk       => pgpTxClk,
         pgpRst       => pgpTxRst,
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
         PHY_AXI_CONFIG_G => SSI_PGP2B_CONFIG_C)
      port map (
         -- AXIS Interface (axisClk domain)
         axisClk      => axilClk,
         axisRst      => axilRst,
         mAxisMaster  => pgpObMaster,
         mAxisSlave   => pgpObSlave,
         -- PGP RX Interface (pgpRxClk domain)
         pgpClk       => pgpRxClk,
         pgpRst       => pgpRxRst,
         rxlinkReady  => pgpRxOut.linkReady,
         pgpRxMasters => pgpRxMasters,
         pgpRxCtrl    => pgpRxCtrl,
         pgpRxSlaves  => pgpRxSlaves);

end mapping;
