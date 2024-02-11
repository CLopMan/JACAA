use library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RegPkg.all;

entity StateRegister is 
    generic(constant SIZE: integer := 32);

    port(
        update: in std_logic; -- signal C7 on the diagram. Update register value
        selector: in std_logic -- signal M7 on the diagram. Select input from bus or Selec
    );

end StateRegister;