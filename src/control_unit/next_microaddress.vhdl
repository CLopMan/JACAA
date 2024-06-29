library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use Work.Constants;

-- Determines the next microaddress
entity NextMicroaddress is
    port (
        signal current, from_opcode, jump_target: in
            std_logic_vector(Constants.MICROADDRESS_SIZE - 1 downto 0);
        signal state_register: in
            std_logic_vector(Constants.WORD_SIZE - 1 downto 0);
        signal invalid_instruction: in std_logic;
        signal mem_ready, IO_ready, interruption: in std_logic;
        signal condition_sel: in std_logic_vector(3 downto 0);
        signal negate: in std_logic;
        signal A0: in std_logic; -- TODO: is there a better name for this?
        signal next_addr: out std_logic_vector(Constants.MICROADDRESS_SIZE - 1 downto 0)
    );
end entity NextMicroaddress;


architecture Rtl of NextMicroaddress is
    constant FETCH: std_logic_vector(Constants.MICROADDRESS_SIZE - 1 downto 0)
        := (others => '0');
    signal addrs: std_logic_vector(Constants.MICROADDRESS_SIZE * 4 - 1 downto 0);
    signal jump_condition: std_logic;
begin
    addr_selector: entity Work.Multiplexer generic map (2, Constants.MICROADDRESS_SIZE)
        port map (
            sel(1) => jump_condition,
            sel(0) => A0,
            data_in => addrs,
            data_out => next_addr
        );
    addrs <= FETCH & jump_target & from_opcode & std_logic_vector(unsigned(current) + 1);
    condition: entity work.JumpCondition port map(
        -- Conditions
        state_register, invalid_instruction, mem_ready, IO_ready, interruption,
        -- Condition selection
        condition_sel, negate,
        -- Result
        jump_condition
    );
end architecture Rtl;
