library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity register_bank is
    generic (
        word_size: positive := 32;
        addr_size: positive := 5
    );
    port (
        signal RA, RB, RC: in unsigned(addr_size - 1 downto 0);
        signal C: in std_logic_vector(word_size - 1 downto 0);
        signal clk, rst, L: in std_logic;
        signal A, B: out std_logic_vector(word_size - 1 downto 0)
    );
end entity register_bank;

architecture rtl of register_bank is
    type reg_state is array(natural range 2**addr_size - 1 downto 0)
                   of std_logic_vector(word_size - 1 downto 0);
    signal State: reg_state := (others => (others => '0'));
begin
    update_state: process(clk, rst)
    begin
        if rst = '1' then
            State <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if L = '1' then
                State(to_integer(RC)) <= C;
            end if;
        end if;
    end process update_state;

    -- Get outputs
    A <= State(to_integer(RA));
    B <= State(to_integer(RB));
end architecture rtl;
