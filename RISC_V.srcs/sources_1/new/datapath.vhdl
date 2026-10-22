library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use STD.textio.all;
use IEEE.std_logic_textio.all;
use work.RISCV_package.all;

entity Datapath is
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
        --mem_hazard : in sl
    );
end Datapath;

architecture Behavioral of Datapath is
    --if
    signal pc_next, pc : slv(I_BYTES_ADDR_BITS - 3 downto 0);
    signal pc_incr : sl;
    signal pc_ctrl : slv(2 downto 0);
    signal cw_decoded : control_word_if_id;

    --if_id
    signal if_id_cw : control_word_if_id;
    signal if_id_pc : slv(I_BYTES_ADDR_BITS - 3 downto 0);

    --id
    signal a_out, b_out : slv(XLEN - 1 downto 0);

    --id_ex
    signal id_ex_cw : control_word_id_ex;
    signal id_ex_pc : slv(I_BYTES_ADDR_BITS - 3 downto 0);
    signal id_ex_a, id_ex_b : slv(XLEN - 1 downto 0);

    --ex
    signal a_pre, b_pre, a_bus, b_bus, alu_out, csr_d, csr_q : slv(XLEN - 1 downto 0);
    signal BTU_out : sl;
    signal branch_correct, branch_take : sl;
    signal pc_base, pc_sum : slv(I_BYTES_ADDR_BITS - 1 downto 0);
    signal pc_d : slv(I_BYTES_ADDR_BITS - 3 downto 0);
    signal pc_latch : sl;

    --ex_mem
    signal ex_mem_cw : control_word_ex_mem;
    signal ex_mem_pc : slv(I_BYTES_ADDR_BITS - 3 downto 0);
    signal ex_mem_data_out : slv(XLEN - 1 downto 0);

    --mem
    signal mem_d_in, mem_PC_d_in : slv(XLEN - 1 downto 0);
    signal data_out : slv(XLEN - 1 downto 0);

    --mem_wb
    signal mem_wb_cw : control_word_mem_wb;
    signal mem_wb_pc : slv(I_BYTES_ADDR_BITS - 3 downto 0);
    signal mem_wb_load_data, mem_wb_data_out : slv(XLEN - 1 downto 0);

    --wb
    signal wb_d_in, wb_PC_d_in : slv(XLEN - 1 downto 0);
    signal exec : sl;

    --control
    signal if_id_stall, id_ex_stall, ex_mem_stall, mem_wb_stall : sl;
    signal if_id_nop, id_ex_nop, ex_mem_nop, mem_wb_nop : sl;
    signal id_ex_nop_dly : sl;
    signal if_id_clr, id_ex_clr, ex_mem_clr, mem_wb_clr : sl;
    signal id_ex_a_hazard, id_ex_b_hazard, ex_mem_a_hazard, ex_mem_b_hazard, raw_hazard : sl;
    signal wait_partial_forward : sl;
    signal branch_hazard : sl;

    --forwarding
    signal ex_mem_a_forward, ex_mem_b_forward, mem_wb_a_forward, mem_wb_b_forward : sl;

    -- Simulation-only retirement trace. The valid bits mirror the pipeline
    -- register hold/bubble/flush behavior; these declarations are ignored by
    -- synthesis.
    -- synthesis translate_off
    signal trace_if_id_valid, trace_id_ex_valid, trace_ex_mem_valid, trace_mem_wb_valid : sl := '0';
    signal trace_if_id_inst, trace_id_ex_inst, trace_ex_mem_inst, trace_mem_wb_inst : slv(31 downto 0) := (others => '0');
    signal trace_ex_mem_store_data, trace_mem_wb_store_data : slv(31 downto 0) := (others => '0');
    file trace_file : text open write_mode is "core_trace.log";
    signal trace_finished : boolean := false;
    -- synthesis translate_on
