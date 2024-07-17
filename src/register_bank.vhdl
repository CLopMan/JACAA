library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use work.Constants;
use work.Types;

entity RegisterBank is
    port (
        signal RA, RB, RC: in unsigned(Constants.REG_ADDR_SIZE - 1 downto 0);
        signal C: in Types.word;
        signal clk, rst, load: in std_logic;
        signal A, B: out Types.word
    );
end entity RegisterBank;


architecture Rtl of RegisterBank is
    type reg_state is array(natural range 1 to 2**Constants.REG_ADDR_SIZE - 1)
                   of Types.word;
    signal state: reg_state := (others => (others => '0'));

    pure function read(s: reg_state; i: unsigned) return Types.word is
    begin
        if i = 0 then
            return (others => '0');
        else
            return s(to_integer(i));
        end if;
    end function;
begin
    update_state: process(clk, rst)
    begin
        if rst = '1' then
            state <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if load = '1' and RC /= 0 then
                state(to_integer(RC)) <= C;
            end if;
        end if;
    end process update_state;

    -- Get outputs
    A <= read(state, RA);
    B <= read(state, RB);
end architecture Rtl;
