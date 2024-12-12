library IEEE;
use IEEE.Std_Logic_1164.all;

use Work.Constants;

-- Commonly used types
package Types is
    -- `WORD`-size logic vector
    subtype word is std_logic_vector(Constants.WORD_SIZE - 1 downto 0);
    -- `MICROADDRESS`-size logic vector
    subtype microaddress is std_logic_vector(Constants.MICROADDRESS_SIZE - 1 downto 0);
end package Types;
