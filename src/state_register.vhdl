library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Constants;
use work.Types;

entity StateRegister is
    port(
        signal clk, rst: in std_logic;
        signal in_data0, in_data1: in Types.word;
        signal update: in std_logic;  -- C7 on the diagram. Update register value
        signal selector: in std_logic; -- M7 on the diagram. Select data from bus/SeleC
        signal out_reg: out Types.word;
        signal out_inter_delete: out Types.word -- this must be deleted
    );
end StateRegister;


architecture behaviour of StateRegister is
    -- interconexion signals
    signal mux_reg: Types.word;
    signal mux_data: std_logic_vector(2*Constants.WORD_SIZE - 1 downto 0);
begin
    mux_data <= in_data1 & in_data0;
    mux: entity work.Multiplexer
        generic map (
            sel_size => 1,
            data_size => Constants.WORD_SIZE
        )
        port map(
            sel(0) => selector,
            data_in => mux_data,
            data_out => mux_reg
        );
    regis: entity work.Reg
        port map(clk, rst, update, mux_reg, out_reg);
    out_inter_delete <= mux_reg;
end behaviour;
