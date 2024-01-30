library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package alu_pkg is
    type StateName is (Zero, Negative, Carry, Overflow);
    type StateType is array (StateName) of std_logic;
end package alu_pkg;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.alu_pkg.all;

entity alu is
    generic (word_size: positive := 32);
    port (
        signal A, B: in signed(word_size - 1 downto 0);
        signal OpCode: in std_logic_vector(4 downto 0);
        signal C: out signed(word_size - 1 downto 0);
        signal State: out StateType
    );
end entity alu;

architecture rtl of alu is
    signal res: signed(word_size downto 0);
    constant Empty: signed(word_size downto 0) := (others => '0');
    signal A33, B33: signed(word_size downto 0);
begin
    -- Copy output
    C <= res(word_size - 1 downto 0);
    -- Append '0' to inputs
    A33 <= '0' & A;
    B33 <= '0' & B;

    -- Calculate result
    with OpCode select
        res <= (others => '0') when "00000", -- No-Op
             A33 and B33 when "00001",
             A33 or B33  when "00010",
             not A33   when "00011",
             A33 xor B33 when "00100",
             A33 + B33   when "00101",
             A33 sll to_integer(B33)   when "00110",
             A33 srl to_integer(B33)   when "00111",
             -- A sra to_integer(B)   when "01000", -- TODO: mirar shift
             -- aritmeticos. Usar resize() en vez de A33
             (others => '0') when others;

    -- Calculate state
    State(Zero)     <= '1' when res = Empty else '0';
    State(Negative) <= '1' when res(res'left - 1) = '1' else '0';
    State(Carry)    <= res(res'left);
    State(Overflow) <= '1' when A(A'Left) = B(B'Left)
                                and (Res(Res'Left - 1) /= A(A'Left))
                           else '0';
end architecture rtl;
