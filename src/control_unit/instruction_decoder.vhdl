library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use Work.Constants;

entity InstructionDecoder is
    port (
        signal instruction: in std_logic_vector(Constants.WORD_SIZE - 1 downto 0);
        signal invalid_instruction: out std_logic;
        signal microaddress: out std_logic_vector(11 downto 0)
    );
end entity InstructionDecoder;


architecture Rtl of InstructionDecoder is
    signal current: std_logic_vector(12 downto 0);
    signal opcode: std_logic_vector(6 downto 0);
    type opcode_index is array(natural range <>) of
        -- MSB is used to determine if the result is valid
        std_logic_vector(12 downto 0);
    constant OPCODE2MICROADDRESS: opcode_index(0 to 2**7 - 1) := (
        '0' & x"000",
        '0' & x"001",
        '0' & x"002",
        '0' & x"003",
        '0' & x"004",
        '0' & x"005",
        '0' & x"006",
        '0' & x"007",
        '0' & x"008",
        '0' & x"009",
        '0' & x"00A",
        '0' & x"00B",
        '0' & x"00C",
        '0' & x"00D",
        '0' & x"00E",
        '0' & x"00F",
        others => ('1' & x"000")
    );
begin
    opcode <= instruction(Constants.WORD_SIZE - 1 downto Constants.WORD_SIZE - 7);
    current <= OPCODE2MICROADDRESS(to_integer(unsigned(opcode)));
    microaddress <= current(12 - 1 downto 0);
    invalid_instruction <= current(12);
end architecture Rtl;
