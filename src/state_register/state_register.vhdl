library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.regpkg;
use work.multiplexor2to1pkg;

entity StateRegister is 
    generic(constant SIZE: integer := regpkg.SIZE);

    port(
        signal clk, rst: in std_logic;
        signal in_data0, in_data1: in std_logic_vector(SIZE - 1 downto 0);
        signal update: in std_logic;  -- C7 on the diagram. Update register value
        signal selector: in std_logic; -- M7 on the diagram. Select data from bus/SeleC
        signal out_reg: out std_logic_vector(SIZE - 1 downto 0);
        signal out_inter_delete: out std_logic_vector(SIZE - 1 downto 0) -- this must be deleted
    );

end StateRegister;


architecture behaivour of StateRegister is 

    -- interconexion signals 
    signal mux_reg, reg_data: std_logic_vector(SIZE - 1 downto 0);

begin
    -- components 
    mux: component multiplexor2to1pkg.Multiplexor2To1 port map(in_data1, in_data0, selector, mux_reg);
    regis: component regpkg.Reg port map(clk, rst, update, mux_reg, out_reg);
    out_inter_delete <= mux_reg;
end behaivour;