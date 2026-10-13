library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RISC_V_tb is
end RISC_V_tb;

architecture Behavioral of RISC_V_tb is

    -- Clock / reset
    signal sys_clock : std_logic := '0';
    signal resetn    : std_logic := '0';

    -- AXI slave: read address channel
    signal S00_AXI_araddr  : std_logic_vector(31 downto 0) := (others => '0');
    signal S00_AXI_arburst : std_logic_vector(1 downto 0)  := "01";
    signal S00_AXI_arcache : std_logic_vector(3 downto 0)  := (others => '0');
    signal S00_AXI_arid    : std_logic_vector(0 to 0)      := "0";
    signal S00_AXI_arlen   : std_logic_vector(7 downto 0)  := (others => '0');
    signal S00_AXI_arlock  : std_logic_vector(0 to 0)      := "0";
    signal S00_AXI_arprot  : std_logic_vector(2 downto 0)  := (others => '0');
    signal S00_AXI_arqos   : std_logic_vector(3 downto 0)  := (others => '0');
    signal S00_AXI_arready : std_logic;
    signal S00_AXI_arsize  : std_logic_vector(2 downto 0)  := "010";
    signal S00_AXI_arvalid : std_logic := '0';

    -- AXI slave: write address channel
    signal S00_AXI_awaddr  : std_logic_vector(31 downto 0) := (others => '0');
    signal S00_AXI_awburst : std_logic_vector(1 downto 0)  := "01";
    signal S00_AXI_awcache : std_logic_vector(3 downto 0)  := (others => '0');
    signal S00_AXI_awid    : std_logic_vector(0 to 0)      := "0";
    signal S00_AXI_awlen   : std_logic_vector(7 downto 0)  := (others => '0');
    signal S00_AXI_awlock  : std_logic_vector(0 to 0)      := "0";
    signal S00_AXI_awprot  : std_logic_vector(2 downto 0)  := (others => '0');
    signal S00_AXI_awqos   : std_logic_vector(3 downto 0)  := (others => '0');
    signal S00_AXI_awready : std_logic;
    signal S00_AXI_awsize  : std_logic_vector(2 downto 0)  := "010";
    signal S00_AXI_awvalid : std_logic := '0';

    -- AXI slave: write response channel
    signal S00_AXI_bid     : std_logic_vector(0 to 0);
    signal S00_AXI_bready  : std_logic := '0';
    signal S00_AXI_bresp   : std_logic_vector(1 downto 0);
    signal S00_AXI_bvalid  : std_logic;

    -- AXI slave: read data channel
    signal S00_AXI_rdata   : std_logic_vector(31 downto 0);
    signal S00_AXI_rid     : std_logic_vector(0 to 0);
    signal S00_AXI_rlast   : std_logic;
    signal S00_AXI_rready  : std_logic := '0';
    signal S00_AXI_rresp   : std_logic_vector(1 downto 0);
    signal S00_AXI_rvalid  : std_logic;

    -- AXI slave: write data channel
    signal S00_AXI_wdata   : std_logic_vector(31 downto 0) := (others => '0');
    signal S00_AXI_wlast   : std_logic := '1';
    signal S00_AXI_wready  : std_logic;
    signal S00_AXI_wstrb   : std_logic_vector(3 downto 0)  := "1111";
    signal S00_AXI_wvalid  : std_logic := '0';

    -- Other wrapper ports
    signal clk_out2       : std_logic;
    signal locked         : std_logic;
    signal mem_hazard     : std_logic;
    signal pc_asserted_1  : std_logic;
    signal slow_clk_restn : std_logic_vector(0 to 0);
    signal status_led_0   : std_logic;

