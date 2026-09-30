library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RISCV_package.all;

--IO
--FFE0 to FFFC

--DATA
--0000 to FFDC

entity io_interconnect is
    port(
        --bram interface from RISC_V CPU
        in_d_addr : in std_logic_vector(D_BYTES_ADDR_BITS - 3 downto 0);
        in_d_data_in : out std_logic_vector(31 downto 0);
        in_d_data_out : in std_logic_vector(31 downto 0);
        in_d_strobe : in std_logic_vector(3 downto 0);
        --bram out to data memeory
        out_d_addr : out std_logic_vector(D_BYTES_ADDR_BITS - 3 downto 0);
        out_d_data_in : in std_logic_vector(31 downto 0);
        out_d_data_out : out std_logic_vector(31 downto 0);
        out_d_strobe : out std_logic_vector(3 downto 0);
        --bram out to test_controller
        io_d_addr : out std_logic_vector(D_BYTES_ADDR_BITS - 3 downto 0);
        io_d_data_out : out std_logic_vector(31 downto 0);
        io_d_strobe : out std_logic_vector(3 downto 0);
    );
end io_interconnect;

architecture Behavioral of io_interconnect is
    signal d_me_msel : sl;
begin
    d_me_msel <= '1' when to_integer(unsigned(in_d_addr)) < D_MEM_SIZE else '0';

    out_d_addr <= in_d_addr;
    in_d_data_in <= out_d_data_in when d_me_msel = '1' else
                    (others => '0');
    out_d_data_out <= in_d_data_out;
    out_d_strobe <= in_d_strobe when d_me_msel = '1' else
                    (others => '0');

    io_d_addr <= in_d_addr;
    io_d_data_out <= in_d_data_out;
    io_d_strobe <= in_d_strobe when d_me_msel = '0' else
                   (others => '0');
end Behavioral;
