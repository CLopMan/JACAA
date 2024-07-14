library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use Work.Constants;
use Work.Types;

entity RegisterSelector is
    port (
        signal instruction: in
            Types.word;
        signal offset: in std_logic_vector(Constants.REG_ADDR_SIZE - 1 downto 0);
        signal sel: in std_logic;
        signal reg: out std_logic_vector(Constants.REG_ADDR_SIZE - 1 downto 0)
    );
end entity RegisterSelector;


architecture Rtl of RegisterSelector is
    signal from_instruction: std_logic_vector(Constants.REG_ADDR_SIZE - 1 downto 0);
    signal int_offset: natural range 0 to 2**Constants.REG_ADDR_SIZE - 1;
    signal selections: std_logic_vector(Constants.REG_ADDR_SIZE * 2 - 1 downto 0);
begin
    int_offset <= to_integer(unsigned(offset));
    from_instruction <= instruction(
        int_offset + Constants.REG_ADDR_SIZE - 1 downto int_offset
    );

    selector: entity Work.Multiplexer generic map(1, 5)
        port map(sel(0) => sel, data_in => selections, data_out => reg);
    selections <= offset & from_instruction;
end architecture Rtl;
