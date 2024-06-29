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
    signal invalid_instruction: std_logic;
    -- Multiplexer cop (determines ALU operation)
    signal mux_cop_data: std_logic_vector(9 downto 0);
    signal mux_cop_out: std_logic_vector(5 downto 0);

    signal microinstruction: ControlMemoryPkg.microinstruction_record;
begin
    next_calc: entity work.NextMicroaddress port map (
        -- Possible next microaddresses
        microaddress, opcode_microaddress, maddr,
        -- Conditions
        state_register, invalid_instruction, mem_ready, IO_ready, interruption,
        -- Condition selection
        condition_sel => microinstruction.C,
        negate => microinstruction.B,
        A0 => microinstruction.A0,
        -- Result
        next_addr => next_microaddress
    );

    instruction_decoder: entity work.InstructionDecoder port map (
        instruction, invalid_instruction, opcode_microaddress
    );

    microaddress_reg: entity Work.Reg generic map(Constants.MICROADDRESS_SIZE)
        port map (clk, rst, '1', next_microaddress, microaddress);

    control_memory: entity work.ControlMemory port map (
        microaddress, microinstruction
    );

    -- TODO: should these be grouped in another subcomponent?

    -- TODO: implement subcomponents
    sel_register_a: entity Work.RegisterSelector port map (
        instruction, microinstruction.selA, microinstruction.MR, microinstruction.RA
    );
    sel_register_b: entity Work.RegisterSelector port map (
        instruction, microinstruction.selB, microinstruction.MR, microinstruction.RB
    );
    sel_register_c: entity Work.RegisterSelector port map (
        instruction, microinstruction.selC, microinstruction.MR, microinstruction.RC
    );

    mux_cop: entity Work.Multiplexer generic map(1, 5)
        port map(
            sel(0) => microinstruction.MC,
            data_in => mux_cop_data,
            data_out => mux_cop_out
        );
    mux_cop_data <= microinstruction.sel_cop & instruction(4 downto 0);
end architecture Rtl;
