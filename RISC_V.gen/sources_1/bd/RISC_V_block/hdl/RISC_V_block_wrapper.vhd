--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
--Copyright 2022-2026 Advanced Micro Devices, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2026.1 (win64) Build 6511674 Tue Jun 16 11:02:23 MDT 2026
--Date        : Wed Aug 26 21:52:19 2026
--Host        : DESKTOP-P2Q0K54 running 64-bit major release  (build 9200)
--Command     : generate_target RISC_V_block_wrapper.bd
--Design      : RISC_V_block_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity RISC_V_block_wrapper is
  port (
    dip_switches_16bits_tri_i : in STD_LOGIC_VECTOR ( 15 downto 0 );
    led_16bits_tri_o : out STD_LOGIC_VECTOR ( 15 downto 0 );
    resetn : in STD_LOGIC;
    sys_clock : in STD_LOGIC
  );
end RISC_V_block_wrapper;

architecture STRUCTURE of RISC_V_block_wrapper is
  component RISC_V_block is
  port (
    dip_switches_16bits_tri_i : in STD_LOGIC_VECTOR ( 15 downto 0 );
    led_16bits_tri_o : out STD_LOGIC_VECTOR ( 15 downto 0 );
    resetn : in STD_LOGIC;
    sys_clock : in STD_LOGIC
  );
  end component RISC_V_block;
begin
RISC_V_block_i: component RISC_V_block
     port map (
      dip_switches_16bits_tri_i(15 downto 0) => dip_switches_16bits_tri_i(15 downto 0),
      led_16bits_tri_o(15 downto 0) => led_16bits_tri_o(15 downto 0),
      resetn => resetn,
      sys_clock => sys_clock
    );
end STRUCTURE;
