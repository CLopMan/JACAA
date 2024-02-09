library ieee; -- biblioteca
use ieee.std_logic_1164.all;

--                    ___
--     in_data1 -32- |   |
--     in_data2 -32- |   | -32- oud_data
--         selec -1- |___|

entity Multiplexor2To1 is 
    generic(constant size: integer := 32);
    
    port(
        in_data1: in std_logic_vector (size - 1 downto 0); 
        in_data2: in std_logic_vector (size - 1 downto 0); 
        selec: in std_logic;
        out_data: out std_logic_vector(size - 1 downto 0)
    );

end Multiplexor2To1;


architecture behaviour of Multiplexor2To1 is
    begin process(selec)
        begin case selec is 
            when '1' => out_data <= in_data1;
            when '0' => out_data <= in_data2;
            when others => out_data <= (others => 'X');
        end case;
    end process;


end architecture behaviour;