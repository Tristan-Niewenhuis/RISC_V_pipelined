library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
use IEEE.math_real.ALL;
use work.mi_package.all;

entity generic_shifter is
    Generic(shamt_bits : natural := 2);
    Port(din : in slv((2 ** shamt_bits) - 1 downto 0);
         dout : out slv((2 ** shamt_bits) - 1 downto 0);
         shamt : in slv(shamt_bits - 1 downto 0);
         func : in slv(1 downto 0); --01 = no shift, 00 = left, 10 = right loigcal, 11 right arithmetic
         co : out sl);
end generic_shifter;

architecture Behavioral of generic_shifter is
    type t_array is array (integer range <>) of slv((2 ** shamt_bits) downto 0);
    signal right_dsd_array : t_array(shamt_bits downto 0);
    signal left_dsd_array : t_array(shamt_bits downto 0);
    signal left : slv((2 ** shamt_bits) downto 0);
    signal right : slv((2 ** shamt_bits) downto 0);

begin
    left_dsd_array(0) <= '0' & din;
    right_dsd_array(0) <= din & '0';
    with func select left <=
        (others => din((2 ** shamt_bits) - 1)) when "11",
        (others => '0') when others;
    right <= (others => '0');

    left_shift_loop : for i in shamt_bits - 1 downto 0 generate
        left_dsd_array(i + 1) <= left_dsd_array(i)(((2 ** shamt_bits) - (2 ** i)) downto 0) & right(2 ** i - 1 downto 0) when shamt(i) = '1' else left_dsd_array(i);
    end generate left_shift_loop;

    right_shift_loop : for i in shamt_bits - 1 downto 0 generate
        right_dsd_array(i + 1) <= left(2 ** i - 1 downto 0) & right_dsd_array(i)((2 ** shamt_bits) downto (2 ** i)) when shamt(i) = '1' else right_dsd_array(i);
    end generate right_shift_loop;

    with func select dout <=
        din when "01",
        left_dsd_array(shamt_bits)((2 ** shamt_bits) - 1 downto 0) when "00",
        right_dsd_array(shamt_bits)((2 ** shamt_bits) downto 1) when others;

    with func select co <=
        '0' when "01",
        left_dsd_array(shamt_bits)(2 ** shamt_bits) when "00",
        right_dsd_array(shamt_bits)((0)) when others;
end Behavioral;
