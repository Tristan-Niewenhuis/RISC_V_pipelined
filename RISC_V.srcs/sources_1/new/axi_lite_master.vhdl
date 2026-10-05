--------------------------------------------------------------------------------
-- axi_lite_master: single-beat AXI4-Lite master for peripheral accesses
--
-- The pipeline holds start, write, addr, wdata, and wstrb steady for the
-- load or store in MEM until done.  The master latches the request when
-- it leaves S_IDLE, runs one AXI4-Lite read or write, and pulses done for
-- one cycle.  rdata and error (a SLVERR or DECERR response) hold their
-- values from the response until the next transaction.
--
-- A write raises AWVALID and WVALID together and finishes when both
-- handshakes have happened, in either order.
--
-- State machine follows the project template: state_q, state_next (after
-- the reset mux), state_next_i (before it), one next-state signal per
-- state, and outputs decoded from state_q.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.RISCV_package.all;

entity axi_lite_master is
  port(
    clk, reset    : in  sl;
    -- request from the pipeline
    start         : in  sl;
    write         : in  sl;                 -- '1' store, '0' load
    addr          : in  slv(31 downto 0);
    wdata         : in  slv(31 downto 0);
    wstrb         : in  slv(3 downto 0);
    done          : out sl;
    rdata         : out slv(31 downto 0);
    error         : out sl;
    -- AXI4-Lite master
    m_axi_awaddr  : out slv(31 downto 0);
    m_axi_awprot  : out slv(2 downto 0);
    m_axi_awvalid : out sl;
    m_axi_awready : in  sl;
    m_axi_wdata   : out slv(31 downto 0);
    m_axi_wstrb   : out slv(3 downto 0);
    m_axi_wvalid  : out sl;
    m_axi_wready  : in  sl;
    m_axi_bresp   : in  slv(1 downto 0);
    m_axi_bvalid  : in  sl;
    m_axi_bready  : out sl;
    m_axi_araddr  : out slv(31 downto 0);
    m_axi_arprot  : out slv(2 downto 0);
    m_axi_arvalid : out sl;
    m_axi_arready : in  sl;
    m_axi_rdata   : in  slv(31 downto 0);
    m_axi_rresp   : in  slv(1 downto 0);
    m_axi_rvalid  : in  sl;
    m_axi_rready  : out sl
  );
end axi_lite_master;

architecture rtl of axi_lite_master is
  type state_t is (S_IDLE, S_AR, S_R, S_AW, S_B, S_DONE);
  constant INIT_STATE : state_t := S_IDLE;

  signal state_q, state_next, state_next_i : state_t;
  signal S_IDLE_next, S_AR_next, S_R_next, S_AW_next, S_B_next, S_DONE_next : state_t;

  signal in_idle, in_ar, in_r, in_aw, in_b : sl;
  signal request                : slv(1 downto 0);
  signal addr_q, wdata_q        : slv(31 downto 0);
  signal wstrb_q                : slv(3 downto 0);
  signal aw_done_q, aw_done_d   : slv(0 downto 0);
  signal w_done_q, w_done_d     : slv(0 downto 0);
  signal aw_ok, w_ok            : sl;
  signal r_handshake, b_handshake, resp_enable : sl;
  signal resp                   : slv(1 downto 0);
  signal error_d, error_q       : slv(0 downto 0);
begin

  ------------------------------------------------------------------------------
  -- State machine
  ------------------------------------------------------------------------------
  state_q    <= state_next when rising_edge(clk);
  state_next <= INIT_STATE when reset = '1' else state_next_i;

  with state_q select state_next_i <=
    S_IDLE_next when S_IDLE,
    S_AR_next   when S_AR,
    S_R_next    when S_R,
    S_AW_next   when S_AW,
    S_B_next    when S_B,
    S_DONE_next when S_DONE;

  request <= start & write;
  with request select S_IDLE_next <=
    S_AW   when "11",
    S_AR   when "10",
    S_IDLE when others;
  S_AR_next   <= S_R    when m_axi_arready = '1' else S_AR;
  S_R_next    <= S_DONE when m_axi_rvalid = '1' else S_R;
  S_AW_next   <= S_B    when aw_ok = '1' and w_ok = '1' else S_AW;
  S_B_next    <= S_DONE when m_axi_bvalid = '1' else S_B;
  S_DONE_next <= S_IDLE;

  in_idle <= '1' when state_q = S_IDLE else '0';
  in_ar   <= '1' when state_q = S_AR   else '0';
  in_r    <= '1' when state_q = S_R    else '0';
  in_aw   <= '1' when state_q = S_AW   else '0';
  in_b    <= '1' when state_q = S_B    else '0';
  done    <= '1' when state_q = S_DONE else '0';

  ------------------------------------------------------------------------------
  -- Request, latched while idle
  ------------------------------------------------------------------------------
  addr_reg : entity work.generic_register
    generic map(bits => 32)
    port map(clk => clk, reset => reset, enable => in_idle, d => addr, q => addr_q);

  wdata_reg : entity work.generic_register
    generic map(bits => 32)
    port map(clk => clk, reset => reset, enable => in_idle, d => wdata, q => wdata_q);

  wstrb_reg : entity work.generic_register
    generic map(bits => 4)
    port map(clk => clk, reset => reset, enable => in_idle, d => wstrb, q => wstrb_q);

  ------------------------------------------------------------------------------
  -- Write address and write data handshakes, which may finish in either order
  ------------------------------------------------------------------------------
  aw_done_reg : entity work.generic_register
    generic map(bits => 1)
    port map(clk => clk, reset => reset, enable => '1', d => aw_done_d, q => aw_done_q);
  aw_ok        <= aw_done_q(0) or m_axi_awready;
  aw_done_d(0) <= in_aw and aw_ok;

  w_done_reg : entity work.generic_register
    generic map(bits => 1)
    port map(clk => clk, reset => reset, enable => '1', d => w_done_d, q => w_done_q);
  w_ok        <= w_done_q(0) or m_axi_wready;
  w_done_d(0) <= in_aw and w_ok;

  ------------------------------------------------------------------------------
  -- Response: read data and error flag
  ------------------------------------------------------------------------------
  rdata_reg : entity work.generic_register
    generic map(bits => 32)
    port map(clk => clk, reset => reset, enable => r_handshake, d => m_axi_rdata, q => rdata);
  r_handshake <= in_r and m_axi_rvalid;

  error_reg : entity work.generic_register
    generic map(bits => 1)
    port map(clk => clk, reset => reset, enable => resp_enable, d => error_d, q => error_q);
  b_handshake <= in_b and m_axi_bvalid;
  resp_enable <= r_handshake or b_handshake;
  resp        <= m_axi_rresp when in_r = '1' else m_axi_bresp;
  error_d(0)  <= resp(1);   -- SLVERR or DECERR
  error       <= error_q(0);

  ------------------------------------------------------------------------------
  -- AXI outputs
  ------------------------------------------------------------------------------
  m_axi_araddr  <= addr_q;
  m_axi_arprot  <= "000";
  m_axi_arvalid <= in_ar;
  m_axi_rready  <= in_r;
  m_axi_awaddr  <= addr_q;
  m_axi_awprot  <= "000";
  m_axi_awvalid <= in_aw and not aw_done_q(0);
  m_axi_wdata   <= wdata_q;
  m_axi_wstrb   <= wstrb_q;
  m_axi_wvalid  <= in_aw and not w_done_q(0);
  m_axi_bready  <= in_b;
end rtl;
