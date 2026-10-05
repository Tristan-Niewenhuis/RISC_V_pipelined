--------------------------------------------------------------------------------
-- RISC_V_TCM Instruction Regression                          riscv_tcm_tb
--
-- Self-checking instruction regression for RISC_V_TCM.  The program is
-- the riscv_core_tb (RISC_V_AXI) regression retargeted to the TCM memory
-- map, plus one check that loads ITCM word 0 through the data lane and
-- eight that use the AXI4-Lite peripheral port.  It
-- is listed in gen_tcm_regression_hex.py, which writes itcm.hex and
-- dtcm.hex.
--
-- x31 holds the DTCM base (0x10000000); every result is stored at an
-- offset from x31.  A passive monitor shadows every DTCM store by
-- watching the DTCM port B inputs inside the core (VHDL-2008 external
-- names), and the checks at the end compare the shadow against the
-- expected values.
--
-- Generics
--   USE_NEGEDGE     passed to RISC_V_TCM
--   INIT_DIR        directory holding itcm.hex and dtcm.hex, with a
--                   trailing '/'
--   PERIPH_LATENCY  read latency of the axi_mem_sim peripheral at
--                   0x40000000, in extra cycles
-- run_tcm_core_tb.sh runs both timing modes at latencies 0 and 3.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RISCV_package.all;

entity riscv_tcm_tb is
    generic (
        USE_NEGEDGE    : boolean := false;
        INIT_DIR       : string  := "./";
        -- extra cycles before the peripheral's first read-data beat
        PERIPH_LATENCY : natural := 0
    );
end entity riscv_tcm_tb;

architecture sim of riscv_tcm_tb is

    constant DATA_BASE : integer := 16#10000000#;

    signal clk    : sl := '0';
    signal resetn : sl := '0';
    signal stop   : boolean := false;

    -- AXI4-Lite peripheral bus, served by axi_mem_sim at 0x40000000
    signal awaddr, wdata, araddr, rdata : slv(31 downto 0);
    signal awprot, arprot : slv(2 downto 0);
    signal wstrb : slv(3 downto 0);
    signal bresp, rresp : slv(1 downto 0);
    signal awvalid, awready, wvalid, wready, bvalid, bready : sl;
    signal arvalid, arready, rvalid, rready : sl;

    -- Shadow of the first 1 KB of DTCM, filled by the store monitor
    type shadow_t is array (0 to 255) of slv(31 downto 0);
    shared variable shadow : shadow_t := (others => (others => '0'));

