library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use Work.Constants;
use Work.ControlMemoryPkg;

entity ControlUnit is
    generic (
        constant SIZE : positive := 80
    );
    port (
        -- Internal connections
        signal instruction: in
            std_logic_vector(Constants.WORD_SIZE - 1 downto 0);
        signal state_register: in
            std_logic_vector(Constants.WORD_SIZE - 1 downto 0);
        signal clk, rst: in std_logic;
        signal control_signals: out std_logic_vector(SIZE - 1 downto 0);
        -- External connections
        signal reg_a, reg_b, reg_c: out std_logic_vector(Constants.REG_ADDR_SIZE - 1 downto 0);
        signal cop: out std_logic_vector(5 downto 0);
        signal mem_ready, IO_ready, interruption: in std_logic;
        signal read: out std_logic;
        signal write: out std_logic;
        signal IO_write: out std_logic;
        signal INTA: out std_logic
    );
end entity ControlUnit;


architecture Rtl of ControlUnit is
    signal opcode_microaddress, maddr, next_microaddress, microaddress:
        std_logic_vector(Constants.MICROADDRESS_SIZE - 1 downto 0);
    signal jump_selection: std_logic_vector(1 downto 0);
    signal invalid_instruction: std_logic;
    -- Multiplexer cop (determines ALU operation)
    signal mux_cop_data: std_logic_vector(9 downto 0);

    signal microinstruction: ControlMemoryPkg.microinstruction_record;
begin
    -- TODO: connect missing outputs
    next_calc: entity work.NextMicroaddress port map (
        -- Possible next microaddresses
        microaddress, opcode_microaddress, maddr,
        -- Selection and result
        jump_selection, next_microaddress
    );
    jump_selection(0) <= microinstruction.A0;
    condition: entity work.JumpCondition port map(
        -- Conditions
        state_register, invalid_instruction, mem_ready, IO_ready, interruption,
        -- Condition selection
        microinstruction.C, microinstruction.B,
        -- Result
        jump_selection(0)
    );

    instruction_decoder: entity work.InstructionDecoder port map (
        instruction, invalid_instruction, opcode_microaddress
    );

    microaddress_reg: entity Work.Reg generic map(Constants.MICROADDRESS_SIZE)
        port map (clk, rst, '1', next_microaddress, microaddress);

    control_memory: entity work.ControlMemory port map (
        microaddress, microinstruction
    );

    -- TODO: should these 4 components be grouped in another subcomponent?
    sel_register_a: entity Work.RegisterSelector port map (
        instruction, microinstruction.sel_a, microinstruction.MR, reg_a
    );
    sel_register_b: entity Work.RegisterSelector port map (
        instruction, microinstruction.sel_b, microinstruction.MR, reg_b
    );
    sel_register_c: entity Work.RegisterSelector port map (
        instruction, microinstruction.sel_c, microinstruction.MR, reg_c
    );

    mux_cop: entity Work.Multiplexer generic map(1, 5)
        port map(
            sel(0) => microinstruction.MC,
            data_in => mux_cop_data,
            data_out => cop
        );
    mux_cop_data <= microinstruction.sel_cop & instruction(4 downto 0);
end architecture Rtl;
