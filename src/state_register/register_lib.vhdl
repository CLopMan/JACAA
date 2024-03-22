library ieee; -- biblioteca
use ieee.std_logic_1164.all;

use work.Constants;

entity Reg is 
    port(
        clk: in std_logic;
        rst: in std_logic;
        update: in std_logic;
        in_data: in std_logic_vector(Constants.WORD_SIZE - 1 downto 0);
        out_data: out std_logic_vector(Constants.WORD_SIZE - 1 downto 0)
    );
end Reg; 


architecture Behaviour of Reg is 
    signal keeped_data: std_logic_vector (Constants.WORD_SIZE - 1 downto 0);
begin 
    process (clk, rst)
    begin 
        if rst = '1' then keeped_data <= (others => '0');
        elsif rising_edge(clk) then 
            if update = '1' then keeped_data <= in_data; 
            end if;
        end if;
    end process; 

    out_data <= keeped_data;             

end architecture Behaviour;
