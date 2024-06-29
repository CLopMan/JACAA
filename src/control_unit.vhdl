library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use work.Constants;

entity ControlUnit is
    generic (
        constant SIZE : positive := 80
    );
    port (
        -- Internal connections
        signal instruction_register: in
            std_logic_vector(Constants.WORD_SIZE - 1 downto 0);
        signal state_register: in
            std_logic_vector(Constants.WORD_SIZE - 1 downto 0);
        signal clk, rst: in std_logic;
        signal control_signals: out std_logic_vector(SIZE - 1 downto 0);
        -- External connections
        signal interrupt: in std_logic;
        signal memory_ready: in std_logic;
        signal IO_ready: in std_logic;
        signal read: out std_logic;
        signal write: out std_logic;
        signal IO_write: out std_logic;
        signal INTA: out std_logic
    );
end entity ControlUnit;


architecture Rtl of ControlUnit is
    -- TODO: refactor code: improve signal names, remove unnecessary ones
    -- Constants
    constant MICROADDRESS_SIZE: positive := 12;
    constant MICROINSTRUCTION_SIZE: positive := 80;
    constant OPCODE_SIZE: positive := 7;
    constant FETCH: std_logic_vector(MICROADDRESS_SIZE - 1 downto 0)
        := (others => '0');
    -- Multiplexer A (select next microaddress)
    signal opcode_microaddress, maddr:
        std_logic_vector(MICROADDRESS_SIZE - 1 downto 0);
    signal mux_a_in: std_logic_vector(MICROADDRESS_SIZE * 4 downto 0);
    signal next_microaddress: std_logic_vector(MICROADDRESS_SIZE - 1 downto 0);
    -- Multiplexer B (partially determines mux A selection)
    signal jump_condition: std_logic;
    signal mux_b_in: std_logic_vector(1 downto 0);
    -- Multiplexer C (determines mux B input)
    signal mux_c_in: std_logic_vector(15 downto 0);
    signal selected_jump_condition: std_logic;
    -- Multiplexer cop (determines ALU operation)
    signal mux_cop_data: std_logic_vector(9 downto 0);
    signal mux_cop_out: std_logic_vector(5 downto 0);

    signal microaddress: std_logic_vector(MICROADDRESS_SIZE - 1 downto 0);

    signal C: std_logic_vector(3 downto 0);
    signal B, A0, MR, MC: std_logic;
    signal sel_a, sel_b, sel_c, sel_cop: std_logic_vector(4 downto 0);
    signal immediate: std_logic_vector(3 downto 0);

    signal control_memory_out: std_logic_vector(79 downto 0);
    type memory is array(natural range <>) of
        std_logic_vector(MICROINSTRUCTION_SIZE - 1 downto 0);
    constant CONTROL_MEMORY: memory(0 to 256) := (
        x"00000000000000000000",
        x"00000000000000000001",
        x"00000000000000000002",
        x"00000000000000000003",
        x"00000000000000000004",
        x"00000000000000000005",
        x"00000000000000000006",
        x"00000000000000000007",
        x"00000000000000000008",
        x"00000000000000000009",
        x"0000000000000000000A",
        x"0000000000000000000B",
        x"0000000000000000000C",
        x"0000000000000000000D",
        x"0000000000000000000E",
        x"0000000000000000000F",
        others => (others => '0')
    );

    signal opcode2microaddress_out: std_logic_vector(MICROADDRESS_SIZE downto 0);
    type opcode_index is array(natural range <>) of
        -- MSB is used to determine if the result is valid
        std_logic_vector(MICROADDRESS_SIZE downto 0);
    constant OPCODE2MICROADDRESS: opcode_index(0 to 2**OPCODE_SIZE - 1) := (
        '0' & x"000",
        '0' & x"001",
        '0' & x"002",
        '0' & x"003",
        '0' & x"004",
        '0' & x"005",
        '0' & x"006",
        '0' & x"007",
        '0' & x"008",
        '0' & x"009",
        '0' & x"00A",
        '0' & x"00B",
        '0' & x"00C",
        '0' & x"00D",
        '0' & x"00E",
        '0' & x"00F",
        others => ('1' & x"000")
    );
begin
    mux_a: entity Work.Multiplexer generic map (2, MICROADDRESS_SIZE)
        port map (
            sel(1) => jump_condition,
            sel(0) => A0,
            data_in => mux_a_in,
            data_out => next_microaddress
        );
    mux_a_in <= FETCH & maddr & opcode_microaddress & std_logic_vector(unsigned(microaddress) + 1);

    mux_b: entity Work.Multiplexer generic map(1, 1)
        port map(
            sel(0) => B,
            data_in => mux_b_in,
            data_out(0) => jump_condition
        );
    mux_b_in <= not selected_jump_condition & selected_jump_condition;

    mux_c: entity Work.Multiplexer generic map(4, 1)
        port map(
            sel => C,
            data_in => mux_c_in,
            data_out(0) => selected_jump_condition
        );
    mux_c_in <= opcode2microaddress_out(MICROADDRESS_SIZE)
                & state_register(31 downto 28)
                & state_register(1 downto 0)
                & memory_ready
                & IO_ready
                & interrupt
                & '0';

    -- TODO: implement subcomponents
    sel_register_a: entity Work.RegisterSelector
        port map (instruction_register, selA, MR, RA);
    sel_register_b: entity Work.RegisterSelector
        port map (instruction_register, selB, MR, RB);
    sel_register_c: entity Work.RegisterSelector
        port map (instruction_register, selC, MR, RC);

    mux_cop: entity Work.Multiplexer generic map(1, 5)
        port map(
            sel(0) => MC,
            data_in => mux_cop_data,
            data_out => mux_cop_out
        );
    mux_cop_data <= sel_cop & instruction_register(4 downto 0);

    microaddress_reg: entity Work.Reg generic map(MICROADDRESS_SIZE)
        port map (
            clk => clk,
            rst => rst,
            update => '1',
            in_data => next_microaddress,
            out_data => microaddress
        );

    control_memory_out <= CONTROL_MEMORY(to_integer(unsigned(microaddress)));
    C <= control_memory_out(79 downto 76);
    B <= control_memory_out(75);
    A0 <= control_memory_out(74);
    MR <= control_memory_out(73);
    sel_a <= control_memory_out(72 downto 68);
    sel_b <= control_memory_out(67 downto 63);
    sel_c <= control_memory_out(62 downto 58);
    MC <= control_memory_out(9);
    sel_cop <= control_memory_out(8 downto 4);
    immediate <= control_memory_out(3 downto 0);

    opcode2microaddress_out <= OPCODE2MICROADDRESS(
        -- Get the highest `OPCODE_SIZE` bits from the instruction register
        -- (opcode bits)
        to_integer(unsigned(instruction_register(
            Constants.WORD_SIZE - 1 downto Constants.WORD_SIZE - 1 - OPCODE_SIZE
        )))
    );
    opcode_microaddress <= opcode2microaddress_out(MICROADDRESS_SIZE - 1 downto 0);
end architecture Rtl;
