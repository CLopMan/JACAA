library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use Work.Types;
use Work.Constants;

entity Selec is
   port (
        se: in std_logic; -- sign extension
        size: in integer; -- number of bytes from offset
        offset: in integer; -- least significant bit
        data_in: in Types.word;
        data_out: out Types.word
   );
end Selec;


architecture Rtl of Selec is
begin
    data_out
        <= std_logic_vector(
                resize(signed(data_in(size + offset - 1 downto offset)),
                Constants.WORD_SIZE)
            ) when se = '1' else
            std_logic_vector(
                resize(unsigned(data_in(size + offset - 1 downto offset)),
                Constants.WORD_SIZE)
            ) when se = '0' else
            (others => 'X');
end Rtl;
