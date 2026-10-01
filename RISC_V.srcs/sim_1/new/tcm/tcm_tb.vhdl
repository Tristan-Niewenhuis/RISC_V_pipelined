--------------------------------------------------------------------------------
-- Tightly Coupled Memory Testbench                                 tcm_tb
--
-- Self-checking test of tightly_coupled_memory with both port A clock
-- edges.  Three instances share one stimulus:
--
--   dut_pos  USE_NEGEDGE=false, initialised from tcm_tb_init.hex
--   dut_neg  USE_NEGEDGE=true,  initialised from tcm_tb_init.hex
--   dut_coe  USE_NEGEDGE=false, READ_ONLY=true, from tcm_tb_init.coe
--
-- The stimulus process drives every input just after a rising edge, the
-- way a rising-edge pipeline register would.  Checks:
--   1. Init images load (.hex and .coe).
--   2. Read latency: dut_neg returns data at the NEXT rising edge
--      (same cycle); dut_pos returns it one rising edge later.
--   3. Port B byte-lane writes, read back through port A.
--   4. Port A byte-lane writes on dut_neg (falling-edge write).
--   5. READ_ONLY rejects port A writes and raises fault.
--
-- INIT_DIR must name the directory holding the init images, with a
-- trailing '/'.  run_tcm_tb.sh passes it with -gINIT_DIR=.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tcm_tb is
    generic (INIT_DIR : string := "./");
end entity tcm_tb;

architecture sim of tcm_tb is

    signal clk  : std_logic := '0';
    signal stop : boolean := false;

    -- shared stimulus
    signal addr      : std_logic_vector(31 downto 0) := (others => '0');
    signal wdata     : std_logic_vector(31 downto 0) := (others => '0');
    signal we        : std_logic := '0';
    signal wstrb     : std_logic_vector(3 downto 0) := (others => '0');
    signal dbg_addr  : std_logic_vector(31 downto 0) := (others => '0');
    signal dbg_wdata : std_logic_vector(31 downto 0) := (others => '0');
    signal dbg_we    : std_logic := '0';
    signal dbg_wstrb : std_logic_vector(3 downto 0) := (others => '0');

    -- per-instance outputs
    signal rdata_pos, rdata_neg, rdata_coe : std_logic_vector(31 downto 0);
    signal fault_pos, fault_neg, fault_coe : std_logic;
    signal dbg_rdata_pos, dbg_rdata_neg, dbg_rdata_coe : std_logic_vector(31 downto 0);

