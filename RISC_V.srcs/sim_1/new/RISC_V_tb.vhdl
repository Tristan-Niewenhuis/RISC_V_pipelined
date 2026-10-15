library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RISC_V_tb is
end RISC_V_tb;

architecture Behavioral of RISC_V_tb is

    -- Clock / reset
    signal sys_clock : std_logic := '0';
    signal reset : std_logic := '0';

    -- AXI slave: read address channel
    signal S00_AXI_araddr : std_logic_vector(31 downto 0) := (others => '0');
    signal S00_AXI_arburst : std_logic_vector(1 downto 0) := "01";
    signal S00_AXI_arcache : std_logic_vector(3 downto 0) := (others => '0');
    signal S00_AXI_arid : std_logic_vector(0 to 0) := "0";
    signal S00_AXI_arlen : std_logic_vector(7 downto 0) := (others => '0');
    signal S00_AXI_arlock : std_logic_vector(0 to 0) := "0";
    signal S00_AXI_arprot : std_logic_vector(2 downto 0) := (others => '0');
    signal S00_AXI_arqos : std_logic_vector(3 downto 0) := (others => '0');
    signal S00_AXI_arready : std_logic;
    signal S00_AXI_arsize : std_logic_vector(2 downto 0) := "010";
    signal S00_AXI_arvalid : std_logic := '0';

    -- AXI slave: write address channel
    signal S00_AXI_awaddr : std_logic_vector(31 downto 0) := (others => '0');
    signal S00_AXI_awburst : std_logic_vector(1 downto 0) := "01";
    signal S00_AXI_awcache : std_logic_vector(3 downto 0) := (others => '0');
    signal S00_AXI_awid : std_logic_vector(0 to 0) := "0";
    signal S00_AXI_awlen : std_logic_vector(7 downto 0) := (others => '0');
    signal S00_AXI_awlock : std_logic_vector(0 to 0) := "0";
    signal S00_AXI_awprot : std_logic_vector(2 downto 0) := (others => '0');
    signal S00_AXI_awqos : std_logic_vector(3 downto 0) := (others => '0');
    signal S00_AXI_awready : std_logic;
    signal S00_AXI_awsize : std_logic_vector(2 downto 0) := "010";
    signal S00_AXI_awvalid : std_logic := '0';

    -- AXI slave: write response channel
    signal S00_AXI_bid : std_logic_vector(0 to 0);
    signal S00_AXI_bready : std_logic := '0';
    signal S00_AXI_bresp : std_logic_vector(1 downto 0);
    signal S00_AXI_bvalid : std_logic;

    -- AXI slave: read data channel
    signal S00_AXI_rdata : std_logic_vector(31 downto 0);
    signal S00_AXI_rid : std_logic_vector(0 to 0);
    signal S00_AXI_rlast : std_logic;
    signal S00_AXI_rready : std_logic := '0';
    signal S00_AXI_rresp : std_logic_vector(1 downto 0);
    signal S00_AXI_rvalid : std_logic;

    -- AXI slave: write data channel
    signal S00_AXI_wdata : std_logic_vector(31 downto 0) := (others => '0');
    signal S00_AXI_wlast : std_logic := '1';
    signal S00_AXI_wready : std_logic;
    signal S00_AXI_wstrb : std_logic_vector(3 downto 0) := "1111";
    signal S00_AXI_wvalid : std_logic := '0';

    -- Other wrapper ports
    signal clk_out2 : std_logic;
    signal locked : std_logic;
    signal mem_hazard : std_logic;
    signal pc_asserted_1 : std_logic;
    signal slow_clk_restn : std_logic_vector(0 to 0);
    signal status_led_0 : std_logic;

