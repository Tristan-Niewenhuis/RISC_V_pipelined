library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_package.all;

entity RISC_V_tb is
end RISC_V_tb;

architecture Behavioral of RISC_V_tb is

    --------------------------------------------------------------------
    -- Clock / reset
    --------------------------------------------------------------------
    signal sys_clock : sl := '0';
    signal resetn : sl := '0';

    --------------------------------------------------------------------
    -- M_AXI_0
    -- Unused master interface.  The DUT is the master, so the TB
    -- provides the response-side signals.
    --------------------------------------------------------------------
    signal M_AXI_0_araddr : std_logic_vector(31 downto 0);
    signal M_AXI_0_arburst : std_logic_vector(1 downto 0);
    signal M_AXI_0_arcache : std_logic_vector(3 downto 0);
    signal M_AXI_0_arid : std_logic_vector(0 downto 0);
    signal M_AXI_0_arlen : std_logic_vector(7 downto 0);
    signal M_AXI_0_arlock : std_logic;
    signal M_AXI_0_arprot : std_logic_vector(2 downto 0);
    signal M_AXI_0_arqos : std_logic_vector(3 downto 0);
    signal M_AXI_0_arready : std_logic := '0';
    signal M_AXI_0_arsize : std_logic_vector(2 downto 0);
    signal M_AXI_0_arvalid : std_logic;

    signal M_AXI_0_awaddr : std_logic_vector(31 downto 0);
    signal M_AXI_0_awburst : std_logic_vector(1 downto 0);
    signal M_AXI_0_awcache : std_logic_vector(3 downto 0);
    signal M_AXI_0_awid : std_logic_vector(0 downto 0);
    signal M_AXI_0_awlen : std_logic_vector(7 downto 0);
    signal M_AXI_0_awlock : std_logic;
    signal M_AXI_0_awprot : std_logic_vector(2 downto 0);
    signal M_AXI_0_awqos : std_logic_vector(3 downto 0);
    signal M_AXI_0_awready : std_logic := '0';
    signal M_AXI_0_awsize : std_logic_vector(2 downto 0);
    signal M_AXI_0_awvalid : std_logic;

    signal M_AXI_0_bid : std_logic_vector(0 downto 0) := "0";
    signal M_AXI_0_bready : std_logic;
    signal M_AXI_0_bresp : std_logic_vector(1 downto 0) := "00";
    signal M_AXI_0_bvalid : std_logic := '0';

    signal M_AXI_0_rdata : std_logic_vector(31 downto 0) := (others => '0');
    signal M_AXI_0_rid : std_logic_vector(0 downto 0) := "0";
    signal M_AXI_0_rlast : std_logic := '0';
    signal M_AXI_0_rready : std_logic;
    signal M_AXI_0_rresp : std_logic_vector(1 downto 0) := "00";
    signal M_AXI_0_rvalid : std_logic := '0';

    signal M_AXI_0_wdata : std_logic_vector(31 downto 0);
    signal M_AXI_0_wlast : std_logic;
    signal M_AXI_0_wready : std_logic := '0';
    signal M_AXI_0_wstrb : std_logic_vector(3 downto 0);
    signal M_AXI_0_wvalid : std_logic;

    --------------------------------------------------------------------
    -- S00_AXI_0
    --------------------------------------------------------------------
    signal S00_AXI_0_araddr : std_logic_vector(31 downto 0) := (others => '0');
    signal S00_AXI_0_arburst : std_logic_vector(1 downto 0) := "01";
    signal S00_AXI_0_arcache : std_logic_vector(3 downto 0) := (others => '0');
    signal S00_AXI_0_arid : std_logic_vector(0 downto 0) := "0";
    signal S00_AXI_0_arlen : std_logic_vector(7 downto 0) := (others => '0');
    signal S00_AXI_0_arlock : std_logic_vector(0 downto 0) := "0";
    signal S00_AXI_0_arprot : std_logic_vector(2 downto 0) := (others => '0');
    signal S00_AXI_0_arqos : std_logic_vector(3 downto 0) := (others => '0');
    signal S00_AXI_0_arready : std_logic;
    signal S00_AXI_0_arsize : std_logic_vector(2 downto 0) := "010";
    signal S00_AXI_0_arvalid : std_logic := '0';

    signal S00_AXI_0_awaddr : std_logic_vector(31 downto 0) := (others => '0');
    signal S00_AXI_0_awburst : std_logic_vector(1 downto 0) := "01";
    signal S00_AXI_0_awcache : std_logic_vector(3 downto 0) := (others => '0');
    signal S00_AXI_0_awid : std_logic_vector(0 downto 0) := "0";
    signal S00_AXI_0_awlen : std_logic_vector(7 downto 0) := (others => '0');
    signal S00_AXI_0_awlock : std_logic_vector(0 downto 0) := "0";
    signal S00_AXI_0_awprot : std_logic_vector(2 downto 0) := (others => '0');
    signal S00_AXI_0_awqos : std_logic_vector(3 downto 0) := (others => '0');
    signal S00_AXI_0_awready : std_logic;
    signal S00_AXI_0_awsize : std_logic_vector(2 downto 0) := "010";
    signal S00_AXI_0_awvalid : std_logic := '0';

    signal S00_AXI_0_bid : std_logic_vector(0 downto 0);
    signal S00_AXI_0_bready : std_logic := '0';
    signal S00_AXI_0_bresp : std_logic_vector(1 downto 0);
    signal S00_AXI_0_bvalid : std_logic;

    signal S00_AXI_0_rdata : std_logic_vector(31 downto 0);
    signal S00_AXI_0_rid : std_logic_vector(0 downto 0);
    signal S00_AXI_0_rlast : std_logic;
    signal S00_AXI_0_rready : std_logic := '0';
    signal S00_AXI_0_rresp : std_logic_vector(1 downto 0);
    signal S00_AXI_0_rvalid : std_logic;

    signal S00_AXI_0_wdata : std_logic_vector(31 downto 0) := (others => '0');
    signal S00_AXI_0_wlast : std_logic := '1';
    signal S00_AXI_0_wready : std_logic;
    signal S00_AXI_0_wstrb : std_logic_vector(3 downto 0) := "1111";
    signal S00_AXI_0_wvalid : std_logic := '0';

    signal cpu_clk_out, test_rig_clk_out : std_logic;
    signal status_led_0 : std_logic;

