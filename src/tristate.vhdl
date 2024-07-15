library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;
use Work.Constants;

entity TriState is
    generic (
        data_size: positive := Constants.WORD_SIZE
    );
    port(
        -- inputs
        data_in: in std_logic_vector(data_size - 1 downto 0)
            := (others => '0');
        activate: in std_logic := '0';
        -- outputs
        data_out: out std_logic_vector(data_size - 1 downto 0)
            := (others => 'Z')
    );
end TriState;

architecture Rtl of TriState is
begin
    process(activate)
    begin
        if activate = '1' then
            data_out <= data_in;
        else
            data_out <= (others => 'Z');
        end if;
    end process;
end Rtl;

