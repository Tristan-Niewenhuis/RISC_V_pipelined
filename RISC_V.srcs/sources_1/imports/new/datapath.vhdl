library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.RISCV_package.all;

entity Datapath is
    port(
        clk, reset : in sl;
        branch_cond : out sl;
        --
        fetch_addr_valid : out sl;
        fetch_addr_ready : in sl;
        fetch_address : out slv(XLEN - 1 downto 0);
        fetch_inst_valid : in sl;
        fetch_inst_ready : out sl;
        inst : in slv(31 downto 0);
        --
        ls_addr_valid : out sl;
        ls_addr_ready : in sl;
        load_store_ctrl : out sl;
        ls_type : out slv(2 downto 0);
        ls_address : out slv(XLEN - 1 downto 0);
        store_data : out slv(XLEN - 1 downto 0);
        ls_done_valid : in sl;
        ls_done_ready : out sl;
        load_data : in slv(XLEN - 1 downto 0)
    );
end Datapath;

architecture Behavioral of Datapath is
    signal d_in, a_out, b_out, a_bus, b_bus, pc, alu_out, id_ex_a, id_ex_b, ex_mem_alu_out, ex_mem_store_data, mem_wb_load_data, mem_wb_alu_out : slv(XLEN - 1 downto 0);
    signal if_id_pc, id_ex_pc, pc_d : slv(29 downto 0);
    signal BTU_out, pc_latch, pc_incr : sl;

    signal fetch_addr_valid_i, fetch_inst_ready_i, ls_addr_valid_i, ls_done_ready_i : sl;

    signal cw_decoded : control_word_if_id;
    signal if_id_cw : control_word_if_id;
    signal id_ex_cw : control_word_id_ex;
    signal ex_mem_cw : control_word_ex_mem;
    signal mem_wb_cw : control_word_mem_wb;

    signal fetch_hazard, ls_hazard : sl;
    signal if_id_stall, id_ex_stall, ex_mem_stall, mem_wb_stall : sl;
    signal if_id_nop, id_ex_nop, ex_mem_nop, mem_wb_nop : sl;
    signal id_ex_a_hazard, id_ex_b_hazard, ex_mem_a_hazard, ex_mem_b_hazard, raw_hazard : sl;
    signal branch_hazard, branch_correct, branch_take : sl;
