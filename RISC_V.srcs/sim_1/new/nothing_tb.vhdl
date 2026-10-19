library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity nothing_tb is
end nothing_tb;

architecture Behavioral of nothing_tb is

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
        wait;
    end process;

end Behavioral;
