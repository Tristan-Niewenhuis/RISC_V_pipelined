library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_package.all;

entity RISC_V is
  Port(clk, reset : in std_logic;
       --fetch unit port
       i_addr : out std_logic_vector(I_BYTES_ADDR_BITS - 3 downto 0);
       i_data_in : in std_logic_vector(31 downto 0);
       --load store unit ports    
       d_addr : out std_logic_vector(D_BYTES_ADDR_BITS - 3 downto 0);
       d_data_in : in std_logic_vector(31 downto 0);
       d_data_out : out std_logic_vector(31 downto 0);
       d_strobe : out std_logic_vector(3 downto 0)
      );
end RISC_V;

architecture Behavioral of RISC_V is
  signal ls_ctrl : sl;
  signal store_type, load_type : slv(2 downto 0);
  signal ls_address : slv(31 downto 0);
  signal load_data, store_data : slv(XLEN - 1 downto 0);
begin
  datapath : entity work.Datapath
    port map(
      clk => clk,
      reset => reset,
      fetch_address => i_addr,
      inst => i_data_in,
      ls_ctrl => ls_ctrl,
      store_type => store_type,
      load_type => load_type,
      ls_address => ls_address,
      store_data => store_data,
      load_data => load_data
    );

  Load_Store_inst : entity work.Load_Store
    port map(
      clk => clk,
      reset => reset,
      load_store => ls_ctrl,
      store_type => store_type,
      load_type => load_type,
      ls_address_in => ls_address,
      store_data => store_data,
      load_data_out => load_data,
      --
      ls_address_out => d_addr,
      load_data_in => d_data_in,
      store_data_out => d_data_out,
      write_strobe => d_strobe
    );

end Behavioral;
