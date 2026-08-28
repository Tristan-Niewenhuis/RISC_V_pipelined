library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

package mi_package is
    subtype sl is std_logic;
    subtype slv is std_logic_vector;

    function decode(signal sel : slv; signal enable : sl) return slv;
    function vector_and(signal to_and : slv) return sl;
end mi_package;

package body mi_package is

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
end mi_package;
