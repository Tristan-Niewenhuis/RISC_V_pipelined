library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_led is
    generic(
        C_S_AXI_DATA_WIDTH : integer := 32;
        C_S_AXI_ADDR_WIDTH : integer := 32
    );
    port(
        -- Global
        S_AXI_ACLK : in std_logic;
        S_AXI_ARESETN : in std_logic;
        -- AXI4-Lite Write Address
        S_AXI_AWADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
        S_AXI_AWVALID : in std_logic;
        S_AXI_AWREADY : out std_logic;
        -- AXI4-Lite Write Data
        S_AXI_WDATA : in std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
        S_AXI_WSTRB : in std_logic_vector((C_S_AXI_DATA_WIDTH / 8) - 1 downto 0);
        S_AXI_WVALID : in std_logic;
        S_AXI_WREADY : out std_logic;
        -- AXI4-Lite Write Response
        S_AXI_BRESP : out std_logic_vector(1 downto 0);
        S_AXI_BVALID : out std_logic;
        S_AXI_BREADY : in std_logic;
        -- AXI4-Lite Read Address
        S_AXI_ARADDR : in std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
        S_AXI_ARVALID : in std_logic;
        S_AXI_ARREADY : out std_logic;
        -- AXI4-Lite Read Data
        S_AXI_RDATA : out std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
        S_AXI_RRESP : out std_logic_vector(1 downto 0);
        S_AXI_RVALID : out std_logic;
        S_AXI_RREADY : in std_logic;
        -- LEDs
        LED : out std_logic_vector(15 downto 0)
    );
end entity axi_led;

architecture rtl of axi_led is

    constant LED_ADDR : std_logic_vector(31 downto 0) := x"DEADBEEF";

    signal led_reg : std_logic_vector(15 downto 0) := (others => '0');

    signal awready_reg : std_logic := '0';
    signal wready_reg : std_logic := '0';
    signal bvalid_reg : std_logic := '0';

    signal arready_reg : std_logic := '0';
    signal rvalid_reg : std_logic := '0';
    signal rdata_reg : std_logic_vector(31 downto 0) := (others => '0');

begin

    --------------------------------------------------------------------
    -- AXI outputs
    --------------------------------------------------------------------

    S_AXI_AWREADY <= awready_reg;
    S_AXI_WREADY <= wready_reg;

    S_AXI_BVALID <= bvalid_reg;
    S_AXI_BRESP <= "00"; -- OKAY

    S_AXI_ARREADY <= arready_reg;

    S_AXI_RVALID <= rvalid_reg;
    S_AXI_RRESP <= "00"; -- OKAY
    S_AXI_RDATA <= rdata_reg;
    LED <= led_reg;

    --------------------------------------------------------------------
    -- AXI slave logic
    --------------------------------------------------------------------

    process(S_AXI_ACLK)
    begin
        if rising_edge(S_AXI_ACLK) then

            if S_AXI_ARESETN = '0' then

                led_reg <= (others => '0');

                awready_reg <= '0';
                wready_reg <= '0';
                bvalid_reg <= '0';

                arready_reg <= '0';
                rvalid_reg <= '0';
                rdata_reg <= (others => '0');

            else

                --------------------------------------------------------
                -- Write transaction
                --------------------------------------------------------

                -- Accept write address
                if (S_AXI_AWVALID = '1') and (awready_reg = '0') then
                    awready_reg <= '1';
                else
                    awready_reg <= '0';
                end if;

                -- Accept write data
                if (S_AXI_WVALID = '1') and (wready_reg = '0') then
                    wready_reg <= '1';
                else
                    wready_reg <= '0';
                end if;

                -- Perform write when both address and data are accepted
                if (S_AXI_AWVALID = '1') and (S_AXI_WVALID = '1') then

                    if S_AXI_AWADDR = LED_ADDR then

                        -- Only update bytes enabled by WSTRB
                        if S_AXI_WSTRB(0) = '1' then
                            led_reg(7 downto 0) <= S_AXI_WDATA(7 downto 0);
                        end if;

                        if S_AXI_WSTRB(1) = '1' then
                            led_reg(15 downto 8) <= S_AXI_WDATA(15 downto 8);
                        end if;

                    end if;

                    -- Generate write response
                    bvalid_reg <= '1';

                end if;

                -- Complete write response
                if (bvalid_reg = '1') and (S_AXI_BREADY = '1') then
                    bvalid_reg <= '0';
                end if;

                --------------------------------------------------------
                -- Read transaction
                --------------------------------------------------------

                if (S_AXI_ARVALID = '1') and (arready_reg = '0') then

                    arready_reg <= '1';

                    if S_AXI_ARADDR = LED_ADDR then

                        -- Return LED register in lower 16 bits
                        rdata_reg <= x"0000" & led_reg;

                    else

                        -- Unknown address
                        rdata_reg <= (others => '0');

                    end if;

                    rvalid_reg <= '1';

                else
                    arready_reg <= '0';
                end if;

                -- Complete read
                if (rvalid_reg = '1') and (S_AXI_RREADY = '1') then
                    rvalid_reg <= '0';
                end if;

            end if;

        end if;
    end process;

end architecture rtl;