begin

    clk <= not clk after 5 ns when not stop else '0';

    uut : entity work.RISC_V_TCM
        generic map (
            ITCM_INIT_FILE => INIT_DIR & "itcm.hex",
            DTCM_INIT_FILE => INIT_DIR & "dtcm.hex",
            USE_NEGEDGE    => USE_NEGEDGE
        )
        port map (clk => clk, resetn => resetn,
                  m_axi_awaddr => awaddr, m_axi_awprot => awprot,
                  m_axi_awvalid => awvalid, m_axi_awready => awready,
                  m_axi_wdata => wdata, m_axi_wstrb => wstrb,
                  m_axi_wvalid => wvalid, m_axi_wready => wready,
                  m_axi_bresp => bresp, m_axi_bvalid => bvalid, m_axi_bready => bready,
                  m_axi_araddr => araddr, m_axi_arprot => arprot,
                  m_axi_arvalid => arvalid, m_axi_arready => arready,
                  m_axi_rdata => rdata, m_axi_rresp => rresp,
                  m_axi_rvalid => rvalid, m_axi_rready => rready);

    periph : entity work.axi_mem_sim
        generic map (SIZE_BYTES => 4096, BASE_ADDR => X"40000000", ID_WIDTH => 1,
                     READ_LATENCY => PERIPH_LATENCY)
        port map (
            clk => clk, rst => not resetn,
            s_axi_awaddr => awaddr, s_axi_awlen => X"00", s_axi_awsize => "010",
            s_axi_awburst => "01", s_axi_awid => "0", s_axi_awvalid => awvalid,
            s_axi_awready => awready,
            s_axi_wdata => wdata, s_axi_wstrb => wstrb, s_axi_wlast => '1',
            s_axi_wvalid => wvalid, s_axi_wready => wready,
            s_axi_bid => open, s_axi_bresp => bresp, s_axi_bvalid => bvalid,
            s_axi_bready => bready,
            s_axi_araddr => araddr, s_axi_arlen => X"00", s_axi_arsize => "010",
            s_axi_arburst => "01", s_axi_arid => "0", s_axi_arvalid => arvalid,
            s_axi_arready => arready,
            s_axi_rid => open, s_axi_rdata => rdata, s_axi_rresp => rresp,
            s_axi_rlast => open, s_axi_rvalid => rvalid, s_axi_rready => rready);

    -- Passive: copies every DTCM port B write into the shadow
    monitor : process
        alias st_we   is <<signal .riscv_tcm_tb.uut.dtcm_st_we   : sl>>;
        alias st_strb is <<signal .riscv_tcm_tb.uut.dtcm_st_strb : slv(3 downto 0)>>;
        alias st_addr is <<signal .riscv_tcm_tb.uut.ls_address   : slv(31 downto 0)>>;
        alias st_data is <<signal .riscv_tcm_tb.uut.st_data      : slv(31 downto 0)>>;
        variable idx : integer;
        variable w   : slv(31 downto 0);
    begin
        loop
            wait until rising_edge(clk);
            if st_we = '1' then
                idx := (to_integer(unsigned(st_addr)) - DATA_BASE) / 4;
                if idx >= 0 and idx <= shadow_t'high then
                    w := shadow(idx);
                    for b in 0 to 3 loop
                        if st_strb(b) = '1' then
                            w(8*b+7 downto 8*b) := st_data(8*b+7 downto 8*b);
                        end if;
                    end loop;
                    shadow(idx) := w;
                end if;
            end if;
        end loop;
    end process monitor;

    main : process
        variable passes : natural := 0;
        variable fails  : natural := 0;

        procedure chk(name : string; addr : integer; expect : slv(31 downto 0)) is
            variable got : slv(31 downto 0);
        begin
            got := shadow((addr - DATA_BASE) / 4);
            if got = expect then
                passes := passes + 1;
                report "PASS  " & name & "  = " & to_hstring(got);
            else
                fails := fails + 1;
                report "FAIL  " & name & "  = " & to_hstring(got)
                     & "  expected " & to_hstring(expect) severity warning;
            end if;
        end procedure chk;
    begin
        resetn <= '0';
        wait for 40 ns;
        wait until rising_edge(clk);
        resetn <= '1';

        wait for 20 us;

        report "==== RISC_V_TCM regression, USE_NEGEDGE="
             & boolean'image(USE_NEGEDGE) & ", PERIPH_LATENCY="
             & integer'image(PERIPH_LATENCY) & " ====";
        chk("sll   x3,x1,x2  ", 16#10000000#, X"00000F00");
        chk("srl   x4,x1,x2  ", 16#10000004#, X"0000000F");
        chk("addi  x5,x0,-2048", 16#10000008#, X"FFFFF800");
        chk("sra   x6,x5,x2  ", 16#1000000C#, X"FFFFFF80");
        chk("srl   x7,x5,x2  ", 16#10000010#, X"0FFFFF80");
        chk("slli  x8,x1,4   ", 16#10000014#, X"00000F00");
        chk("srli  x9,x5,4   ", 16#10000018#, X"0FFFFF80");
        chk("srai  x10,x5,4  ", 16#1000001C#, X"FFFFFF80");
        chk("slt   x11       ", 16#10000020#, X"00000001");
        chk("sltu  x12       ", 16#10000024#, X"00000000");
        chk("slti  x13       ", 16#10000028#, X"00000001");
        chk("sltiu x14       ", 16#1000002C#, X"00000001");
        chk("xor   x15       ", 16#10000030#, X"000000F4");
        chk("or    x16       ", 16#10000034#, X"000000F4");
        chk("and   x17       ", 16#10000038#, X"00000000");
        chk("xori  x18       ", 16#1000003C#, X"0000000F");
        chk("ori   x19       ", 16#10000040#, X"000000FF");
        chk("andi  x20       ", 16#10000044#, X"000000F0");
        chk("add   x21       ", 16#10000048#, X"000000F4");
        chk("sub   x22       ", 16#1000004C#, X"000000EC");
        chk("auipc x23 @0xAC ", 16#10000050#, X"000000AC");
        chk("jal   x24 link  ", 16#10000054#, X"000000B8");
        chk("jal   skipped   ", 16#10000058#, X"00000000");
        chk("jalr  x28 link  ", 16#1000005C#, X"000000CC");
        chk("lw    x29       ", 16#10000060#, X"81726354");
        chk("lb    +0        ", 16#10000064#, X"00000054");
        chk("lb    +1        ", 16#10000068#, X"00000063");
        chk("lb    +2        ", 16#1000006C#, X"00000072");
        chk("lb    +3        ", 16#10000070#, X"FFFFFF81");
        chk("lbu   +3        ", 16#10000074#, X"00000081");
        chk("lh    +0        ", 16#10000078#, X"00006354");
        chk("lh    +2        ", 16#1000007C#, X"FFFF8172");
        chk("lhu   +2        ", 16#10000080#, X"00008172");
        chk("sb    all 4 offs", 16#10000084#, X"AAAAAAAA");
        chk("sh    both halfs", 16#10000088#, X"00AB00AB");
        chk("backward loop   ", 16#1000008C#, X"0000000F");
        chk("all 6 branches  ", 16#10000090#, X"00000000");
        chk("lw from ITCM    ", 16#10000094#, X"10000FB7");
        chk("periph sw, lw   ", 16#10000098#, X"0000005A");
        chk("periph sb, lbu  ", 16#1000009C#, X"0000005A");
        chk("periph lw/add/sw", 16#100000A0#, X"0000005B");
        chk("DTCM sw during periph lw", 16#100000A4#, X"0000005A");
        chk("periph lw value ", 16#100000A8#, X"0000005A");
        chk("jal after periph sw, link", 16#100000AC#, X"00000218");
        chk("jal after periph sw, skip", 16#100000B0#, X"00000000");
        chk("periph byte lane 3", 16#100000B4#, X"5A000000");

        report "==== " & integer'image(passes) & " passed, "
             & integer'image(fails) & " failed ====";
        assert fails = 0
            report "RISC_V_TCM regression FAILED" severity failure;

        stop <= true;
        wait for 100 ns;
        std.env.stop;
    end process main;

end architecture sim;
