--------------------------------------------------------------------------------
-- RISC_V_TCM: pipelined RV32I core with on-chip tightly coupled memory
--
-- Same Datapath and Load_Store as RISC_V, but instruction and data
-- memory are tightly_coupled_memory instances inside the core instead
-- of Block Memory Generator IP in the block design.
--
-- Memory map
--   ITCM  0x00000000 .. ITCM_BYTES-1        code, and read-only data
--   DTCM  DTCM_BASE  .. DTCM_BASE+DTCM_BYTES-1
--   everything else  peripherals, through the AXI4-Lite master port
--   (the board puts AXI GPIO for the LEDs at 0x40000000 and for the
--   switches at 0x40010000, the addresses RISC_V decodes locally)
--
-- Peripheral accesses run from the MEM stage.  The EX-stage address,
-- formatted store data, and byte lanes are registered into MEM; while
-- the AXI transaction is outstanding, mem_stall holds IF through MEM
-- and these registers, and MEM/WB takes a bubble.  Stores to the ITCM
-- are dropped.
--
-- Port use
--   ITCM port A  instruction fetch (read only, edge set by USE_NEGEDGE)
--   ITCM port B  data loads from the ITCM region (rising edge)
--   DTCM port A  data loads (edge set by USE_NEGEDGE)
--   DTCM port B  data stores (rising edge in both modes)
--
-- USE_NEGEDGE=false: both TCMs latch their read address on the rising
--   edge at the end of the stage that computes it (pc_next for fetch,
--   the EX-stage address for loads).  This matches the timing RISC_V
--   expects from its block-design BRAM.
-- USE_NEGEDGE=true: the read ports latch registered addresses (pc, and
--   the EX address registered into MEM) on the falling edge.  Read data
--   reaches the same pipeline stage as before, so CPI is unchanged; the
--   PC and address-adder logic leaves the path into the BRAM.
--
-- TCM sizes must be powers of two, and DTCM_BASE must be a multiple of
-- DTCM_BYTES.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV_package.all;

entity RISC_V_TCM is
  generic(
    ITCM_BYTES : natural := 65536;
    ITCM_INIT_FILE : string := "";
    DTCM_BYTES : natural := 65536;
    DTCM_BASE : slv(31 downto 0) := x"10000000";
    DTCM_INIT_FILE : string := "";
    USE_NEGEDGE : boolean := false
  );
  port(
    clk, resetn : in std_logic;
    -- AXI4-Lite master for peripherals
    m_axi_awaddr : out std_logic_vector(31 downto 0);
    m_axi_awprot : out std_logic_vector(2 downto 0);
    m_axi_awvalid : out std_logic;
    m_axi_awready : in std_logic;
    m_axi_wdata : out std_logic_vector(31 downto 0);
    m_axi_wstrb : out std_logic_vector(3 downto 0);
    m_axi_wvalid : out std_logic;
    m_axi_wready : in std_logic;
    m_axi_bresp : in std_logic_vector(1 downto 0);
    m_axi_bvalid : in std_logic;
    m_axi_bready : out std_logic;
    m_axi_araddr : out std_logic_vector(31 downto 0);
    m_axi_arprot : out std_logic_vector(2 downto 0);
    m_axi_arvalid : out std_logic;
    m_axi_arready : in std_logic;
    m_axi_rdata : in std_logic_vector(31 downto 0);
    m_axi_rresp : in std_logic_vector(1 downto 0);
    m_axi_rvalid : in std_logic;
    m_axi_rready : out std_logic
  );
end RISC_V_TCM;

