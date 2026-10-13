library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_package.all;

entity nothing_tb is
end nothing_tb;

architecture Behavioral of nothing_tb is

    --------------------------------------------------------------------
    -- Clock / reset
    --------------------------------------------------------------------
    signal sys_clock : sl := '0';
    signal resetn : sl := '0';

    signal status_led_0 : sl;

begin

    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------
    uut : entity work.TCM_wrapper
        port map(
            resetn => resetn,
            status_led_0 => status_led_0,
            sys_clock => sys_clock
        );

    --------------------------------------------------------------------
    -- 100 MHz clock
    --------------------------------------------------------------------
    sys_clock <= not sys_clock after 5 ns;

    test : process
    begin
        ----------------------------------------------------------------
        -- Reset
        ----------------------------------------------------------------
        resetn <= '0';

        wait for 100 ns;
        resetn <= '1';

        wait;
    end process;

end Behavioral;
