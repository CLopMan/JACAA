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
        shift_ll, shift_lr, shift_ar,
        -- Comparison operations
        less_than, less_than_unsigned
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
    constant EMPTY: signed(MSB downto 0) := (others => '0');

    signal result: signed(Constants.WORD_SIZE downto 0) := (others => '0');
    signal A_ext, B_ext: signed(Constants.WORD_SIZE downto 0);
    signal shift_n, shift_n_arith: natural range 0 to MSB;
    signal B_sign: std_logic;

    pure function lt(lhs, rhs: signed) return signed is
        constant err: signed(Constants.WORD_SIZE downto 0) := (others => 'X');
    begin
        if lhs < rhs then return to_signed(1, Constants.WORD_SIZE+1);
        elsif lhs >= rhs then return to_signed(0, Constants.WORD_SIZE+1);
        else return err;
        end if;
    end function;
begin
    -- Copy output
    C <= result(result'left - 1 downto 0);
    -- Append '0' to inputs
    A_ext <= '0' & A;
    B_ext <= '0' & B;

    -- Calculate amount to shift by
    -- For logical shifts, it's the second value mod WORD_SIZE
    shift_n <= to_integer(unsigned(B) rem Constants.WORD_SIZE);
    -- For arithmetic shifts, the value is clamped at WORD_SIZE
    shift_n_arith <= to_integer(unsigned(B)) when unsigned(B) <= MSB else MSB;

    -- Calculate B's sign depending on if the operation is a subtraction or not
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
             shift_left(A_ext, shift_n) when shift_ll,
             shift_right(A_ext, shift_n) when shift_lr,
             shift_right(A(A'high) & A, shift_n_arith) when shift_ar,
             lt(A, B)         when less_than,
             lt(A_ext, B_ext) when less_than_unsigned,
             (others => '0')  when others;

    -- Calculate state
    state(Zero)     <= '1' when result(result'left - 1 downto 0) = EMPTY
                           else '0';
    state(Negative) <= '1' when result(result'left - 1) = '1' else '0';
    state(Carry)    <= result(result'left);
    state(Overflow) <= '1' when A(A'left) = B_sign
                                and (result(result'left - 1) /= A(A'left))
                                and op_code /= less_than
                                and op_code /= less_than_unsigned
                           else '0';
end architecture Rtl;
