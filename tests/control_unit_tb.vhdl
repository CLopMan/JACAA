library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

library Src;
use Src.Types;
use Src.ControlUnitPkg;

use Work.TestingPkg.assert_eq;
use Work.TestingPkg.to_word;

-- A testbench has no ports
entity ControlUnitTB is
end ControlUnitTB;


architecture Rtl of ControlUnitTB is
    signal instruction, state_register: Types.word := (others => '0');
    signal clk, clk_kill: std_logic := '0';
    signal rst: std_logic := '1';
    signal mem_ready, IO_ready, interruption: std_logic := '0';
    signal control_signals: ControlUnitPkg.control_signals;
begin
    -- Component instantiation
    uut: entity Src.ControlUnit port map (
        instruction, state_register,
        clk, rst,
        mem_ready, IO_ready, interruption,
        control_signals
    );

    clock: entity work.Clock port map (clk_kill, clk);

    process
        variable ctrl: ControlUnitPkg.control_signals;

        type test_case is record
            -- Inputs
            instruction, state_register: Types.word;
            -- Expected output
            control_signals: ControlUnitPkg.control_signals;
        end record;
        -- The patterns to apply
        type tests_array is array (natural range <>) of test_case;
        constant TESTS : tests_array := (
            ( -- 1: Fetch cycle 1
                -- mar <- PC, rt1 <- PC, PC <- PC + 4
                to_word(0), to_word(0),
                (
                    C0 => '1', T2 => '1', C2 => '1', M2 => '1', C4 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "-----",
                    clk_cycles => to_word(0), instructions => to_word(0),
                    others => '0'
                )
            ),
            ( -- 2: Fetch cycle 2
                -- mbr <- mem[mar], rt3 <- rt1 + 0
                to_word(0), to_word(0),
                (
                    TA => '1', R => '1', M1 => '1', C1 => '1', MA => '1', C6 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "11",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "01010",
                    clk_cycles => to_word(0), instructions => to_word(0),
                    others => '0'
                )
            ),
            ( -- 3: Fetch cycle 3
                -- ir <- mbr
                to_word(0), to_word(0),
                (
                    T1 => '1', C3 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "-----",
                    clk_cycles => to_word(0), instructions => to_word(0),
                    others => '0'
                )
            ),
            ( -- 4: Fetch cycle 4 (Jump to microprogram)
                -- Instruction: addi x21 x10 63
                "00000011111101010000101010010011", to_word(0),
                (
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "01010",
                    clk_cycles => to_word(0), instructions => to_word(0),
                    others => '0'
                )
            ),
            ( -- 5: Op-Inm cycle 1
                -- rt2 <- inm
                "00000011111101010000101010010011", to_word(0),
                (
                    SE => '1', T3 => '1', C5 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "01100", offset => "10100",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "01010",
                    clk_cycles => to_word(0), instructions => to_word(0),
                    others => '0'
                )
            ),
            ( -- 6 Op-Inm cycle 2
                -- rd <- rs1 op rt2
                "00000011111101010000101010010011", to_word(0),
                (
                    T6 => '1', LC => '1',
                    MB => "01", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "01010", reg_b => "00000", reg_c => "10101",
                    cop => "01010",
                    clk_cycles => to_word(0), instructions => to_word(0),
                    others => '0'
                )
            ),
            ---────────────────────────────────────────────────────────────────
            ( -- 7: Fetch cycle 1
                to_word(0), to_word(0),
                (
                    C0 => '1', T2 => '1', C2 => '1', M2 => '1', C4 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "-----",
                    clk_cycles => to_word(0), instructions => to_word(1),
                    others => '0'
                )
            ),
            ( -- 8: Fetch cycle 2
                to_word(0), to_word(0),
                (
                    TA => '1', R => '1', M1 => '1', C1 => '1', MA => '1', C6 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "11",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "01010",
                    clk_cycles => to_word(0), instructions => to_word(1),
                    others => '0'
                )
            ),
            ( -- 9: Fetch cycle 3
                to_word(0), to_word(0),
                (
                    T1 => '1', C3 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "-----",
                    clk_cycles => to_word(0), instructions => to_word(1),
                    others => '0'
                )
            ),
            ( -- 10: Fetch cycle 4 (Jump to microprogram)
                -- Instruction: lui x16 31775
                "00000111110000011111100000110111", x"11111111",
                (
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "-----",
                    clk_cycles => to_word(0), instructions => to_word(1),
                    others => '0'
                )
            ),
            ( -- 11: LUI cycle 1
                -- rt1 <- inm
                "00000111110000011111100000110111", x"11111111",
                (
                    T3 => '1', C4 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "10100", offset => "01100",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "-----",
                    clk_cycles => to_word(0), instructions => to_word(1),
                    others => '0'
                )
            ),
            ( -- 12: LUI cycle 2
                -- rt2 <- 12
                "00000111110000011111100000110111", x"11111111",
                (
                    T11 => '1', C5 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "-----",
                    clk_cycles => to_word(0), instructions => to_word(1),
                    others => '0'
                )
            ),
            ( -- 13: LUI cycle 3
                -- rd <- rt1 << rt2 (inm << 12)
                "00000111110000011111100000110111", x"11111111",
                (
                    T6 => '1', LC => '1', MA => '1',
                    MB => "01", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "10000",
                    cop => "00111",
                    clk_cycles => to_word(0), instructions => to_word(1),
                    others => '0'
                )
            ),
            ---────────────────────────────────────────────────────────────────
            ( -- 14: Fetch cycle 1
                to_word(0), to_word(0),
                (
                    C0 => '1', T2 => '1', C2 => '1', M2 => '1', C4 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "-----",
                    clk_cycles => to_word(0), instructions => to_word(2),
                    others => '0'
                )
            ),
            ( -- 15: Fetch cycle 2
                to_word(0), to_word(0),
                (
                    TA => '1', R => '1', M1 => '1', C1 => '1', MA => '1', C6 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "11",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "01010",
                    clk_cycles => to_word(0), instructions => to_word(2),
                    others => '0'
                )
            ),
            ( -- 16: Fetch cycle 3
                to_word(0), to_word(0),
                (
                    T1 => '1', C3 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "-----",
                    clk_cycles => to_word(0), instructions => to_word(2),
                    others => '0'
                )
            ),
            ( -- 17: Fetch cycle 4 (Jump to microprogram)
                -- Instruction: auipc x1 -523776
                "10000000001000000000000010010111", x"11000011",
                (
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "-----",
                    clk_cycles => to_word(0), instructions => to_word(2),
                    others => '0'
                )
            ),
            ( -- 18: AUIPC cycle 1
                -- rt1 <- inm
                "10000000001000000000000010010111", x"11000011",
                (
                    T3 => '1', C4 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "10100", offset => "01100",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "-----",
                    clk_cycles => to_word(0), instructions => to_word(2),
                    others => '0'
                )
            ),
            ( -- 19: AUIPC cycle 2
                -- rt2 <- 12
                "10000000001000000000000010010111", x"11000011",
                (
                    T11 => '1', C5 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "-----",
                    clk_cycles => to_word(0), instructions => to_word(2),
                    others => '0'
                )
            ),
            ( -- 20: AUIPC cycle 3
                -- rt1 <- rt1 << rt2 (inm << 12)
                "10000000001000000000000010010111", x"11000011",
                (
                    T6 => '1', C4 => '1', MA => '1',
                    MB => "01", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "00111",
                    clk_cycles => to_word(0), instructions => to_word(2),
                    others => '0'
                )
            ),
            ( -- 21: AUIPC cycle 4
                -- rt2 <- rt3 (prev PC)
                "10000000001000000000000010010111", x"11000011",
                (
                    T7 => '1', C5 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "-----",
                    clk_cycles => to_word(0), instructions => to_word(2),
                    others => '0'
                )
            ),
            ( -- 21: AUIPC cycle 5
                -- rd <- rt1 + rt2
                "10000000001000000000000010010111", x"11000011",
                (
                    T6 => '1', LC => '1', MA => '1',
                    MB => "01", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00001",
                    cop => "01010",
                    clk_cycles => to_word(0), instructions => to_word(2),
                    others => '0'
                )
            ),
            ---────────────────────────────────────────────────────────────────
            ( -- 22: Fetch cycle 1
                to_word(0), to_word(0),
                (
                    C0 => '1', T2 => '1', C2 => '1', M2 => '1', C4 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "-----",
                    clk_cycles => to_word(0), instructions => to_word(3),
                    others => '0'
                )
            ),
            ( -- 23: Fetch cycle 2
                to_word(0), to_word(0),
                (
                    TA => '1', R => '1', M1 => '1', C1 => '1', MA => '1', C6 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "11",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "01010",
                    clk_cycles => to_word(0), instructions => to_word(3),
                    others => '0'
                )
            ),
            ( -- 24: Fetch cycle 3
                to_word(0), to_word(0),
                (
                    T1 => '1', C3 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "-----",
                    clk_cycles => to_word(0), instructions => to_word(3),
                    others => '0'
                )
            ),
            ( -- 25: Fetch cycle 4 (Jump to microprogram)
                -- Instruction: xor x8 x5 x24
                "00000001100000101100010000110011", x"00111100",
                (
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00000", reg_b => "00000", reg_c => "00000",
                    cop => "00100",
                    clk_cycles => to_word(0), instructions => to_word(3),
                    others => '0'
                )
            ),
            -- Op
            ( -- 15
                -- rd <- rs1 op rs2
                "00000001100000101100010000110011", x"00111100",
                (
                    T6 => '1', LC => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    reg_a => "00101", reg_b => "11000", reg_c => "01000",
                    cop => "00100",
                    clk_cycles => to_word(0), instructions => to_word(3),
                    others => '0'
                )
            )
        );
    begin
        rst <= '0';
        wait for 1 ns;
        -- Check each pattern
        for i in TESTS'range loop
            -- Set the inputs
            instruction <= TESTS(i).instruction;
            state_register <= TESTS(i).state_register;
            -- Wait for the results
            -- Check the outputs
            ctrl := TESTS(i).control_signals;
            -- Control signals checks
            assert_eq(control_signals.C0,           ctrl.C0,           i, "C0");
            assert_eq(control_signals.C1,           ctrl.C1,           i, "C1");
            assert_eq(control_signals.C2,           ctrl.C2,           i, "C2");
            assert_eq(control_signals.C3,           ctrl.C3,           i, "C3");
            assert_eq(control_signals.C4,           ctrl.C4,           i, "C4");
            assert_eq(control_signals.C5,           ctrl.C5,           i, "C5");
            assert_eq(control_signals.C6,           ctrl.C6,           i, "C6");
            assert_eq(control_signals.C7,           ctrl.C7,           i, "C7");
            assert_eq(control_signals.T1,           ctrl.T1,           i, "T1");
            assert_eq(control_signals.T2,           ctrl.T2,           i, "T2");
            assert_eq(control_signals.T3,           ctrl.T3,           i, "T3");
            assert_eq(control_signals.T4,           ctrl.T4,           i, "T4");
            assert_eq(control_signals.T5,           ctrl.T5,           i, "T5");
            assert_eq(control_signals.T6,           ctrl.T6,           i, "T6");
            assert_eq(control_signals.T7,           ctrl.T7,           i, "T7");
            assert_eq(control_signals.T8,           ctrl.T8,           i, "T8");
            assert_eq(control_signals.T9,           ctrl.T9,           i, "T9");
            assert_eq(control_signals.T10,          ctrl.T10,          i, "T10");
            assert_eq(control_signals.T11,          ctrl.T11,          i, "T11");
            assert_eq(control_signals.T12,          ctrl.T12,          i, "T12");
            assert_eq(control_signals.M1,           ctrl.M1,           i, "M1");
            assert_eq(control_signals.M2,           ctrl.M2,           i, "M2");
            assert_eq(control_signals.M7,           ctrl.M7,           i, "M7");
            assert_eq(control_signals.MA,           ctrl.MA,           i, "MA");
            assert_eq(control_signals.MB,           ctrl.MB,           i, "MB");
            assert_eq(control_signals.MH,           ctrl.MH,           i, "MH");
            assert_eq(control_signals.sel_p,        ctrl.sel_p,        i, "sel_p");
            assert_eq(control_signals.LC,           ctrl.LC,           i, "LC");
            assert_eq(control_signals.SE,           ctrl.SE,           i, "SE");
            assert_eq(control_signals.size,         ctrl.size,         i, "size");
            assert_eq(control_signals.offset,       ctrl.offset,       i, "offset");
            assert_eq(control_signals.BW,           ctrl.BW,           i, "BW");
            assert_eq(control_signals.R,            ctrl.R,            i, "R");
            assert_eq(control_signals.W,            ctrl.W,            i, "W");
            assert_eq(control_signals.TA,           ctrl.TA,           i, "TA");
            assert_eq(control_signals.TD,           ctrl.TD,           i, "TD");
            assert_eq(control_signals.IOR,          ctrl.IOR,          i, "IOR");
            assert_eq(control_signals.IOW,          ctrl.IOW,          i, "IOW");
            assert_eq(control_signals.INTA,         ctrl.INTA,         i, "INTA");
            assert_eq(control_signals.I,            ctrl.I,            i, "I");
            assert_eq(control_signals.U,            ctrl.U,            i, "U");
            assert_eq(control_signals.reg_a,        ctrl.reg_a,        i, "reg_a");
            assert_eq(control_signals.reg_b,        ctrl.reg_b,        i, "reg_b");
            assert_eq(control_signals.reg_c,        ctrl.reg_c,        i, "reg_c");
            assert_eq(control_signals.cop,          ctrl.cop,          i, "cop");
            assert_eq(control_signals.clk_cycles,   to_word(i),        i, "clk_cycles");
            assert_eq(control_signals.instructions, ctrl.instructions, i, "instructions");
            wait for 10 ns;
        end loop;
        clk_kill <= '1';
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end Rtl;
