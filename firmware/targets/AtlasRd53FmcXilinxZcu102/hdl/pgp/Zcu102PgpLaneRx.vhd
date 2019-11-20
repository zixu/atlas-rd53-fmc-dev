-------------------------------------------------------------------------------
-- File       : Zcu102Zcu102PgpLaneRx.vhd
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
use surf.Pgp3Pkg.all;

entity Zcu102PgpLaneRx is
   generic (
      TPD_G            : time     := 1 ns;
      ROGUE_SIM_EN_G   : boolean  := false;
      NUM_VC_G         : positive := 4;
      APP_AXI_CONFIG_G : AxiStreamConfigType;
      PHY_AXI_CONFIG_G : AxiStreamConfigType);
   port (
      -- AXIS Interface (axisClk domain)
      axisClk      : in  sl;
      axisRst      : in  sl;
      mAxisMaster  : out AxiStreamMasterType;
      mAxisSlave   : in  AxiStreamSlaveType;
      -- PGP Interface (pgpClk domain)
      pgpClk       : in  sl;
      pgpRst       : in  sl;
      rxlinkReady  : in  sl;
      pgpRxMasters : in  AxiStreamMasterArray(NUM_VC_G-1 downto 0);
      pgpRxCtrl    : out AxiStreamCtrlArray(NUM_VC_G-1 downto 0);
      pgpRxSlaves  : out AxiStreamSlaveArray(NUM_VC_G-1 downto 0));
end Zcu102PgpLaneRx;

architecture mapping of Zcu102PgpLaneRx is

   signal pgpMasters : AxiStreamMasterArray(NUM_VC_G-1 downto 0);
   signal rxMasters  : AxiStreamMasterArray(NUM_VC_G-1 downto 0);
   signal rxSlaves   : AxiStreamSlaveArray(NUM_VC_G-1 downto 0);

   signal mAxisMasters : AxiStreamMasterArray(NUM_VC_G-1 downto 0);
   signal mAxisSlaves  : AxiStreamSlaveArray(NUM_VC_G-1 downto 0);

begin

   BLOWOFF_FILTER : process (pgpRxMasters, rxlinkReady) is
      variable tmp : AxiStreamMasterArray(NUM_VC_G-1 downto 0);
      variable i   : natural;
   begin
      tmp := pgpRxMasters;
      for i in NUM_VC_G-1 downto 0 loop
         if (rxlinkReady = '0') then
            tmp(i).tValid := '0';
         end if;
      end loop;
      pgpMasters <= tmp;
   end process;

   GEN_VEC :
   for i in NUM_VC_G-1 downto 0 generate

      BUFFER_FIFO : entity surf.AxiStreamFifoV2
         generic map (
            -- General Configurations
            TPD_G               => TPD_G,
            SLAVE_READY_EN_G    => ROGUE_SIM_EN_G,
            -- FIFO configurations
            GEN_SYNC_FIFO_G     => false,
            FIFO_ADDR_WIDTH_G   => 9,
            FIFO_FIXED_THRESH_G => true,
            FIFO_PAUSE_THRESH_G => 128,
            -- AXI Stream Port Configurations
            SLAVE_AXI_CONFIG_G  => PHY_AXI_CONFIG_G,
            MASTER_AXI_CONFIG_G => APP_AXI_CONFIG_G)
         port map (
            -- Slave Port
            sAxisClk    => pgpClk,
            sAxisRst    => pgpRst,
            sAxisMaster => pgpMasters(i),
            sAxisCtrl   => pgpRxCtrl(i),
            sAxisSlave  => pgpRxSlaves(i),
            -- Master Port
            mAxisClk    => axisClk,
            mAxisRst    => axisRst,
            mAxisMaster => rxMasters(i),
            mAxisSlave  => rxSlaves(i));

      BURST_RESIZE_FIFO : entity surf.AxiStreamFifoV2
         generic map (
            -- General Configurations
            TPD_G               => TPD_G,
            SLAVE_READY_EN_G    => true,
            VALID_THOLD_G       => 128,  -- Hold until enough to burst into the interleaving MUX
            VALID_BURST_MODE_G  => true,
            -- FIFO configurations
            GEN_SYNC_FIFO_G     => true,
            FIFO_ADDR_WIDTH_G   => 9,
            -- AXI Stream Port Configurations
            SLAVE_AXI_CONFIG_G  => APP_AXI_CONFIG_G,
            MASTER_AXI_CONFIG_G => APP_AXI_CONFIG_G)
         port map (
            -- Slave Port
            sAxisClk    => axisClk,
            sAxisRst    => axisRst,
            sAxisMaster => rxMasters(i),
            sAxisSlave  => rxSlaves(i),
            -- Master Port
            mAxisClk    => axisClk,
            mAxisRst    => axisRst,
            mAxisMaster => mAxisMasters(i),
            mAxisSlave  => mAxisSlaves(i));

   end generate GEN_VEC;

   U_Mux : entity surf.AxiStreamMux
      generic map (
         TPD_G                => TPD_G,
         NUM_SLAVES_G         => NUM_VC_G,
         MODE_G               => "INDEXED",
         ILEAVE_EN_G          => true,
         ILEAVE_ON_NOTVALID_G => false,
         ILEAVE_REARB_G       => 128,
         PIPE_STAGES_G        => 1)
      port map (
         -- Clock and reset
         axisClk      => axisClk,
         axisRst      => axisRst,
         -- Inbound Master Ports
         sAxisMasters => mAxisMasters,
         -- Inbound Slave Ports
         sAxisSlaves  => mAxisSlaves,
         -- Outbound Port
         mAxisMaster  => mAxisMaster,
         mAxisSlave   => mAxisSlave);

end mapping;
