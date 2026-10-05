--------------------------------------------------------------------------------
-- RISC_V_TCM Program Runner                              riscv_tcm_prog_tb
--
-- Runs a program built with tcm_sw (tcm.ld + start.S) on RISC_V_TCM and
-- checks the value main returns.  start.S stores main's return value to
-- tcm_result and then 1 to tcm_done (both start at 0 in .bss).  This
-- testbench watches the DTCM port B stores inside the core (VHDL-2008
-- external names) for those two addresses.
--
-- Generics
--   USE_NEGEDGE  passed to RISC_V_TCM
--   INIT_DIR     directory holding itcm.hex and dtcm.hex, with a
--                trailing '/'
--   RESULT_ADDR  address of tcm_result (from nm)
--   DONE_ADDR    address of tcm_done (from nm)
--   EXPECT       expected return value of main
--   MAX_CYCLES   give up after this many clock cycles
--
-- On completion it reports the cycle count, which is the program's
-- run time in clocks from reset to the tcm_done store.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RISCV_package.all;

entity riscv_tcm_prog_tb is
    generic (
        USE_NEGEDGE : boolean          := false;
        INIT_DIR    : string           := "./";
        RESULT_ADDR : slv(31 downto 0) := x"10000004";
        DONE_ADDR   : slv(31 downto 0) := x"10000008";
        EXPECT      : slv(31 downto 0) := x"00000000";
        MAX_CYCLES  : natural          := 1000000
    );
end entity riscv_tcm_prog_tb;

architecture sim of riscv_tcm_prog_tb is
    signal clk    : sl := '0';
    signal resetn : sl := '0';
    signal stop   : boolean := false;
    signal sw     : slv(15 downto 0) := (others => '0');
    signal led    : slv(15 downto 0);
begin

    clk <= not clk after 5 ns when not stop else '0';

    uut : entity work.RISC_V_TCM
        generic map (
            ITCM_INIT_FILE => INIT_DIR & "itcm.hex",
            DTCM_INIT_FILE => INIT_DIR & "dtcm.hex",
            USE_NEGEDGE    => USE_NEGEDGE
        )
        port map (clk => clk, resetn => resetn, sw => sw, led => led);

    main : process
        alias st_we   is <<signal .riscv_tcm_prog_tb.uut.dtcm_st_we : sl>>;
        alias st_addr is <<signal .riscv_tcm_prog_tb.uut.ls_address : slv(31 downto 0)>>;
        alias st_data is <<signal .riscv_tcm_prog_tb.uut.st_data    : slv(31 downto 0)>>;
        variable result : slv(31 downto 0) := (others => 'U');
        variable cycles : natural := 0;
        variable done   : boolean := false;
    begin
        resetn <= '0';
        wait for 40 ns;
        wait until rising_edge(clk);
        resetn <= '1';

        while not done and cycles < MAX_CYCLES loop
            wait until rising_edge(clk);
            cycles := cycles + 1;
            if st_we = '1' and st_addr = RESULT_ADDR then
                result := st_data;
            end if;
            -- start.S clears .bss first, which stores 0 to tcm_done
            if st_we = '1' and st_addr = DONE_ADDR and unsigned(st_data) /= 0 then
                done := true;
            end if;
        end loop;

        report "USE_NEGEDGE=" & boolean'image(USE_NEGEDGE)
             & "  cycles=" & integer'image(cycles)
             & "  result=" & to_hstring(result)
             & "  expected=" & to_hstring(EXPECT);
        assert done report "program did not finish within MAX_CYCLES"
            severity failure;
        assert result = EXPECT report "program result MISMATCH"
            severity failure;
        report "PASS";

        stop <= true;
        wait for 20 ns;
        std.env.stop;
    end process main;

end architecture sim;
