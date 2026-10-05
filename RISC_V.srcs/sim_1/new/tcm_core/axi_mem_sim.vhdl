-- axi_mem_sim.vhdl
--
-- Behavioural AXI4 memory slave for testbench use.
--
-- Backed by a RAM array of SIZE_BYTES; AXI addresses in
-- [BASE_ADDR, BASE_ADDR+SIZE_BYTES) map to internal words
-- 0 .. SIZE_BYTES/4-1. Single outstanding transaction (no
-- pipelining); writes have priority over reads when both
-- AWVALID and ARVALID arrive in the same idle cycle.
--
-- Supports INCR burst reads and writes with byte-lane strobes.
-- AWSIZE / AWBURST / ARSIZE / ARBURST are accepted but not
-- enforced -- this is a sim model, callers are expected to drive
-- the standard "010 / 01" pattern that the v2 cache + AXI master
-- emit.
--
-- The mem_init port is an unconstrained array of (addr, data)
-- pairs; the caller assigns it as a constant and the slave seeds
-- the matching word indices at elaboration. Pairs whose addr
-- falls outside [BASE_ADDR, BASE_ADDR+SIZE_BYTES) are silently
-- ignored so callers can list addresses in any base they like.
--
-- Storage is a clocked process (allowed for memory / sim
-- testbench code per project VHDL rules).
--
-- Ported from v1 RISCV_pyeatt/memory_interfaces/testbenches/
-- axi_mem_sim.vhdl. Adaptations:
--   * mem_init constant generic added (was not in v1; v1 callers
--     loaded the array via signal forces or hierarchical aliases)
--   * BASE_ADDR generic typed as std_logic_vector for symmetry
--     with the rest of the v2 codebase
--
-- ============================================================
-- Engineering checkoff log
--   2026-05-08  L. Pyeatt   ported from v1 axi_mem_sim
--   2026-09-11  copied verbatim from Pinnacle_IP/RISCV_pyeatt_v2/
--               testbenches/ into this project for riscv_core_tb
-- ============================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package axi_mem_sim_pkg is
    type axi_mem_init_word_t is record
        addr : std_logic_vector(31 downto 0);
        data : std_logic_vector(31 downto 0);
    end record;

    type axi_mem_init_t is array(natural range <>) of axi_mem_init_word_t;

    constant AXI_MEM_INIT_NONE : axi_mem_init_t(1 to 0)
        := (others => (X"00000000", X"00000000"));
end package axi_mem_sim_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.axi_mem_sim_pkg.all;

entity axi_mem_sim is
    generic (
        SIZE_BYTES : integer                       := 4096;
        BASE_ADDR  : std_logic_vector(31 downto 0) := X"40000000";
        ID_WIDTH   : integer                       := 1;
        MEM_INIT   : axi_mem_init_t                := AXI_MEM_INIT_NONE;
        -- Wait states inserted after AR acceptance before the first
        -- read-data beat, modelling DDR/MIG fill latency.  Default 0
        -- preserves the original 1-cycle behaviour for existing TBs.
        READ_LATENCY : natural                     := 0
    );
    port (
        clk : in std_logic;
        rst : in std_logic;

        -- AXI4 Write Address Channel
        s_axi_awaddr  : in  std_logic_vector(31 downto 0);
        s_axi_awlen   : in  std_logic_vector(7 downto 0);
        s_axi_awsize  : in  std_logic_vector(2 downto 0);
        s_axi_awburst : in  std_logic_vector(1 downto 0);
        s_axi_awid    : in  std_logic_vector(ID_WIDTH-1 downto 0);
        s_axi_awvalid : in  std_logic;
        s_axi_awready : out std_logic;

        -- AXI4 Write Data Channel
        s_axi_wdata   : in  std_logic_vector(31 downto 0);
        s_axi_wstrb   : in  std_logic_vector(3 downto 0);
        s_axi_wlast   : in  std_logic;
        s_axi_wvalid  : in  std_logic;
        s_axi_wready  : out std_logic;

        -- AXI4 Write Response Channel
        s_axi_bid     : out std_logic_vector(ID_WIDTH-1 downto 0);
        s_axi_bresp   : out std_logic_vector(1 downto 0);
        s_axi_bvalid  : out std_logic;
        s_axi_bready  : in  std_logic;

        -- AXI4 Read Address Channel
        s_axi_araddr  : in  std_logic_vector(31 downto 0);
        s_axi_arlen   : in  std_logic_vector(7 downto 0);
        s_axi_arsize  : in  std_logic_vector(2 downto 0);
        s_axi_arburst : in  std_logic_vector(1 downto 0);
        s_axi_arid    : in  std_logic_vector(ID_WIDTH-1 downto 0);
        s_axi_arvalid : in  std_logic;
        s_axi_arready : out std_logic;

        -- AXI4 Read Data Channel
        s_axi_rid     : out std_logic_vector(ID_WIDTH-1 downto 0);
        s_axi_rdata   : out std_logic_vector(31 downto 0);
        s_axi_rresp   : out std_logic_vector(1 downto 0);
        s_axi_rlast   : out std_logic;
        s_axi_rvalid  : out std_logic;
        s_axi_rready  : in  std_logic
    );
end entity axi_mem_sim;

