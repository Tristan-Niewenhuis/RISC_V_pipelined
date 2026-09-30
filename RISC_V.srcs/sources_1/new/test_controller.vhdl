library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.RISCV_package.all;

entity test_controller is
    port(
        clk, resetn : in std_logic;
        CPU_resetn : out std_logic;
        -- AXI4-Lite Slave Interface from PC throught JTAG->AXI
        -- Write address channel
        S_AXI_AWADDR : in std_logic_vector(4 downto 0);
        S_AXI_AWVALID : in std_logic;
        S_AXI_AWREADY : out std_logic;
        -- Write data channel
        S_AXI_WDATA : in std_logic_vector(31 downto 0);
        S_AXI_WSTRB : in std_logic_vector(3 downto 0);
        S_AXI_WVALID : in std_logic;
        S_AXI_WREADY : out std_logic;
        -- Write response channel
        S_AXI_BRESP : out std_logic_vector(1 downto 0);
        S_AXI_BVALID : out std_logic;
        S_AXI_BREADY : in std_logic;
        -- Read address channel
        S_AXI_ARADDR : in std_logic_vector(4 downto 0);
        S_AXI_ARVALID : in std_logic;
        S_AXI_ARREADY : out std_logic;
        -- Read data channel
        S_AXI_RDATA : out std_logic_vector(31 downto 0);
        S_AXI_RRESP : out std_logic_vector(1 downto 0);
        S_AXI_RVALID : out std_logic;
        S_AXI_RREADY : in std_logic;
        -- Memory maped IO from RISC_V CPU
        riscv_d_addr : in std_logic_vector(D_BYTES_ADDR_BITS - 3 downto 0);
        riscv_d_data_in : in std_logic_vector(31 downto 0);
        riscv_d_strobe : in std_logic_vector(3 downto 0);
    );
end test_controller;

architecture Behavioral of test_controller is
    type state_t is (ACCEPTING, RESPONSE);
    --axi write
    signal w_cur_state, w_next_state_i, w_next_state_final : state_t;
    signal w_ACCEPTING_next, w_RESPONSE_next : state_t;

    signal awready, wready, bvalid : sl;
    signal axi_w_addr_trans, axi_w_data_trans, axi_b_resp_trans : sl;
    signal axi_w_address, axi_w_address_next : slv(4 downto 0);

    --axi read
    signal r_cur_state, r_next_state_i, r_next_state_final : state_t;
    signal r_ACCEPTING_next, r_RESPONSE_next : state_t;

    signal arready, rvalid : sl;
    signal axi_r_addr_trans, axi_r_data_trans : sl;
    signal axi_r_address, axi_r_address_next : slv(4 downto 0);

    --storage of variables
    signal cycle_lo, cycle_hi, instret_lo, instret_hi : slv(31 downto 0);
    signal done, resetn_reg : sl;
begin
    --AXI write intrface (only for reset)
    w_cur_state <= w_next_state_final when rising_edge(clk);
    w_next_state_final <= ACCEPTING when resetn = '0' else w_next_state_i;
    --next state
    with w_cur_state select w_next_state_i <=
        w_ACCEPTING_next when ACCEPTING,
        w_RESPONSE_next when RESPONSE;

    w_ACCEPTING_next <= RESPONSE when axi_w_data_trans = '1' else
                        ACCEPTING;
    w_RESPONSE_next <= ACCEPTING when axi_b_resp_trans = '1' else
                       RESPONSE;

    --AXI write outputs
    awready <= '1';
    wready <= '1';
    bvalid <= '1' when w_cur_state = RESPONSE else '0';
    S_AXI_AWREADY <= awready;
    S_AXI_WREADY <= wready;
    S_AXI_BVALID <= bvalid;
    S_AXI_BRESP <= "00";

    axi_w_address <= axi_w_address_next when rising_edge(clk);
    axi_w_address_next <= (others => '0') when resetn = '0' else
                          S_AXI_AWADDR when axi_w_addr_trans = '1' else
                          axi_w_address;

    axi_w_addr_trans <= S_AXI_AWVALID and awready;
    axi_w_data_trans <= S_AXI_WVALID and wready;
    axi_b_resp_trans <= bvalid and S_AXI_BREADY;

    --AXI read intrface
    r_cur_state <= r_next_state_final when rising_edge(clk);
    r_next_state_final <= ACCEPTING when resetn = '0' else r_next_state_i;
    --next state
    with r_cur_state select r_next_state_i <=
        r_ACCEPTING_next when ACCEPTING,
        r_RESPONSE_next when RESPONSE;

    r_ACCEPTING_next <= RESPONSE when axi_r_addr_trans = '1' else
                        ACCEPTING;
    r_RESPONSE_next <= ACCEPTING when axi_r_data_trans = '1' else
                       RESPONSE;

    --AXI read outputs
    arready <= '1';
    rvalid <= '1' when r_cur_state = RESPONSE else '0';
    S_AXI_ARREADY <= arready;
    S_AXI_RVALID <= rvalid;
    S_AXI_RRESP <= "00";
    with axi_r_address(4 downto 2) select S_AXI_RDATA <=
        cycle_lo when "000",
        cycle_hi when "001",
        instret_lo when "010",
        instret_hi when "011",
        ((31 downto 1 => '0') & done) when "100",
        ((31 downto 1 => '0') & resetn_reg) when others;

    axi_r_address <= axi_r_address_next when rising_edge(clk);
    axi_r_address_next <= (others => '0') when resetn = '0' else
                          S_AXI_ARADDR when axi_r_addr_trans = '1' else
                          axi_r_address;

    axi_r_addr_trans <= S_AXI_ARVALID and arready;
    axi_r_data_trans <= rvalid and S_AXI_RREADY;

    read_regs : process(clk) is
    begin
        if rising_edge(clk) then
            if (resetn = '0') then
                cycle_lo <= (others => '0');
                cycle_hi <= (others => '0');
                instret_lo <= (others => '0');
                instret_hi <= (others => '0');
                done <= '0';
                resetn_reg <= '1';
                CPU_resetn <= '1';
            else
                --axi write
                if (axi_w_address = "10100" and S_AXI_WSTRB(0) = '1') then
                    resetn_reg <= S_AXI_WDATA(0);
                end if;

                --bram interface
                if (riscv_d_strobe = "1111") then
                    case riscv_d_addr(4 downto 2) is
                        when "000" =>
                            cycle_lo <= riscv_d_data_in;
                        when "001" =>
                            cycle_hi <= riscv_d_data_in;
                        when "010" =>
                            instret_lo <= riscv_d_data_in;
                        when "011" =>
                            instret_hi <= riscv_d_data_in;
                        when "100" =>
                            done <= riscv_d_data_in(0);
                        when others =>
                            null;
                    end case;
                end if;

                CPU_resetn <= resetn and resetn_reg;
            end if;
        end if;
    end process;

end Behavioral;
