-------------------------------------------------------------------------------
-- File       : Zcu102PgpWrapper.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Zcu102PgpWrapper File
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

library unisim;
use unisim.vcomponents.all;

entity Zcu102PgpWrapper is
   generic (
      TPD_G                : time                        := 1 ns;
      ROGUE_SIM_EN_G       : boolean                     := false;
      ROGUE_SIM_PORT_NUM_G : natural range 1024 to 49151 := 4000;
      DMA_AXIS_CONFIG_G    : AxiStreamConfigType;
      PGP_TYPE_G           : boolean                     := true;  -- False: PGPv2b, True: PGPv3, 
      PGP3_RATE_G          : string                      := "6.25Gbps";  -- or "10.3125Gbps" 
      AXIL_CLK_FREQ_G      : real                        := 156.25E+6;  -- units of Hz
      AXI_BASE_ADDR_G      : slv(31 downto 0)            := x"0000_0000");
   port (
      ------------------------      
      --  Top Level Interfaces
      ------------------------    
      -- Reference Clock
      sfpClk156       : out sl;
      -- AXI-Lite Interface
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- PGP Streams (axilClk domain)
      dmaObMaster     : in  AxiStreamMasterType;
      dmaObSlave      : out AxiStreamSlaveType;
      dmaIbMaster     : out AxiStreamMasterType;
      dmaIbSlave      : in  AxiStreamSlaveType;
      -- SFP Interface
      sfpClk156P      : in  sl;
      sfpClk156N      : in  sl;
      sfpTxP          : out slv(3 downto 0);
      sfpTxN          : out slv(3 downto 0);
      sfpRxP          : in  slv(3 downto 0);
      sfpRxN          : in  slv(3 downto 0));
end Zcu102PgpWrapper;

architecture mapping of Zcu102PgpWrapper is

   constant PGP_TDEST_ROUTE_TABLE_G : Slv8Array := (
      0 => "0000----",  -- PGP[Lane=0] = TDEST 0x00-0x0F
      1 => "0001----",  -- PGP[Lane=1] = TDEST 0x10-0x1F
      2 => "0010----",  -- PGP[Lane=2] = TDEST 0x20-0x2F
      3 => "0011----");  -- PGP[Lane=3] = TDEST 0x30-0x3F

   constant NUM_AXIL_MASTERS_C : positive := 4;

   constant PGP_INDEX_C : natural := 0;

   constant AXIL_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := (
      PGP_INDEX_C+0   => (
         baseAddr     => (AXI_BASE_ADDR_G+x"0000_0000"),
         addrBits     => 16,
         connectivity => x"FFFF"),
      PGP_INDEX_C+1   => (
         baseAddr     => (AXI_BASE_ADDR_G+x"0001_0000"),
         addrBits     => 16,
         connectivity => x"FFFF"),
      PGP_INDEX_C+2   => (
         baseAddr     => (AXI_BASE_ADDR_G+x"0002_0000"),
         addrBits     => 16,
         connectivity => x"FFFF"),
      PGP_INDEX_C+3   => (
         baseAddr     => (AXI_BASE_ADDR_G+x"0003_0000"),
         addrBits     => 16,
         connectivity => x"FFFF"));

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);

   signal pgpIbMasters : AxiStreamMasterArray(3 downto 0);
   signal pgpIbSlaves  : AxiStreamSlaveArray(3 downto 0);
   signal pgpObMasters : AxiStreamMasterArray(3 downto 0);
   signal pgpObSlaves  : AxiStreamSlaveArray(3 downto 0);

   signal qpllLock   : Slv2Array(3 downto 0);
   signal qpllClk    : Slv2Array(3 downto 0);
   signal qpllRefclk : Slv2Array(3 downto 0);
   signal qpllRst    : Slv2Array(3 downto 0);

   signal refClk : sl;
   signal refClkDiv : sl;

