library IEEE;
use IEEE.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;
use work.mi_package.all;

package RISCV_package is
  constant XLEN_BITS : integer := 5;
  constant XLEN : integer := 2 ** XLEN_BITS;
  constant REGS_ADDR_BITS : integer := 5;
  constant MEM_ADDR_BITS : integer := 32;
  constant PRE_FETCH_SIZE : integer := 4;

  -- Function to create a vector from a bit
  function to_boolean(x : sl) return boolean;

  -- Function to convert boolean to sl
  function to_sl(L : BOOLEAN) return std_ulogic;

  -- Function to convert sl to boolean
  function to_vector(x : sl) return slv;

  -- function to return the ceiling of log base 2 of x
  function clog2(X : integer) return integer;

  type slv_array_32 is array (natural range <>) of slv(31 downto 0);
  type control_word is record
    Asel : slv(4 downto 0);
    Bsel : slv(4 downto 0);
    Dsel : slv(4 downto 0);
    Dlen : sl;
    PCAsel : sl;
    IMMBsel : sl;
    PCDsel : sl;
    PCie : sl;
    PCle : sl; --might not needed
    isBR : sl;
    BRcond : slv(2 downto 0);
    ALUFunc : slv(3 downto 0);
    IMM : slv(31 downto 0);
  end record control_word;

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
