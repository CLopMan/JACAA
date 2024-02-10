library IEEE;
use IEEE.Std_Logic_1164.all;

entity Clock is
    generic (period: time := 10 ns);
    port (
        signal kill: in std_logic;
        signal clk: inout std_logic := '0'
    );
end entity Clock;


architecture Rtl of Clock is
begin
    tick: process
    begin
        if kill = '1' then
            wait;
        end if;
        wait for period / 2;
        clk <= not clk;
    end process tick;
end architecture Rtl;
