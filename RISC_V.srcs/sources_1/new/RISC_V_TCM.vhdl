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
--   0x40000000 LEDs (store), 0x40010000 switches (load), decoded in
--   Load_Store as in RISC_V.  These move to an AXI peripheral port in a
--   later change.
--   Stores outside the DTCM are dropped; loads outside both TCMs return
--   zero (except the switch register).
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
    ITCM_BYTES     : natural          := 65536;
    ITCM_INIT_FILE : string           := "";
    DTCM_BYTES     : natural          := 65536;
    DTCM_BASE      : slv(31 downto 0) := x"10000000";
    DTCM_INIT_FILE : string           := "";
    USE_NEGEDGE    : boolean          := false
  );
  port(
    clk, resetn : in  std_logic;
    sw          : in  std_logic_vector(15 downto 0);
    led         : out std_logic_vector(15 downto 0)
  );
end RISC_V_TCM;

architecture Behavioral of RISC_V_TCM is
  constant ITCM_ADDR_BITS : integer := clog2(ITCM_BYTES);
  constant DTCM_ADDR_BITS : integer := clog2(DTCM_BYTES);

  signal reset : sl;

  -- datapath <-> Load_Store
  signal fetch_address          : slv(ITCM_ADDR_BITS - 3 downto 0);
  signal inst                   : slv(31 downto 0);
  signal ls_ctrl                : sl;
  signal store_type, load_type  : slv(2 downto 0);
  signal ls_address             : slv(31 downto 0);
  signal store_data, load_data  : slv(XLEN - 1 downto 0);
  signal st_data                : slv(31 downto 0);
  signal st_strb                : slv(3 downto 0);
  signal mem_rdata              : slv(31 downto 0);

  -- address decode (EX stage) and its MEM-stage copy
  signal in_itcm, in_dtcm       : boolean;
  signal region, region_q       : slv(1 downto 0);
  signal ls_address_q           : slv(31 downto 0);

  -- TCM ports
  signal itcm_fetch_addr        : slv(31 downto 0);
  signal itcm_ld_rdata          : slv(31 downto 0);
  signal dtcm_ld_addr           : slv(31 downto 0);
  signal dtcm_ld_rdata          : slv(31 downto 0);
  signal dtcm_st_strb           : slv(3 downto 0);
  signal dtcm_st_we             : sl;
begin
  reset <= not resetn;

  datapath : entity work.Datapath
    generic map(
      I_ADDR_BITS  => ITCM_ADDR_BITS,
      BRAM_NEGEDGE => USE_NEGEDGE
    )
    port map(
      clk           => clk,
      reset         => reset,
      fetch_address => fetch_address,
      inst          => inst,
      ls_ctrl       => ls_ctrl,
      store_type    => store_type,
      load_type     => load_type,
      ls_address    => ls_address,
      store_data    => store_data,
      load_data     => load_data
    );

  Load_Store_inst : entity work.Load_Store
    port map(
      clk            => clk,
      reset          => reset,
      load_store     => ls_ctrl,
      store_type     => store_type,
      load_type      => load_type,
      ls_address_in  => ls_address,
      store_data     => store_data,
      load_data_out  => load_data,
      ls_address_out => open,
      load_data_in   => mem_rdata,
      store_data_out => st_data,
      write_strobe   => open,
      store_strobe   => st_strb,
      sw_in          => sw,
      led_out        => led
    );

  ----------------------------------------------------------------------------
  -- Address decode
  ----------------------------------------------------------------------------
  in_itcm <= unsigned(ls_address(31 downto ITCM_ADDR_BITS)) = 0;
  in_dtcm <= ls_address(31 downto DTCM_ADDR_BITS) = DTCM_BASE(31 downto DTCM_ADDR_BITS);
  region  <= "10" when in_dtcm else
             "01" when in_itcm else
             "00";

  -- EX-stage region and address, registered into the MEM stage
  region_reg : entity work.generic_register
    generic map(bits => 2)
    port map(clk => clk, reset => reset, enable => '1', d => region, q => region_q);

  ls_address_reg : entity work.generic_register
    generic map(bits => 32)
    port map(clk => clk, reset => reset, enable => '1', d => ls_address, q => ls_address_q);

  -- MEM-stage load data
  with region_q select mem_rdata <=
    dtcm_ld_rdata   when "10",
    itcm_ld_rdata   when "01",
    (others => '0') when others;

  ----------------------------------------------------------------------------
  -- ITCM
  ----------------------------------------------------------------------------
  itcm_fetch_addr <= (31 downto ITCM_ADDR_BITS => '0') & fetch_address & "00";

  itcm : entity work.tightly_coupled_memory
    generic map(
      SIZE_BYTES   => ITCM_BYTES,
      INIT_FILE    => ITCM_INIT_FILE,
      READ_ONLY    => true,
      PORT_B_WRITE => false,
      USE_NEGEDGE  => USE_NEGEDGE
    )
    port map(
      clk       => clk,
      addr      => itcm_fetch_addr,
      wdata     => (others => '0'),
      rdata     => inst,
      we        => '0',
      wstrb     => "0000",
      ready     => open,
      fault     => open,
      dbg_addr  => ls_address,
      dbg_wdata => (others => '0'),
      dbg_rdata => itcm_ld_rdata,
      dbg_we    => '0',
      dbg_wstrb => "0000"
    );

  ----------------------------------------------------------------------------
  -- DTCM
  ----------------------------------------------------------------------------
  dtcm_ld_addr <= ls_address_q when USE_NEGEDGE else ls_address;
  dtcm_st_strb <= st_strb when in_dtcm else "0000";
  dtcm_st_we   <= '1' when in_dtcm and ls_ctrl = '1' else '0';

  dtcm : entity work.tightly_coupled_memory
    generic map(
      SIZE_BYTES   => DTCM_BYTES,
      INIT_FILE    => DTCM_INIT_FILE,
      READ_ONLY    => true,   -- port A only loads; stores use port B
      PORT_B_WRITE => true,
      USE_NEGEDGE  => USE_NEGEDGE
    )
    port map(
      clk       => clk,
      addr      => dtcm_ld_addr,
      wdata     => (others => '0'),
      rdata     => dtcm_ld_rdata,
      we        => '0',
      wstrb     => "0000",
      ready     => open,
      fault     => open,
      dbg_addr  => ls_address,
      dbg_wdata => st_data,
      dbg_rdata => open,
      dbg_we    => dtcm_st_we,
      dbg_wstrb => dtcm_st_strb
    );

end Behavioral;
