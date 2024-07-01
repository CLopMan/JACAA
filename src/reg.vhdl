library IEEE;
use IEEE.Std_Logic_1164.all;

use work.Constants;

entity Reg is
    generic(
        reg_size: positive := Constants.WORD_SIZE;
        updt_rising: std_logic := '1'
    );
    port(
        clk: in std_logic;
        rst: in std_logic;
        update: in std_logic;
        in_data: in std_logic_vector(reg_size - 1 downto 0);
        out_data: out std_logic_vector(reg_size - 1 downto 0)
    );
end Reg;


architecture Behaviour of Reg is
    signal keeped_data: std_logic_vector (reg_size - 1 downto 0);
begin
    process (clk, rst)
    begin
        if rst = '1' then keeped_data <= (others => '0');
        elsif clk'event and clk = updt_rising then
            if update = '1' then keeped_data <= in_data;
            end if;
        end if;
    end process;

    out_data <= keeped_data;
end architecture Behaviour;