architecture Behavioral of RISC_V_TCM is
  constant ITCM_ADDR_BITS : integer := clog2(ITCM_BYTES);
  constant DTCM_ADDR_BITS : integer := clog2(DTCM_BYTES);

  signal reset : sl;

  -- datapath <-> Load_Store
  signal fetch_address : slv(ITCM_ADDR_BITS - 3 downto 0);
  signal inst : slv(31 downto 0);
  signal ls_ctrl, ls_valid : sl;
  signal store_type, load_type : slv(2 downto 0);
  signal ls_address : slv(31 downto 0);
  signal store_data, load_data : slv(XLEN - 1 downto 0);
  signal st_data : slv(31 downto 0);
  signal st_strb : slv(3 downto 0);
  signal mem_rdata : slv(31 downto 0);

  -- address decode (EX stage) and its MEM-stage copy
  signal in_itcm, in_dtcm : boolean;
  signal region, region_q : slv(1 downto 0);
  signal ls_address_q : slv(31 downto 0);

  -- peripheral access in MEM
  signal mem_stall, mem_advance : sl;
  signal periph, periph_q : slv(0 downto 0);
  signal is_store, is_store_q : slv(0 downto 0);
  signal st_data_q : slv(31 downto 0);
  signal st_strb_q : slv(3 downto 0);
  signal axi_done : sl;
  signal axi_rdata : slv(31 downto 0);

  -- TCM ports
  signal itcm_fetch_addr : slv(31 downto 0);
  signal itcm_ld_rdata : slv(31 downto 0);
  signal dtcm_ld_addr : slv(31 downto 0);
  signal dtcm_ld_rdata : slv(31 downto 0);
  signal dtcm_st_strb : slv(3 downto 0);
  signal dtcm_st_we : sl;
