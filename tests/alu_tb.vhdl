library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

library Src;
use Src.ALUPkg.all;

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
        constant TESTS : tests_array := (
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
            ( -- 6: Addition test
                to_signed(3, 32), to_signed(5, 32), add,
                to_signed(8, 32), (others => '0')
            ),
            ( -- 7: Subtraction test
                to_signed(5, 32), to_signed(3, 32), sub,
                to_signed(2, 32), (others => '0')
            ),
            ( -- 8: Logical shift left test
                "01000000000000000000000000000010",
                to_signed(1, 32), shift_ll,
                "10000000000000000000000000000100",
                (Negative => '1', Overflow => '1', others => '0')
            ),
            ( -- 9: Logical shift left test by the word size
                "11111111111111111111111111111111",
                to_signed(32, 32), shift_ll,
                "11111111111111111111111111111111",
                (Negative => '1', others => '0')
            ),
            ( -- 10: Logical shift left test by more than the word size with MSB unset
                "01111111111111111111111111111111",
                to_signed(33, 32), shift_ll,
                "11111111111111111111111111111110",
                (Negative => '1', Overflow => '1', others => '0')
            ),
            ( -- 11: Logical shift left test by more than the word size with MSB set
                "11111111111111111111111111111111",
                to_signed(33, 32), shift_ll,
                "11111111111111111111111111111110",
                (Negative => '1', Carry => '1', others => '0')
            ),
            ( -- 12: Logical shift right test with MSB unset
                "01000000000000000000000000000010",
                to_signed(1, 32), shift_lr,
                "00100000000000000000000000000001", (others => '0')
            ),
            ( -- 13: Logical shift right test with MSB set
                "11000000000000000000000000000010",
                to_signed(1, 32), shift_lr,
                "01100000000000000000000000000001", (others => '0')
            ),
            ( -- 14: Logical shift right test by the word size
                "11111111111111111111111111111111",
                to_signed(32, 32), shift_lr,
                "11111111111111111111111111111111",
                (Negative => '1', others => '0')
            ),
            ( -- 15: Logical shift right test by more than the word size
                "11111111111111111111111111111111",
                to_signed(33, 32), shift_lr,
                "01111111111111111111111111111111",
                (others => '0')
            ),
            ( -- 16: Negative result test
                to_signed(5, 32), to_signed(6, 32), sub,
                to_signed(-1, 32),
                (Negative => '1', Carry => '1', others => '0')
            ),
            ( -- 17: Carry result test
                "11111111111111111111111111111111", to_signed(1, 32), add,
                to_signed(0, 32), (Zero => '1', Carry => '1', others => '0')
            ),
            ( -- 18: Overflow result test
                "01111111111111111111111111111111", to_signed(1, 32), add,
                "10000000000000000000000000000000",
                (Negative => '1', Overflow => '1', others => '0')
            )
        );
    begin
        assert false report "start of test" severity note;
        -- Check each pattern
        for i in TESTS'range loop
            -- Set the inputs
            A <= TESTS(i).A;
            B <= TESTS(i).B;
            op_code <= TESTS(i).op_code;
            -- Wait for the results
            wait for 10 ns;
            -- Check the outputs
            assert C = TESTS(i).C
                report "bad ALU result on test: " & integer'image(i + 1)
                    & ", result: "
                    & integer'image(to_integer(signed(C)))
                    & ", expected: "
                    & integer'image(to_integer(signed(TESTS(i).C)))
                severity error;
            assert state = TESTS(i).state
                report "bad state result on test: " & integer'image(i + 1)
                severity error;
        end loop;
        assert false report "end of test" severity note;
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end Rtl;