begin

    --------------------------------------------------------------------
    -- DUT
    --------------------------------------------------------------------
    uut : entity work.TCM_axi_slave_wrapper
        port map(
            S00_AXI_araddr => S00_AXI_araddr,
            S00_AXI_arburst => S00_AXI_arburst,
            S00_AXI_arcache => S00_AXI_arcache,
            S00_AXI_arid => S00_AXI_arid,
            S00_AXI_arlen => S00_AXI_arlen,
            S00_AXI_arlock => S00_AXI_arlock,
            S00_AXI_arprot => S00_AXI_arprot,
            S00_AXI_arqos => S00_AXI_arqos,
            S00_AXI_arready => S00_AXI_arready,
            S00_AXI_arsize => S00_AXI_arsize,
            S00_AXI_arvalid => S00_AXI_arvalid,
            S00_AXI_awaddr => S00_AXI_awaddr,
            S00_AXI_awburst => S00_AXI_awburst,
            S00_AXI_awcache => S00_AXI_awcache,
            S00_AXI_awid => S00_AXI_awid,
            S00_AXI_awlen => S00_AXI_awlen,
            S00_AXI_awlock => S00_AXI_awlock,
            S00_AXI_awprot => S00_AXI_awprot,
            S00_AXI_awqos => S00_AXI_awqos,
            S00_AXI_awready => S00_AXI_awready,
            S00_AXI_awsize => S00_AXI_awsize,
            S00_AXI_awvalid => S00_AXI_awvalid,
            S00_AXI_bid => S00_AXI_bid,
            S00_AXI_bready => S00_AXI_bready,
            S00_AXI_bresp => S00_AXI_bresp,
            S00_AXI_bvalid => S00_AXI_bvalid,
            S00_AXI_rdata => S00_AXI_rdata,
            S00_AXI_rid => S00_AXI_rid,
            S00_AXI_rlast => S00_AXI_rlast,
            S00_AXI_rready => S00_AXI_rready,
            S00_AXI_rresp => S00_AXI_rresp,
            S00_AXI_rvalid => S00_AXI_rvalid,
            S00_AXI_wdata => S00_AXI_wdata,
            S00_AXI_wlast => S00_AXI_wlast,
            S00_AXI_wready => S00_AXI_wready,
            S00_AXI_wstrb => S00_AXI_wstrb,
            S00_AXI_wvalid => S00_AXI_wvalid,
            clk_out2 => clk_out2,
            locked => locked,
            mem_hazard => mem_hazard,
            pc_asserted_1 => pc_asserted_1,
            reset => reset,
            slow_clk_restn => slow_clk_restn,
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
            variable aw_done : boolean := false;
            variable w_done : boolean := false;
        begin
            wait until rising_edge(clk_out2);
            -- Drive AW and W channels together
            S00_AXI_awaddr <= addr;
            S00_AXI_awvalid <= '1';
            S00_AXI_wdata <= data;
            S00_AXI_wstrb <= "1111";
            S00_AXI_wlast <= '1';
            S00_AXI_wvalid <= '1';
            S00_AXI_bready <= '1';

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
            constant addr : in std_logic_vector(31 downto 0);
            variable data : out std_logic_vector(31 downto 0)
        ) is
        begin
            -- Address phase
            S00_AXI_araddr <= addr;
            S00_AXI_arvalid <= '1';
            S00_AXI_rready <= '1';

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

        variable read_data : std_logic_vector(31 downto 0);
        variable poll_count : natural := 0;
        type word_array_t is array (natural range <>) of std_logic_vector(31 downto 0);
        constant iram_program : word_array_t(0 to 99) := (
            0 => x"00020117",
            1 => x"FE010113",
            2 => x"00010297",
            3 => x"FF828293",
            4 => x"00010317",
            5 => x"01030313",
            6 => x"0062D863",
            7 => x"0002A023",
            8 => x"00428293",
            9 => x"FF5FF06F",
            10 => x"034000EF",
            11 => x"0000006F",
            12 => x"00008067",
            13 => x"00008067",
            14 => x"06400793",
            15 => x"00000013",
            16 => x"FFF78793",
            17 => x"FE079CE3",
            18 => x"0BE00513",
            19 => x"00008067",
            20 => x"F4250513",
            21 => x"00153513",
            22 => x"00008067",
            23 => x"FE010113",
            24 => x"00112E23",
            25 => x"038000EF",
            26 => x"FC9FF0EF",
            27 => x"00100513",
            28 => x"FC5FF0EF",
            29 => x"030000EF",
            30 => x"FC1FF0EF",
            31 => x"00A12623",
            32 => x"058000EF",
            33 => x"00C12503",
            34 => x"FC9FF0EF",
            35 => x"01C12083",
            36 => x"00153513",
            37 => x"02010113",
            38 => x"00008067",
            39 => x"00000513",
            40 => x"00008067",
            41 => x"C0002773",
            42 => x"000107B7",
            43 => x"00E7AC23",
            44 => x"C8002773",
            45 => x"000107B7",
            46 => x"00E7AE23",
            47 => x"C0202773",
            48 => x"000107B7",
            49 => x"00E7A423",
            50 => x"C8202773",
            51 => x"000107B7",
            52 => x"00E7A623",
            53 => x"00008067",
            54 => x"C00027F3",
            55 => x"00010637",
            56 => x"00F62823",
            57 => x"C80027F3",
            58 => x"00010737",
            59 => x"00F72A23",
            60 => x"C02027F3",
            61 => x"000106B7",
            62 => x"00F6A023",
            63 => x"C82025F3",
            64 => x"000107B7",
            65 => x"00B7A223",
            66 => x"000105B7",
            67 => x"01C5AE03",
            68 => x"000105B7",
            69 => x"0185A503",
            70 => x"01472703",
            71 => x"01062583",
            72 => x"00010637",
            73 => x"00C62303",
            74 => x"00010637",
            75 => x"00862603",
            76 => x"0047A783",
            77 => x"0006A683",
            78 => x"40A58533",
            79 => x"00A5B5B3",
            80 => x"000108B7",
            81 => x"41C70733",
            82 => x"FEA8A023",
            83 => x"40B70733",
            84 => x"40C68633",
            85 => x"00010837",
            86 => x"FEE82223",
            87 => x"00010537",
            88 => x"00C6B6B3",
            89 => x"406787B3",
            90 => x"FEC52423",
            91 => x"40D787B3",
            92 => x"000105B7",
            93 => x"FEF5A623",
            94 => x"00010737",
            95 => x"00100793",
            96 => x"FEF72823",
            97 => x"00000013",
            98 => x"00000013",
            99 => x"FF9FF06F"
        );
    begin
        ----------------------------------------------------------------
        -- Reset
        ----------------------------------------------------------------
        reset <= '1';
        wait for 100 ns;
        reset <= '0';

        if locked /= '1' then
            wait until locked = '1';
        end if;
        wait for 10000 ns;

        ----------------------------------------------------------------
        -- 1. Clear benchmark control register
        ----------------------------------------------------------------
        report "Writing 0 to C000_0014";
        axi_write(x"C0000014", x"00000000");

        ----------------------------------------------------------------
        -- 1.5. Load the 100-word benchmark program into IRAM.
        -- AXI addresses are byte addresses, so each 32-bit word advances
        -- the address by four bytes. CPU remains in reset during loading.
        ----------------------------------------------------------------
        for i in iram_program'range loop
            axi_write(
                std_logic_vector(to_unsigned(i * 4, 32)),
                iram_program(i)
            );
        end loop;

        report "Loaded " & integer'image(iram_program'length) & " words into IRAM.";

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
