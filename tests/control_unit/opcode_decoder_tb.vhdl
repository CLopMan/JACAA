library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

library Src;
use Src.Types;

use Work.TestingPkg.assert_eq;

-- A testbench has no ports
entity OpcodeDecoderTB is
end OpcodeDecoderTB;


architecture Rtl of OpcodeDecoderTB is
    signal instruction: Types.word := (others => '0');
    signal invalid_instruction: std_logic;
    signal microaddress: Types.microaddress;
begin
    -- Component instantiation
    uut: entity Src.OpcodeDecoder port map (instruction, invalid_instruction, microaddress);

    process
        type test_case is record
            -- Inputs
            instruction: Types.word;
            -- Expected output
            invalid_instruction: std_logic;
            microaddress: Types.microaddress;
        end record;
        -- The patterns to apply
        type tests_array is array (natural range <>) of test_case;
        constant TESTS : tests_array := (
            -- TODO: test a few cases once the opcode to microaddress table is
            -- filled
            ("00000000000000000000000000000000", '0', x"000"),
            ("00000000000000000000000000000001", '0', x"001"),
            ("00000000000000000000000000000010", '0', x"002"),
            ("00000000000000000000000001110000", '1', "------------")
        );
    begin
        -- Check each pattern
        for i in TESTS'range loop
            -- Set the inputs
            instruction <= TESTS(i).instruction;
            -- Wait for the results
            wait for 10 ns;
            -- Check the outputs
            assert_eq(invalid_instruction, TESTS(i).invalid_instruction, i,
                      "invalid instruction");
            assert_eq(microaddress, TESTS(i).microaddress, i, "microaddress");
        end loop;
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end Rtl;
