library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;
use std.textio.all;

package RISCV_package is
  subtype sl is std_logic;
  subtype slv is std_logic_vector;

  --NONE just stalls
  --PARTIAL only forwards from EX_MEM back to alu
  --FULL is both EX_MEM and MEM_WB to alu
  type forwarding_t is (NONE, PARTIAL, FULL);
  constant FORWARDING_AMOUNT : forwarding_t := FULL;

  -- DEBUG true keeps the pipeline registers for an ILA (mark_debug).  It is
  -- off by default because mark_debug blocks optimization across those
  -- registers and lowers Fmax.  All timing and CPI measurements use FALSE.
  constant DEBUG : boolean := FALSE;
  constant XLEN_BITS : integer := 5;
  constant XLEN : integer := 2 ** XLEN_BITS;
  constant REGS_ADDR_BITS : integer := 5;
  constant I_BYTES_ADDR_BITS : integer := 16;
  constant D_BYTES_ADDR_BITS : integer := 16;
  constant PRE_FETCH_BURST_SIZE : integer := 4;

  constant I_MEM_BASE : slv(31 downto 0) := x"00000000";
  constant I_MEM_SIZE_LOGICAL : integer := 16#10000#;
  constant I_MEM_BYTES_REAL : integer := 16#10000#; --must be power of 2
  constant I_MEM_INIT_FILE : string; --set in the package body
  --Keep the BRAMs on the rising edge (I_USE_NEGEDGE and D_USE_NEGEDGE false).
  --The falling-edge option does not change CPI, and its half-cycle path
  --(BRAM clock-to-out plus decode) caps Fmax near 105 MHz, below every
  --forwarding variant on the rising edge (Fmax sweep of 2026-11-01).
  constant I_USE_NEGEDGE : boolean := false;
  constant D_MEM_BASE : slv(31 downto 0) := x"00010000";
  constant D_MEM_SIZE_LOGICAL : integer := 16#FFE0#;
  constant D_MEM_BYTES_REAL : integer := 16#10000#; --must be power of 2
  constant D_MEM_INIT_FILE : string; --set in the package body
  constant D_IO_BASE : slv(31 downto 0) := x"C0000000";
  constant D_USE_NEGEDGE : boolean := false; --keep false, see I_USE_NEGEDGE

  -- Function to create a vector from a bit
  function to_boolean(x : sl) return boolean;

  -- Function to convert boolean to sl
  function to_sl(L : BOOLEAN) return std_ulogic;

  -- Function to convert sl to boolean
  function to_vector(x : sl) return slv;

  -- function to return the ceiling of log base 2 of x
  function clog2(X : integer) return integer;

  type slv_array_32 is array (natural range <>) of slv(31 downto 0);

  type control_word_if_id is record
    Asel_CSRuimm : slv(4 downto 0);
    Aused : sl;
    Bsel : slv(4 downto 0);
    Bused : sl;
    PCAsel : sl;
    IMMBsel : sl;
    PCle : sl;
    isBR : sl;
    ALUFunc_CSRtype : slv(3 downto 0);
    IMM : slv(31 downto 0);
    is_load : sl;
    is_store : sl;
    BRcond_LStype : slv(2 downto 0);
    is_CSR : sl;
    CSR_reg : slv(11 downto 0);
    Dsel : slv(4 downto 0);
    Dlen : sl;
    PCDsel : sl;
    LoadDsel : sl;
  end record control_word_if_id;

  constant CONTROL_WORD_IF_ID_NOP : control_word_if_id := (
    Asel_CSRuimm => (others => '0'),
    Aused => '0',
    Bsel => (others => '0'),
    Bused => '0',
    PCAsel => '0',
    IMMBsel => '0',
    PCle => '0',
    isBR => '0',
    ALUFunc_CSRtype => (others => '0'),
    IMM => (others => '0'),
    is_load => '0',
    is_store => '0',
    BRcond_LStype => (others => '0'),
    is_CSR => '0',
    CSR_reg => (others => '0'),
    Dsel => (others => '0'),
    Dlen => '0',
    PCDsel => '0',
    LoadDsel => '0'
  );

  type control_word_id_ex is record
    Asel_CSRuimm : slv(4 downto 0);
    Aused : sl;
    Bsel : slv(4 downto 0);
    Bused : sl;
    PCAsel : sl;
    IMMBsel : sl;
    PCle : sl;
    isBR : sl;
    ALUFunc_CSRtype : slv(3 downto 0);
    IMM : slv(31 downto 0);
    is_load : sl;
    is_store : sl;
    BRcond_LStype : slv(2 downto 0);
    is_CSR : sl;
    CSR_reg : slv(11 downto 0);
    Dsel : slv(4 downto 0);
    Dlen : sl;
    PCDsel : sl;
    LoadDsel : sl;
  end record control_word_id_ex;

  constant CONTROL_WORD_ID_EX_NOP : control_word_id_ex := (
    Asel_CSRuimm => (others => '0'),
    Aused => '0',
    Bsel => (others => '0'),
    Bused => '0',
    PCAsel => '0',
    IMMBsel => '0',
    PCle => '0',
    isBR => '0',
    ALUFunc_CSRtype => (others => '0'),
    IMM => (others => '0'),
    is_load => '0',
    is_store => '0',
    BRcond_LStype => (others => '0'),
    is_CSR => '0',
    CSR_reg => (others => '0'),
    Dsel => (others => '0'),
    Dlen => '0',
    PCDsel => '0',
    LoadDsel => '0'
  );

  type control_word_ex_mem is record
    is_load : sl;
    is_store : sl;
    BRcond_LStype : slv(2 downto 0);
    is_CSR : sl;
    CSR_reg : slv(11 downto 0);
    Dsel : slv(4 downto 0);
    Dlen : sl;
    PCDsel : sl;
    LoadDsel : sl;
  end record control_word_ex_mem;

  constant CONTROL_WORD_EX_MEM_NOP : control_word_ex_mem := (
    is_load => '0',
    is_store => '0',
    BRcond_LStype => (others => '0'),
    is_CSR => '0',
    CSR_reg => (others => '0'),
    Dsel => (others => '0'),
    Dlen => '0',
    PCDsel => '0',
    LoadDsel => '0'
  );

  type control_word_mem_wb is record
    Dsel : slv(4 downto 0);
    Dlen : sl;
    PCDsel : sl;
    LoadDsel : sl;
  end record control_word_mem_wb;

  constant CONTROL_WORD_MEM_WB_NOP : control_word_mem_wb := (
    Dsel => (others => '0'),
    Dlen => '0',
    PCDsel => '0',
    LoadDsel => '0'
  );

  function if_id_to_id_ex(if_id : control_word_if_id) return control_word_id_ex;
  function id_ex_to_ex_mem(id_ex : control_word_id_ex) return control_word_ex_mem;
  function ex_mem_to_mem_wb(ex_mem : control_word_ex_mem) return control_word_mem_wb;

  function decode(signal sel : slv; signal enable : sl) return slv;
  function vector_and(signal to_and : slv) return sl;
