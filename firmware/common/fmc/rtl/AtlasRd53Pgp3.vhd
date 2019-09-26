-------------------------------------------------------------------------------
-- File       : AtlasRd53Pgp3.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper for PGPv3 communication
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS RD53 DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'ATLAS RD53 DEV', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;
use work.SsiPkg.all;
use work.Pgp3Pkg.all;

entity AtlasRd53Pgp3 is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false);  -- or "10.3125Gbps"  
   port (
      -- DMA Interface (dmaClk domain)
      dmaClk       : in  sl;
      dmaRst       : in  sl;
      dmaObMasters : out AxiStreamMasterArray(1 downto 0);
      dmaObSlaves  : in  AxiStreamSlaveArray(1 downto 0);
      dmaIbMasters : in  AxiStreamMasterArray(1 downto 0);
      dmaIbSlaves  : out AxiStreamSlaveArray(1 downto 0);
      -- PGP Ports
      pgpClk       : in  sl;
      pgpRst       : in  sl;
      pgpTxMasters : out AxiStreamMasterArray(8 downto 0);
      pgpTxSlaves  : in  AxiStreamSlaveArray(8 downto 0);
      pgpRxMasters : in  AxiStreamMasterArray(8 downto 0);
      pgpRxSlaves  : out AxiStreamSlaveArray(8 downto 0);
      pgpRxCtrl    : out AxiStreamCtrlArray(8 downto 0));
end AtlasRd53Pgp3;

architecture mapping of AtlasRd53Pgp3 is

   signal txMasters : AxiStreamMasterArray(8 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal txSlaves  : AxiStreamSlaveArray(8 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);
   signal rxMasters : AxiStreamMasterArray(8 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal rxSlaves  : AxiStreamSlaveArray(8 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

begin

   GEN_VEC : for i in 8 downto 0 generate

      U_Fifo : entity work.AtlasRd53Pgp3AxisFifo
         generic map (
            TPD_G        => TPD_G,
            SIMULATION_G => SIMULATION_G)
         port map (
            -- System Interface (axilClk domain)
            sysClk      => dmaClk,
            sysRst      => dmaRst,
            sAxisMaster => txMasters(i),
            sAxisSlave  => txSlaves(i),
            mAxisMaster => rxMasters(i),
            mAxisSlave  => rxSlaves(i),
            -- PGP Interface (pgpClk domain)
            pgpClk      => pgpClk,
            pgpRst      => pgpRst,
            pgpRxMaster => pgpRxMasters(i),
            pgpRxSlave  => pgpRxSlaves(i),
            pgpRxCtrl   => pgpRxCtrl(i),
            pgpTxMaster => pgpTxMasters(i),
            pgpTxSlave  => pgpTxSlaves(i));

   end generate GEN_VEC;

   -- Data Access VC = [0x0:0x7]
   U_DeMux : entity work.AxiStreamDeMux
      generic map (
         TPD_G         => TPD_G,
         NUM_MASTERS_G => 8,
         PIPE_STAGES_G => 1)
      port map (
         -- Clock and reset
         axisClk      => dmaClk,
         axisRst      => dmaRst,
         -- Slave         
         mAxisMasters => txMasters(7 downto 0),
         mAxisSlaves  => txSlaves(7 downto 0),
         -- Masters
         sAxisMaster  => dmaIbMasters(0),
         sAxisSlave   => dmaIbSlaves(0));



   U_Mux : entity work.AxiStreamMux
      generic map (
         TPD_G                => TPD_G,
         NUM_SLAVES_G         => 8,
         ILEAVE_EN_G          => true,
         ILEAVE_ON_NOTVALID_G => true,
         ILEAVE_REARB_G       => 128,
         PIPE_STAGES_G        => 1)
      port map (
         -- Clock and reset
         axisClk      => dmaClk,
         axisRst      => dmaRst,
         -- Slaves
         sAxisMasters => rxMasters(7 downto 0),
         sAxisSlaves  => rxSlaves(7 downto 0),
         -- Master
         mAxisMaster  => dmaObMasters(0),
         mAxisSlave   => dmaObSlaves(0));

   -- SRPv3 Access: VC = 0x8
   dmaObMasters(1) <= rxMasters(8);
   rxSlaves(8)     <= dmaObSlaves(1);
   txMasters(8)    <= dmaIbMasters(1);
   dmaIbSlaves(1)  <= txSlaves(8);

end mapping;