begin

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

   ------------------------
   -- GT Clocking
   ------------------------
   U_sfpClk156 : IBUFDS_GTE4
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => sfpClk156P,
         IB    => sfpClk156N,
         CEB   => '0',
         ODIV2 => refClkDiv,
         O     => refClk);

   U_BUFG_GT : BUFG_GT
      port map (
         I       => refClkDiv,
         CE      => '1',
         CEMASK  => '1',
         CLR     => '0',
         CLRMASK => '1',
         DIV     => "000",
         O       => sfpClk156);

   GEN_PGP3_QPLL : if (PGP_TYPE_G = true) generate
      U_QPLL : entity surf.Pgp3GthUsQpll
         generic map (
            TPD_G    => TPD_G,
            RATE_G   => PGP3_RATE_G,
            EN_DRP_G => false)
         port map (
            -- Stable Clock and Reset
            stableClk  => axilClk,
            stableRst  => axilRst,
            -- QPLL Clocking
            pgpRefClk  => refClk,
            qpllLock   => qpllLock,
            qpllClk    => qpllClk,
            qpllRefclk => qpllRefclk,
            qpllRst    => qpllRst);
   end generate;

   --------------
   -- PGP Modules
   --------------
   GEN_LANE :
   for i in 3 downto 0 generate

      GEN_PGP3 : if (PGP_TYPE_G = true) generate
         U_Lane : entity work.Zcu102Pgp3Lane
            generic map (
               TPD_G                => TPD_G,
               ROGUE_SIM_EN_G       => ROGUE_SIM_EN_G,
               ROGUE_SIM_PORT_NUM_G => (ROGUE_SIM_PORT_NUM_G + i*34),
               DMA_AXIS_CONFIG_G    => DMA_AXIS_CONFIG_G,
               RATE_G               => PGP3_RATE_G,
               AXIL_CLK_FREQ_G      => AXIL_CLK_FREQ_G,
               AXI_BASE_ADDR_G      => AXIL_CONFIG_C(i).baseAddr)
            port map (
               -- QPLL Interface
               qpllLock        => qpllLock(i),
               qpllClk         => qpllClk(i),
               qpllRefclk      => qpllRefclk(i),
               qpllRst         => qpllRst(i),
               -- PGP Serial Ports
               pgpRxP          => sfpRxP(i),
               pgpRxN          => sfpRxN(i),
               pgpTxP          => sfpTxP(i),
               pgpTxN          => sfpTxN(i),
               -- Streaming Interface (axilClk domain)
               pgpIbMaster     => pgpIbMasters(i),
               pgpIbSlave      => pgpIbSlaves(i),
               pgpObMaster     => pgpObMasters(i),
               pgpObSlave      => pgpObSlaves(i),
               -- AXI-Lite Interface (axilClk domain)
               axilClk         => axilClk,
               axilRst         => axilRst,
               axilReadMaster  => axilReadMasters(i),
               axilReadSlave   => axilReadSlaves(i),
               axilWriteMaster => axilWriteMasters(i),
               axilWriteSlave  => axilWriteSlaves(i));
      end generate;

      GEN_PGP2b : if (PGP_TYPE_G = false) generate
         U_Lane : entity work.Zcu102Pgp2bLane
            generic map (
               TPD_G                => TPD_G,
               ROGUE_SIM_EN_G       => ROGUE_SIM_EN_G,
               ROGUE_SIM_PORT_NUM_G => (ROGUE_SIM_PORT_NUM_G + i*34),
               DMA_AXIS_CONFIG_G    => DMA_AXIS_CONFIG_G,
               AXIL_CLK_FREQ_G      => AXIL_CLK_FREQ_G,
               AXI_BASE_ADDR_G      => AXIL_CONFIG_C(i).baseAddr)
            port map (
               -- PGP Serial Ports
               pgpRxP          => sfpRxP(i),
               pgpRxN          => sfpRxN(i),
               pgpTxP          => sfpTxP(i),
               pgpTxN          => sfpTxN(i),
               pgpRefClk       => refClk,
               -- Streaming Interface (axilClk domain)
               pgpIbMaster     => pgpIbMasters(i),
               pgpIbSlave      => pgpIbSlaves(i),
               pgpObMaster     => pgpObMasters(i),
               pgpObSlave      => pgpObSlaves(i),
               -- AXI-Lite Interface (axilClk domain)
               axilClk         => axilClk,
               axilRst         => axilRst,
               axilReadMaster  => axilReadMasters(i),
               axilReadSlave   => axilReadSlaves(i),
               axilWriteMaster => axilWriteMasters(i),
               axilWriteSlave  => axilWriteSlaves(i));
      end generate;

   end generate GEN_LANE;

   -------------------
   -- AXI Stream DEMUX
   -------------------
   U_Demux : entity surf.AxiStreamDeMux
      generic map (
         TPD_G          => TPD_G,
         NUM_MASTERS_G  => 4,
         MODE_G         => "ROUTED",
         TDEST_ROUTES_G => PGP_TDEST_ROUTE_TABLE_G,
         PIPE_STAGES_G  => 1)
      port map (
         -- Clock and reset
         axisClk      => axilClk,
         axisRst      => axilRst,
         -- Slaves
         sAxisMaster  => dmaObMaster,
         sAxisSlave   => dmaObSlave,
         -- Master
         mAxisMasters => pgpIbMasters,
         mAxisSlaves  => pgpIbSlaves);

   -----------------
   -- AXI Stream MUX
   -----------------
   U_Mux : entity surf.AxiStreamMux
      generic map (
         TPD_G                => TPD_G,
         NUM_SLAVES_G         => 4,
         MODE_G               => "ROUTED",
         TDEST_ROUTES_G       => PGP_TDEST_ROUTE_TABLE_G,
         ILEAVE_EN_G          => true,
         ILEAVE_ON_NOTVALID_G => false,
         ILEAVE_REARB_G       => 128,
         PIPE_STAGES_G        => 1)
      port map (
         -- Clock and reset
         axisClk      => axilClk,
         axisRst      => axilRst,
         -- Inbound Master Ports
         sAxisMasters => pgpObMasters,
         -- Inbound Slave Ports
         sAxisSlaves  => pgpObSlaves,
         -- Outbound Port
         mAxisMaster  => dmaIbMaster,
         mAxisSlave   => dmaIbSlave);

end mapping;
