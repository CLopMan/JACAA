library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use Work.Constants;
use Work.Types;

entity OpcodeDecoder is
    port (
        signal instruction: in Types.word;
        signal invalid_instruction: out std_logic;
        signal microaddress: out Types.microaddress := (others => '0')
    );
end entity OpcodeDecoder;


architecture Rtl of OpcodeDecoder is
    -- Opcode translation table entry type
    type opcode_table_entry is record
        -- Whether this entry corresponds to an invalid instruction
        invalid: std_logic;
        -- Address of the microprogram associated with this instruction
        microaddress: Types.microaddress;
    end record;
    type opcode_table is array(natural range <>) of opcode_table_entry;
    -- TODO: fill memory
    constant OPCODE2MICROADDRESS: opcode_table(0 to 2**Constants.OPCODE_SIZE - 1) := (
        ('0', x"000"),
        ('0', x"001"),
        ('0', x"002"),
        ('0', x"003"),
        ('0', x"004"),
        ('0', x"005"),
        ('0', x"006"),
        ('0', x"007"),
        ('0', x"008"),
        ('0', x"009"),
        ('0', x"00A"),
        ('0', x"00B"),
        ('0', x"00C"),
        ('0', x"00D"),
        ('0', x"00E"),
        ('0', x"00F"),
        others => ('1', "------------")
    );
begin
    process (instruction)
        variable current: opcode_table_entry;
        variable opcode: std_logic_vector(Constants.OPCODE_SIZE - 1 downto 0);
    begin
        opcode := instruction(Constants.OPCODE_SIZE - 1 downto 0);
        current := OPCODE2MICROADDRESS(to_integer(unsigned(opcode)));
        microaddress <= current.microaddress;
        invalid_instruction <= current.invalid;
    end process;
end architecture Rtl;
