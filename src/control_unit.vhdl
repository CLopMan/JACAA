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
    constant MICROADDRESS_SIZE: positive := 12;
    constant FETCH: std_logic_vector(MICROADDRESS_SIZE - 1 downto 0)
        := (others => '0');
    constant ONE: positive := 1;
    -- Multiplexer A (select next microaddress)
    signal opcode_microaddress, maddr:
        std_logic_vector(MICROADDRESS_SIZE - 1 downto 0);
    signal mux_a_sel: std_logic_vector(1 downto 0);
    signal mux_a_in: std_logic_vector(MICROADDRESS_SIZE * 4 downto 0);
    signal mux_a_out: std_logic_vector(MICROADDRESS_SIZE - 1 downto 0);
    -- Multiplexer B (partially determines mux A selection)
    signal mux_b_data: std_logic;
    signal mux_b_sel: std_logic;
    signal mux_b_out: std_logic;
    -- Multiplexer C (determines mux B input)
    signal mux_c_sel: std_logic_vector(3 downto 0);
    signal mux_c_in: std_logic_vector(15 downto 0);
    signal mux_c_out: std_logic_vector(0 downto 0);
    -- Multiplexer cop (determines ALU operation)
    signal mux_cop_sel: std_logic_vector(0 downto 0);
    signal mux_cop_out: std_logic_vector(0 downto 0);

    signal instruction_exception: std_logic;
    signal microaddress: std_logic_vector(MICROADDRESS_SIZE - 1 downto 0);
begin
    mux_a: entity Work.Multiplexer generic map (2, MICROADDRESS_SIZE)
        port map (
            sel => mux_a_sel,
            data_in => mux_a_in,
            data_out => mux_a_out
        );
    mux_a_in <= FETCH & maddr & opcode_microaddress
                              & std_logic_vector(unsigned(microaddress) + 1);

    -- Ad-hoc component instead of using the generic multiplexer to avoid
    -- declaring std_logic_vectors with a single bit
    mux_b_out <= not mux_b_data when mux_b_sel = '1' else
                     mux_b_data when mux_b_sel = '0' else 'X';
    mux_b_data <= mux_c_out(0);

    mux_c: entity Work.Multiplexer generic map(4, 1)
        port map(
            sel => mux_c_sel,
            data_in => mux_c_in,
            data_out => mux_c_out
        );
    mux_c_in <= instruction_exception
                & state_register(31 downto 28)
                & state_register(1 downto 0)
                & memory_ready
                & IO_ready
                & interrupt
                & '0';

    sel_register_a: entity Work.RegisterSelector
        port map (instruction, selA, MR, RA);
    sel_register_b: entity Work.RegisterSelector
        port map (instruction, selB, MR, RB);
    sel_register_c: entity Work.RegisterSelector
        port map (instruction, selC, MR, RC);

    mux_cop: entity Work.Multiplexer generic map(1, 5)
        port map(
            sel => MC,
            data_in => mux_cop_sel & instruction_register(4 downto 0),
            data_out => mux_cop_out
        );

    microaddress_reg: entity Work.Reg generic map(MICROADDRESS_SIZE)
        port map (
            clk => clk,
            rst => rst,
            update => '1',
            in_data => mux_a_out,
            out_data => microaddress
        );

    -- TODO: missing control signals declaration (output from control memory)
    -- TODO: control memory
    -- TODO: co2microaddress
    -- TODO: subcomponents
end architecture Rtl;
