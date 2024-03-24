library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

package ALUPkg is
    type op_code_name is (
        noop,
        -- Bitwise boolean operations
        land, lor, lxor, lnot,
        -- Arithmetic operations
        add, sub,
        -- Shift operations
        shift_ll, shift_lr, shift_ar
    );
    type state_name is (Zero, Negative, Carry, Overflow);
    type state_type is array (state_name) of std_logic;
end package ALUPkg;


library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use work.ALUPkg.all;
use work.Constants;

entity ALU is
    port (
        signal A, B: in signed(Constants.WORD_SIZE - 1 downto 0);
        signal op_code: in op_code_name;
        signal C: out signed(Constants.WORD_SIZE - 1 downto 0);
        signal state: out state_type
    );
end entity ALU;


architecture Rtl of ALU is
    constant MSB: positive := Constants.WORD_SIZE - 1;

    signal result: signed(Constants.WORD_SIZE downto 0) := (others => '0');
    constant EMPTY: signed(MSB downto 0) := (others => '0');
    signal A_ext, B_ext: signed(Constants.WORD_SIZE downto 0);
    signal shift_n_arith: natural range 0 to MSB;
    signal B_sign: std_logic;
begin
    -- Copy output
    C <= result(result'left - 1 downto 0);
    -- Append '0' to inputs
    A_ext <= '0' & A;
    B_ext <= '0' & B;
    -- Calculate B's sign depending on if the operation is a subtractiob or not
    -- Calculate amount to shift by
    shift_n_arith <= to_integer(unsigned(B)) when unsigned(B) <= MSB else MSB;
    B_sign <= B(B'left) when op_code /= sub else NOT B(B'left);

    -- Calculate result
    with op_code select
        result <= (others => '0') when noop,
             A_ext and B_ext when land,
             A_ext or B_ext  when lor,
             A_ext xor B_ext when lxor,
             not A_ext       when lnot,
             A_ext + B_ext   when add,
             A_ext - B_ext   when sub,
             A_ext sll to_integer(B_ext) when shift_ll,
             A_ext srl to_integer(B_ext) when shift_lr,
             shift_right(A(A'high) & A, shift_n_arith) when shift_ar,
             (others => '0') when others;

    -- Calculate state
    state(Zero)     <= '1' when result(result'left - 1 downto 0) = EMPTY
                           else '0';
    state(Negative) <= '1' when result(result'left - 1) = '1' else '0';
    state(Carry)    <= result(result'left);
    state(Overflow) <= '1' when A(A'left) = B_sign
                                and (result(result'left - 1) /= A(A'left))
                           else '0';
end architecture Rtl;
