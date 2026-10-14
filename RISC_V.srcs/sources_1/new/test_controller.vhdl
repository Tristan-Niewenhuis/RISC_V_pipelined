library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.RISCV_package.all;

entity test_controller is
    port(
        clk, resetn : in std_logic;
        CPU_resetn : out std_logic := '0';
        status_led : out std_logic := '0';
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
        mem_hazard : out std_logic
    );
end test_controller;

architecture Behavioral of test_controller is
    type state_t is (ACCEPTING, RESPONSE);
    --axi write
    signal aw_captured : std_logic := '0';
    signal w_captured : std_logic := '0';
    signal bvalid_reg : std_logic := '0';

    signal awaddr_reg : std_logic_vector(4 downto 0) := (others => '0');
    signal wdata_reg : std_logic_vector(31 downto 0) := (others => '0');
    signal wstrb_reg : std_logic_vector(3 downto 0) := (others => '0');

    signal awready_i : std_logic;
    signal wready_i : std_logic;

    signal write_commit, write_commit_reg : std_logic;

    --axi read
    signal r_cur_state, r_next_state_i, r_next_state_final : state_t;
    signal r_ACCEPTING_next, r_RESPONSE_next : state_t;

    signal arready, rvalid : sl;
    signal axi_r_addr_trans, axi_r_data_trans : sl;
    signal axi_r_address, axi_r_address_next : slv(4 downto 0);

    --pipeline registers
    signal riscv_d_data_in_1 : std_logic_vector(31 downto 0);
    signal riscv_d_addr_1 : std_logic_vector(D_BYTES_ADDR_BITS - 3 downto 0);
    signal riscv_d_strobe_1 : std_logic_vector(3 downto 0);

    --storage of variables
    signal cycle_lo, cycle_hi, instret_lo, instret_hi : slv(31 downto 0);
    signal done, resetn_reg : sl;

begin

    awready_i <= '1' when resetn = '1' and aw_captured = '0' and bvalid_reg = '0' else
                 '0';

    wready_i <= '1' when resetn = '1' and w_captured = '0' and bvalid_reg = '0' else
                '0';

    S_AXI_AWREADY <= awready_i;
    S_AXI_WREADY <= wready_i;

    S_AXI_BVALID <= bvalid_reg;
    S_AXI_BRESP <= "00"; -- OKAY

    -- Commit once both current/prior channel transfers are available.
    write_commit <= '1' when bvalid_reg = '0' and (aw_captured = '1' or (S_AXI_AWVALID = '1' and awready_i = '1')) and (w_captured = '1' or (S_AXI_WVALID = '1' and wready_i = '1')) else
                    '0';

    axi_write_proc : process(clk)
    begin
        if rising_edge(clk) then
            if resetn = '0' then
                aw_captured <= '0';
                w_captured <= '0';
                bvalid_reg <= '0';

                awaddr_reg <= (others => '0');
                wdata_reg <= (others => '0');
                wstrb_reg <= (others => '0');
                write_commit_reg <= '0';

            else
                -- Capture address independently.
                if S_AXI_AWVALID = '1' and awready_i = '1' then
                    awaddr_reg <= S_AXI_AWADDR;
                    aw_captured <= '1';
                end if;

                -- Capture data and byte strobes independently.
                if S_AXI_WVALID = '1' and wready_i = '1' then
                    wdata_reg <= S_AXI_WDATA;
                    wstrb_reg <= S_AXI_WSTRB;
                    w_captured <= '1';
                end if;

                -- Issue the response once the write is committed.
                if write_commit = '1' then
                    bvalid_reg <= '1';
                elsif bvalid_reg = '1' and S_AXI_BREADY = '1' then
                    bvalid_reg <= '0';
                    aw_captured <= '0';
                    w_captured <= '0';
                end if;
            end if;
            write_commit_reg <= write_commit;
        end if;
    end process;

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

    --Pipeline CPU inputs and mem_hazard logic
    pipeline : process(clk) is
    begin
        if rising_edge(clk) then
            if (resetn = '0') then
                riscv_d_data_in_1 <= (others => '0');
                riscv_d_addr_1 <= (others => '0');
                riscv_d_strobe_1 <= (others => '0');
            else
                riscv_d_data_in_1 <= riscv_d_data_in;
                riscv_d_addr_1 <= riscv_d_addr;
                riscv_d_strobe_1 <= riscv_d_strobe;
            end if;
        end if;
    end process pipeline;

    --mem_hazard <= riscv_d_strobe_1 = "1111";

    --Registers
    read_regs : process(clk) is
    begin
        if rising_edge(clk) then
            if (resetn = '0') then
                cycle_lo <= (others => '0');
                cycle_hi <= X"12349876"; --test data (others => '0'); 
                instret_lo <= (others => '0');
                instret_hi <= (others => '0');
                done <= '0';
                resetn_reg <= '0';
            else
                --axi write
                if (write_commit_reg = '1' and awaddr_reg = "10100" and wstrb_reg(0) = '1') then
                    resetn_reg <= wdata_reg(0);
                end if;
            end if;

            --bram interface
            if (riscv_d_strobe_1 = "1111") then
                case riscv_d_addr_1(2 downto 0) is
                    when "000" =>
                        cycle_lo <= riscv_d_data_in_1;
                    when "001" =>
                        cycle_hi <= riscv_d_data_in_1;
                    when "010" =>
                        instret_lo <= riscv_d_data_in_1;
                    when "011" =>
                        instret_hi <= riscv_d_data_in_1;
                    when "100" =>
                        done <= riscv_d_data_in_1(0);
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    CPU_resetn <= resetn and resetn_reg;

    status_led <= resetn_reg;

end Behavioral;
