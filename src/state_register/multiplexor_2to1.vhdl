
-- PACKAGE 
library ieee; -- biblioteca

package Multiplexor2To1Pkg is 
    use ieee.std_logic_1164.all;
    constant SIZE: integer := 32;

    component Multiplexor2To1 is 
        port (
            in_data1: in std_logic_vector (SIZE - 1 downto 0); 
            in_data0: in std_logic_vector (SIZE - 1 downto 0); 
            selec: in std_logic;
            out_data: out std_logic_vector(SIZE - 1 downto 0)
        );
    end component;

end Multiplexor2To1Pkg; 

package body Multiplexor2To1Pkg is 
end Multiplexor2To1Pkg;

-- END OF PACKAGE

library ieee; -- biblioteca
use ieee.std_logic_1164.all;
use work.Multiplexor2To1Pkg.all;

--                    ___
--     in_data1 -32- |   |
--     in_data2 -32- |   | -32- oud_data
--         selec -1- |___|
entity Multiplexor2To1 is 
    
    port(
        in_data1: in std_logic_vector (SIZE - 1 downto 0); 
        in_data0: in std_logic_vector (SIZE - 1 downto 0); 
        selec: in std_logic;
        out_data: out std_logic_vector(SIZE - 1 downto 0)
    );

end Multiplexor2To1;


architecture behaviour of Multiplexor2To1 is
    begin process(selec, in_data0, in_data1)
        begin case selec is 
            when '1' => out_data <= in_data1;
            when '0' => out_data <= in_data0;
            when others => out_data <= (others => 'X');
        end case;
    end process;


end architecture behaviour;