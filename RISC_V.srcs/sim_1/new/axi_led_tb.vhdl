library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_led_tb is
end entity axi_led_tb;

architecture sim of axi_led_tb is

    constant CLK_PERIOD : time := 10 ns;

    -- AXI signals
    signal S_AXI_ACLK    : std_logic := '0';
    signal S_AXI_ARESETN : std_logic := '0';

    signal S_AXI_AWADDR  : std_logic_vector(31 downto 0) := (others => '0');
    signal S_AXI_AWVALID : std_logic := '0';
    signal S_AXI_AWREADY : std_logic;

    signal S_AXI_WDATA   : std_logic_vector(31 downto 0) := (others => '0');
    signal S_AXI_WSTRB   : std_logic_vector(3 downto 0) := (others => '0');
    signal S_AXI_WVALID  : std_logic := '0';
    signal S_AXI_WREADY  : std_logic;

    signal S_AXI_BRESP   : std_logic_vector(1 downto 0);
    signal S_AXI_BVALID  : std_logic;
    signal S_AXI_BREADY  : std_logic := '0';

    signal S_AXI_ARADDR  : std_logic_vector(31 downto 0) := (others => '0');
    signal S_AXI_ARVALID : std_logic := '0';
    signal S_AXI_ARREADY : std_logic;

    signal S_AXI_RDATA   : std_logic_vector(31 downto 0);
    signal S_AXI_RRESP   : std_logic_vector(1 downto 0);
    signal S_AXI_RVALID  : std_logic;
    signal S_AXI_RREADY  : std_logic := '0';

    signal LED : std_logic_vector(15 downto 0);

begin

    --------------------------------------------------------------------
    -- Clock
    --------------------------------------------------------------------

    clk_process : process
    begin
        while true loop
            S_AXI_ACLK <= '0';
            wait for CLK_PERIOD / 2;

            S_AXI_ACLK <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;


    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------

    dut : entity work.axi_led
        port map (
            S_AXI_ACLK    => S_AXI_ACLK,
            S_AXI_ARESETN => S_AXI_ARESETN,

            S_AXI_AWADDR  => S_AXI_AWADDR,
            S_AXI_AWVALID => S_AXI_AWVALID,
            S_AXI_AWREADY => S_AXI_AWREADY,

            S_AXI_WDATA   => S_AXI_WDATA,
            S_AXI_WSTRB   => S_AXI_WSTRB,
            S_AXI_WVALID  => S_AXI_WVALID,
            S_AXI_WREADY  => S_AXI_WREADY,

            S_AXI_BRESP   => S_AXI_BRESP,
            S_AXI_BVALID  => S_AXI_BVALID,
            S_AXI_BREADY  => S_AXI_BREADY,

            S_AXI_ARADDR  => S_AXI_ARADDR,
            S_AXI_ARVALID => S_AXI_ARVALID,
            S_AXI_ARREADY => S_AXI_ARREADY,

            S_AXI_RDATA   => S_AXI_RDATA,
            S_AXI_RRESP   => S_AXI_RRESP,
            S_AXI_RVALID  => S_AXI_RVALID,
            S_AXI_RREADY  => S_AXI_RREADY,

            LED           => LED
        );


    --------------------------------------------------------------------
    -- Test
    --------------------------------------------------------------------

    stimulus : process

        constant TEST_ADDRESS : std_logic_vector(31 downto 0)
            := x"DEADBEEF";

        constant TEST_DATA : std_logic_vector(31 downto 0)
            := x"000000A5";

        variable read_data : std_logic_vector(31 downto 0);

    begin

        ----------------------------------------------------------------
        -- Reset
        ----------------------------------------------------------------

        S_AXI_ARESETN <= '0';

        wait for 5 * CLK_PERIOD;

        S_AXI_ARESETN <= '1';

        wait for 2 * CLK_PERIOD;


        ----------------------------------------------------------------
        -- WRITE 0x000000A5 -> 0xDEADBEEF
        ----------------------------------------------------------------

        report "Starting AXI WRITE";

        S_AXI_AWADDR  <= TEST_ADDRESS;
        S_AXI_AWVALID <= '1';

        S_AXI_WDATA   <= TEST_DATA;
        S_AXI_WSTRB   <= "1111";
        S_AXI_WVALID  <= '1';

        -- Wait until address and data are accepted
        wait until rising_edge(S_AXI_ACLK);

        while (S_AXI_AWREADY = '0') or
              (S_AXI_WREADY  = '0') loop
            wait until rising_edge(S_AXI_ACLK);
        end loop;

        -- Deassert VALID after handshake
        S_AXI_AWVALID <= '0';
        S_AXI_WVALID  <= '0';

        report "AXI WRITE accepted";


        ----------------------------------------------------------------
        -- WRITE RESPONSE
        ----------------------------------------------------------------

        S_AXI_BREADY <= '1';

        wait until rising_edge(S_AXI_ACLK);

        while S_AXI_BVALID = '0' loop
            wait until rising_edge(S_AXI_ACLK);
        end loop;

        assert S_AXI_BRESP = "00"
            report "AXI write response was not OKAY"
            severity error;

        S_AXI_BREADY <= '0';

        report "AXI WRITE response OK";


        ----------------------------------------------------------------
        -- Check LED output
        ----------------------------------------------------------------

        wait until rising_edge(S_AXI_ACLK);

        assert LED = x"00A5"
            report "LED register did not contain 0x00A5"
            severity error;

        report "LED register = 0x00A5";


        ----------------------------------------------------------------
        -- READ from 0xDEADBEEF
        ----------------------------------------------------------------

        report "Starting AXI READ";

        S_AXI_ARADDR  <= TEST_ADDRESS;
        S_AXI_ARVALID <= '1';

        wait until rising_edge(S_AXI_ACLK);

        while S_AXI_ARREADY = '0' loop
            wait until rising_edge(S_AXI_ACLK);
        end loop;

        S_AXI_ARVALID <= '0';

        report "AXI READ address accepted";


        ----------------------------------------------------------------
        -- READ RESPONSE
        ----------------------------------------------------------------

        S_AXI_RREADY <= '1';

        wait until rising_edge(S_AXI_ACLK);

        while S_AXI_RVALID = '0' loop
            wait until rising_edge(S_AXI_ACLK);
        end loop;

        read_data := S_AXI_RDATA;

        assert S_AXI_RRESP = "00"
            report "AXI read response was not OKAY"
            severity error;

        S_AXI_RREADY <= '0';


        ----------------------------------------------------------------
        -- Verify read data
        ----------------------------------------------------------------

        assert read_data = TEST_DATA
            report "READ DATA MISMATCH!"
            severity error;

        report "READ DATA MATCH";


        ----------------------------------------------------------------
        -- Done
        ----------------------------------------------------------------

        report "========================================";
        report "AXI LED TEST PASSED";
        report "Wrote 0x000000A5 to 0xDEADBEEF";
        report "Read  0x000000A5 from 0xDEADBEEF";
        report "========================================";

        wait;

    end process;

end architecture sim;