library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

library Src;
use Src.Constants;
use Src.Types;

-- A testbench has no ports
entity RegisterSelectorTB is
end RegisterSelectorTB;


architecture Rtl of RegisterSelectorTB is
    signal instruction: Types.word := (others => '0');
    signal offset: std_logic_vector(Constants.REG_ADDR_SIZE - 1 downto 0)
        := (others => '0');
    signal sel: std_logic := '0';
    signal reg: std_logic_vector(Constants.REG_ADDR_SIZE - 1 downto 0)
        := (others => '0');
begin
    -- Component instantiation
    uut: entity Src.RegisterSelector port map (instruction, offset, sel, reg);

    process
        type test_case is record
            -- Inputs
            instruction: Types.word;
            offset: std_logic_vector(Constants.REG_ADDR_SIZE - 1 downto 0);
            sel: std_logic;
            -- Expected output
            reg: std_logic_vector(Constants.REG_ADDR_SIZE - 1 downto 0);
        end record;
        -- The patterns to apply
        type tests_array is array (natural range <>) of test_case;
        constant TESTS : tests_array := (
            ( -- 1: Read microinstruction ID
                "00000000000000000000000000000000",
                "01010", '1',
                "01010"
            ),
            ( -- 2: Read microinstruction ID 2
                "11111111111111111111111111111111",
                "10011", '1',
                "10011"
            ),
            ( -- 3: Read from instruction
                "10111101101110101111101111100111",
                "00000", '0',
                "00111"
            ),
            ( -- 4: Read from instruction 2
                "10100100100010000100000001010110",
                "11011", '0',
                "10100"
            )
        );
    begin
        report "start of test" severity note;
        -- Check each pattern
        for i in TESTS'range loop
            -- Set the inputs
            instruction <= TESTS(i).instruction;
            offset <= TESTS(i).offset;
            sel <= TESTS(i).sel;
            -- Wait for the results
            wait for 10 ns;
            -- Check the outputs
            assert reg = TESTS(i).reg
                report "bad result on test: " & integer'image(i + 1)
                    & ", result: "
                    & integer'image(to_integer(unsigned(reg)))
                    & ", expected: "
                    & integer'image(to_integer(unsigned(TESTS(i).reg)))
                severity error;
        end loop;
        report "end of test" severity note;
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end Rtl;
