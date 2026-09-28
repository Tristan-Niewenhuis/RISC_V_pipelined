
library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_package.all;

entity CSR_regs is
  port(
    clk, reset : sl;
    d_sel : in slv(11 downto 0); -- select register to write
    d_len : in sl; -- write the register when 1
    d_in : in slv(31 downto 0); -- data/mask to be written
    d_type : in slv(1 downto 0); --type of write --01 = straight write, 10 = set mask, 11 = clear mastk
    q_sel : in slv(11 downto 0); -- select the output register
    q_out : out slv(31 downto 0); -- data from selected register
    -- Some registers need to be written or read directly by other hardware.
    exec : in sl -- needed to know when to increment minstret
  );
end CSR_regs;

architecture behavioral of CSR_regs is
  type reg_array is array (natural range <>) of slv(31 downto 0);
  signal dsel_decoded : slv(2 ** 12 - 1 downto 0);
  --signal reg_out : reg_array(2**12-1 downto 0) := (others => (others => '0'));
  signal reg_out : reg_array(2 ** 12 - 1 downto 0) := (others => (others => '0'));
  signal d, d_prev : slv(31 downto 0);
  signal mcycle_counter, mcycle_counter_next, minstret_counter, minstret_counter_next : slv(63 downto 0);
begin

  dsel_decoded <= decode(d_sel, d_len);
  d_prev <= reg_out(to_integer(unsigned(d_sel)));
  with d_type select d <=
    (d_prev or d_in) when "10",
    (d_prev and not d_in) when "11",
    d_in when others;

  -- These CSRs should be simple counters.
  -- mcycle/mcycleh (64 bit counter)
  mcycle_counter <= mcycle_counter_next when rising_edge(clk);
  mcycle_counter_next <= (others => '0') when reset = '1' else
                         mcycle_counter(63 downto 32) & d when dsel_decoded(16#B00#) = '1' else
                         d & mcycle_counter(31 downto 0) when dsel_decoded(16#B80#) = '1' else
                         slv(unsigned(mcycle_counter) + 1);
  --mcycle
  reg_out(16#B00#) <= mcycle_counter(31 downto 0);
  reg_out(16#B80#) <= mcycle_counter(63 downto 32);
  --cycle
  reg_out(16#C00#) <= mcycle_counter(31 downto 0);
  reg_out(16#C80#) <= mcycle_counter(63 downto 32);
  --time just equal to cycle
  reg_out(16#C01#) <= mcycle_counter(31 downto 0);
  reg_out(16#C81#) <= mcycle_counter(63 downto 32);

  -- minstret/minstreth (64 bit counter)
  minstret_counter <= minstret_counter_next when rising_edge(clk);
  minstret_counter_next <= (others => '0') when reset = '1' else
                           minstret_counter(63 downto 32) & d when dsel_decoded(16#B02#) = '1' else
                           d & minstret_counter(31 downto 0) when dsel_decoded(16#B82#) = '1' else
                           slv(unsigned(minstret_counter) + 1) when exec = '1' else
                           minstret_counter;
  --minstret
  reg_out(16#B02#) <= minstret_counter(31 downto 0);
  reg_out(16#B82#) <= minstret_counter(63 downto 32);
  --instreth
  reg_out(16#C02#) <= minstret_counter(31 downto 0);
  reg_out(16#C82#) <= minstret_counter(63 downto 32);

  q_out <= reg_out(to_integer(unsigned(q_sel)));
end Behavioral;

-- We also need a memory-mapped real-time counter(mtime and mtimecmp)

-- We also need to decode and implement ECALL and MRET instructions.

-- Also need the WFI instruction
