library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use Work.Constants;
use Work.Types;
use Work.ControlMemoryPkg;

entity ControlUnit is
    generic (
        constant SIZE : positive := 80
    );
    port (
        -- Internal connections
        signal instruction, state_register: in Types.word;
        signal clk, rst: in std_logic;
        signal control_signals: out std_logic_vector(SIZE - 1 downto 0);
        -- External connections
        signal reg_a, reg_b, reg_c: out std_logic_vector(Constants.REG_ADDR_SIZE - 1 downto 0);
        signal cop: out std_logic_vector(5 downto 0);
        signal mem_ready, IO_ready, interruption: in std_logic;
        signal read: out std_logic;
        signal write: out std_logic;
        signal IO_write: out std_logic;
        signal INTA: out std_logic;
        signal performance_counter: out Types.word
    );
end entity ControlUnit;


architecture Rtl of ControlUnit is
    signal opcode_microaddress, maddr, next_microaddress, microaddress:
        Types.microaddress;
    signal jump_selection: std_logic_vector(1 downto 0);
    signal invalid_instruction: std_logic;
    -- Multiplexer cop (determines ALU operation)
    signal mux_cop_data: std_logic_vector(9 downto 0);

    signal microinstruction: ControlMemoryPkg.microinstruction_record;
    signal clk_cycles, instructions: Types.word;
    signal hardware_counters:
        std_logic_vector(Constants.WORD_SIZE * 2 - 1 downto 0);
begin
    -- TODO: connect missing outputs
    next_calc: entity Work.NextMicroaddress port map (
        -- Possible next microaddresses
        microaddress, opcode_microaddress, maddr,
        -- Selection and result
        jump_selection, next_microaddress
    );
    jump_selection(0) <= microinstruction.A0;
    condition: entity Work.JumpCondition port map(
        -- Conditions
        state_register, invalid_instruction, mem_ready, IO_ready, interruption,
        -- Condition selection
        microinstruction.C, microinstruction.B,
        -- Result
        jump_selection(0)
    );

    instruction_decoder: entity Work.InstructionDecoder port map (
        instruction, invalid_instruction, opcode_microaddress
    );

    microaddress_reg: entity Work.Reg generic map(Constants.MICROADDRESS_SIZE)
        port map (clk, rst, '1', next_microaddress, microaddress);

    control_memory: entity Work.ControlMemory port map (
        microaddress, microinstruction
    );

    performance_counters: entity Work.PerformanceCounters port map (
        clk, rst, next_microaddress, clk_cycles, instructions
    );
    performance_counters_mux: entity Work.Multiplexer
        generic map (1, Constants.WORD_SIZE)
        port map (
            sel(0) => microinstruction.MH,
            data_in => hardware_counters,
            data_out => performance_counter
        );
    hardware_counters <= instructions & clk_cycles;

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
