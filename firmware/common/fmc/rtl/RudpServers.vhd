-------------------------------------------------------------------------------
-- File       : RudpServers.vhd
-- Company    : SLAC National Accelerator Laboratory
-- Created    : 2015-01-30
-- Last update: 2019-04-18
-------------------------------------------------------------------------------
-- Description: RUDP Server Modules
-------------------------------------------------------------------------------
-- This file is part of 'Example Project Firmware'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'Example Project Firmware', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;
use surf.AxiLitePkg.all;
use surf.EthMacPkg.all;

entity RudpServers is
   generic (
      TPD_G             : time             := 1 ns;
      DMA_AXIS_CONFIG_G : AxiStreamConfigType;
      CLK_FREQUENCY_G   : real             := 156.25E+6;
      IP_ADDR_G         : slv(31 downto 0) := x"0A02A8C0";  -- Set the default IP address before DHCP: 192.168.2.10 = x"0A02A8C0"
      DHCP_G            : boolean          := true;
      JUMBO_G           : boolean          := false);
   port (
      -- Clock and Reset
      dmaClk       : in  sl;
      dmaRst       : in  sl;
      -- ETH interface
      localMac     : in  slv(47 downto 0);
      ibMacMaster  : out AxiStreamMasterType;
      ibMacSlave   : in  AxiStreamSlaveType;
      obMacMaster  : in  AxiStreamMasterType;
      obMacSlave   : out AxiStreamSlaveType;
      -- DMA Interface
      dmaIbMasters : in  AxiStreamMasterArray(1 downto 0);
      dmaIbSlaves  : out AxiStreamSlaveArray(1 downto 0);
      dmaObMasters : out AxiStreamMasterArray(1 downto 0);
      dmaObSlaves  : in  AxiStreamSlaveArray(1 downto 0));
end RudpServers;

architecture mapping of RudpServers is

   constant TIMEOUT_C          : real     := 1.0E-3;  -- In units of seconds
   constant WINDOW_ADDR_SIZE_C : positive := ite(JUMBO_G, 3, 4);
   constant MAX_SEG_SIZE_C     : positive := ite(JUMBO_G, 8192, 1024);  -- Jumbo frame chucking

   constant APP_AXIS_CONFIG_C : AxiStreamConfigArray(0 downto 0) := (others => DMA_AXIS_CONFIG_G);

   constant NUM_SERVERS_C  : positive                                := 2;
   constant SERVER_PORTS_C : PositiveArray(NUM_SERVERS_C-1 downto 0) := (0 => 8192, 1 => 8193);

   signal ibServerMasters : AxiStreamMasterArray(NUM_SERVERS_C-1 downto 0);
   signal ibServerSlaves  : AxiStreamSlaveArray(NUM_SERVERS_C-1 downto 0);
   signal obServerMasters : AxiStreamMasterArray(NUM_SERVERS_C-1 downto 0);
   signal obServerSlaves  : AxiStreamSlaveArray(NUM_SERVERS_C-1 downto 0);

begin

   ----------------------
   -- IPv4/ARP/UDP Engine
   ----------------------
   U_UDP : entity surf.UdpEngineWrapper
      generic map (
         -- Simulation Generics
         TPD_G          => TPD_G,
         -- UDP Server Generics
         SERVER_EN_G    => true,
         SERVER_SIZE_G  => NUM_SERVERS_C,
         SERVER_PORTS_G => SERVER_PORTS_C,
         -- UDP Client Generics
         CLIENT_EN_G    => false,
         -- General IPv4/ARP/DHCP Generics
         DHCP_G         => DHCP_G,
         CLK_FREQ_G     => CLK_FREQUENCY_G,
         COMM_TIMEOUT_G => 30)
      port map (
         -- Local Configurations
         localMac        => localMac,
         localIp         => IP_ADDR_G,
         -- Interface to Ethernet Media Access Controller (MAC)
         obMacMaster     => obMacMaster,
         obMacSlave      => obMacSlave,
         ibMacMaster     => ibMacMaster,
         ibMacSlave      => ibMacSlave,
         -- Interface to UDP Server engine(s)
         obServerMasters => obServerMasters,
         obServerSlaves  => obServerSlaves,
         ibServerMasters => ibServerMasters,
         ibServerSlaves  => ibServerSlaves,
         -- Clock and Reset
         clk             => dmaClk,
         rst             => dmaRst);

   GEN_VEC :
   for i in NUM_SERVERS_C-1 downto 0 generate
      U_RssiServer : entity surf.RssiCoreWrapper
         generic map (
            TPD_G               => TPD_G,
            SERVER_G            => true,
            CLK_FREQUENCY_G     => CLK_FREQUENCY_G,
            TIMEOUT_UNIT_G      => TIMEOUT_C,
            APP_ILEAVE_EN_G     => true,  -- true = AxiStreamPacketizer2
            APP_STREAMS_G       => 1,
            SEGMENT_ADDR_SIZE_G => bitSize(MAX_SEG_SIZE_C/8),
            WINDOW_ADDR_SIZE_G  => WINDOW_ADDR_SIZE_C,
            -- AXIS Configurations
            APP_AXIS_CONFIG_G   => APP_AXIS_CONFIG_C,
            TSP_AXIS_CONFIG_G   => EMAC_AXIS_CONFIG_C,
            -- Window parameters of receiver module
            MAX_NUM_OUTS_SEG_G  => (2**WINDOW_ADDR_SIZE_C),
            MAX_SEG_SIZE_G      => MAX_SEG_SIZE_C,
            -- Counters
            MAX_RETRANS_CNT_G   => (2**WINDOW_ADDR_SIZE_C),
            MAX_CUM_ACK_CNT_G   => WINDOW_ADDR_SIZE_C)
         port map (
            clk_i                => dmaClk,
            rst_i                => dmaRst,
            openRq_i             => '1',
            -- Application Layer Interface
            sAppAxisMasters_i(0) => dmaIbMasters(i),
            sAppAxisSlaves_o(0)  => dmaIbSlaves(i),
            mAppAxisMasters_o(0) => dmaObMasters(i),
            mAppAxisSlaves_i(0)  => dmaObSlaves(i),
            -- Transport Layer Interface
            sTspAxisMaster_i     => obServerMasters(i),
            sTspAxisSlave_o      => obServerSlaves(i),
            mTspAxisMaster_o     => ibServerMasters(i),
            mTspAxisSlave_i      => ibServerSlaves(i));
   end generate GEN_VEC;

end mapping;
