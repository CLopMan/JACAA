library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

library Src;
use Src.Constants;
use Src.Types;

-- A testbench has no ports
entity JumpConditionTB is
end JumpConditionTB;


architecture Rtl of JumpConditionTB is
    signal state_register: Types.word := (others => '0');
    signal invalid_instruction, mem_ready, IO_ready, interruption: std_logic
        := '0';
    signal condition_sel: std_logic_vector(3 downto 0) := (others => '0');
    signal negate, jump: std_logic := '0';
begin
    -- Component instantiation
    uut: entity Src.JumpCondition port map (
        state_register,
        invalid_instruction, mem_ready, IO_ready, interruption,
        condition_sel, negate, jump
    );

    process
        type test_case is record
            -- Inputs
            state_register: Types.word;
            invalid_instruction, mem_ready, IO_ready, interruption: std_logic;
            condition_sel: std_logic_vector(3 downto 0);
            negate: std_logic;
            -- Expected output
            jump: std_logic;
        end record;
        -- The patterns to apply
        type tests_array is array (natural range <>) of test_case;
        constant TESTS : tests_array := (
            ( -- 1: Constant 0
                "11111111111111111111111111111111",
                '1', '1', '1', '1',
                "0000", '0', '0'
            ),
            ( -- 2: Constant 0+negate
                "11111111111111111111111111111111",
                '1', '1', '1', '1',
                "0000", '1', '1'
            ),
            ( -- 3: Interruption 1
                "00000000000000000000000000000000",
                '0', '0', '0', '1',
                "0001", '0', '1'
            ),
            ( -- 4: Interruption 0
                "00000000000000000000000000000000",
                '0', '0', '0', '0',
                "0001", '0', '0'
            ),
            ( -- 5: Interruption+negate
                "00000000000000000000000000000000",
                '0', '0', '0', '1',
                "0001", '1', '0'
            ),
            ( -- 6: IO_ready 1
                "00000000000000000000000000000000",
                '0', '0', '1', '0',
                "0010", '0', '1'
            ),
            ( -- 7: IO_ready 0
                "11111100000000000000000000000011",
                '1', '1', '0', '0',
                "0010", '0', '0'
            ),
            ( -- 8: IO_ready+negate
                "00000000000000000000000000000000",
                '0', '0', '0', '0',
                "0010", '1', '1'
            ),
            ( -- 9: mem_ready 1
                "00000000000000000000000000000000",
                '0', '1', '0', '0',
                "0011", '0', '1'
            ),
            ( -- 10: mem_ready 0
                "11111111111111111111111111111111",
                '1', '0', '1', '1',
                "0011", '0', '0'
            ),
            ( -- 11: IO_ready+negate
                "00000000000000000000000000000000",
                '0', '1', '0', '0',
                "0011", '1', '0'
            ),
            ( -- 12: state register user mode 1
                "00000000000000000000000000000001",
                '0', '0', '0', '0',
                "0100", '0', '1'
            ),
            ( -- 13: state register user mode 0
                "11111111111111111111111111111110",
                '0', '0', '0', '0',
                "0100", '0', '0'
            ),
            ( -- 14: state register user mode+negate
                "00000000000000000000000000000000",
                '1', '1', '1', '1',
                "0100", '1', '1'
            ),
            ( -- 15: state register interruptions enabled 1
                "00000000000000000000000000000010",
                '0', '0', '0', '0',
                "0101", '0', '1'
            ),
            ( -- 16: state register interruptions enabled 0
                "11111111111111111111111111111101",
                '1', '1', '1', '1',
                "0101", '0', '0'
            ),
            ( -- 17: state register zero 1
                "00010000000000000000000000000000",
                '0', '0', '1', '0',
                "0110", '0', '1'
            ),
            ( -- 18: state register zero 0
                "11101111111111111111111111111111",
                '1', '1', '1', '1',
                "0110", '0', '0'
            ),
            ( -- 19: state register negative 1
                "00100000000000000000000000000000",
                '0', '0', '0', '0',
                "0111", '0', '1'
            ),
            ( -- 20: state register negative 0
                "11011111111111111111111111111111",
                '0', '0', '0', '0',
                "0111", '0', '0'
            ),
            ( -- 21: state register overflow 1
                "01000000000000000000000000000000",
                '0', '0', '0', '0',
                "1000", '0', '1'
            ),
            ( -- 22: state register overflow 0
                "00000000000000000000000000000000",
                '0', '0', '0', '0',
                "1000", '0', '0'
            ),
            ( -- 23: state register carry 1
                "10000000000000000000000000000000",
                '0', '0', '0', '0',
                "1001", '0', '1'
            ),
            ( -- 24: state register carry 0
                "01111111111111111111111111111111",
                '1', '1', '1', '1',
                "1001", '0', '0'
            ),
            ( -- 25: instruction exception 1
                "00000000000000000000000000000000",
                '1', '0', '0', '0',
                "1010", '0', '1'
            ),
            ( -- 26: instruction exception 0
                "11111111111111111111111111111111",
                '0', '1', '1', '1',
                "1010", '0', '0'
            ),
            ( -- 27: instruction exception+negate
                "00000000000000000000000000000000",
                '1', '0', '0', '0',
                "1010", '1', '0'
            )
        );
    begin
        report "start of test" severity note;
        -- Check each pattern
        for i in TESTS'range loop
            -- Set the inputs
            state_register <= TESTS(i).state_register;
            invalid_instruction <= TESTS(i).invalid_instruction;
            mem_ready <= TESTS(i).mem_ready;
            IO_ready <= TESTS(i).IO_ready;
            interruption <= TESTS(i).interruption;
            condition_sel <= TESTS(i).condition_sel;
            negate <= TESTS(i).negate;
            -- Wait for the results
            wait for 10 ns;
            -- Check the outputs
            assert jump = TESTS(i).jump
                report "bad result on test: " & integer'image(i + 1)
                    & ", result: "
                    & std_logic'image(jump)
                    & ", expected: "
                    & std_logic'image(TESTS(i).jump)
                severity error;
        end loop;
        report "end of test" severity note;
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end Rtl;
