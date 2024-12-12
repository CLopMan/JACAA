library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

library Src;
use Src.Types;

use Work.TestingPkg.assert_eq;
use Work.TestingPkg.to_word;

-- A testbench has no ports
entity HardwareCountersTB is
end HardwareCountersTB;


architecture Rtl of HardwareCountersTB is
    signal clk_cycles, instructions: Types.word;
    signal sel: std_logic_vector(1 downto 0) := "00";
    signal counter: Types.word;
begin
    -- Component instantiation
    register_bank: entity Src.HardwareCounters port map (
        clk_cycles, instructions, sel, counter
    );

    process
        type tests_case is record
            -- Inputs
            clk_cycles, instructions: Types.word;
            sel: std_logic_vector(1 downto 0);
            -- Expected output
            counter: Types.word;
        end record;
        -- The patterns to apply
        type tests_array is array (natural range <>) of tests_case;
        constant TESTS: tests_array := (
            -- 1: Get clk_cycles
            (to_word(1), to_word(5), "00", to_word(1)),
            -- 2: Change clk_cycles
            (to_word(2), to_word(5), "00", to_word(2)),
            -- 3: Change instructions
            (to_word(2), to_word(10), "00", to_word(2)),
            -- 4: Change selection
            (to_word(2), to_word(10), "01", to_word(10)),
            -- 5: Change instructions
            (to_word(2), to_word(32), "01", to_word(32)),
            -- 6: Change clk_cycles
            (to_word(128), to_word(32), "01", to_word(32)),
            -- 7: Change selection
            (to_word(128), to_word(32), "00", to_word(128))
        );
    begin
        -- Check each pattern
        for i in TESTS'range loop
            -- Set the inputs
            clk_cycles <= TESTS(i).clk_cycles;
            instructions <= TESTS(i).instructions;
            sel <= TESTS(i).sel;
            -- Wait for the next clock cycle
            wait for 10 ns;
            -- Check the outputs
            assert_eq(counter, TESTS(i).counter, i, int => true);
        end loop;
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end Rtl;