begin

    branch_correct <= '1' when pc_d = if_id_pc else '0';
    branch_take <= id_ex_cw.PCle or BTU_out;

    pc_d <= slv(signed(id_ex_pc) + signed(id_ex_cw.IMM(31 downto 2))); --unsigned or signed add, doesn't matter. same logic under the hood
    pc_latch <= branch_take and not branch_correct;
    pc_incr <= if_id_stall;
    Program_Counter : entity work.generic_counter(Behavioral)
        generic map(bits => XLEN - 2)
        port map(clk => clk,
                 reset => reset,
                 latch => pc_latch,
                 enable => pc_incr,
                 d => pc_d,
                 q => pc(31 downto 2));
    pc(1 downto 0) <= "00"; --hard set last 2 bits of pc to 00

    fetch_addr_valid_i <= '1';
    fetch_addr_valid <= fetch_addr_valid_i;
    fetch_address <= pc;

    fetch_inst_ready_i <= not ls_hazard;
    fetch_inst_ready <= fetch_inst_ready_i;

    fetch_hazard <= (fetch_addr_valid_i and not fetch_addr_ready) or (fetch_inst_ready_i and not fetch_inst_valid);

    Instruction_Decoder : entity work.Instruction_Decoder(Behavioral)
        port map(
            branch_cond => '0', --TODO
            inst => inst,
            control_word_out => cw_decoded,
            exeception => open --TODO
        );

    IF_ID_proc : process(clk) is
    begin
        if rising_edge(clk) then
            if (reset = '1' or if_id_nop = '1') then
                if_id_pc <= (others => '0');
                if_id_cw <= CONTROL_WORD_IF_ID_NOP;
            else
                if (if_id_stall = '0') then
                    if_id_pc <= pc(31 downto 2);

                    if_id_cw <= cw_decoded;
                end if;
            end if;
        end if;
    end process;

    d_in <= mem_wb_load_data when mem_wb_cw.LoadDsel = '1' else
            slv(unsigned(pc) + 4) when mem_wb_cw.PCDsel = '1' else
            mem_wb_alu_out;

    Regs : entity work.generic_register_file(Behavioral)
        generic map(word_len => XLEN, addr_bits => REGS_ADDR_BITS)
        port map(clk => clk,
                 reset => reset,
                 write_en => mem_wb_cw.Dlen,
                 d_addr => mem_wb_cw.Dsel,
                 d_in => d_in,
                 a_addr => if_id_cw.Asel,
                 a_out => a_out,
                 b_addr => if_id_cw.Bsel,
                 b_out => b_out);

    ID_EX_proc : process(clk) is
    begin
        if rising_edge(clk) then
            if (reset = '1' or id_ex_nop = '1') then
                id_ex_pc <= (others => '0');
                id_ex_a <= (others => '0');
                id_ex_b <= (others => '0');
                id_ex_cw <= CONTROL_WORD_ID_EX_NOP;
            else
                if (id_ex_stall = '0') then
                    id_ex_pc <= if_id_pc;
                    id_ex_a <= a_out;
                    id_ex_b <= b_out;

                    id_ex_cw <= if_id_to_id_ex(if_id_cw);
                end if;
            end if;
        end if;
    end process;

    a_bus <= id_ex_pc & "00" when id_ex_cw.PCAsel = '1' else
             id_ex_a;
    b_bus <= id_ex_cw.IMM when id_ex_cw.IMMBsel = '1' else
             id_ex_b;

    ALU : entity work.ALU(Behavioral)
        port map(a => a_bus,
                 b => b_bus,
                 alu_out => alu_out,
                 func => id_ex_cw.ALUfunc);

    BTU : entity work.BTU(Behavioral)
        port map(a => id_ex_a,
                 b => id_ex_b,
                 cond => id_ex_cw.BRcond_LStype,
                 enable => id_ex_cw.isBR,
                 BTU_out => BTU_out);

    EX_MEM_proc : process(clk) is
    begin
        if rising_edge(clk) then
            if (reset = '1' or ex_mem_nop = '1') then
                ex_mem_alu_out <= (others => '0');
                ex_mem_store_data <= (others => '0');
                ex_mem_cw <= CONTROL_WORD_EX_MEM_NOP;
            else
                if (ex_mem_stall = '0') then
                    ex_mem_alu_out <= alu_out;
                    ex_mem_store_data <= id_ex_b;

                    ex_mem_cw <= id_ex_to_ex_mem(id_ex_cw);
                end if;
            end if;
        end if;
    end process;

    ls_addr_valid_i <= ex_mem_cw.is_load or ex_mem_cw.is_store;
    ls_addr_valid <= ls_addr_valid_i;
    load_store_ctrl <= ex_mem_cw.is_load;
    ls_type <= ex_mem_cw.BRcond_LStype;
    ls_address <= ex_mem_alu_out;
    store_data <= ex_mem_store_data;
    ls_done_ready_i <= ls_addr_valid_i;
    ls_done_ready <= ls_done_ready_i;

    ls_hazard <= (ls_addr_valid_i and not ls_addr_ready) or (ls_done_ready_i and not ls_done_valid);

    MEM_WB_proc : process(clk) is
    begin
        if rising_edge(clk) then
            if (reset = '1' or mem_wb_nop = '1') then
                mem_wb_load_data <= (others => '0');
                mem_wb_alu_out <= (others => '0');
                mem_wb_cw <= CONTROL_WORD_MEM_WB_NOP;
            else
                if (mem_wb_stall = '0') then
                    mem_wb_load_data <= load_data;
                    mem_wb_alu_out <= ex_mem_alu_out;

                    mem_wb_cw <= ex_mem_to_mem_wb(ex_mem_cw);
                end if;
            end if;
        end if;
    end process;

    ----control logic----
    --RAW hazard (just stall)
    -- @formatter:off
    id_ex_a_hazard <= '1' when (if_id_cw.Asel = id_ex_cw.Dsel and 
                                if_id_cw.Asel /= "00000" and 
                                if_id_cw.Aused = '1' and 
                                id_ex_cw.Dlen = '1') else
                                '0';

    id_ex_b_hazard <= '1' when (if_id_cw.Bsel = id_ex_cw.Dsel and 
                                if_id_cw.Bsel /= "00000" and 
                                if_id_cw.Bused = '1' and 
                                id_ex_cw.Dlen = '1') else
                                '0';

    ex_mem_a_hazard <= '1' when (if_id_cw.Asel = ex_mem_cw.Dsel and 
                                if_id_cw.Asel /= "00000" and 
                                if_id_cw.Aused = '1' and 
                                ex_mem_cw.Dlen = '1') else
                                '0';

    ex_mem_b_hazard <= '1' when (if_id_cw.Bsel = ex_mem_cw.Dsel and 
                                if_id_cw.Bsel /= "00000" and 
                                if_id_cw.Bused = '1' and 
                                ex_mem_cw.Dlen = '1') else
                                '0';


    raw_hazard <= id_ex_a_hazard or id_ex_b_hazard or 
                  ex_mem_a_hazard or ex_mem_b_hazard;
    -- @formatter:on

    --branch hazard
    branch_hazard <= '1' when (branch_take = '1' and branch_correct = '0') else '0';

    --pipeline register bubbles
    if_id_nop <= fetch_hazard or branch_hazard;
    id_ex_nop <= raw_hazard or branch_hazard;
    ex_mem_nop <= '0';
    mem_wb_nop <= ls_hazard;

    --pipeline register enable
    if_id_stall <= id_ex_stall or raw_hazard;
    id_ex_stall <= ex_mem_stall;
    ex_mem_stall <= ls_hazard;
    mem_wb_stall <= '0';

end Behavioral;
