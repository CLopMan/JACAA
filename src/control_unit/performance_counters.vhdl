library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use Work.Constants;

-- Determines the microjump selection
entity PerformanceCounters is
    port (
        signal clk, rst: in std_logic;
        signal next_microaddress:
            in std_logic_vector(Constants.MICROADDRESS_SIZE - 1 downto 0);
        signal clk_cycles, instructions:
            out std_logic_vector(Constants.WORD_SIZE - 1 downto 0)
    );
end entity PerformanceCounters;


architecture Rtl of PerformanceCounters is
    signal clk_cycles_in, clk_cycles_out:
        std_logic_vector(Constants.WORD_SIZE - 1 downto 0) := (others => '0');

    signal instructions_in, instructions_out:
        std_logic_vector(Constants.WORD_SIZE - 1 downto 0) := (others => '0');
    signal update_instructions: std_logic;

    pure function increment(value: std_logic_vector) return std_logic_vector is
    begin
        return std_logic_vector(unsigned(value) + 1);
    end function;

    pure function is_zero(value: std_logic_vector) return std_logic is
    begin
        if value = (value'range => '0') then return '1';
        elsif Is_X(value) then return 'X';
        else return '0';
        end if;
    end function;
begin
    -- Clock cycles counter
    clk_cycles_reg: entity Work.Reg port map(
        clk, rst, '1', clk_cycles_in, clk_cycles_out
    );
    clk_cycles_in <= increment(clk_cycles_out);
    clk_cycles <= clk_cycles_out;
    -- Instructions executed counter
    instructions_reg: entity Work.Reg port map(
        clk, rst, update_instructions, instructions_in, instructions_out
    );
    instructions_in <= increment(instructions_out);
    instructions <= instructions_out;
    update_instructions <= is_zero(next_microaddress);
end architecture Rtl;
