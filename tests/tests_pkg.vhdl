library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_std.all;

library Src;
use Src.Constants;

-- This package add some utilities for testing
-- to_string: convert vector to string in order to be printed with report
-- assert_eq: general test function asserting that 2 values are equal and
-- printing a formatted output if they aren't
-- to_word: convert integer to word type (WORD_SIZE std_logic_vector)
-- to_vec: convert integer to std_logic_vector of specified size 
package TestingPkg is
    function to_string(a: std_logic_vector) return string;
    function to_vec(a: integer; size: integer) return std_logic_vector;
    function to_word(a: integer) return std_logic_vector;

    -- Only use for types that can't be printed
    procedure assert_true(
        -- Comparison to check
        check: boolean;
        -- ID of the test, starting at 0
        id: natural;
        -- Optional name of the test, in case there are multiple different
        -- checks in a given testbench
        test_name: string := ""
    );

    -- Generic assert eq, requires manual output formatting. Use the other
    -- overloads if possible
    procedure assert_eq(
        -- Comparison to check
        comparison: boolean;
        -- Formatted value found/expected
        found, expected: string;
        -- ID of the test, starting at 0
        id: natural;
        -- Optional name of the test, in case there are multiple different
        -- checks in a given testbench
        test_name: string := ""
    );
    procedure assert_eq(
        found, expected: std_logic;
        id: natural;
        test_name: string := ""
    );
    procedure assert_eq(
        found, expected: std_logic_vector;
        id: natural;
        test_name: string := "";
        -- Whether the vector should be printed as an integer or in binary
        int: boolean := false
    );
    procedure assert_eq(
        found, expected: signed;
        id: natural;
        test_name: string := ""
    );
    procedure assert_eq(
        found, expected: unsigned;
        id: natural;
        test_name: string := ""
    );
    procedure assert_eq(
        found, expected: integer;
        id: natural;
        test_name: string := ""
    );
end package TestingPkg;

package body TestingPkg is
    function to_string(a: std_logic_vector) return string is
        variable b: string (1 to a'length) := (others => NUL);
        variable stri: integer := 1;
    begin
        for i in a'range loop
            -- std_logic image starts with '
            -- Must extract the second char, which is the value
            b(stri) := std_logic'image(a((i)))(2);

            stri := stri + 1;
        end loop;
        return b;
    end function;

    function to_vec(a: integer; size: integer) return std_logic_vector is
    begin
        return std_logic_vector(to_signed(a, size));
    end function;

    function to_word(a: integer) return std_logic_vector is
    begin
        return to_vec(a, Constants.WORD_SIZE);
    end function;

    procedure assert_eq(
        comparison: boolean;
        found, expected: string;
        id: natural;
        test_name: string := ""
    ) is
        variable name_prefix: string(0 to test_name'length) := (others => NUL);
    begin
        if test_name /= "" then
            name_prefix := test_name & "-";
        end if;
        assert comparison
            report ESC & "[31;1m[FAILURE]" & ESC & "[0m " & name_prefix & natural'image(id + 1) & LF
                & "Expected: " & expected & LF
                & "Found:    " & found
            severity error;
    end procedure;

    procedure assert_eq(
        found, expected: std_logic; id: natural; test_name: string := ""
    ) is
    begin
        assert_eq(
            found = expected,
            std_logic'image(found),
            std_logic'image(expected),
            id, test_name
        );
    end procedure;

    procedure assert_eq(
        found, expected: std_logic_vector; id: natural; test_name: string := "";
        int: boolean := false
    ) is
    begin
        if int then
            assert_eq(
                found = expected,
                integer'image(to_integer(unsigned(found))),
                integer'image(to_integer(unsigned(expected))),
                id, test_name
            );
        else
            assert_eq(
                found = expected,
                to_string(found),
                to_string(expected),
                id, test_name
            );
        end if;
    end procedure;

    procedure assert_eq(
        found, expected: signed; id: natural; test_name: string := ""
    ) is
    begin
        assert_eq(
            found = expected,
            integer'image(to_integer(found)),
            integer'image(to_integer(expected)),
            id, test_name
        );
    end procedure;

    procedure assert_eq(
        found, expected: unsigned; id: natural; test_name: string := ""
    ) is
    begin
        assert_eq(
            found = expected,
            integer'image(to_integer(found)),
            integer'image(to_integer(expected)),
            id, test_name
        );
    end procedure;

    procedure assert_eq(
        found, expected: integer; id: natural; test_name: string := ""
    ) is
    begin
        assert_eq(
            found = expected,
            integer'image(found),
            integer'image(expected),
            id, test_name
        );
    end procedure;

    procedure assert_true(
        check: boolean; id: natural; test_name: string := ""
    ) is
    begin
        assert_eq(
            check,
            "<can't display>", "<can't display>",
            id, test_name
        );
    end procedure;
end package body TestingPkg;
