library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

library Src;
use Src.ALUPkg.all;

use Work.TestingPkg.all;

-- A testbench has no ports
entity ALUTB is
end ALUTB;


architecture Rtl of ALUTB is
    signal A, B: signed(31 downto 0) := (others => '0');
    signal op_code: op_code_name := noop;
    signal C: signed(31 downto 0) := (others => '0');
    signal state: state_type := (others => '0');
begin
    -- Component instantiation
    alu: entity Src.ALU port map (A, B, op_code, C, state);

    process
        type test_case is record
            -- Inputs
            A, B: signed(31 downto 0);
            op_code: op_code_name;
            -- Expected output
            C: signed(31 downto 0);
            state: state_type;
        end record;
        -- The patterns to apply
        type tests_array is array (natural range <>) of test_case;
        constant TESTS: tests_array := (
            ( -- 1: No-Op test. Always results in 0
                x"00000001", x"00000003", noop,
                x"00000000", (Zero => '1', others => '0')
            ),
            ( -- 2: Bitwise AND test
                "00000000000000000000000000000001",
                "00000000000000000000000000000011", land,
                "00000000000000000000000000000001", (others => '0')
            ),
            ( -- 3: Bitwise OR test
                "00000000000000000000000000000011",
                "00000000000000000000000000000101", lor,
                "00000000000000000000000000000111", (others => '0')
            ),
            ( -- 4: Bitwise XOR test
                "00000000000000000000000000000011",
                "00000000000000000000000000000101", lxor,
                "00000000000000000000000000000110", (others => '0')
            ),
            ( -- 5: Bitwise NOT A test
                "00000000000000000000000000010101",
                "00000000000000000000000000000010", lnot,
                "11111111111111111111111111101010",
                (Zero => '0', others => '1')
            ),
            ( -- 6: Addition test 1
                to_signed(3, 32), to_signed(5, 32), add,
                to_signed(8, 32), (others => '0')
            ),
            ( -- 7: Addition test 2
                to_signed(10, 32), to_signed(-5, 32), add,
                to_signed(5, 32), (Carry => '1', others => '0')
            ),
            ( -- 8: Addition test 3
                to_signed(-5, 32), to_signed(10, 32), add,
                to_signed(5, 32), (Carry => '1', others => '0')
            ),
            ( -- 9: Addition test 4
                to_signed(-5, 32), to_signed(-5, 32), add,
                to_signed(-10, 32),
                (Negative => '1', Carry => '1', others => '0')
            ),
            ( -- 10: Addition test 5
                to_signed(2**29, 32), to_signed(2**29, 32), add,
                to_signed(2**30, 32), (others => '0')
            ),
            ( -- 11: Subtraction test 1
                to_signed(5, 32), to_signed(3, 32), sub,
                to_signed(2, 32), (others => '0')
            ),
            ( -- 12: Subtraction test 2
                to_signed(5, 32), to_signed(-5, 32), sub,
                to_signed(10, 32), (Carry => '1', others => '0')
            ),
            ( -- 13: Subtraction test 3
                to_signed(-5, 32), to_signed(5, 32), sub,
                to_signed(-10, 32), (Negative => '1', others => '0')
            ),
            ( -- 14: Subtraction test 4
                to_signed(-5, 32), to_signed(-5, 32), sub,
                to_signed(0, 32), (Zero => '1', others => '0')
            ),
            ( -- 15: Subtraction test 5
                to_signed(2**30, 32), to_signed(2**30, 32), sub,
                to_signed(0, 32), (Zero => '1', others => '0')
            ),
            ( -- 16: Logical shift left test
                "01000000000000000000000000000010",
                to_signed(1, 32), shift_ll,
                "10000000000000000000000000000100",
                (Negative => '1', Overflow => '1', others => '0')
            ),
            ( -- 17: Logical shift left test by the word size
                "11111111111111111111111111111111",
                to_signed(32, 32), shift_ll,
                "11111111111111111111111111111111",
                (Negative => '1', others => '0')
            ),
            ( -- 18: Logical shift left test by more than the word size with MSB unset
                "01111111111111111111111111111111",
                to_signed(33, 32), shift_ll,
                "11111111111111111111111111111110",
                (Negative => '1', Overflow => '1', others => '0')
            ),
            ( -- 19: Logical shift left test by more than the word size with MSB set
                "11111111111111111111111111111111",
                to_signed(33, 32), shift_ll,
                "11111111111111111111111111111110",
                (Negative => '1', Carry => '1', others => '0')
            ),
            ( -- 20: Logical shift right test with MSB unset
                "01000000000000000000000000000010",
                to_signed(1, 32), shift_lr,
                "00100000000000000000000000000001", (others => '0')
            ),
            ( -- 21: Logical shift right test with MSB set
                "11000000000000000000000000000010",
                to_signed(1, 32), shift_lr,
                "01100000000000000000000000000001", (others => '0')
            ),
            ( -- 22: Logical shift right test by the word size
                "11111111111111111111111111111111",
                to_signed(32, 32), shift_lr,
                "11111111111111111111111111111111",
                (Negative => '1', others => '0')
            ),
            ( -- 23: Logical shift right test by more than the word size
                "11111111111111111111111111111111",
                to_signed(33, 32), shift_lr,
                "01111111111111111111111111111111",
                (others => '0')
            ),
            ( -- 24: Negative result test
                to_signed(5, 32), to_signed(6, 32), sub,
                to_signed(-1, 32),
                (Negative => '1', Carry => '1', others => '0')
            ),
            ( -- 25: Carry result test
                "11111111111111111111111111111111", to_signed(1, 32), add,
                to_signed(0, 32), (Zero => '1', Carry => '1', others => '0')
            ),
            ( -- 26: Overflow result test
                "01111111111111111111111111111111", to_signed(1, 32), add,
                "10000000000000000000000000000000",
                (Negative => '1', Overflow => '1', others => '0')
            )
        );
    begin
        -- Check each pattern
        for i in TESTS'range loop
            -- Set the inputs
            A <= TESTS(i).A;
            B <= TESTS(i).B;
            op_code <= TESTS(i).op_code;
            -- Wait for the results
            wait for 10 ns;
            -- Check the outputs
            assert_eq(C, TESTS(i).C, i, "ALU");
            assert_true(state = TESTS(i).state, i, "State");
        end loop;
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end Rtl;
