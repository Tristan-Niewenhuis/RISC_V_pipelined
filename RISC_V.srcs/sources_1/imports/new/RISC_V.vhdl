library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_package.all;

entity RISC_V is
  Port(clk, reset : in std_logic;
       --fetch unit port
       f_M_AXI_ARID : out std_logic_vector(0 downto 0);
       f_M_AXI_ARADDR : out std_logic_vector(MEM_ADDR_BITS - 1 downto 0);
       f_M_AXI_ARLEN : out std_logic_vector(7 downto 0);
       f_M_AXI_ARSIZE : out std_logic_vector(2 downto 0);
       f_M_AXI_ARBURST : out std_logic_vector(1 downto 0);
       f_M_AXI_ARLOCK : out std_logic;
       f_M_AXI_ARCACHE : out std_logic_vector(3 downto 0);
       f_M_AXI_ARPROT : out std_logic_vector(2 downto 0);
       f_M_AXI_ARQOS : out std_logic_vector(3 downto 0);
       --M_AXI_ARUSER	: out std_logic_vector(C_M_AXI_ARUSER_WIDTH-1 downto 0); 
       f_M_AXI_ARVALID : out std_logic;
       f_M_AXI_ARREADY : in std_logic;
       -- AXI Read Data Channel
       f_M_AXI_RID : in std_logic_vector(0 downto 0);
       f_M_AXI_RDATA : in std_logic_vector(32 - 1 downto 0);
       f_M_AXI_RRESP : in std_logic_vector(1 downto 0);
       f_M_AXI_RLAST : in std_logic;
       --M_AXI_RUSER	: in std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0); 
       f_M_AXI_RVALID : in std_logic;
       f_M_AXI_RREADY : out std_logic;
       --load store unit ports            
       ls_M_AXI_ARID : out std_logic_vector(0 downto 0);
       ls_M_AXI_ARADDR : out std_logic_vector(MEM_ADDR_BITS - 1 downto 0);
       ls_M_AXI_ARLEN : out std_logic_vector(7 downto 0);
       ls_M_AXI_ARSIZE : out std_logic_vector(2 downto 0);
       ls_M_AXI_ARBURST : out std_logic_vector(1 downto 0);
       ls_M_AXI_ARLOCK : out std_logic;
       ls_M_AXI_ARCACHE : out std_logic_vector(3 downto 0);
       ls_M_AXI_ARPROT : out std_logic_vector(2 downto 0);
       ls_M_AXI_ARQOS : out std_logic_vector(3 downto 0);
       --M_AXI_ARUSER	: out std_logic_vector(C_M_AXI_ARUSER_WIDTH-1 downto 0); 
       ls_M_AXI_ARVALID : out std_logic;
       ls_M_AXI_ARREADY : in std_logic;
       -- AXI Read Data Channel
       ls_M_AXI_RID : in std_logic_vector(0 downto 0);
       ls_M_AXI_RDATA : in std_logic_vector(32 - 1 downto 0);
       ls_M_AXI_RRESP : in std_logic_vector(1 downto 0);
       ls_M_AXI_RLAST : in std_logic;
       --M_AXI_RUSER	: in std_logic_vector(C_M_AXI_RUSER_WIDTH-1 downto 0); 
       ls_M_AXI_RVALID : in std_logic;
       ls_M_AXI_RREADY : out std_logic;
       -- AXI Write Address Channel
       ls_M_AXI_AWID : out std_logic_vector(0 downto 0);
       ls_M_AXI_AWADDR : out std_logic_vector(MEM_ADDR_BITS - 1 downto 0);
       ls_M_AXI_AWLEN : out std_logic_vector(7 downto 0);
       ls_M_AXI_AWSIZE : out std_logic_vector(2 downto 0);
       ls_M_AXI_AWBURST : out std_logic_vector(1 downto 0);
       ls_M_AXI_AWLOCK : out std_logic;
       ls_M_AXI_AWCACHE : out std_logic_vector(3 downto 0);
       ls_M_AXI_AWPROT : out std_logic_vector(2 downto 0);
       ls_M_AXI_AWQOS : out std_logic_vector(3 downto 0);
       --M_AXI_AWUSER	: out std_logic_vector(C_M_AXI_AWUSER_WIDTH-1 downto 0); 
       ls_M_AXI_AWVALID : out std_logic;
       ls_M_AXI_AWREADY : in std_logic;
       -- AXI Write Data Channel
       ls_M_AXI_WDATA : out std_logic_vector(32 - 1 downto 0);
       ls_M_AXI_WSTRB : out std_logic_vector(32 / 8 - 1 downto 0);
       ls_M_AXI_WLAST : out std_logic;
       --M_AXI_WUSER	: out std_logic_vector(C_M_AXI_WUSER_WIDTH-1 downto 0); 
       ls_M_AXI_WVALID : out std_logic;
       ls_M_AXI_WREADY : in std_logic;
       -- AXI Write Response Channel
       ls_M_AXI_BID : in std_logic_vector(0 downto 0);
       ls_M_AXI_BRESP : in std_logic_vector(1 downto 0);
       --M_AXI_BUSER	: in std_logic_vector(C_M_AXI_BUSER_WIDTH-1 downto 0); 
       ls_M_AXI_BVALID : in std_logic;
       ls_M_AXI_BREADY : out std_logic);
