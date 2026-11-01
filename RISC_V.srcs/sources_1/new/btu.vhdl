library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.RISCV_package.all;

entity btu is
    Port(a : in slv(XLEN - 1 downto 0);
         b : in slv(XLEN - 1 downto 0);
         cond : in slv(2 downto 0); -- bit 2: 1 = less then: 0 = eq, bit 1: 1 = signed: 2 = signed, bit 0: 1 = invert result  
         enable : in STD_LOGIC;
         BTU_out : out STD_LOGIC);
end btu;

architecture Behavioral of btu is
    signal pre_out, equal, lt, a_ext, b_ext : std_logic;
    signal diff : slv(XLEN downto 0);
begin
    equal <= '1' when a = b else '0';

    --One subtraction gives both less-than results.  The extra top bit is the
    --sign bit for BLT/BGE and zero for BLTU/BGEU, so the sign of the
    --difference is the comparison either way.
    a_ext <= a(XLEN - 1) and not cond(1);
    b_ext <= b(XLEN - 1) and not cond(1);
    diff <= slv(unsigned(a_ext & a) - unsigned(b_ext & b));
    lt <= diff(XLEN);

    with cond(2) select pre_out <=
        lt when '1',
        equal when others;

    BTU_out <= (pre_out xor cond(0)) and enable;

end Behavioral;
