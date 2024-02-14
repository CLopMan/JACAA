library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ProgramCounter is 
    generic(
        constant SIZE:integer := 32;
        constant addr_size:integer := 4    
    );
    port(
        -- control signal
        m2: in std_logic; -- mutex selector
        c2: in std_logic; -- update selector

        -- clk & reset 
        clk: in std_logic;
        rst: in std_logic;

        -- data lines 
        from_bus: in std_logic_vector(SIZE - 1 downto 0); 
        -- output 
        out_data: out std_logic_vector(SIZE - 1 downto 0)
    );
end ProgramCounter;

architecture behaviour of ProgramCounter is 
    signal in_data: std_logic_vector(SIZE - 1 downto 0); 
    
begin
    process (clk, rst, m2, c2, from_bus)
    begin
        if rst = '1' then in_data <= (others => '0');
        elsif rising_edge(clk) then 
            if c2 = '1' then 
                if m2 = '1' then 
                    in_data <= std_logic_vector(unsigned(in_data) + addr_size);
                elsif m2 = '0' then 
                    in_data <= from_bus;
                end if;
            end if;
        end if;
    end process;

    out_data <= in_data; 

end behaviour;