end RISCV_package;

package body RISCV_package is

  -- The memory init files live in the project tree.  Look for RISC_V.xpr
  -- relative to the tool's working directory: the project directory itself
  -- (GHDL), two levels down (Vivado synthesis runs in RISC_V.runs/<run>),
  -- or four levels down (xsim runs in RISC_V.sim/sim_1/behav/xsim).  The
  -- original Windows checkout is the last resort.
  constant WINDOWS_ROOT : string := "C:/RISC_V_research/RISC_V_pipelined_private";

  -- Function to test whether a file can be opened for reading
  impure function file_exists(name : string) return boolean is
    file f : text;
    variable status : file_open_status;
  begin
    file_open(status, f, name, read_mode);
    if status = OPEN_OK then
      file_close(f);
    end if;
    return status = OPEN_OK;
  end function;

  -- Function to select the project root for this platform
  impure function find_project_root return string is
  begin
    if file_exists("RISC_V.xpr") then
      return ".";
    elsif file_exists("../../RISC_V.xpr") then
      return "../..";
    elsif file_exists("../../../../RISC_V.xpr") then
      return "../../../..";
    else
      return WINDOWS_ROOT;
    end if;
  end function;

  constant PROJECT_ROOT : string := find_project_root;
  constant I_MEM_INIT_FILE : string := PROJECT_ROOT & "/embench-iot-files/build/src/wikisort/wikisort_rom.coe"; --sim_test/test_2/build/rom.coe";
  constant D_MEM_INIT_FILE : string := PROJECT_ROOT & "/embench-iot-files/build/src/wikisort/wikisort_ram.coe"; --sim_test/test_2/build/ram.coe";

  -- Function to convert sl to boolean
  function to_boolean(x : sl) return boolean is
  begin
    return x = '1';
  end function;

  -- Function to convert boolean to sl
  function to_sl(L : BOOLEAN) return std_ulogic is
  begin
    if L then
      return ('1');
    else
      return ('0');
    end if;
  end function To_sl;

  -- Function to create a vector from a bit
  function to_vector(x : sl) return slv is
    variable r : slv(0 downto 0);
  begin
    r(0) := x;
    return r;
  end function;

  -- function to return the ceiling of log base 2 of x
  function clog2(X : integer) return integer is
  begin
    return integer(ceil(log2(real(X))));
  end function clog2;

  function if_id_to_id_ex(if_id : control_word_if_id) return control_word_id_ex is
    variable id_ex : control_word_id_ex;
  begin
    id_ex.Asel_CSRuimm := if_id.Asel_CSRuimm;
    id_ex.Aused := if_id.Aused;
    id_ex.Bsel := if_id.Bsel;
    id_ex.Bused := if_id.Bused;
    id_ex.PCAsel := if_id.PCAsel;
    id_ex.IMMBsel := if_id.IMMBsel;
    id_ex.PCle := if_id.PCle;
    id_ex.isBR := if_id.isBR;
    id_ex.ALUFunc_CSRtype := if_id.ALUFunc_CSRtype;
    id_ex.IMM := if_id.IMM;
    id_ex.is_load := if_id.is_load;
    id_ex.is_store := if_id.is_store;
    id_ex.BRcond_LStype := if_id.BRcond_LStype;
    id_ex.is_CSR := if_id.is_CSR;
    id_ex.CSR_reg := if_id.CSR_reg;
    id_ex.Dsel := if_id.Dsel;
    id_ex.Dlen := if_id.Dlen;
    id_ex.PCDsel := if_id.PCDsel;
    id_ex.LoadDsel := if_id.LoadDsel;
    return id_ex;
  end function;

  function id_ex_to_ex_mem(id_ex : control_word_id_ex) return control_word_ex_mem is
    variable ex_mem : control_word_ex_mem;
  begin
    ex_mem.is_load := id_ex.is_load;
    ex_mem.is_store := id_ex.is_store;
    ex_mem.BRcond_LStype := id_ex.BRcond_LStype;
    ex_mem.is_CSR := id_ex.is_CSR;
    ex_mem.CSR_reg := id_ex.CSR_reg;
    ex_mem.Dsel := id_ex.Dsel;
    ex_mem.Dlen := id_ex.Dlen;
    ex_mem.PCDsel := id_ex.PCDsel;
    ex_mem.LoadDsel := id_ex.LoadDsel;
    return ex_mem;
  end function;

  function ex_mem_to_mem_wb(ex_mem : control_word_ex_mem) return control_word_mem_wb is
    variable mem_wb : control_word_mem_wb;
  begin
    mem_wb.Dsel := ex_mem.Dsel;
    mem_wb.Dlen := ex_mem.Dlen;
    mem_wb.PCDsel := ex_mem.PCDsel;
    mem_wb.LoadDsel := ex_mem.LoadDsel;
    return mem_wb;
  end function;

  function decode(signal sel : slv; signal enable : sl) return slv is
    variable decoded : slv((2 ** sel'length) - 1 downto 0);
  begin
    decoded := (others => '0');
    decoded(to_integer(unsigned(sel))) := enable;
    return decoded;
  end function;

  function vector_and(signal to_and : slv) return sl is
    variable result : sl := '1';
  begin
    for i in to_and'range loop
      result := to_and(i) and result;
    end loop;
  end function;

end RISCV_package;
