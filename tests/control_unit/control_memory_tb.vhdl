library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

library Src;
use Src.Types;
use Src.ControlMemoryPkg;
use Src.ControlUnitPkg;

use Work.TestingPkg.assert_eq;

-- A testbench has no ports
entity ControlMemoryTB is
end ControlMemoryTB;


architecture Rtl of ControlMemoryTB is
    signal microaddress: Types.microaddress := (others => '0');
    signal microinstruction: ControlMemoryPkg.microinstruction_record;
    signal control_signals: ControlUnitPkg.control_signals;
begin
    -- Component instantiation
    uut: entity Src.ControlMemory port map (microaddress, microinstruction, control_signals);

    process
        -- ControlUnitPkg.control_signals with only the signals that are
        -- actually modified by the control memory
        type control_signals_microinstruction is record
            C0, C1, C2, C3, C4, C5, C6, C7: std_logic;
            T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, T11, T12: std_logic;
            M1, M2, M7, MA: std_logic;
            MB, MH, sel_p: std_logic_vector(1 downto 0);
            LC, SE: std_logic;
            size, offset: std_logic_vector(4 downto 0);
            BW: std_logic_vector(1 downto 0);
            R, W, TA, TD, IOR, IOW, INTA, I, U: std_logic;
        end record;

        variable inst: ControlMemoryPkg.microinstruction_record;
        variable ctrl: control_signals_microinstruction;

        type test_case is record
            -- Inputs
            microaddress: Types.microaddress;
            -- Expected output
            microinstruction: ControlMemoryPkg.microinstruction_record;
            control_signals: control_signals_microinstruction;
        end record;
        -- The patterns to apply
        type tests_array is array (natural range <>) of test_case;
        constant TESTS : tests_array := (
            -- TODO: test a few cases once the control memory is filled
            ( -- 1: Fetch cycle 1
                x"000",
                (
                    x"0", '0', '0', '0', '0',
                    "00000", "00000", "00000", "00000",
                    x"000", x"0"
                ),
                (
                    C0 => '1', T2 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    others => '0'
                )
            ),
            ( -- 2: Fetch cycle 2
                x"001",
                (
                    x"0", '0', '0', '0', '0',
                    "00000", "00000", "00000", "00000",
                    x"000", x"0"
                ),
                (
                    TA => '1', R => '1', M1 => '1', C1 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "11",
                    size => "00000", offset => "00000",
                    others => '0'
                )
            ),
            ( -- 3: Fetch cycle 3
                x"002",
                (
                    x"0", '0', '0', '0', '0',
                    "00000", "00000", "00000", "00000",
                    x"000", x"0"
                ),
                (
                    T1 => '1', M2 => '1', C2 => '1', C3 => '1',
                    MB => "00", MH => "00", sel_p => "00", BW => "11",
                    size => "00000", offset => "00000",
                    others => '0'
                )
            ),
            ( -- 4: Fetch cycle 4
                x"003",
                (
                    x"0", '0', '1', '0', '0',
                    "00000", "00000", "00000", "00000",
                    x"000", x"0"
                ),
                (
                    MB => "00", MH => "00", sel_p => "00", BW => "00",
                    size => "00000", offset => "00000",
                    others => '0'
                )
            )
        );
    begin
        -- Check each pattern
        for i in TESTS'range loop
            -- Set the inputs
            microaddress <= TESTS(i).microaddress;
            -- Wait for the results
            wait for 10 ns;
            -- Check the outputs
            inst := TESTS(i).microinstruction;
            ctrl := TESTS(i).control_signals;
            -- Microinstruction checks
            assert_eq(microinstruction.A0,        inst.A0,        i, "A0");
            assert_eq(microinstruction.B,         inst.B,         i, "B");
            assert_eq(microinstruction.C,         inst.C,         i, "C");
            assert_eq(microinstruction.sel_a,     inst.sel_a,     i, "sel_a");
            assert_eq(microinstruction.sel_b,     inst.sel_b,     i, "sel_b");
            assert_eq(microinstruction.sel_c,     inst.sel_c,     i, "sel_c");
            assert_eq(microinstruction.sel_cop,   inst.sel_cop,   i, "sel_cop");
            assert_eq(microinstruction.maddr,     inst.maddr,     i, "maddr");
            assert_eq(microinstruction.immediate, inst.immediate, i, "immediate");
            assert_eq(microinstruction.MR,        inst.MR,        i, "MR");
            assert_eq(microinstruction.MC,        inst.MC,        i, "MC");
            -- Control signals checks
            assert_eq(control_signals.C0,         ctrl.C0,        i, "C0");
            assert_eq(control_signals.C1,         ctrl.C1,        i, "C1");
            assert_eq(control_signals.C2,         ctrl.C2,        i, "C2");
            assert_eq(control_signals.C3,         ctrl.C3,        i, "C3");
            assert_eq(control_signals.C4,         ctrl.C4,        i, "C4");
            assert_eq(control_signals.C5,         ctrl.C5,        i, "C5");
            assert_eq(control_signals.C6,         ctrl.C6,        i, "C6");
            assert_eq(control_signals.C7,         ctrl.C7,        i, "C7");
            assert_eq(control_signals.T1,         ctrl.T1,        i, "T1");
            assert_eq(control_signals.T2,         ctrl.T2,        i, "T2");
            assert_eq(control_signals.T3,         ctrl.T3,        i, "T3");
            assert_eq(control_signals.T4,         ctrl.T4,        i, "T4");
            assert_eq(control_signals.T5,         ctrl.T5,        i, "T5");
            assert_eq(control_signals.T6,         ctrl.T6,        i, "T6");
            assert_eq(control_signals.T7,         ctrl.T7,        i, "T7");
            assert_eq(control_signals.T8,         ctrl.T8,        i, "T8");
            assert_eq(control_signals.T9,         ctrl.T9,        i, "T9");
            assert_eq(control_signals.T10,        ctrl.T10,       i, "T10");
            assert_eq(control_signals.T11,        ctrl.T11,       i, "T11");
            assert_eq(control_signals.T12,        ctrl.T12,       i, "T12");
            assert_eq(control_signals.M1,         ctrl.M1,        i, "M1");
            assert_eq(control_signals.M2,         ctrl.M2,        i, "M2");
            assert_eq(control_signals.M7,         ctrl.M7,        i, "M7");
            assert_eq(control_signals.MA,         ctrl.MA,        i, "MA");
            assert_eq(control_signals.MB,         ctrl.MB,        i, "MB");
            assert_eq(control_signals.MH,         ctrl.MH,        i, "MH");
            assert_eq(control_signals.sel_p,      ctrl.sel_p,     i, "sel_p");
            assert_eq(control_signals.LC,         ctrl.LC,        i, "LC");
            assert_eq(control_signals.SE,         ctrl.SE,        i, "SE");
            assert_eq(control_signals.size,       ctrl.size,      i, "size");
            assert_eq(control_signals.offset,     ctrl.offset,    i, "offset");
            assert_eq(control_signals.BW,         ctrl.BW,        i, "BW");
            assert_eq(control_signals.R,          ctrl.R,         i, "R");
            assert_eq(control_signals.W,          ctrl.W,         i, "W");
            assert_eq(control_signals.TA,         ctrl.TA,        i, "TA");
            assert_eq(control_signals.TD,         ctrl.TD,        i, "TD");
            assert_eq(control_signals.IOR,        ctrl.IOR,       i, "IOR");
            assert_eq(control_signals.IOW,        ctrl.IOW,       i, "IOW");
            assert_eq(control_signals.INTA,       ctrl.INTA,      i, "INTA");
            assert_eq(control_signals.I,          ctrl.I,         i, "I");
            assert_eq(control_signals.U,          ctrl.U,         i, "U");
        end loop;
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end Rtl;