begin

    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------
    uut : entity work.TCM_axi_slave_wrapper
        port map(
            S00_AXI_araddr  => S00_AXI_araddr,
            S00_AXI_arburst => S00_AXI_arburst,
            S00_AXI_arcache => S00_AXI_arcache,
            S00_AXI_arid    => S00_AXI_arid,
            S00_AXI_arlen   => S00_AXI_arlen,
            S00_AXI_arlock  => S00_AXI_arlock,
            S00_AXI_arprot  => S00_AXI_arprot,
            S00_AXI_arqos   => S00_AXI_arqos,
            S00_AXI_arready => S00_AXI_arready,
            S00_AXI_arsize  => S00_AXI_arsize,
            S00_AXI_arvalid => S00_AXI_arvalid,

            S00_AXI_awaddr  => S00_AXI_awaddr,
            S00_AXI_awburst => S00_AXI_awburst,
            S00_AXI_awcache => S00_AXI_awcache,
            S00_AXI_awid    => S00_AXI_awid,
            S00_AXI_awlen   => S00_AXI_awlen,
            S00_AXI_awlock  => S00_AXI_awlock,
            S00_AXI_awprot  => S00_AXI_awprot,
            S00_AXI_awqos   => S00_AXI_awqos,
            S00_AXI_awready => S00_AXI_awready,
            S00_AXI_awsize  => S00_AXI_awsize,
            S00_AXI_awvalid => S00_AXI_awvalid,

            S00_AXI_bid     => S00_AXI_bid,
            S00_AXI_bready  => S00_AXI_bready,
            S00_AXI_bresp   => S00_AXI_bresp,
            S00_AXI_bvalid  => S00_AXI_bvalid,

            S00_AXI_rdata   => S00_AXI_rdata,
            S00_AXI_rid     => S00_AXI_rid,
            S00_AXI_rlast   => S00_AXI_rlast,
            S00_AXI_rready  => S00_AXI_rready,
            S00_AXI_rresp   => S00_AXI_rresp,
            S00_AXI_rvalid  => S00_AXI_rvalid,

            S00_AXI_wdata   => S00_AXI_wdata,
            S00_AXI_wlast   => S00_AXI_wlast,
            S00_AXI_wready  => S00_AXI_wready,
            S00_AXI_wstrb   => S00_AXI_wstrb,
            S00_AXI_wvalid  => S00_AXI_wvalid,

            clk_out2        => clk_out2,
            locked          => locked,
            mem_hazard      => mem_hazard,
            pc_asserted_1   => pc_asserted_1,
            resetn          => resetn,
            slow_clk_restn  => slow_clk_restn,
            status_led_0    => status_led_0,
            sys_clock       => sys_clock
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
            variable aw_done : boolean := false;
            variable w_done  : boolean := false;
        begin
            -- Drive AW and W channels together
            S00_AXI_awaddr  <= addr;
            S00_AXI_awvalid <= '1';
            S00_AXI_wdata   <= data;
            S00_AXI_wstrb   <= "1111";
            S00_AXI_wlast   <= '1';
            S00_AXI_wvalid  <= '1';
            S00_AXI_bready  <= '1';

            -- Each handshake completes on the clock edge where valid and ready are both '1'
            while not (aw_done and w_done) loop
                wait until rising_edge(clk_out2);
                if S00_AXI_awvalid = '1' and S00_AXI_awready = '1' then
                    aw_done := true;
                    S00_AXI_awvalid <= '0';
                end if;
                if S00_AXI_wvalid = '1' and S00_AXI_wready = '1' then
                    w_done := true;
                    S00_AXI_wvalid <= '0';
                end if;
            end loop;

            -- Wait for write response
            loop
                if S00_AXI_bvalid = '1' then
                    exit;
                end if;
                wait until rising_edge(clk_out2);
            end loop;

            assert S00_AXI_bresp = "00"
                report "AXI write returned an error"
                severity error;

            wait until rising_edge(clk_out2);
            S00_AXI_bready <= '0';
        end procedure;

        procedure axi_read(
            constant addr : in  std_logic_vector(31 downto 0);
            variable data : out std_logic_vector(31 downto 0)
        ) is
        begin
            -- Address phase
            S00_AXI_araddr  <= addr;
            S00_AXI_arvalid <= '1';
            S00_AXI_rready  <= '1';

            loop
                wait until rising_edge(clk_out2);
                exit when S00_AXI_arready = '1';
            end loop;
            S00_AXI_arvalid <= '0';

            -- Data phase
            loop
                if S00_AXI_rvalid = '1' then
                    exit;
                end if;
                wait until rising_edge(clk_out2);
            end loop;

            data := S00_AXI_rdata;

            assert S00_AXI_rresp = "00"
                report "AXI read returned an error"
                severity error;

            wait until rising_edge(clk_out2);
            S00_AXI_rready <= '0';
        end procedure;

        variable read_data  : std_logic_vector(31 downto 0);
        variable poll_count : natural := 0;
    begin
        ----------------------------------------------------------------
        -- Reset
        ----------------------------------------------------------------
        resetn <= '0';
        wait for 100 ns;
        resetn <= '1';
        wait for 1000 ns;

        if locked /= '1' then
            wait until locked = '1';
        end if;
        wait until rising_edge(clk_out2);
        wait until rising_edge(clk_out2);

        ----------------------------------------------------------------
        -- 1. Clear benchmark control register
        ----------------------------------------------------------------
        report "Writing 0 to C000_0014";
        axi_write(x"C0000014", x"00000000");

        ----------------------------------------------------------------
        -- 1.5. Mock writing program
        ----------------------------------------------------------------
        axi_write(x"00003FFF", x"DEADBEEF");
        axi_write(x"80003FFF", x"DEADBEE5");
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