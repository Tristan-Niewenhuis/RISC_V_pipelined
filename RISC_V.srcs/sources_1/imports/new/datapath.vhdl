library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.RISCV_package.all;

entity Datapath is
    port(
        clk, reset : in sl;
        control_word : in control_word;
        load_inst : in sl;
        load_data : in slv(XLEN - 1 downto 0);
        branch_cond : out sl;
        pc_out : out slv(XLEN - 1 downto 0);
        ls_address : out slv(XLEN - 1 downto 0);
        store_data : out slv(XLEN - 1 downto 0));
end Datapath;

architecture Behavioral of Datapath is
    signal post_d_bus, d_bus, a_pre_bus, b_pre_bus, a_bus, b_bus, pc, alu_out : slv(XLEN - 1 downto 0);
    signal pc_in : slv(29 downto 0);
    signal BTU_out, pc_latch : sl;

begin

    Regs : entity work.generic_register_file(Behavioral)
        generic map(word_len => XLEN, addr_bits => REGS_ADDR_BITS)
        port map(clk => clk, reset => reset,
                 write_en => control_word.Dlen,
                 d_addr => control_word.Dsel,
                 d_in => post_d_bus,
                 a_addr => control_word.Asel,
                 a_out => a_pre_bus,
                 b_addr => control_word.Bsel,
                 b_out => b_pre_bus);

    ALU : entity work.ALU(Behavioral)
        port map(a => a_bus, b => b_bus, alu_out => alu_out, func => control_word.ALUfunc);

    Program_Counter : entity work.generic_counter(Behavioral)
        generic map(bits => XLEN - 2)
        port map(clk => clk, reset => reset, latch => pc_latch, enable => control_word.PCie, d => pc_in, q => pc(31 downto 2));
    pc(1 downto 0) <= "00"; --hard set last 2 bits of pc to 00
    pc_out <= pc;
    pc_in <= slv(unsigned(alu_out(31 downto 2)) - 1) when control_word.PCAsel = '1' else
             alu_out(31 downto 2); --back one instruction on pc relative branches

    BTU : entity work.BTU(Behavioral)
        port map(a => a_pre_bus, b => b_pre_bus, cond => control_word.BRcond, enable => control_word.isBR, BTU_out => BTU_out);
    branch_cond <= BTU_out;

    a_bus <= pc when control_word.PCAsel = '1' else
             a_pre_bus;
    b_bus <= control_word.IMM when control_word.IMMBsel = '1' else
             b_pre_bus;
    d_bus <= pc when control_word.PCDsel = '1' else
             alu_out;
    post_d_bus <= load_data when load_inst = '1' else d_bus;
    pc_latch <= control_word.PCle or BTU_out;

    --load and store values
    ls_address <= alu_out;
    store_data <= b_pre_bus;

end Behavioral;
