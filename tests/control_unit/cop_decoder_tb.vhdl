library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

library Src;
use Src.Types;

use Work.TestingPkg.assert_eq;

-- A testbench has no ports
entity CopDecoderTB is
end CopDecoderTB;


architecture Rtl of CopDecoderTB is
    signal instruction: Types.word;
    signal sel_cop: std_logic_vector(4 downto 0);
    signal sel: std_logic := '0';
    signal cop: std_logic_vector(4 downto 0);

    pure function inst(opcode, funct3: std_logic_vector; funct7: std_logic)
        return std_logic_vector is
    begin
        return "0" & funct7 & "000000000000000" & funct3 & "00000" & opcode;
    end function;
begin
    -- Component instantiation
    uut: entity Src.CopDecoder port map (instruction, sel_cop, sel, cop);

    process
        type test_case is record
            -- Inputs
            instruction: Types.word;
            sel_cop: std_logic_vector(4 downto 0);
            sel: std_logic;
            -- Expected output
            cop: std_logic_vector(4 downto 0);
        end record;
        -- The patterns to apply
        type tests_array is array (natural range <>) of test_case;
        constant TESTS : tests_array := (
            -- 1: Read microinstruction cop
            (x"00000000", "10101", '1', "10101"),
            -- 2: ADDI
            (inst("0010011", "000", '0'), "11111", '0', "01010"),
            -- 3: SLTI
            (inst("0010011", "010", '0'), "00000", '0', "11010"),
            -- 4: SLTIU
            (inst("0010011", "011", '0'), "11111", '0', "11011"),
            -- 5: XORI
            (inst("0010011", "100", '0'), "00000", '0', "00100"),
            -- 6: ORI
            (inst("0010011", "110", '0'), "11111", '0', "00010"),
            -- 7: ANDI
            (inst("0010011", "111", '0'), "00000", '0', "00001"),
            -- 8: SLLI
            (inst("0010011", "001", '0'), "11111", '0', "00111"),
            -- 9: SRLI
            (inst("0010011", "101", '0'), "00000", '0', "00101"),
            -- 10: SRAI
            (inst("0110011", "101", '1'), "11111", '0', "00110"),
            -- 11: ADD
            (inst("0110011", "000", '0'), "00000", '0', "01010"),
            -- 12: SUB
            (inst("0110011", "000", '1'), "11111", '0', "01011"),
            -- 13: SLL
            (inst("0110011", "001", '0'), "00000", '0', "00111"),
            -- 14: SLT
            (inst("0110011", "010", '0'), "11111", '0', "11010"),
            -- 15: SLTU
            (inst("0110011", "011", '0'), "00000", '0', "11011"),
            -- 16: XOR
            (inst("0110011", "100", '0'), "11111", '0', "00100"),
            -- 17: SRL
            (inst("0110011", "101", '0'), "00000", '0', "00101"),
            -- 18: SRA
            (inst("0110011", "101", '1'), "11111", '0', "00110"),
            -- 19: OR
            (inst("0110011", "110", '0'), "00000", '0', "00010"),
            -- 20: AND
            (inst("0110011", "111", '0'), "11111", '0', "00001")
        );
    begin
        -- Check each pattern
        for i in TESTS'range loop
            -- Set the inputs
            instruction <= TESTS(i).instruction;
            sel_cop <= TESTS(i).sel_cop;
            sel <= TESTS(i).sel;
            -- Wait for the results
            wait for 10 ns;
            -- Check the outputs
            assert_eq(cop, TESTS(i).cop, i);
        end loop;
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end Rtl;
