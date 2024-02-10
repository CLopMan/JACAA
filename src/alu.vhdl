library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

package ALUPkg is
    type state_name is (Zero, Negative, Carry, Overflow);
    type state_type is array (state_name) of std_logic;
end package ALUPkg;


library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use work.ALUPkg.all;

entity ALU is
    generic (word_size: positive := 32);
    port (
        signal A, B: in signed(word_size - 1 downto 0);
        signal op_code: in std_logic_vector(4 downto 0);
        signal C: out signed(word_size - 1 downto 0);
        signal state: out state_type
    );
end entity ALU;


architecture Rtl of ALU is
    signal result: signed(word_size downto 0) := (others => '0');
    constant EMPTY: signed(word_size downto 0) := (others => '0');
    signal A_ext, B_ext: signed(word_size downto 0);
begin
    -- Copy output
    C <= result(word_size - 1 downto 0);
    -- Append '0' to inputs
    A_ext <= '0' & A;
    B_ext <= '0' & B;

    -- Calculate result
    with op_code select
        result <= (others => '0') when "00000", -- No-Op
             A_ext and B_ext when "00001",
             A_ext or B_ext  when "00010",
             A_ext xor B_ext when "00011",
             not A_ext       when "00100",
             A_ext + B_ext   when "00101",
             A_ext - B_ext   when "00110",
             A_ext sll to_integer(B_ext)   when "00111",
             A_ext srl to_integer(B_ext)   when "01000",
             -- TODO: check how arithmetic shifts are done.
             -- Use `resize()` instead of AExt
             -- A sra to_integer(B)   when "01000",
             (others => '0') when others;

    -- Calculate state
    state(Zero)     <= '1' when result = EMPTY else '0';
    state(Negative) <= '1' when result(result'left - 1) = '1' else '0';
    state(Carry)    <= result(result'left);
    state(Overflow) <= '1' when A(A'left) = B(B'left)
                                and (result(result'left - 1) /= A(A'left))
                           else '0';
end architecture Rtl;