architecture sim of axi_mem_sim is

    constant NUM_WORDS : integer := SIZE_BYTES / 4;
    constant BASE_U    : unsigned(31 downto 0) := unsigned(BASE_ADDR);

    type mem_t is array(0 to NUM_WORDS-1) of std_logic_vector(31 downto 0);

    function init_mem return mem_t is
        variable r   : mem_t := (others => (others => '0'));
        variable au  : unsigned(31 downto 0);
        variable idx : integer;
    begin
        for k in MEM_INIT'range loop
            au := unsigned(MEM_INIT(k).addr);
            if au >= BASE_U
                and au < BASE_U + to_unsigned(SIZE_BYTES, 32) then
                idx := to_integer((au - BASE_U) srl 2);
                if idx < NUM_WORDS then
                    r(idx) := MEM_INIT(k).data;
                end if;
            end if;
        end loop;
        return r;
    end function;

    signal mem : mem_t := init_mem;

    type state_t is (S_IDLE, S_WRITE, S_WRESP, S_RWAIT, S_READ);
    signal state : state_t := S_IDLE;

    signal rd_wait : natural := 0;

    signal aw_addr : unsigned(31 downto 0);
    signal aw_len  : unsigned(7 downto 0);
    signal aw_id   : std_logic_vector(ID_WIDTH-1 downto 0);
    signal aw_cnt  : unsigned(7 downto 0);

    signal ar_addr : unsigned(31 downto 0);
    signal ar_len  : unsigned(7 downto 0);
    signal ar_id   : std_logic_vector(ID_WIDTH-1 downto 0);
    signal ar_cnt  : unsigned(7 downto 0);

    function word_index(a : unsigned(31 downto 0)) return integer is
    begin
        return to_integer((a - BASE_U) srl 2) mod NUM_WORDS;
    end function;

begin

    fsm : process(clk)
        variable idx : integer;
        variable wd  : std_logic_vector(31 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state         <= S_IDLE;
                s_axi_awready <= '0';
                s_axi_wready  <= '0';
                s_axi_bvalid  <= '0';
                s_axi_arready <= '0';
                s_axi_rvalid  <= '0';
                s_axi_rlast   <= '0';
            else
                -- Defaults
                s_axi_awready <= '0';
                s_axi_arready <= '0';

                -- Drop response/data channels once accepted
                if s_axi_bvalid = '1' and s_axi_bready = '1' then
                    s_axi_bvalid <= '0';
                end if;

                if s_axi_rvalid = '1' and s_axi_rready = '1' then
                    s_axi_rvalid <= '0';
                    s_axi_rlast  <= '0';
                end if;

                if state = S_IDLE then
                    s_axi_wready <= '0';
                    -- Write address has priority
                    if s_axi_awvalid = '1' then
                        s_axi_awready <= '1';
                        aw_addr <= unsigned(s_axi_awaddr);
                        aw_len  <= unsigned(s_axi_awlen);
                        aw_id   <= s_axi_awid;
                        aw_cnt  <= (others => '0');
                        s_axi_wready <= '1';
                        state <= S_WRITE;
                    elsif s_axi_arvalid = '1' then
                        s_axi_arready <= '1';
                        ar_addr <= unsigned(s_axi_araddr);
                        ar_len  <= unsigned(s_axi_arlen);
                        ar_id   <= s_axi_arid;
                        ar_cnt  <= (others => '0');
                        if READ_LATENCY = 0 then
                            state <= S_READ;
                        else
                            rd_wait <= READ_LATENCY;
                            state   <= S_RWAIT;
                        end if;
                    end if;

                elsif state = S_RWAIT then
                    -- DDR fill latency: stall before the first data beat.
                    if rd_wait > 1 then
                        rd_wait <= rd_wait - 1;
                    else
                        state <= S_READ;
                    end if;

                elsif state = S_WRITE then
                    s_axi_wready <= '1';
                    if s_axi_wvalid = '1' then
                        idx := word_index(aw_addr + (aw_cnt & "00"));
                        wd := mem(idx);
                        if s_axi_wstrb(0) = '1' then
                            wd(7  downto 0)  := s_axi_wdata(7  downto 0);
                        end if;
                        if s_axi_wstrb(1) = '1' then
                            wd(15 downto 8)  := s_axi_wdata(15 downto 8);
                        end if;
                        if s_axi_wstrb(2) = '1' then
                            wd(23 downto 16) := s_axi_wdata(23 downto 16);
                        end if;
                        if s_axi_wstrb(3) = '1' then
                            wd(31 downto 24) := s_axi_wdata(31 downto 24);
                        end if;
                        mem(idx) <= wd;
                        if s_axi_wlast = '1' then
                            s_axi_wready <= '0';
                            s_axi_bvalid <= '1';
                            s_axi_bresp  <= "00";
                            s_axi_bid    <= aw_id;
                            state <= S_WRESP;
                        else
                            aw_cnt <= aw_cnt + 1;
                        end if;
                    end if;

                elsif state = S_WRESP then
                    if s_axi_bvalid = '0' then
                        state <= S_IDLE;
                    end if;

                elsif state = S_READ then
                    if s_axi_rvalid = '0' then
                        idx := word_index(ar_addr + (ar_cnt & "00"));
                        s_axi_rdata  <= mem(idx);
                        s_axi_rvalid <= '1';
                        s_axi_rresp  <= "00";
                        s_axi_rid    <= ar_id;
                        if ar_cnt = ar_len then
                            s_axi_rlast <= '1';
                        else
                            s_axi_rlast <= '0';
                        end if;
                    elsif s_axi_rready = '1' then
                        if ar_cnt = ar_len then
                            s_axi_rvalid <= '0';
                            s_axi_rlast  <= '0';
                            state <= S_IDLE;
                        else
                            ar_cnt <= ar_cnt + 1;
                            idx := word_index(ar_addr + ((ar_cnt + 1) & "00"));
                            s_axi_rdata <= mem(idx);
                            s_axi_rresp <= "00";
                            s_axi_rid   <= ar_id;
                            if ar_cnt + 1 = ar_len then
                                s_axi_rlast <= '1';
                            else
                                s_axi_rlast <= '0';
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture sim;
