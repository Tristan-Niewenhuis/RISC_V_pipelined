library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_package.all;


entity RISC_V_tb is
end RISC_V_tb;

architecture Behavioral of RISC_V_tb is
    signal sys_clock : sl := '1';
    signal resetn : sl := '1';
    signal led_16bits_tri_o, dip_switches_16bits_tri_i : slv(15 downto 0);
begin
    uut: entity work.RISC_V_block_wrapper (STRUCTURE)
        port map ( sys_clock => sys_clock,
                  resetn => resetn,
                  dip_switches_16bits_tri_i => dip_switches_16bits_tri_i,
                  led_16bits_tri_o => led_16bits_tri_o);

     --clk
  sys_clock <= not sys_clock after 5 ns;

  test: process
    begin
      dip_switches_16bits_tri_i <= "0000000000000001";
      wait for 10 ns;
      --reset in beginning
      resetn <= '0';
      wait for 10 ns;
      resetn <= '1';
      wait for 300us;
      dip_switches_16bits_tri_i <= "0000000000000011";    
      wait;
  end process;
end Behavioral;
