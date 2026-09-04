library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

package RISCV_package is
  constant XLEN_BITS : integer := 5;
  constant XLEN : integer := 2 ** XLEN_BITS;
  constant REGS_ADDR_BITS : integer := 5;
  constant MEM_ADDR_BITS : integer := 32;
  constant PRE_FETCH_SIZE : integer := 4;

  subtype sl is std_logic;
  subtype slv is std_logic_vector;

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
    Asel : slv(4 downto 0);
    Aused : sl;
    Bsel : slv(4 downto 0);
    Bused : sl;
    PCAsel : sl;
    IMMBsel : sl;
    PCle : sl;
    isBR : sl;
    ALUFunc : slv(3 downto 0);
    IMM : slv(31 downto 0);
    is_load : sl;
    is_store : sl;
    BRcond_LStype : slv(2 downto 0);
    Dsel : slv(4 downto 0);
    Dlen : sl;
    PCDsel : sl;
    LoadDsel : sl;
  end record control_word_if_id;

  constant CONTROL_WORD_IF_ID_NOP : control_word_if_id := (
    Asel => (others => '0'),
    Aused => '0',
    Bsel => (others => '0'),
    Bused => '0',
    PCAsel => '0',
    IMMBsel => '0',
    PCle => '0',
    isBR => '0',
    ALUFunc => (others => '0'),
    IMM => (others => '0'),
    is_load => '0',
    is_store => '0',
    BRcond_LStype => (others => '0'),
    Dsel => (others => '0'),
    Dlen => '0',
    PCDsel => '0',
    LoadDsel => '0'
  );

  type control_word_id_ex is record
    PCAsel : sl;
    IMMBsel : sl;
    PCle : sl;
    isBR : sl;
    ALUFunc : slv(3 downto 0);
    IMM : slv(31 downto 0);
    is_load : sl;
    is_store : sl;
    BRcond_LStype : slv(2 downto 0);
    Dsel : slv(4 downto 0);
    Dlen : sl;
    PCDsel : sl;
    LoadDsel : sl;
  end record control_word_id_ex;

  constant CONTROL_WORD_ID_EX_NOP : control_word_id_ex := (
    PCAsel => '0',
    IMMBsel => '0',
    PCle => '0',
    isBR => '0',
    ALUFunc => (others => '0'),
    IMM => (others => '0'),
    is_load => '0',
    is_store => '0',
    BRcond_LStype => (others => '0'),
    Dsel => (others => '0'),
    Dlen => '0',
    PCDsel => '0',
    LoadDsel => '0'
  );

  type control_word_ex_mem is record
    is_load : sl;
    is_store : sl;
    BRcond_LStype : slv(2 downto 0);
    Dsel : slv(4 downto 0);
    Dlen : sl;
    PCDsel : sl;
    LoadDsel : sl;
  end record control_word_ex_mem;

  constant CONTROL_WORD_EX_MEM_NOP : control_word_ex_mem := (
    is_load => '0',
    is_store => '0',
    BRcond_LStype => (others => '0'),
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
    id_ex.PCAsel := if_id.PCAsel;
    id_ex.IMMBsel := if_id.IMMBsel;
    id_ex.PCle := if_id.PCle;
    id_ex.isBR := if_id.isBR;
    id_ex.ALUFunc := if_id.ALUFunc;
    id_ex.IMM := if_id.IMM;
    id_ex.is_load := if_id.is_load;
    id_ex.is_store := if_id.is_store;
    id_ex.BRcond_LStype := if_id.BRcond_LStype;
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