begin
  reset <= not resetn;

  datapath : entity work.Datapath
    port map(
      clk => clk,
      reset => reset,
      fetch_address => fetch_address,
      inst => inst,
      ls_ctrl => ls_ctrl,
      store_type => store_type,
      load_type => load_type,
      ls_address => ls_address,
      store_data => store_data,
      load_data => load_data,
      ls_valid => ls_valid,
      mem_hazard => mem_stall
    );

  Load_Store_inst : entity work.Load_Store
    generic map(LOCAL_IO => false)
    port map(
      clk => clk,
      reset => reset,
      load_store => ls_ctrl,
      store_type => store_type,
      load_type => load_type,
      ls_address_in => ls_address,
      store_data => store_data,
      load_data_out => load_data,
      ls_address_out => open,
      load_data_in => mem_rdata,
      store_data_out => st_data,
      write_strobe => open,
      store_strobe => st_strb,
      led_out => open,
      hold => mem_stall
    );

  ----------------------------------------------------------------------------
  -- Address decode
  ----------------------------------------------------------------------------
  in_itcm <= unsigned(ls_address(31 downto ITCM_ADDR_BITS)) = 0;
  in_dtcm <= ls_address(31 downto DTCM_ADDR_BITS) = DTCM_BASE(31 downto DTCM_ADDR_BITS);
  region <= "10" when in_dtcm else
            "01" when in_itcm else
            "00";

  -- EX-stage region and address, registered into the MEM stage and held
  -- while MEM is stalled
  mem_advance <= not mem_stall;

  region_reg : entity work.generic_register
    generic map(bits => 2)
    port map(clk => clk, reset => reset, enable => mem_advance, d => region, q => region_q);

  ls_address_reg : entity work.generic_register
    generic map(bits => 32)
    port map(clk => clk, reset => reset, enable => mem_advance, d => ls_address, q => ls_address_q);

  -- MEM-stage load data: DTCM, ITCM, or the peripheral read
  with region_q select mem_rdata <=
    dtcm_ld_rdata when "10",
    itcm_ld_rdata when "01",
    axi_rdata when others;

  ----------------------------------------------------------------------------
  -- Peripheral accesses (AXI4-Lite), run from MEM
  ----------------------------------------------------------------------------
  periph_reg : entity work.generic_register
    generic map(bits => 1)
    port map(clk => clk, reset => reset, enable => mem_advance, d => periph, q => periph_q);
  periph(0) <= '1' when ls_valid = '1' and not in_itcm and not in_dtcm else '0';

  is_store_reg : entity work.generic_register
    generic map(bits => 1)
    port map(clk => clk, reset => reset, enable => mem_advance, d => is_store, q => is_store_q);
  is_store(0) <= ls_ctrl;

  st_data_reg : entity work.generic_register
    generic map(bits => 32)
    port map(clk => clk, reset => reset, enable => mem_advance, d => st_data, q => st_data_q);

  st_strb_reg : entity work.generic_register
    generic map(bits => 4)
    port map(clk => clk, reset => reset, enable => mem_advance, d => st_strb, q => st_strb_q);

  mem_stall <= periph_q(0) and not axi_done;

  axi_master : entity work.axi_lite_master
    port map(
      clk => clk, reset => reset,
      start => periph_q(0), write => is_store_q(0), addr => ls_address_q,
      wdata => st_data_q, wstrb => st_strb_q, done => axi_done,
      rdata => axi_rdata, error => open,
      m_axi_awaddr => m_axi_awaddr, m_axi_awprot => m_axi_awprot,
      m_axi_awvalid => m_axi_awvalid, m_axi_awready => m_axi_awready,
      m_axi_wdata => m_axi_wdata, m_axi_wstrb => m_axi_wstrb,
      m_axi_wvalid => m_axi_wvalid, m_axi_wready => m_axi_wready,
      m_axi_bresp => m_axi_bresp, m_axi_bvalid => m_axi_bvalid,
      m_axi_bready => m_axi_bready,
      m_axi_araddr => m_axi_araddr, m_axi_arprot => m_axi_arprot,
      m_axi_arvalid => m_axi_arvalid, m_axi_arready => m_axi_arready,
      m_axi_rdata => m_axi_rdata, m_axi_rresp => m_axi_rresp,
      m_axi_rvalid => m_axi_rvalid, m_axi_rready => m_axi_rready
    );

  ----------------------------------------------------------------------------
  -- ITCM
  ----------------------------------------------------------------------------
  itcm_fetch_addr <= (31 downto ITCM_ADDR_BITS => '0') & fetch_address & "00";

  itcm : entity work.tightly_coupled_memory
    generic map(
      SIZE_BYTES => ITCM_BYTES,
      INIT_FILE => ITCM_INIT_FILE,
      READ_ONLY => true,
      PORT_B_WRITE => false,
      USE_NEGEDGE => USE_NEGEDGE
    )
    port map(
      clk => clk,
      addr => itcm_fetch_addr,
      wdata => (others => '0'),
      rdata => inst,
      we => '0',
      wstrb => "0000",
      ready => open,
      fault => open,
      dbg_addr => ls_address,
      dbg_wdata => (others => '0'),
      dbg_rdata => itcm_ld_rdata,
      dbg_we => '0',
      dbg_wstrb => "0000"
    );

  ----------------------------------------------------------------------------
  -- DTCM
  ----------------------------------------------------------------------------
  dtcm_ld_addr <= ls_address_q when USE_NEGEDGE else ls_address;
  dtcm_st_strb <= st_strb when in_dtcm else "0000";
  dtcm_st_we <= '1' when in_dtcm and ls_ctrl = '1' else '0';

  dtcm : entity work.tightly_coupled_memory
    generic map(
      SIZE_BYTES => DTCM_BYTES,
      INIT_FILE => DTCM_INIT_FILE,
      READ_ONLY => true, -- port A only loads; stores use port B
      PORT_B_WRITE => true,
      USE_NEGEDGE => USE_NEGEDGE
    )
    port map(
      clk => clk,
      addr => dtcm_ld_addr,
      wdata => (others => '0'),
      rdata => dtcm_ld_rdata,
      we => '0',
      wstrb => "0000",
      ready => open,
      fault => open,
      dbg_addr => ls_address,
      dbg_wdata => st_data,
      dbg_rdata => open,
      dbg_we => dtcm_st_we,
      dbg_wstrb => dtcm_st_strb
    );

end Behavioral;