begin

    branch_correct <= '1' when pc_d = if_id_pc else '0';
    branch_take <= id_ex_cw.PCle or BTU_out;

    pc_base <= id_ex_pc & "00" when id_ex_cw.PCAsel = '1' else id_ex_a(I_BYTES_ADDR_BITS - 1 downto 0);
    pc_sum <= slv(signed(pc_base) + signed(id_ex_cw.IMM(I_BYTES_ADDR_BITS - 1 downto 0))); --unsigned or signed add, doesn't matter. same logic under the hood
    pc_d <= pc_sum(I_BYTES_ADDR_BITS - 1 downto 2);
    pc_latch <= branch_take and (not branch_correct);
    pc_incr <= (not if_id_stall and not branch_hazard);

    --counter
    pc <= pc_next when rising_edge(clk);
    pc_ctrl <= reset & pc_latch & pc_incr;
    with pc_ctrl select pc_next <=
        pc when "000",
        slv(unsigned(pc) + 1) when "001",
        pc_d when "010" | "011",
        "00010000000000" when others; --starting address as x1000 for test_2, else set zero

    fetch_address <= pc when I_USE_NEGEDGE else pc_next;

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
            if (reset = '1' or if_id_clr = '1' or (if_id_nop = '1' and if_id_stall = '0')) then
                if_id_pc <= (others => '0');
                if_id_cw <= CONTROL_WORD_IF_ID_NOP;
            else
                if (if_id_stall = '0') then
                    if_id_pc <= pc;

                    if_id_cw <= cw_decoded;
                end if;
            end if;
        end if;
    end process;

    Regs : entity work.generic_register_file(Behavioral)
        generic map(word_len => XLEN, addr_bits => REGS_ADDR_BITS)
        port map(clk => clk,
                 reset => reset,
                 write_en => mem_wb_cw.Dlen,
                 d_addr => mem_wb_cw.Dsel,
                 d_in => wb_d_in,
                 a_addr => if_id_cw.Asel_CSRuimm,
                 a_out => a_out,
                 b_addr => if_id_cw.Bsel,
                 b_out => b_out);

    ID_EX_proc : process(clk) is
    begin
        if rising_edge(clk) then
            if (reset = '1' or id_ex_clr = '1' or (id_ex_nop = '1' and id_ex_stall = '0')) then
                id_ex_pc <= (others => '0');
                id_ex_a <= (others => '0');
                id_ex_b <= (others => '0');
                id_ex_cw <= CONTROL_WORD_ID_EX_NOP;
            else
                id_ex_nop_dly <= id_ex_nop;
                if (id_ex_stall = '0') then
                    id_ex_pc <= if_id_pc;
                    id_ex_a <= a_out;
                    id_ex_b <= b_out;

                    id_ex_cw <= if_id_to_id_ex(if_id_cw);
                end if;
            end if;
        end if;
    end process;

    --TODO: can move this to id if not meeting timing
    a_pre <= ((31 downto I_BYTES_ADDR_BITS => '0') & id_ex_pc & "00") when id_ex_cw.PCAsel = '1' else
             id_ex_a;
    b_pre <= id_ex_cw.IMM when id_ex_cw.IMMBsel = '1' else
             id_ex_b;

    ALU_NONE_FORWARDING : if FORWARDING_AMOUNT = NONE generate
        a_bus <= a_pre;
        b_bus <= b_pre;
    end generate;

    ALU_PARTIAL_FORWARDING : if FORWARDING_AMOUNT = PARTIAL generate
        a_bus <= mem_d_in when ex_mem_a_forward = '1' else
                 a_pre;
        b_bus <= mem_d_in when ex_mem_b_forward = '1' else
                 b_pre;
    end generate;

    ALU_FULL_FORWARDING : if FORWARDING_AMOUNT = FULL generate
        a_bus <= mem_d_in when ex_mem_a_forward = '1' else
                 wb_d_in when mem_wb_a_forward = '1' else
                 a_pre;
        b_bus <= mem_d_in when ex_mem_b_forward = '1' else
                 wb_d_in when mem_wb_b_forward = '1' else
                 b_pre;
    end generate;

    ALU : entity work.ALU(Behavioral)
        port map(a => a_bus,
                 b => b_bus,
                 alu_out => alu_out,
                 func => id_ex_cw.ALUFunc_CSRtype);

    BTU : entity work.BTU(Behavioral)
        port map(a => id_ex_a,
                 b => id_ex_b,
                 cond => id_ex_cw.BRcond_LStype,
                 enable => id_ex_cw.isBR,
                 BTU_out => BTU_out);

    --load/store addr goes in now, so data is ready by the time the mem stage happens
    ls_ctrl <= id_ex_cw.is_store;
    store_type <= id_ex_cw.BRcond_LStype;
    ls_address <= slv(unsigned(id_ex_a) + unsigned(id_ex_cw.IMM)); --slv(unsigned(id_ex_a(D_ADDR_BITS - 1 downto 0)) + unsigned(id_ex_cw.IMM(D_ADDR_BITS - 1 downto 0)));
    store_data <= id_ex_b;

    exec <= '0' when (mem_wb_pc = (mem_wb_pc'range => '0')) or mem_wb_stall = '1' else '1';
    csr_d <= ((XLEN - 1 downto 5 => '0') & id_ex_cw.Asel_CSRuimm) when id_ex_cw.ALUFunc_CSRtype(3) = '1' else id_ex_a;
    CSR_regs : entity work.CSR_regs
        port map(
            clk => clk,
            reset => reset,
            d_sel => id_ex_cw.CSR_reg,
            d_len => id_ex_cw.is_CSR,
            d_in => csr_d,
            d_type => id_ex_cw.ALUFunc_CSRtype(2 downto 1),
            q_sel => id_ex_cw.CSR_reg,
            q_out => csr_q,
            exec => exec
        );

    data_out <= csr_q when id_ex_cw.is_CSR = '1' else alu_out;

    EX_MEM_proc : process(clk) is
    begin
        if rising_edge(clk) then
            if (reset = '1' or ex_mem_clr = '1' or (ex_mem_nop = '1' and ex_mem_stall = '0')) then
                ex_mem_data_out <= (others => '0');
                ex_mem_pc <= (others => '0');
                ex_mem_cw <= CONTROL_WORD_EX_MEM_NOP;
            else
                if (ex_mem_stall = '0') then
                    ex_mem_data_out <= data_out;
                    ex_mem_pc <= id_ex_pc;

                    ex_mem_cw <= id_ex_to_ex_mem(id_ex_cw);
                end if;
            end if;
        end if;
    end process;

    mem_PC_d_in <= ((31 downto I_BYTES_ADDR_BITS => '0') & slv(unsigned(ex_mem_pc) + 1) & "00");
    mem_d_in <= mem_PC_d_in when ex_mem_cw.PCDsel = '1' else
                ex_mem_data_out;

    load_type <= ex_mem_cw.BRcond_LStype;

    MEM_WB_proc : process(clk) is
    begin
        if rising_edge(clk) then
            if (reset = '1' or mem_wb_clr = '1' or (mem_wb_nop = '1' and mem_wb_stall = '0')) then
                mem_wb_load_data <= (others => '0');
                mem_wb_data_out <= (others => '0');
                mem_wb_pc <= (others => '0');
                mem_wb_cw <= CONTROL_WORD_MEM_WB_NOP;
            else
                if (mem_wb_stall = '0') then
                    mem_wb_load_data <= load_data;
                    mem_wb_data_out <= ex_mem_data_out;
                    mem_wb_pc <= ex_mem_pc;

                    mem_wb_cw <= ex_mem_to_mem_wb(ex_mem_cw);
                end if;
            end if;
        end if;
    end process;

    wb_PC_d_in <= ((31 downto I_BYTES_ADDR_BITS => '0') & slv(unsigned(mem_wb_pc) + 1) & "00");
    wb_d_in <= mem_wb_load_data when mem_wb_cw.LoadDsel = '1' else
               wb_PC_d_in when mem_wb_cw.PCDsel = '1' else
               mem_wb_data_out;

    ----control logic----
    --RAW hazard (just stall)
    -- @formatter:off
    id_ex_a_hazard <= '1' when (if_id_cw.Asel_CSRuimm = id_ex_cw.Dsel and 
                                if_id_cw.Asel_CSRuimm /= "00000" and 
                                if_id_cw.Aused = '1' and 
                                id_ex_cw.Dlen = '1') else
                      '0';

    id_ex_b_hazard <= '1' when (if_id_cw.Bsel = id_ex_cw.Dsel and 
                                if_id_cw.Bsel /= "00000" and 
                                if_id_cw.Bused = '1' and 
                                id_ex_cw.Dlen = '1') else
                      '0';

    ex_mem_a_hazard <= '1' when (if_id_cw.Asel_CSRuimm = ex_mem_cw.Dsel and 
                                if_id_cw.Asel_CSRuimm /= "00000" and 
                                if_id_cw.Aused = '1' and 
                                ex_mem_cw.Dlen = '1') else
                       '0';

    ex_mem_b_hazard <= '1' when (if_id_cw.Bsel = ex_mem_cw.Dsel and 
                                if_id_cw.Bsel /= "00000" and 
                                if_id_cw.Bused = '1' and 
                                ex_mem_cw.Dlen = '1') else
                       '0';


    RAW_NONE_FORWARDING : if FORWARDING_AMOUNT = NONE generate
    raw_hazard <= id_ex_a_hazard or id_ex_b_hazard or 
                  ex_mem_a_hazard or ex_mem_b_hazard;
    end generate;

    RAW_PARTIAL_FORWARDING : if FORWARDING_AMOUNT = PARTIAL generate
    raw_hazard <= (id_ex_a_hazard and id_ex_cw.is_load) or 
                  id_ex_b_hazard or 
                  (ex_mem_a_hazard and ex_mem_cw.is_load) or 
                  ex_mem_b_hazard;
    end generate;

    RAW_FULL_FORWARDING : if FORWARDING_AMOUNT = FULL generate
    raw_hazard <= (id_ex_a_hazard and id_ex_cw.is_load) or
                  (ex_mem_a_hazard and ex_mem_cw.is_load);
    end generate;




    -- @formatter:on

    --branch hazard
    branch_hazard <= '1' when (branch_take = '1' and branch_correct = '0') else '0';

    --pipeline register bubbles
    if_id_clr <= branch_hazard;
    id_ex_clr <= branch_hazard;
    ex_mem_clr <= '0';
    mem_wb_clr <= '0';

    if_id_nop <= '0';
    id_ex_nop <= raw_hazard;
    ex_mem_nop <= '0';
    mem_wb_nop <= '0'; --mem_hazard;

    --pipeline register enable
    if_id_stall <= raw_hazard; -- mem_hazard;
    id_ex_stall <= '0'; -- mem_hazard;
    ex_mem_stall <= wait_partial_forward; -- mem_hazard;
    mem_wb_stall <= '0';

    --Forward Logic
    -- @formatter:off
    ex_mem_a_forward <= '1' when (id_ex_cw.Asel_CSRuimm = ex_mem_cw.Dsel and 
                                  id_ex_cw.Asel_CSRuimm /= "00000" and 
                                  id_ex_cw.Aused = '1' and 
                                  ex_mem_cw.Dlen = '1' and 
                                  ex_mem_cw.is_load = '0') else
                        '0';

    ex_mem_b_forward <= '1' when (id_ex_cw.Bsel = ex_mem_cw.Dsel and 
                                  id_ex_cw.Bsel /= "00000" and 
                                  id_ex_cw.Bused = '1' and 
                                  ex_mem_cw.Dlen = '1' and 
                                  ex_mem_cw.is_load = '0') else
                        '0';

    mem_wb_a_forward <= '1' when (id_ex_cw.Asel_CSRuimm = mem_wb_cw.Dsel and 
                                  id_ex_cw.Asel_CSRuimm /= "00000" and 
                                  id_ex_cw.Aused = '1' and 
                                  mem_wb_cw.Dlen = '1') else
                        '0';

    mem_wb_b_forward <= '1' when (id_ex_cw.Bsel = mem_wb_cw.Dsel and 
                                  id_ex_cw.Bsel /= "00000" and 
                                  id_ex_cw.Bused = '1' and 
                                  mem_wb_cw.Dlen = '1') else
                        '0';

    wait_partial_forward <= ((ex_mem_a_hazard and not ex_mem_cw.is_load) or 
                              ex_mem_b_hazard) and 
                              id_ex_nop_dly;
    -- @formatter:on

    -- Simulation-only trace in Spike commit-log format. Each valid
    -- instruction is emitted once at WB, including instructions that do not
    -- write a register. Stop and close the file when test_2 writes its pass or
    -- fail marker to x31, avoiding an unbounded trace of the terminal loop.
    -- synthesis translate_off
    TRACE_PIPELINE : process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                trace_if_id_valid <= '0';
                trace_id_ex_valid <= '0';
                trace_ex_mem_valid <= '0';
                trace_mem_wb_valid <= '0';
                trace_if_id_inst <= (others => '0');
                trace_id_ex_inst <= (others => '0');
                trace_ex_mem_inst <= (others => '0');
                trace_mem_wb_inst <= (others => '0');
                trace_ex_mem_store_data <= (others => '0');
                trace_mem_wb_store_data <= (others => '0');
            else
                if if_id_clr = '1' or (if_id_nop = '1' and if_id_stall = '0') then
                    trace_if_id_valid <= '0';
                    trace_if_id_inst <= (others => '0');
                elsif if_id_stall = '0' then
                    trace_if_id_valid <= '1';
                    trace_if_id_inst <= inst;
                end if;

                if id_ex_clr = '1' or (id_ex_nop = '1' and id_ex_stall = '0') then
                    trace_id_ex_valid <= '0';
                    trace_id_ex_inst <= (others => '0');
                elsif id_ex_stall = '0' then
                    trace_id_ex_valid <= trace_if_id_valid;
                    trace_id_ex_inst <= trace_if_id_inst;
                end if;

                if ex_mem_clr = '1' or (ex_mem_nop = '1' and ex_mem_stall = '0') then
                    trace_ex_mem_valid <= '0';
                    trace_ex_mem_inst <= (others => '0');
                    trace_ex_mem_store_data <= (others => '0');
                elsif ex_mem_stall = '0' then
                    trace_ex_mem_valid <= trace_id_ex_valid;
                    trace_ex_mem_inst <= trace_id_ex_inst;
                    trace_ex_mem_store_data <= id_ex_b;
                end if;

                if mem_wb_clr = '1' or (mem_wb_nop = '1' and mem_wb_stall = '0') then
                    trace_mem_wb_valid <= '0';
                    trace_mem_wb_inst <= (others => '0');
                    trace_mem_wb_store_data <= (others => '0');
                elsif mem_wb_stall = '0' then
                    trace_mem_wb_valid <= trace_ex_mem_valid;
                    trace_mem_wb_inst <= trace_ex_mem_inst;
                    trace_mem_wb_store_data <= trace_ex_mem_store_data;
                end if;
            end if;
        end if;
    end process TRACE_PIPELINE;

    TRACE_COMMIT : process(clk)
        variable trace_line : line;
        variable trace_pc : slv(31 downto 0);
        variable trace_mem_value : slv(31 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '0' and trace_mem_wb_valid = '1' and not trace_finished then
                trace_pc := (31 downto I_BYTES_ADDR_BITS => '0') & mem_wb_pc & "00";
                write(trace_line, string'("core   0: 3 0x"));
                hwrite(trace_line, trace_pc);
                write(trace_line, string'(" (0x"));
                hwrite(trace_line, trace_mem_wb_inst);
                write(trace_line, string'(")"));

                if mem_wb_cw.Dlen = '1' and mem_wb_cw.Dsel /= "00000" then
                    write(trace_line, string'(" x"));
                    write(trace_line, to_integer(unsigned(mem_wb_cw.Dsel)));
                    write(trace_line, string'(" 0x"));
                    hwrite(trace_line, wb_d_in);
                end if;

                if trace_mem_wb_inst(6 downto 0) = "0000011" then
                    write(trace_line, string'(" mem 0x"));
                    hwrite(trace_line, mem_wb_data_out);
                elsif trace_mem_wb_inst(6 downto 0) = "0100011" then
                    trace_mem_value := trace_mem_wb_store_data;
                    case trace_mem_wb_inst(14 downto 12) is
                        when "000" => trace_mem_value := (31 downto 8 => '0') & trace_mem_wb_store_data(7 downto 0);
                        when "001" => trace_mem_value := (31 downto 16 => '0') & trace_mem_wb_store_data(15 downto 0);
                        when others => null;
                    end case;
                    write(trace_line, string'(" mem 0x"));
                    hwrite(trace_line, mem_wb_data_out);
                    write(trace_line, string'(" 0x"));
                    hwrite(trace_line, trace_mem_value);
                end if;
                writeline(trace_file, trace_line);

                if mem_wb_cw.Dlen = '1' and mem_wb_cw.Dsel = "11111" and (wb_d_in = x"600D600D" or wb_d_in = x"BAD0BAD0") then
                    file_close(trace_file);
                    trace_finished <= true;
                end if;
            end if;
        end if;
    end process TRACE_COMMIT;
    -- synthesis translate_on

end Behavioral;
