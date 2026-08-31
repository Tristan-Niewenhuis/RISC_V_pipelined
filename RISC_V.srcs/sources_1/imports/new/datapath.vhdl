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
        ls_address : out slv(XLEN - 1 downto 0);
        store_data : out slv(XLEN - 1 downto 0);
        ls_done_valid : in sl;
        ls_done_ready : out sl;
        load_data : in slv(XLEN - 1 downto 0)
    );
end Datapath;

architecture Behavioral of Datapath is
    signal d_in, a_out, b_out, a_bus, b_bus, pc, alu_out, a_id_ex, b_id_ex, alu_out_ex_mem, store_data_ex_mem, load_data_mem_wb, alu_out_mem_wb : slv(XLEN - 1 downto 0);
    signal pc_if_id, pc_id_ex, pc_d : slv(29 downto 0);
    signal BTU_out, pc_latch, pc_incr, if_id_en, id_ex_en, ex_mem_en, mem_wb_en : sl;
    signal cw_decoded : control_word_if_id;
    signal if_id : control_word_if_id;
    signal id_ex : control_word_id_ex;
    signal ex_mem : control_word_ex_mem;
    signal mem_wb : control_word_mem_wb;
begin

    pc_d <= slv(unsigned(pc_id_ex) + unsigned(id_ex.IMM(31 downto 2))); --unsigned or signed add, doesn't matter. same logic under the hood
    pc_latch <= id_ex.PCle or BTU_out;
    pc_incr <= fetch_inst_valid and fetch_inst_ready;
    Program_Counter : entity work.generic_counter(Behavioral)
        generic map(bits => XLEN - 2)
        port map(clk => clk,
                 reset => reset,
                 latch => pc_latch,
                 enable => pc_incr,
                 d => pc_d,
                 q => pc(31 downto 2));
    pc(1 downto 0) <= "00"; --hard set last 2 bits of pc to 00

    fetch_addr_valid <= '1';
    fetch_address <= pc;

    fetch_inst_ready <= not stall;

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
            if reset = '1' then
                pc_if_id <= (others => '0');
                if_id <= CONTROL_WORD_IF_ID_ZERO;
            else
                if (if_id_en = '1') then
                    pc_if_id <= pc(31 downto 2);

                    if_id <= cw_decoded;
                end if;
            end if;
        end if;
    end process;

    d_in <= load_data_mem_wb when if_id.LoadDsel = '1' else
            slv(unsigned(pc) + 4) when if_id.PCDsel = '1' else
            alu_out_mem_wb;

    Regs : entity work.generic_register_file(Behavioral)
        generic map(word_len => XLEN, addr_bits => REGS_ADDR_BITS)
        port map(clk => clk,
                 reset => reset,
                 write_en => if_id.Dlen,
                 d_addr => if_id.Dsel,
                 d_in => d_in,
                 a_addr => if_id.Asel,
                 a_out => a_out,
                 b_addr => if_id.Bsel,
                 b_out => b_out);

    ID_EX_proc : process(clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pc_id_ex <= (others => '0');
                a_id_ex <= (others => '0');
                b_id_ex <= (others => '0');
                id_ex <= CONTROL_WORD_ID_EX_ZERO;
            else
                if (id_ex_en = '1') then
                    pc_id_ex <= pc_if_id;
                    a_id_ex <= a_out;
                    b_id_ex <= b_out;

                    id_ex <= if_id_to_id_ex(if_id);
                end if;
            end if;
        end if;
    end process;

    a_bus <= pc_id_ex & "00" when id_ex.PCAsel = '1' else
             a_id_ex;
    b_bus <= id_ex.IMM when id_ex.IMMBsel = '1' else
             b_id_ex;

    ALU : entity work.ALU(Behavioral)
        port map(a => a_bus,
                 b => b_bus,
                 alu_out => alu_out,
                 func => id_ex.ALUfunc);

    BTU : entity work.BTU(Behavioral)
        port map(a => a_id_ex,
                 b => b_id_ex,
                 cond => id_ex.BRcond,
                 enable => id_ex.isBR,
                 BTU_out => BTU_out);

    EX_MEM_proc : process(clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                alu_out_ex_mem <= (others => '0');
                store_data_ex_mem <= (others => '0');
                ex_mem <= CONTROL_WORD_EX_MEM_ZERO;
            else
                if (ex_mem_en = '1') then
                    alu_out_ex_mem <= alu_out;
                    store_data_ex_mem <= b_id_ex;

                    ex_mem <= id_ex_to_ex_mem(id_ex);
                end if;
            end if;
        end if;
    end process;

    ls_addr_valid <= ex_mem.is_load or ex_mem.is_store
        ls_addr_ready
        load_store_ctrl
        ls_address
        store_data
        ls_done_valid
        ls_done_ready
        load_data
    ls_address <= alu_out_ex_mem;
    store_data <= store_data_ex_mem;

    MEM_WB_proc : process(clk) is
    begin
        if rising_edge(clk) then
            if reset = '1' then
                load_data_mem_wb <= (others => '0');
                alu_out_mem_wb <= (others => '0');
                mem_wb <= CONTROL_WORD_MEM_WB_ZERO;
            else
                if (mem_wb_en = '1') then
                    load_data_mem_wb <= load_data;
                    alu_out_mem_wb <= alu_out_ex_mem;

                    mem_wb <= ex_mem_to_mem_wb(ex_mem);
                end if;
            end if;
        end if;
    end process;

end Behavioral;
