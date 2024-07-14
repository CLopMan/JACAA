library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_std.all;


-- This package add some utilities for testing
-- to_string: convert vector to string in order
-- to be printed with report

package Debug is
    function to_string(a: std_logic_vector)
    return string;
end package Debug;

package body Debug is

    function to_string(a: std_logic_vector) return string is
        variable b : string (1 to a'length) := (others => NUL);
        variable stri : integer := 1;
    begin
        for i in a'range loop
            -- std_logic image starts whit '
            -- Must extract the second char, which is the value
            b(stri) := std_logic'image(a((i)))(2);

            stri := stri + 1;
        end loop;
        return b;
    end function;

end package body Debug;

