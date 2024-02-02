library IEEE;
use IEEE.std_logic_1164.all;

entity clock is
    generic (period: time := 10 ns);
    port (
        kill: in std_logic;
        clk: inout std_logic := '0'
    );
end entity clock;

architecture rtl of clock is
begin
    -- Clock process definition
    clk_process: process
    begin
        if kill = '1' then
            wait;
        end if;
        wait for period/2;
        clk <= not clk;
    end process;
end architecture rtl;
