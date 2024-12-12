library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

library Src;
use Src.Constants;
use Src.Types;

use Work.TestingPkg.assert_eq;
use Work.TestingPkg.to_vec;
use Work.TestingPkg.to_word;

-- A testbench has no ports
entity PerformanceCountersTB is
end PerformanceCountersTB;


architecture Rtl of PerformanceCountersTB is
    signal clk, clk_kill: std_logic;
    signal rst: std_logic := '1';
    signal next_microaddress: Types.microaddress;
    signal clk_cycles, instructions: Types.word;

    pure function microaddr(
        addr: natural range 0 to 2**Constants.MICROADDRESS_SIZE - 1
    ) return std_logic_vector is
    begin
        return to_vec(addr, Constants.MICROADDRESS_SIZE);
    end function;
begin
    -- Component instantiation
    uut: entity Src.PerformanceCounters port map (
        clk, rst, next_microaddress, clk_cycles, instructions
    );

    clock: entity Work.Clock port map (clk_kill, clk);

    process
        type test_case is record
            -- Inputs
            next_microaddress: Types.microaddress;
            -- Expected output
            instructions: Types.word;
        end record;
        -- The patterns to apply
        type tests_array is array (natural range <>) of test_case;
        constant TESTS : tests_array := (
            -- 1: Start at fetch
            (microaddr(1), to_word(0)),
            -- 2: Jump to a microprogram
            (microaddr(16), to_word(0)),
            -- 3: Jump forwards
            (microaddr(18), to_word(0)),
            -- 4: Next microinstruction
            (microaddr(19), to_word(0)),
            -- 5: Finish instruction and jump to fetch
            (microaddr(0), to_word(1)),
            -- Repeat everything again
            -- 6: Jump to a microprogram
            (microaddr(128), to_word(1)),
            -- 7: Next microinstruction
            (microaddr(129), to_word(1)),
            -- 8: Jump forwards
            (microaddr(132), to_word(1)),
            -- 9: Next microinstruction
            (microaddr(133), to_word(1)),
            -- 10: Next microinstruction
            (microaddr(134), to_word(1)),
            -- 11: Finish instruction and jump to fetch
            (microaddr(0), to_word(2))
        );
    begin
        rst <= '0';
        -- Check each pattern
        for i in TESTS'range loop
            -- Set the inputs
            next_microaddress <= TESTS(i).next_microaddress;
            -- Wait for the results
            wait for 10 ns;
            -- Check the outputs
            assert_eq(clk_cycles, to_word(i + 1), i, "clk_cycles", int => true);
            assert_eq(instructions, TESTS(i).instructions, i, "instructions",
                      int => true);
        end loop;
        clk_kill <= '1';
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end Rtl;