begin

    clk <= not clk after 5 ns when not stop else '0';

    dut_pos : entity work.tightly_coupled_memory
        generic map (SIZE_BYTES => 1024, INIT_FILE => INIT_DIR & "tcm_tb_init.hex",
                     READ_ONLY => false, USE_NEGEDGE => false)
        port map (clk => clk, addr => addr, wdata => wdata, rdata => rdata_pos,
                  we => we, wstrb => wstrb, ready => open, fault => fault_pos,
                  dbg_addr => dbg_addr, dbg_wdata => dbg_wdata,
                  dbg_rdata => dbg_rdata_pos, dbg_we => dbg_we,
                  dbg_wstrb => dbg_wstrb);

    dut_neg : entity work.tightly_coupled_memory
        generic map (SIZE_BYTES => 1024, INIT_FILE => INIT_DIR & "tcm_tb_init.hex",
                     READ_ONLY => false, USE_NEGEDGE => true)
        port map (clk => clk, addr => addr, wdata => wdata, rdata => rdata_neg,
                  we => we, wstrb => wstrb, ready => open, fault => fault_neg,
                  dbg_addr => dbg_addr, dbg_wdata => dbg_wdata,
                  dbg_rdata => dbg_rdata_neg, dbg_we => dbg_we,
                  dbg_wstrb => dbg_wstrb);

    dut_coe : entity work.tightly_coupled_memory
        generic map (SIZE_BYTES => 1024, INIT_FILE => INIT_DIR & "tcm_tb_init.coe",
                     READ_ONLY => true, USE_NEGEDGE => false)
        port map (clk => clk, addr => addr, wdata => wdata, rdata => rdata_coe,
                  we => we, wstrb => wstrb, ready => open, fault => fault_coe,
                  dbg_addr => dbg_addr, dbg_wdata => dbg_wdata,
                  dbg_rdata => dbg_rdata_coe, dbg_we => '0',
                  dbg_wstrb => "0000");

    main : process
        variable passes : natural := 0;
        variable fails  : natural := 0;

        procedure chk(name : string; got, expect : std_logic_vector) is
        begin
            if got = expect then
                passes := passes + 1;
                report "PASS  " & name & " = " & to_hstring(got);
            else
                fails := fails + 1;
                report "FAIL  " & name & " = " & to_hstring(got)
                     & "  expected " & to_hstring(expect) severity warning;
            end if;
        end procedure;

        procedure chk_bit(name : string; got, expect : std_logic) is
        begin
            if got = expect then
                passes := passes + 1;
                report "PASS  " & name & " = " & std_logic'image(got);
            else
                fails := fails + 1;
                report "FAIL  " & name & " = " & std_logic'image(got)
                     & "  expected " & std_logic'image(expect) severity warning;
            end if;
        end procedure;

        -- Advance to just after the next rising edge
        procedure tick is
        begin
            wait until rising_edge(clk);
            wait for 1 ns;
        end procedure;

        function word(n : natural) return std_logic_vector is
        begin
            return std_logic_vector(to_unsigned(4 * n, 32));
        end function;
    begin
        tick;

        -- 1 + 2: init images and read latency -----------------------------
        -- Present word 1 just after edge k.
        addr <= word(1);
        -- At edge k+1: dut_neg already has word 1, dut_pos does not yet.
        wait until rising_edge(clk);
        chk("neg: word 1 ready at next edge     ", rdata_neg, X"DEADBEEF");
        if rdata_pos = X"DEADBEEF" then
            fails := fails + 1;
            report "FAIL  pos: word 1 arrived a cycle early" severity warning;
        else
            passes := passes + 1;
            report "PASS  pos: word 1 not yet ready at next edge";
        end if;
        -- At edge k+2: dut_pos has it too.
        wait until rising_edge(clk);
        chk("pos: word 1 ready one edge later   ", rdata_pos, X"DEADBEEF");
        chk("coe: word 1 (rising edge)          ", rdata_coe, X"0BADF00D");
        wait for 1 ns;

        addr <= word(3);
        tick;
        tick;
        chk("hex: word 3 (pos)                  ", rdata_pos, X"CAFEF00D");
        chk("hex: word 3 (neg)                  ", rdata_neg, X"CAFEF00D");
        chk("coe: word 3 beyond image is zero   ", rdata_coe, X"00000000");

        -- 3: port B byte-lane writes -----------------------------------------
        dbg_addr  <= word(8);
        dbg_wdata <= X"11223344";
        dbg_we    <= '1';
        dbg_wstrb <= "1111";
        tick;
        dbg_wdata <= X"AABBCCDD";
        dbg_wstrb <= "0101";
        tick;
        dbg_we    <= '0';
        dbg_wstrb <= "0000";
        addr <= word(8);
        tick;
        tick;
        chk("portB byte lanes 0,2 (pos)         ", rdata_pos, X"11BB33DD");
        chk("portB byte lanes 0,2 (neg)         ", rdata_neg, X"11BB33DD");

        -- 4 + 5: port A writes (neg writes on falling edge), READ_ONLY ------
        addr  <= word(9);
        wdata <= X"CAFEBABE";
        we    <= '1';
        wstrb <= "1100";
        wait for 2 ns;  -- fault is combinational
        chk_bit("coe READ_ONLY write raises fault   ", fault_coe, '1');
        chk_bit("neg write raises no fault          ", fault_neg, '0');
        tick;
        we    <= '0';
        wstrb <= "0000";
        tick;
        tick;
        chk("portA write lanes 2,3 (pos)        ", rdata_pos, X"CAFE0000");
        chk("portA write lanes 2,3 (neg)        ", rdata_neg, X"CAFE0000");
        chk("READ_ONLY word 9 unchanged         ", rdata_coe, X"00000000");

        report "==== tcm_tb: " & integer'image(passes) & " passed, "
             & integer'image(fails) & " failed ====";
        assert fails = 0 report "tcm_tb FAILED" severity failure;

        stop <= true;
        wait for 20 ns;
        std.env.stop;
    end process main;

end architecture sim;
