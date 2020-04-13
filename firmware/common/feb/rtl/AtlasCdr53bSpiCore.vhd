-------------------------------------------------------------------------------
-- File       : AtlasCdr53bSpiCore.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: CDR53b SPI module
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;

entity AtlasCdr53bSpiCore is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- AXI-Lite Interface (axilClk domain)
      axilClk         : in    sl;
      axilRst         : in    sl;
      axilReadMaster  : in    AxiLiteReadMasterType;
      axilReadSlave   : out   AxiLiteReadSlaveType;
      axilWriteMaster : in    AxiLiteWriteMasterType;
      axilWriteSlave  : out   AxiLiteWriteSlaveType;
      -- RD53 ASIC Serial Ports
      dPortDataP      : inout slv(3 downto 0);
      dPortDataN      : inout slv(3 downto 0);
      dPortCmdP       : inout sl;
      dPortCmdN       : inout sl);
end AtlasCdr53bSpiCore;

architecture rtl of AtlasCdr53bSpiCore is

   constant SHIFT_REG_SIZE_C : natural := 206;
   constant WRD_SIZE_C       : natural := (SHIFT_REG_SIZE_C/32)+4;

   type StateType is (
      IDLE_S,
      DATA_SHIFT_S,
      DATA_SAMPLE_S,
      LOAD_SHIFT_S,
      LOAD_SAMPLE_S);

   type RegType is record
      start          : sl;
      cnt            : natural range 0 to SHIFT_REG_SIZE_C-1;
      clkCnt         : slv(15 downto 0);
      sclk           : sl;
      sld            : sl;
      data           : slv((32*WRD_SIZE_C) downto 0);
      shiftReg       : slv(SHIFT_REG_SIZE_C-1 downto 0);
      rstL           : sl;
      invCmd         : sl;
      invData        : slv(3 downto 0);
      sclkPeriod     : slv(15 downto 0);  -- Units of axilClk clock cycles
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
      state          : StateType;
   end record;

   constant REG_INIT_C : RegType := (
      start          => '1',
      cnt            => 0,
      clkCnt         => (others => '0'),
      sclk           => '0',
      sld            => '0',
      data           => (others => '0'),
      shiftReg       => (others => '0'),
      rstL           => '1',
      invCmd         => '0',
      invData        => (others => '1'),   -- Invert by default
      sclkPeriod     => toSlv(156/2, 16),  -- ~1 MHz SCLK
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C,
      state          => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal dPortData : slv(3 downto 0);
   signal dPortCmd  : sl;
   signal sdo       : sl;

begin

   U_DP3_SDO : entity surf.InputBufferReg
      generic map (
         TPD_G       => TPD_G,
         DIFF_PAIR_G => true)
      port map (
         C  => axilClk,
         I  => dPortDataP(3),
         IB => dPortDataN(3),
         Q1 => dPortData(3));

   comb : process (axilReadMaster, axilRst, axilWriteMaster, dPortData, r) is
      variable v          : RegType;
      variable axilStatus : AxiLiteStatusType;
      variable wrIdx      : natural;
      variable rdIdx      : natural;
   begin
      -- Latch the current value
      v := r;

      -- Update the variables
      wrIdx := conv_integer(axilWriteMaster.awaddr(11 downto 2));
      rdIdx := conv_integer(axilReadMaster.araddr(11 downto 2));

      -- Determine the transaction type
      axiSlaveWaitTxn(axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave, axilStatus);

      -- Check for a read request
      if (axilStatus.readEnable = '1') then
         if (axilReadMaster.araddr(11 downto 0) = x"FFC") then
            v.axilReadSlave.rdata(31)           := r.rstL;
            v.axilReadSlave.rdata(30 downto 21) := (others => '0');
            v.axilReadSlave.rdata(20)           := r.invCmd;
            v.axilReadSlave.rdata(19 downto 16) := r.invData;
            v.axilReadSlave.rdata(15 downto 0)  := r.sclkPeriod;
         else
            v.axilReadSlave.rdata := r.data((32*rdIdx)+31 downto (32*rdIdx));
         end if;
         -- Send AXI-Lite Response
         axiSlaveReadResponse(v.axilReadSlave, AXI_RESP_OK_C);
      end if;

      -- Check for a write request
      if (axilStatus.writeEnable = '1') then
         if (axilWriteMaster.awaddr(11 downto 0) = x"FFC") then
            v.rstL       := axilWriteMaster.wdata(31);
            v.invCmd     := axilWriteMaster.wdata(20);
            v.invData    := axilWriteMaster.wdata(19 downto 16);
            v.sclkPeriod := axilWriteMaster.wdata(15 downto 0);
         else
            v.data((32*wrIdx)+31 downto (32*wrIdx)) := axilWriteMaster.wdata;
            -- Set the flag
            v.start                                 := '1';
         end if;
         -- Send AXI-Lite response
         axiSlaveWriteResponse(v.axilWriteSlave, AXI_RESP_OK_C);
      end if;

      ----------------------------------------------------------------------
      -- State Machine
      ----------------------------------------------------------------------
      case (r.state) is
         ----------------------------------------------------------------------
         when IDLE_S =>
            -- Check for SW start flag
            if (v.start = '1') then
               -- Reset the flag
               v.start    := '0';
               -- Initialize the shift register
               v.shiftReg := v.data(SHIFT_REG_SIZE_C-1 downto 0);
               -- Next state
               v.state    := DATA_SAMPLE_S;
            end if;
         ----------------------------------------------------------------------
         when DATA_SAMPLE_S =>
            -- Wait half a clock period
            if (r.clkCnt = r.sclkPeriod) then
               -- Reset the counter
               v.clkCnt := (others => '0');
               -- Set clock high
               v.sclk   := '1';
               -- Next state
               v.state  := DATA_SHIFT_S;
            else
               -- Increment the counter
               v.clkCnt := r.clkCnt + 1;
            end if;
         ----------------------------------------------------------------------
         when DATA_SHIFT_S =>
            -- Wait half a clock period
            if (r.clkCnt = r.sclkPeriod) then
               -- Reset the counter
               v.clkCnt   := (others => '0');
               -- Set clock low
               v.sclk     := '0';
               -- Shift the output data
               v.shiftReg := r.shiftReg(SHIFT_REG_SIZE_C-2 downto 0) & '0';
               -- Check the shift counter
               if (r.cnt = (SHIFT_REG_SIZE_C-1)) then
                  -- Reset the counter
                  v.cnt   := 0;
                  -- Set LOAD high
                  v.sld   := '1';
                  -- Next state
                  v.state := LOAD_SAMPLE_S;
               else
                  -- Increment the counter
                  v.cnt   := r.cnt + 1;
                  -- Next state
                  v.state := DATA_SAMPLE_S;
               end if;
            else
               -- Increment the counter
               v.clkCnt := r.clkCnt + 1;
            end if;
         ----------------------------------------------------------------------
         when LOAD_SAMPLE_S =>
            -- Wait half a clock period
            if (r.clkCnt = r.sclkPeriod) then
               -- Reset the counter
               v.clkCnt := (others => '0');
               -- Set clock high
               v.sclk   := '1';
               -- Next state
               v.state  := LOAD_SHIFT_S;
            else
               -- Increment the counter
               v.clkCnt := r.clkCnt + 1;
            end if;
         ----------------------------------------------------------------------
         when LOAD_SHIFT_S =>
            -- Wait half a clock period
            if (r.clkCnt = r.sclkPeriod)then
               -- Reset the counter
               v.clkCnt := (others => '0');
               -- Set clock low
               v.sclk   := '0';
               -- Set LOAD low
               v.sld    := '0';
               -- Next state
               v.state  := IDLE_S;
            else
               -- Increment the counter
               v.clkCnt := r.clkCnt + 1;
            end if;
      ----------------------------------------------------------------------
      end case;

      -- Outputs
      axilWriteSlave <= r.axilWriteSlave;
      axilReadSlave  <= r.axilReadSlave;
      dPortData(0)   <= r.shiftReg(SHIFT_REG_SIZE_C-1) xor r.invData(0);  -- DP0_SDI
      dPortData(1)   <= r.sclk xor r.invData(1);        -- DP1_SCK
      dPortData(2)   <= r.sld xor r.invData(2);         -- DP2_SLD
      sdo            <= dPortData(3) xor r.invData(3);  -- DP3_SDO
      dPortCmd       <= r.rstL xor r.invCmd;            -- DPa_DEF_CNFG_B

      -- Reset
      if (axilRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (axilClk) is
   begin
      if (rising_edge(axilClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

   U_DP0_SDI : entity surf.OutputBufferReg
      generic map (
         TPD_G       => TPD_G,
         DIFF_PAIR_G => true)
      port map (
         C  => axilClk,
         I  => dPortData(0),
         O  => dPortDataP(0),
         OB => dPortDataN(0));

   U_DP1_SCK : entity surf.OutputBufferReg
      generic map (
         TPD_G       => TPD_G,
         DIFF_PAIR_G => true)
      port map (
         C  => axilClk,
         I  => dPortData(1),
         O  => dPortDataP(1),
         OB => dPortDataN(1));

   U_DP2_SLD : entity surf.OutputBufferReg
      generic map (
         TPD_G       => TPD_G,
         DIFF_PAIR_G => true)
      port map (
         C  => axilClk,
         I  => dPortData(2),
         O  => dPortDataP(2),
         OB => dPortDataN(2));

   U_DPa_DEF_CNFG_B : entity surf.OutputBufferReg
      generic map (
         TPD_G       => TPD_G,
         DIFF_PAIR_G => true)
      port map (
         C  => axilClk,
         I  => dPortCmd,
         O  => dPortCmdP,
         OB => dPortCmdN);

end rtl;
