library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

entity RegisterBank is
    generic (
        word_size: positive := 32;
        addr_size: positive := 5
    );
    port (
        signal RA, RB, RC: in unsigned(addr_size - 1 downto 0);
        signal C: in std_logic_vector(word_size - 1 downto 0);
        signal clk, rst, load: in std_logic;
        signal A, B: out std_logic_vector(word_size - 1 downto 0)
    );
end entity RegisterBank;


architecture Rtl of RegisterBank is
    type reg_state is array(natural range 0 to 2**addr_size - 1)
                   of std_logic_vector(word_size - 1 downto 0);
    signal state: reg_state := (others => (others => '0'));
begin
    update_state: process(clk, rst)
    begin
        if rst = '1' then
            state <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if load = '1' then
                state(to_integer(RC)) <= C;
            end if;
        end if;
    end process update_state;

    -- Get outputs
    A <= state(to_integer(RA));
    B <= state(to_integer(RB));
end architecture Rtl;