end RISC_V;

architecture Behavioral of RISC_V is
  signal control_word : control_word_if_id;
  signal branch_cond, exeception, PC_inc : sl;
  signal fetch_done, start_fetch, execute, fetch_error, ls_error : sl;
  signal load_done, store_done, start_load, start_store : sl;
  signal load_inst, store_inst : sl;
  signal not_reset : sl;
  signal fetch_address, ls_address : slv(XLEN - 1 downto 0);
  signal instruction : slv(31 downto 0);
  signal load_data, store_data : slv(XLEN - 1 downto 0);
begin
  not_reset <= not reset;

  datapath : entity work.Datapath
    port map(
      clk => clk,
      reset => reset,
      branch_cond => branch_cond,
      fetch_addr_valid => open,
      fetch_addr_ready => '1',
      fetch_address => fetch_address,
      fetch_inst_valid => '1',
      fetch_inst_ready => open,
      inst => (others => '0'),
      ls_addr_valid => open,
      ls_addr_ready => '1',
      load_store_ctrl => open,
      ls_address => ls_address,
      store_data => store_data,
      ls_done_valid => '1',
      ls_done_ready => open,
      load_data => load_data
    );

  -- datapath : entity work.Datapath
  --   port map(
  --     clk => clk,
  --     reset => reset,
  --     branch_cond => branch_cond,
  --     fetch_addr_valid => fetch_addr_valid,
  --     fetch_addr_ready => fetch_addr_ready,
  --     fetch_address => fetch_address,
  --     fetch_inst_valid => fetch_inst_valid,
  --     fetch_inst_ready => fetch_inst_ready,
  --     inst => inst,
  --     ls_addr_valid => ls_addr_valid,
  --     ls_addr_ready => ls_addr_ready,
  --     load_store_ctrl => load_store_ctrl,
  --     ls_address => ls_address,
  --     store_data => store_data,
  --     ls_done_valid => ls_done_valid,
  --     ls_done_ready => ls_done_ready,
  --     load_data => load_data
  --   );

  Fetch : entity work.Fetch(implementation)
    GENERIC MAP(
      C_M_TARGET_SLAVE_BASE_ADDR => X"00000000",
      C_M_AXI_BURST_LEN => 1,
      C_M_AXI_ID_WIDTH => 1,
      C_M_AXI_ADDR_WIDTH => 32,
      C_M_AXI_DATA_WIDTH => 32,
      C_M_AXI_AWUSER_WIDTH => 0,
      C_M_AXI_ARUSER_WIDTH => 0,
      C_M_AXI_WUSER_WIDTH => 0,
      C_M_AXI_RUSER_WIDTH => 0,
      C_M_AXI_BUSER_WIDTH => 0
    )
    PORT MAP(
      read_addr_valid => start_fetch,
      read_address => fetch_address,
      Read_Done => fetch_done,
      read_data => instruction,
      Error => fetch_error,
      clk => clk,
      reset => reset,
      M_AXI_ARID => f_M_AXI_ARID,
      M_AXI_ARADDR => f_M_AXI_ARADDR,
      M_AXI_ARLEN => f_M_AXI_ARLEN,
      M_AXI_ARSIZE => f_M_AXI_ARSIZE,
      M_AXI_ARBURST => f_M_AXI_ARBURST,
      M_AXI_ARLOCK => f_M_AXI_ARLOCK,
      M_AXI_ARCACHE => f_M_AXI_ARCACHE,
      M_AXI_ARPROT => f_M_AXI_ARPROT,
      M_AXI_ARQOS => f_M_AXI_ARQOS,
      M_AXI_ARVALID => f_M_AXI_ARVALID,
      M_AXI_ARREADY => f_M_AXI_ARREADY,
      M_AXI_RID => f_M_AXI_RID,
      M_AXI_RDATA => f_M_AXI_RDATA,
      M_AXI_RRESP => f_M_AXI_RRESP,
      M_AXI_RLAST => f_M_AXI_RLAST,
      M_AXI_RVALID => f_M_AXI_RVALID,
      M_AXI_RREADY => f_M_AXI_RREADY
    );

  Load_Store : entity work.Load_Store(implementation)
    GENERIC MAP(
      C_M_TARGET_SLAVE_BASE_ADDR => X"00000000",
      C_M_AXI_BURST_LEN => 1,
      C_M_AXI_ID_WIDTH => 1,
      C_M_AXI_ADDR_WIDTH => 32,
      C_M_AXI_DATA_WIDTH => 32,
      C_M_AXI_AWUSER_WIDTH => 0,
      C_M_AXI_ARUSER_WIDTH => 0,
      C_M_AXI_WUSER_WIDTH => 0,
      C_M_AXI_RUSER_WIDTH => 0,
      C_M_AXI_BUSER_WIDTH => 0
    )
    PORT MAP(
      start_load => start_load,
      start_store => start_store,
      load_store_type => instruction(14 downto 12),
      address => ls_address,
      store_data => store_data,
      load_data_out => load_data,
      load_done => load_done,
      store_done => store_done,
      Error => ls_error,
      M_AXI_ACLK => clk,
      M_AXI_ARESETN => not_reset,
      M_AXI_ARID => ls_M_AXI_ARID,
      M_AXI_ARADDR => ls_M_AXI_ARADDR,
      M_AXI_ARLEN => ls_M_AXI_ARLEN,
      M_AXI_ARSIZE => ls_M_AXI_ARSIZE,
      M_AXI_ARBURST => ls_M_AXI_ARBURST,
      M_AXI_ARLOCK => ls_M_AXI_ARLOCK,
      M_AXI_ARCACHE => ls_M_AXI_ARCACHE,
      M_AXI_ARPROT => ls_M_AXI_ARPROT,
      M_AXI_ARQOS => ls_M_AXI_ARQOS,
      M_AXI_ARVALID => ls_M_AXI_ARVALID,
      M_AXI_ARREADY => ls_M_AXI_ARREADY,
      M_AXI_RID => ls_M_AXI_RID,
      M_AXI_RDATA => ls_M_AXI_RDATA,
      M_AXI_RRESP => ls_M_AXI_RRESP,
      M_AXI_RLAST => ls_M_AXI_RLAST,
      M_AXI_RVALID => ls_M_AXI_RVALID,
      M_AXI_RREADY => ls_M_AXI_RREADY,
      M_AXI_AWID => ls_M_AXI_AWID,
      M_AXI_AWADDR => ls_M_AXI_AWADDR,
      M_AXI_AWLEN => ls_M_AXI_AWLEN,
      M_AXI_AWSIZE => ls_M_AXI_AWSIZE,
      M_AXI_AWBURST => ls_M_AXI_AWBURST,
      M_AXI_AWLOCK => ls_M_AXI_AWLOCK,
      M_AXI_AWCACHE => ls_M_AXI_AWCACHE,
      M_AXI_AWPROT => ls_M_AXI_AWPROT,
      M_AXI_AWQOS => ls_M_AXI_AWQOS,
      M_AXI_AWVALID => ls_M_AXI_AWVALID,
      M_AXI_AWREADY => ls_M_AXI_AWREADY,
      M_AXI_WDATA => ls_M_AXI_WDATA,
      M_AXI_WSTRB => ls_M_AXI_WSTRB,
      M_AXI_WLAST => ls_M_AXI_WLAST,
      M_AXI_WVALID => ls_M_AXI_WVALID,
      M_AXI_WREADY => ls_M_AXI_WREADY,
      M_AXI_BID => ls_M_AXI_BID,
      M_AXI_BRESP => ls_M_AXI_BRESP,
      M_AXI_BVALID => ls_M_AXI_BVALID,
      M_AXI_BREADY => ls_M_AXI_BREADY
    );

end Behavioral;
