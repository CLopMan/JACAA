library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Constants;


entity StateRegister is 

    port(
        signal clk, rst: in std_logic;
        signal in_data0, in_data1: in std_logic_vector(Constants.WORD_SIZE - 1 downto 0);
        signal update: in std_logic;  -- C7 on the diagram. Update register value
        signal selector: in std_logic; -- M7 on the diagram. Select data from bus/SeleC
        signal out_reg: out std_logic_vector(Constants.WORD_SIZE - 1 downto 0);
        signal out_inter_delete: out std_logic_vector(Constants.WORD_SIZE - 1 downto 0) -- this must be deleted
    );

end StateRegister;


architecture behaivour of StateRegister is 

    -- interconexion signals 
    signal mux_reg, reg_data: std_logic_vector(Constants.WORD_SIZE - 1 downto 0);

begin
    -- components 
    mux: entity work.Multiplexor2To1 port map(in_data1, in_data0, selector, mux_reg);
    regis: entity work.Reg port map(clk, rst, update, mux_reg, out_reg);
    out_inter_delete <= mux_reg;
end behaivour;