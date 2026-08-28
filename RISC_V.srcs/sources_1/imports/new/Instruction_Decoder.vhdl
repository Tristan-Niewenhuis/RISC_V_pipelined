library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.RISCV_package.all;

entity Instruction_Decoder is
    Port(execute, PCie, branch_cond : in sl;
         inst : in slv(31 downto 0);
         control_word : out control_word;
         exeception : out sl;
         store_inst : out sl;
         load_inst : out sl);
end Instruction_Decoder;

architecture Behavioral of Instruction_Decoder is
    signal immediate : slv(XLEN - 1 downto 0);
    signal type_control_sig : slv(2 downto 0);
    signal jalr_condition, instruction_address_misaligned, bottom_11 : sl;
    signal force_add : sl;
    signal is_LOAD, is_LUI, is_AUIPC, is_JALR, is_ADDI : sl;
    signal is_R, is_I, is_S, is_B, is_U, is_J, is_system, is_MRET, is_WFI, is_illegal : sl;
begin
    --throw expection when inst(1 downto 0) != 0
    bottom_11 <= '1' when inst(1 downto 0) = "00" else '0';

    --jump/branch alligment
    jalr_condition <= '0' when inst(21 downto 20) = "00" else '1';
    instruction_address_misaligned <= (is_J and inst(21)) or (is_B and inst(8) and branch_cond) or (is_JALR and jalr_condition);

    --opcode interpretation
    is_LOAD <= '1' when inst(6 downto 2) = "00000" else '0';
    is_LUI <= '1' when inst(6 downto 2) = "01101" else '0';
    is_AUIPC <= '1' when inst(6 downto 2) = "00101" else '0';
    is_JALR <= '1' when inst(6 downto 2) = "11001" else '0';
    is_ADDI <= '1' when inst(6 downto 2) = "00100" and inst(14 downto 12) = "000" else '0';

    --MISC-MEM aka FENCE inst(6 downto 2) = "00011"
    --STYSTEM aka ECALL and EBreak inst(6 downto 2) = "11100"
    is_R <= '1' when inst(6 downto 2) = "01100" else '0';
    with inst(6 downto 2) select is_I <=
        '1' when "00100" | "00000" | "11001",
        '0' when others;
    is_S <= '1' when inst(6 downto 2) = "01000" else '0';
    is_B <= '1' when inst(6 downto 2) = "11000" else '0';
    --is_U <= is_LUI or is_AUIPC;
    with inst(6 downto 2) select is_U <=
        '1' when "01101" | "00101",
        '0' when others;
    is_J <= '1' when inst(6 downto 2) = "11011" else '0';

    --encode these into a 3 bit control word
    with slv'(is_R & is_I & is_S & is_B & is_U & is_J) select type_control_sig <=
        "000" when "100000", --R
        "001" when "010000", --I
        "010" when "001000", --S
        "011" when "000100", --B
        "100" when "000010", --U
        "101" when "000001", --J
        "111" when others;

    is_illegal <= '1' when type_control_sig = "111" else '0';

    --immediate assembly
    with type_control_sig select immediate <=
        (31 downto 11 => inst(31)) & inst(30 downto 20) when "001", --I
        (31 downto 11 => inst(31)) & inst(30 downto 25) & inst(11 downto 7) when "010", --S
        (31 downto 12 => inst(31)) & inst(7) & inst(30 downto 25) & inst(11 downto 8) & '0' when "011", --B
        inst(31) & inst(30 downto 12) & "000000000000" when "100", --U
        (31 downto 20 => inst(31)) & inst(19 downto 12) & inst(20) & inst(30 downto 21) & '0' when "101", --J
        (others => '0') when others;

    --all the functions that need a add
    force_add <= (not is_R and not is_I) or is_JALR or is_LOAD or is_ADDI;

    control_word.Asel <= "00000" when is_LUI = '1' else inst(19 downto 15);
    control_word.Bsel <= inst(24 downto 20);
    control_word.Dsel <= inst(11 downto 7);
    control_word.Dlen <= execute and (is_R or is_I or is_U or is_J);
    control_word.PCAsel <= is_AUIPC or is_J or is_B;
    control_word.IMMBsel <= is_S or is_I or is_U or is_J or is_B;
    control_word.PCDsel <= is_J or is_JALR;
    control_word.PCie <= PCie;
    control_word.PCle <= execute and (is_J or is_JALR);
    control_word.isBR <= execute and (is_B);
    control_word.BRcond <= inst(14 downto 12);
    control_word.ALUFunc <= "0000" when force_add = '1' else inst(14 downto 12) & (inst(30));
    control_word.IMM <= immediate;

    exeception <= is_illegal or bottom_11 or instruction_address_misaligned;
    store_inst <= is_S;
    load_inst <= is_LOAD;
end Behavioral;
