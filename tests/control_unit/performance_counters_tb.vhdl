library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

library Src;
use Src.Constants;

-- A testbench has no ports
entity PerformanceCountersTB is
end PerformanceCountersTB;


architecture Rtl of PerformanceCountersTB is
    signal clk, clk_kill: std_logic;
    signal rst: std_logic := '1';
    signal next_microaddress:
        std_logic_vector(Constants.MICROADDRESS_SIZE - 1 downto 0);
    signal clk_cycles, instructions:
        std_logic_vector(Constants.WORD_SIZE - 1 downto 0);

    pure function microaddr(
        addr: natural range 0 to 2**Constants.MICROADDRESS_SIZE - 1
    ) return std_logic_vector is
    begin
        return std_logic_vector(to_unsigned(addr, Constants.MICROADDRESS_SIZE));
    end function;

    pure function word(addr: natural) return std_logic_vector is
    begin
        return std_logic_vector(to_unsigned(addr, Constants.WORD_SIZE));
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
            next_microaddress: std_logic_vector(Constants.MICROADDRESS_SIZE - 1 downto 0);
            -- Expected output
            instructions: std_logic_vector(Constants.WORD_SIZE - 1 downto 0);
        end record;
        -- The patterns to apply
        type tests_array is array (natural range <>) of test_case;
        constant TESTS : tests_array := (
            -- 1: Start at fetch
            (microaddr(1), word(0)),
            -- 2: Jump to a microprogram
            (microaddr(16), word(0)),
            -- 3: Jump forwards
            (microaddr(18), word(0)),
            -- 4: Next microinstruction
            (microaddr(19), word(0)),
            -- 5: Finish instruction and jump to fetch
            (microaddr(0), word(1)),
            -- Repeat everything again
            -- 6: Jump to a microprogram
            (microaddr(128), word(1)),
            -- 7: Next microinstruction
            (microaddr(129), word(1)),
            -- 8: Jump forwards
            (microaddr(132), word(1)),
            -- 9: Next microinstruction
            (microaddr(133), word(1)),
            -- 10: Next microinstruction
            (microaddr(134), word(1)),
            -- 11: Finish instruction and jump to fetch
            (microaddr(0), word(2))
        );
    begin
        rst <= '0';
        report "start of test" severity note;
        -- Check each pattern
        for i in TESTS'range loop
            -- Set the inputs
            next_microaddress <= TESTS(i).next_microaddress;
            -- Wait for the results
            wait for 10 ns;
            -- Check the outputs
            assert clk_cycles = word(i + 1)
                report "bad result on test: " & integer'image(i + 1)
                    & ", result: "
                    & integer'image(to_integer(unsigned(clk_cycles)))
                    & ", expected: "
                    & integer'image(to_integer(unsigned(word(i + 1))))
                severity error;
            assert instructions = TESTS(i).instructions
                report "bad result on test: " & integer'image(i + 1)
                    & ", result: "
                    & integer'image(to_integer(unsigned(instructions)))
                    & ", expected: "
                    & integer'image(to_integer(unsigned(TESTS(i).instructions)))
                severity error;
        end loop;
        clk_kill <= '1';
        report "end of test" severity note;
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end Rtl;