begin

    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------
    uut : entity work.TCM_wrapper
        port map(
            M_AXI_0_araddr => M_AXI_0_araddr,
            M_AXI_0_arburst => M_AXI_0_arburst,
            M_AXI_0_arcache => M_AXI_0_arcache,
            M_AXI_0_arid => M_AXI_0_arid,
            M_AXI_0_arlen => M_AXI_0_arlen,
            M_AXI_0_arlock => M_AXI_0_arlock,
            M_AXI_0_arprot => M_AXI_0_arprot,
            M_AXI_0_arqos => M_AXI_0_arqos,
            M_AXI_0_arready => M_AXI_0_arready,
            M_AXI_0_arsize => M_AXI_0_arsize,
            M_AXI_0_arvalid => M_AXI_0_arvalid,
            M_AXI_0_awaddr => M_AXI_0_awaddr,
            M_AXI_0_awburst => M_AXI_0_awburst,
            M_AXI_0_awcache => M_AXI_0_awcache,
            M_AXI_0_awid => M_AXI_0_awid,
            M_AXI_0_awlen => M_AXI_0_awlen,
            M_AXI_0_awlock => M_AXI_0_awlock,
            M_AXI_0_awprot => M_AXI_0_awprot,
            M_AXI_0_awqos => M_AXI_0_awqos,
            M_AXI_0_awready => M_AXI_0_awready,
            M_AXI_0_awsize => M_AXI_0_awsize,
            M_AXI_0_awvalid => M_AXI_0_awvalid,
            M_AXI_0_bid => M_AXI_0_bid,
            M_AXI_0_bready => M_AXI_0_bready,
            M_AXI_0_bresp => M_AXI_0_bresp,
            M_AXI_0_bvalid => M_AXI_0_bvalid,
            M_AXI_0_rdata => M_AXI_0_rdata,
            M_AXI_0_rid => M_AXI_0_rid,
            M_AXI_0_rlast => M_AXI_0_rlast,
            M_AXI_0_rready => M_AXI_0_rready,
            M_AXI_0_rresp => M_AXI_0_rresp,
            M_AXI_0_rvalid => M_AXI_0_rvalid,
            M_AXI_0_wdata => M_AXI_0_wdata,
            M_AXI_0_wlast => M_AXI_0_wlast,
            M_AXI_0_wready => M_AXI_0_wready,
            M_AXI_0_wstrb => M_AXI_0_wstrb,
            M_AXI_0_wvalid => M_AXI_0_wvalid,
            S00_AXI_0_araddr => S00_AXI_0_araddr,
            S00_AXI_0_arburst => S00_AXI_0_arburst,
            S00_AXI_0_arcache => S00_AXI_0_arcache,
            S00_AXI_0_arid => S00_AXI_0_arid,
            S00_AXI_0_arlen => S00_AXI_0_arlen,
            S00_AXI_0_arlock => S00_AXI_0_arlock,
            S00_AXI_0_arprot => S00_AXI_0_arprot,
            S00_AXI_0_arqos => S00_AXI_0_arqos,
            S00_AXI_0_arready => S00_AXI_0_arready,
            S00_AXI_0_arsize => S00_AXI_0_arsize,
            S00_AXI_0_arvalid => S00_AXI_0_arvalid,
            S00_AXI_0_awaddr => S00_AXI_0_awaddr,
            S00_AXI_0_awburst => S00_AXI_0_awburst,
            S00_AXI_0_awcache => S00_AXI_0_awcache,
            S00_AXI_0_awid => S00_AXI_0_awid,
            S00_AXI_0_awlen => S00_AXI_0_awlen,
            S00_AXI_0_awlock => S00_AXI_0_awlock,
            S00_AXI_0_awprot => S00_AXI_0_awprot,
            S00_AXI_0_awqos => S00_AXI_0_awqos,
            S00_AXI_0_awready => S00_AXI_0_awready,
            S00_AXI_0_awsize => S00_AXI_0_awsize,
            S00_AXI_0_awvalid => S00_AXI_0_awvalid,
            S00_AXI_0_bid => S00_AXI_0_bid,
            S00_AXI_0_bready => S00_AXI_0_bready,
            S00_AXI_0_bresp => S00_AXI_0_bresp,
            S00_AXI_0_bvalid => S00_AXI_0_bvalid,
            S00_AXI_0_rdata => S00_AXI_0_rdata,
            S00_AXI_0_rid => S00_AXI_0_rid,
            S00_AXI_0_rlast => S00_AXI_0_rlast,
            S00_AXI_0_rready => S00_AXI_0_rready,
            S00_AXI_0_rresp => S00_AXI_0_rresp,
            S00_AXI_0_rvalid => S00_AXI_0_rvalid,
            S00_AXI_0_wdata => S00_AXI_0_wdata,
            S00_AXI_0_wlast => S00_AXI_0_wlast,
            S00_AXI_0_wready => S00_AXI_0_wready,
            S00_AXI_0_wstrb => S00_AXI_0_wstrb,
            S00_AXI_0_wvalid => S00_AXI_0_wvalid,
            cpu_clk_out => cpu_clk_out,
            test_rig_clk_out => test_rig_clk_out,
            resetn => resetn,
            status_led_0 => status_led_0,
            sys_clock => sys_clock
        );

    --------------------------------------------------------------------
    -- 100 MHz clock
    --------------------------------------------------------------------
    sys_clock <= not sys_clock after 5 ns;

    --------------------------------------------------------------------
    -- AXI test process
    --------------------------------------------------------------------
    test : process
        procedure axi_write(
            constant addr : in std_logic_vector(31 downto 0);
            constant data : in std_logic_vector(31 downto 0)
        ) is
        begin

            -- Put address on AW channel
            S00_AXI_0_awaddr <= addr;
            S00_AXI_0_awvalid <= '1';

            -- Put data on W channel
            S00_AXI_0_wdata <= data;
            S00_AXI_0_wstrb <= "1111";
            S00_AXI_0_wvalid <= '1';

            -- Wait until both address and data have been accepted.
            while (S00_AXI_0_awready = '0' or S00_AXI_0_wready = '0') loop
                wait until rising_edge(test_rig_clk_out);
            end loop;

            wait until rising_edge(test_rig_clk_out);

            S00_AXI_0_awvalid <= '0';
            S00_AXI_0_wvalid <= '0';

            -- Wait for write response
            S00_AXI_0_bready <= '1';

            while S00_AXI_0_bvalid = '0' loop
                wait until rising_edge(test_rig_clk_out);
            end loop;

            assert S00_AXI_0_bresp = "00"
            report "AXI write returned an error"
            severity error;

            wait until rising_edge(test_rig_clk_out);

            S00_AXI_0_bready <= '0';

        end procedure;

        procedure axi_read(
            constant addr : in std_logic_vector(31 downto 0);
            variable data : out std_logic_vector(31 downto 0)
        ) is
        begin

            -- Put address on AR channel
            S00_AXI_0_araddr <= addr;
            S00_AXI_0_arvalid <= '1';

            -- Wait for address handshake
            while S00_AXI_0_arready = '0' loop
                wait until rising_edge(test_rig_clk_out);
            end loop;

            wait until rising_edge(test_rig_clk_out);

            S00_AXI_0_arvalid <= '0';

            -- Accept read response
            S00_AXI_0_rready <= '1';

            while S00_AXI_0_rvalid = '0' loop
                wait until rising_edge(test_rig_clk_out);
            end loop;

            data := S00_AXI_0_rdata;

            assert S00_AXI_0_rresp = "00"
            report "AXI read returned an error"
            severity error;

            wait until rising_edge(test_rig_clk_out);

            S00_AXI_0_rready <= '0';

        end procedure;

        variable read_data : std_logic_vector(31 downto 0);
        variable poll_count : natural := 0;
    begin
        ----------------------------------------------------------------
        -- Reset
        ----------------------------------------------------------------
        resetn <= '0';

        M_AXI_0_arready <= '0';
        M_AXI_0_awready <= '0';
        M_AXI_0_wready <= '0';

        wait for 100 ns;
        resetn <= '1';

        wait for 1000 ns;
        wait until rising_edge(test_rig_clk_out);
        wait until rising_edge(test_rig_clk_out);

        ----------------------------------------------------------------
        -- 1. Clear benchmark control register
        ----------------------------------------------------------------
        report "Writing 0 to C000_0014";
        axi_write(x"C0000014", x"00000000");

        wait for 100 ns;

        ----------------------------------------------------------------
        -- 2. Start benchmark
        ----------------------------------------------------------------
        report "Writing 1 to C000_0014";
        axi_write(x"C0000014", x"00000001");

        ----------------------------------------------------------------
        -- 3. Poll C000_0010 until done = 1
        ----------------------------------------------------------------
        report "Polling C000_0010 for completion";

        loop
            axi_read(x"C0000010", read_data);

            exit when read_data = x"00000001";

            poll_count := poll_count + 1;

            assert poll_count < 100000
            report "TIMEOUT: Benchmark did not complete"
            severity failure;
        end loop;

        report "Benchmark complete";

        ----------------------------------------------------------------
        -- 4. Read and report result registers
        ----------------------------------------------------------------
        axi_read(x"C000000C", read_data);
        report "C000_000C = " & to_hstring(to_bitvector(read_data));

        axi_read(x"C0000008", read_data);
        report "C000_0008 = " & to_hstring(to_bitvector(read_data));

        axi_read(x"C0000004", read_data);
        report "C000_0004 = " & to_hstring(to_bitvector(read_data));

        axi_read(x"C0000000", read_data);
        report "C000_0000 = " & to_hstring(to_bitvector(read_data));

        report "Benchmark test completed successfully.";

        wait;
    end process;

end Behavioral;
