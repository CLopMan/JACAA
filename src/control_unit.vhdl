library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use Work.Constants;
use Work.Types;

package ControlUnitPkg is
    type control_signals is record
        -- Microinstruction signals
        C0, C1, C2, C3, C4, C5, C6, C7: std_logic;
        T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12: std_logic;
        M1, M2, M7, MA: std_logic;
        MB, MH, sel_p: std_logic_vector(1 downto 0);
        LC, SE: std_logic;
        size, offset: std_logic_vector(4 downto 0);
        BW: std_logic_vector(1 downto 0);
        R, W, TA, TD, IOR, IOW, INTA, I, U: std_logic;
        -- Signals calculated by the control unit
        reg_a, reg_b, reg_c: std_logic_vector(Constants.REG_ADDR_SIZE - 1 downto 0);
        cop: std_logic_vector(4 downto 0);
        clk_cycles, instructions: Types.word;
    end record;
end package ControlUnitPkg;

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use Work.Constants;
use Work.Types;
use Work.ControlMemoryPkg;
use Work.ControlUnitPkg;


entity ControlUnit is
    port (
        -- Internal connections
        signal instruction, state_register: in Types.word;
        signal clk, rst: in std_logic;
        -- External connections
        signal mem_ready, IO_ready, interruption: in std_logic;
        signal control_signals: out ControlUnitPkg.control_signals
    );
end entity ControlUnit;


architecture Rtl of ControlUnit is
    signal opcode_microaddress, next_microaddress, microaddress:
        Types.microaddress;
    signal jump_selection: std_logic_vector(1 downto 0);
    signal invalid_instruction: std_logic;
    -- Multiplexer cop (determines ALU operation)
    signal microinstruction: ControlMemoryPkg.microinstruction_record;
begin
    next_calc: entity Work.NextMicroaddress port map (
        -- Possible next microaddresses
        microaddress, opcode_microaddress, microinstruction.maddr,
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
        clk, rst, next_microaddress,
        control_signals.clk_cycles, control_signals.instructions
    );

    -- TODO: should these 4 components be grouped in another subcomponent?
    sel_register_a: entity Work.RegisterSelector port map (
        instruction, microinstruction.sel_a, microinstruction.MR,
        control_signals.reg_a
    );
    sel_register_b: entity Work.RegisterSelector port map (
        instruction, microinstruction.sel_b, microinstruction.MR,
        control_signals.reg_b
    );
    sel_register_c: entity Work.RegisterSelector port map (
        instruction, microinstruction.sel_c, microinstruction.MR,
        control_signals.reg_c
    );

    cop_decoder: entity Work.CopDecoder port map (
        instruction, microinstruction.sel_cop, microinstruction.MC,
        control_signals.cop
    );
end architecture Rtl;
