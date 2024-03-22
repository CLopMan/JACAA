library ieee;
use work.Constants;
use ieee.std_logic_1164.all;
--                    ___
--     in_data1 -32- |   |
--     in_data2 -32- |   | -32- oud_data
--         selec -1- |___|
entity Multiplexor2To1 is 
    
    port(
        in_data1: in std_logic_vector (Constants.WORD_SIZE - 1 downto 0); 
        in_data0: in std_logic_vector (Constants.WORD_SIZE - 1 downto 0); 
        selec: in std_logic;
        out_data: out std_logic_vector(Constants.WORD_SIZE - 1 downto 0)
    );

end Multiplexor2To1;


architecture behaviour of Multiplexor2To1 is
begin 
    process(selec, in_data0, in_data1)
        begin case selec is 
            when '1' => out_data <= in_data1;
            when '0' => out_data <= in_data0;
            when others => out_data <= (others => 'X');
        end case;
    end process;

end architecture behaviour;