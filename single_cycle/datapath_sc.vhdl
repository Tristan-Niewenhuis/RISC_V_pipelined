library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.RISCV_package.all;

-- Single-cycle reference datapath.  Each instruction is fetched, decoded,
-- executed, and written back in one clock cycle, using the same decoder,
-- ALU, BTU, CSRs, and memories as the pipelined datapath.  The instruction
-- BRAM is addressed with pc_next, so the instruction is ready at the start
-- of its cycle.  A load takes two cycles, because the data BRAM read is
-- synchronous.  RISC_V_TCM_SC instantiates it.  It uses only new entity
-- names, so it cannot replace any part of the pipelined core.
entity Datapath_SC is
    port(
        clk, reset : in sl;
        --
        fetch_address : out slv(I_BYTES_ADDR_BITS - 3 downto 0);
        inst : in slv(31 downto 0);
        --
        ls_ctrl : out sl;
        store_type : out slv(2 downto 0);
        load_type : out slv(2 downto 0);
        ls_address : out slv(31 downto 0);
        store_data : out slv(XLEN - 1 downto 0);
        load_data : in slv(XLEN - 1 downto 0)
    );
end Datapath_SC;

architecture Behavioral of Datapath_SC is
    signal cw : control_word_if_id;
    signal pc, pc_next, pc_seq, pc_d : slv(I_BYTES_ADDR_BITS - 3 downto 0);
    signal pc_ctrl : slv(1 downto 0);
    signal pc_base, pc_sum : slv(I_BYTES_ADDR_BITS - 1 downto 0);
    signal a_out, b_out, a_alu, b_alu, alu_out, csr_d, csr_q, link, wb_d : slv(XLEN - 1 downto 0);
    signal wb_sel : slv(2 downto 0);
    signal BTU_out, branch_take, stall, rf_we, exec, csr_write : sl;
    signal load_wait, load_wait_next : slv(0 downto 0);

    -- Names the GHDL testbench probes in the pipelined datapath, kept so the
    -- same testbench runs this one.  The retiring instruction is the current
    -- one.
    signal mem_wb_pc : slv(I_BYTES_ADDR_BITS - 3 downto 0);
    signal mem_wb_cw : control_word_mem_wb;
    signal wb_d_in : slv(XLEN - 1 downto 0);
    signal raw_hazard, branch_hazard, wait_partial_forward : sl;
begin

    Instruction_Decoder : entity work.Instruction_Decoder(Behavioral)
        port map(
            branch_cond => '0',
            inst => inst,
            control_word_out => cw,
            exeception => open
        );

    --pc
    pc_reg : entity work.generic_register
        generic map(bits => I_BYTES_ADDR_BITS - 2)
        port map(clk => clk, reset => reset, enable => '1', d => pc_next, q => pc);

    --A load waits one cycle for the data BRAM
    pc_seq <= pc when stall = '1' else slv(unsigned(pc) + 1);
    pc_ctrl <= reset & branch_take;
    with pc_ctrl select pc_next <=
        pc_seq when "00",
        pc_d when "01",
        (others => '0') when others;

    fetch_address <= pc_next;

    --load wait
    load_wait_reg : entity work.generic_register
        generic map(bits => 1)
        port map(clk => clk, reset => reset, enable => '1', d => load_wait_next, q => load_wait);

    load_wait_next(0) <= stall;
    stall <= cw.is_load and not load_wait(0);

    --register file, without write-through: a register written by this
    --instruction must read its old value in this same cycle
    Regs : entity work.register_file_sc(Behavioral)
        generic map(word_len => XLEN, addr_bits => REGS_ADDR_BITS)
        port map(clk => clk,
                 reset => reset,
                 write_en => rf_we,
                 d_addr => cw.Dsel,
                 d_in => wb_d,
                 a_addr => cw.Asel_CSRuimm,
                 a_out => a_out,
                 b_addr => cw.Bsel,
                 b_out => b_out);

    rf_we <= cw.Dlen and not stall;

    --execute
    a_alu <= ((31 downto I_BYTES_ADDR_BITS => '0') & pc & "00") when cw.PCAsel = '1' else
             a_out;
    b_alu <= cw.IMM when cw.IMMBsel = '1' else
             b_out;

    ALU : entity work.ALU(Behavioral)
        port map(a => a_alu,
                 b => b_alu,
                 alu_out => alu_out,
                 func => cw.ALUFunc_CSRtype);

    BTU : entity work.BTU(Behavioral)
        port map(a => a_out,
                 b => b_out,
                 cond => cw.BRcond_LStype,
                 enable => cw.isBR,
                 BTU_out => BTU_out);

    branch_take <= cw.PCle or BTU_out;
    pc_base <= pc & "00" when cw.PCAsel = '1' else a_out(I_BYTES_ADDR_BITS - 1 downto 0);
    pc_sum <= slv(signed(pc_base) + signed(cw.IMM(I_BYTES_ADDR_BITS - 1 downto 0)));
    pc_d <= pc_sum(I_BYTES_ADDR_BITS - 1 downto 2);

    --memory
    --cw is decoded straight from the instruction BRAM, which keeps reading
    --while reset is held, so block stores during reset.
    ls_ctrl <= cw.is_store and not reset;
    store_type <= cw.BRcond_LStype;
    load_type <= cw.BRcond_LStype;
    ls_address <= slv(unsigned(a_out) + unsigned(cw.IMM));
    store_data <= b_out;

    --CSRs
    csr_d <= ((XLEN - 1 downto 5 => '0') & cw.Asel_CSRuimm) when cw.ALUFunc_CSRtype(3) = '1' else
             a_out;
    exec <= not stall;
    -- CSRRS and CSRRC (and their immediate forms) with rs1 = x0 or uimm = 0
    -- only read the CSR, so do not write it.
    csr_write <= cw.is_CSR when cw.ALUFunc_CSRtype(2 downto 1) = "01" or
                               cw.Asel_CSRuimm /= "00000" else
                 '0';

    CSR_regs : entity work.CSR_regs
        port map(
            clk => clk,
            reset => reset,
            d_sel => cw.CSR_reg,
            d_len => csr_write,
            d_in => csr_d,
            d_type => cw.ALUFunc_CSRtype(2 downto 1),
            q_sel => cw.CSR_reg,
            q_out => csr_q,
            exec => exec
        );

    --write-back
    link <= (31 downto I_BYTES_ADDR_BITS => '0') & slv(unsigned(pc) + 1) & "00";
    wb_sel <= cw.LoadDsel & cw.PCDsel & cw.is_CSR;
    with wb_sel select wb_d <=
        load_data when "100",
        link when "010",
        csr_q when "001",
        alu_out when others;

    --testbench names
    mem_wb_pc <= pc;
    mem_wb_cw <= (Dsel => cw.Dsel, Dlen => rf_we, PCDsel => cw.PCDsel, LoadDsel => cw.LoadDsel);
    wb_d_in <= wb_d;
    raw_hazard <= stall;
    branch_hazard <= branch_take;
    wait_partial_forward <= '0';

end Behavioral;
