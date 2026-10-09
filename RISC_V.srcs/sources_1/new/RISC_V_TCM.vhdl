library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_package.all;

entity RISC_V_TCM is
  Port(clk, resetn : in std_logic;
       --fetch unit port
       i_dgb_addr : in std_logic_vector(I_BYTES_ADDR_BITS - 3 downto 0);
       i_dgb_wdata : in std_logic_vector(31 downto 0);
       i_dgb_we : in std_logic;
       --load store unit ports    
       d_dgb_addr : in std_logic_vector(I_BYTES_ADDR_BITS - 3 downto 0);
       d_dgb_wdata : in std_logic_vector(31 downto 0);
       d_dgb_we : in std_logic;
       --io ports
       io_addr : out std_logic_vector(D_BYTES_ADDR_BITS - 3 downto 0);
       io_s_data : out std_logic_vector(31 downto 0);
       io_s_strobe : out std_logic_vector(3 downto 0);
       mem_hazard : in std_logic
      );
end RISC_V_TCM;

architecture Behavioral of RISC_V_TCM is
  signal ls_ctrl, reset : sl;
  signal store_type, load_type : slv(2 downto 0);
  signal ls_address : slv(31 downto 0);
  signal load_data, store_data : slv(XLEN - 1 downto 0);
  signal i_addr : slv(I_BYTES_ADDR_BITS - 3 downto 0);
  signal d_addr_v, d_addr_p, d_addr_p_1 : slv(D_BYTES_ADDR_BITS - 3 downto 0); --_v = virtual, _p = physical
  signal i_data, d_l_data_v, d_s_data_v : slv(31 downto 0);
  signal d_l_data_p, d_s_data_p, d_s_data_p1, d_s_data_p_f : slv(31 downto 0);
  signal d_s_strobe_v, d_s_strobe_p, d_s_strobe_p1, d_s_strobe_f : slv(3 downto 0);
  signal i_addr_f, i_dbg_addr_f, d_addr_p_f, d_dbg_addr_f : slv(31 downto 0);
  signal d_me_msel : sl;
begin
  reset <= not resetn;
  datapath : entity work.Datapath
    port map(
      clk => clk,
      reset => reset,
      fetch_address => i_addr,
      inst => i_data,
      ls_ctrl => ls_ctrl,
      store_type => store_type,
      load_type => load_type,
      ls_address => ls_address,
      store_data => store_data,
      load_data => load_data,
      mem_hazard => mem_hazard
    );

  Load_Store_inst : entity work.Load_Store
    port map(
      clk => clk,
      load_store => ls_ctrl,
      store_type => store_type,
      load_type => load_type,
      ls_address_in => ls_address,
      store_data => store_data,
      load_data_out => load_data,
      --
      ls_address_out => d_addr_v,
      load_data_in => d_l_data_v,
      store_data_out => d_s_data_v,
      store_strobe => d_s_strobe_v,
      mem_hazard => mem_hazard
    );

  d_me_msel <= '1' when to_integer(unsigned(d_addr_v)) < D_MEM_SIZE_LOGICAL else '0';

  d_addr_p <= d_addr_v;
  d_l_data_v <= d_l_data_p when d_me_msel = '1' else
                (others => '0');
  d_s_data_p <= d_s_data_v;
  d_s_strobe_p <= d_s_strobe_v when d_me_msel = '1' else
                  (others => '0');

  io_addr <= d_addr_v;
  io_s_data <= d_s_data_v;
  io_s_strobe <= d_s_strobe_v when d_me_msel = '0' else
                 (others => '0');

  NEGEDGE : if USE_NEGEDGE generate
  begin
    delay : process(clk) is
    begin
      if rising_edge(clk) then
        if reset = '1' then
          d_addr_p_1 <= (others => '0');
          d_s_data_p1 <= (others => '0');
          d_s_strobe_p1 <= (others => '0');
        else
          d_addr_p_1 <= d_addr_p;
          d_s_data_p1 <= d_s_data_p;
          d_s_strobe_p1 <= d_s_strobe_p;
        end if;
      end if;
    end process delay;
  end generate;

  ----------------------------------------------------------------------------
  -- ITCM
  ----------------------------------------------------------------------------
  i_addr_f <= (31 downto I_BYTES_ADDR_BITS => '0') & i_addr & "00"; --NEGEDGE accounted for in datapath
  i_dbg_addr_f <= (31 downto I_BYTES_ADDR_BITS => '0') & i_dgb_addr & "00";

  itcm : entity work.tightly_coupled_memory
    generic map(
      SIZE_BYTES => I_MEM_BYTES_REAL,
      INIT_FILE => I_MEM_INIT_FILE,
      READ_ONLY => true,
      PORT_B_WRITE => true,
      USE_NEGEDGE => USE_NEGEDGE
    )
    port map(
      clk => clk,
      addr => i_addr_f,
      wdata => (others => '0'),
      rdata => i_data,
      we => '0',
      wstrb => "0000",
      ready => open,
      fault => open,
      dbg_addr => i_dbg_addr_f,
      dbg_wdata => i_dgb_wdata,
      dbg_rdata => open,
      dbg_we => i_dgb_we,
      dbg_wstrb => "1111"
    );

  ----------------------------------------------------------------------------
  -- DTCM
  ----------------------------------------------------------------------------
  d_addr_p_f <= (31 downto D_BYTES_ADDR_BITS => '0') & d_addr_p_1 & "00" when USE_NEGEDGE else
                (31 downto D_BYTES_ADDR_BITS => '0') & d_addr_p & "00";
  d_s_data_p_f <= d_s_data_p1 when USE_NEGEDGE else d_s_data_p;
  d_s_strobe_f <= d_s_strobe_p1 when USE_NEGEDGE else d_s_strobe_p;
  d_dbg_addr_f <= (31 downto D_BYTES_ADDR_BITS => '0') & d_dgb_addr & "00";

  dtcm : entity work.tightly_coupled_memory
    generic map(
      SIZE_BYTES => D_MEM_BYTES_REAL,
      INIT_FILE => D_MEM_INIT_FILE,
      READ_ONLY => true,
      PORT_B_WRITE => true,
      USE_NEGEDGE => USE_NEGEDGE
    )
    port map(
      clk => clk,
      addr => d_addr_p_f,
      wdata => d_s_data_p_f,
      rdata => d_l_data_p,
      we => '1',
      wstrb => d_s_strobe_f,
      ready => open,
      fault => open,
      dbg_addr => d_dbg_addr_f,
      dbg_wdata => d_dgb_wdata,
      dbg_rdata => open,
      dbg_we => d_dgb_we,
      dbg_wstrb => "1111"
    );

end Behavioral;
