library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use Work.Constants;
use Work.Types;

entity HardwareCounters is
    port (
        signal clk_cycles, instructions: in Types.word;
        -- Selections 10 and 11 are currently unused and thus trying to access
        -- them is undefined behavior
        signal sel: in std_logic_vector(1 downto 0);
        signal counter: out Types.word
    );
end entity HardwareCounters;


architecture Rtl of HardwareCounters is
    signal counters: std_logic_vector(Constants.WORD_SIZE * 4 - 1 downto 0)
        := (others => '-');
begin
    mux: entity Work.Multiplexer generic map(2, Constants.WORD_SIZE)
        port map(sel, counters, counter);
    counters(Constants.WORD_SIZE * 2 - 1 downto 0) <= instructions & clk_cycles;
end architecture Rtl;
