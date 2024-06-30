library IEEE;
use IEEE.Std_Logic_1164.all;

use Work.Constants;

-- Determines the microjump selection
entity JumpCondition is
    port (
        signal state_register: in
            std_logic_vector(Constants.WORD_SIZE - 1 downto 0);
        signal invalid_instruction: in std_logic;
        signal mem_ready, IO_ready, interruption: in std_logic;
        signal condition_sel: in std_logic_vector(3 downto 0);
        signal negate: in std_logic;
        signal jump: out std_logic
    );
end entity JumpCondition;


architecture Rtl of JumpCondition is
    signal negated_jump_condition, jump_condition: std_logic;
    signal conditions: std_logic_vector(10 downto 0);
begin
    optional_negation: entity Work.Multiplexer generic map(1, 1)
        port map(
            sel(0) => negate,
            data_in(1) => jump_condition,
            data_in(0) => negated_jump_condition,
            data_out(0) => jump
        );
    negated_jump_condition <= not jump_condition;

    condition_selector: entity Work.Multiplexer generic map(4, 1)
        port map(condition_sel, conditions, data_out(0) => jump_condition);
    conditions <= invalid_instruction
                & state_register(31 downto 28)
                & state_register(1 downto 0)
                & mem_ready
                & IO_ready
                & interruption
                & '0';
end architecture Rtl;
