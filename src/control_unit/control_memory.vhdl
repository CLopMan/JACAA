library IEEE;
use IEEE.Std_Logic_1164.all;

use Work.Types;

package ControlMemoryPkg is
    type microinstruction_record is record
        C: std_logic_vector(3 downto 0);
        B, A0, MR, MC: std_logic;
        sel_a, sel_b, sel_c, sel_cop: std_logic_vector(4 downto 0);
        maddr: Types.microaddress;
        immediate: std_logic_vector(3 downto 0);
    end record;
end package ControlMemoryPkg;

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use Work.ControlMemoryPkg.all;
use Work.ControlUnitPkg;
use Work.Constants;
use Work.Types;

entity ControlMemory is
    port (
        signal microaddress: in Types.microaddress;
        signal microinstruction: out microinstruction_record := (
            x"0", '0', '0', '0', '0',
            "00000", "00000", "00000", "00000",
            x"000", x"0"
        );
        signal control_signals: out ControlUnitPkg.control_signals
    );
end entity ControlMemory;


architecture Rtl of ControlMemory is
    -- Microinstruction size in memory
    constant SIZE: positive := 88;
    -- Microinstruction from memory signal type
    subtype microinstruction_raw is std_logic_vector(SIZE - 1 downto 0);
    -- Max amount of microinstructions in the control memory
    constant CONTROL_MEMORY_SIZE: positive := 256;
    -- TODO: should we represent this with a vector in case we want to swap to a
    -- ROM or use the `microinstruction_record` type?
    type memory is array(natural range <>) of microinstruction_raw;
    -- TODO: fill memory
    constant CONTROL_MEMORY: memory(0 to CONTROL_MEMORY_SIZE - 1) := (
        x"0000000000000000000000",
        x"0000000000000000000001",
        x"0000000000000000000002",
        x"0000000000000000000003",
        x"0000000000000000000004",
        x"0000000000000000000005",
        x"0000000000000000000006",
        x"0000000000000000000007",
        x"0000000000000000000008",
        x"0000000000000000000009",
        x"000000000000000000000A",
        x"000000000000000000000B",
        x"000000000000000000000C",
        x"000000000000000000000D",
        x"000000000000000000000E",
        x"000000000000000000000F",
        others => (others => '0')
    );
begin
    process(microaddress)
        variable current: microinstruction_raw;
    begin
        current := CONTROL_MEMORY(to_integer(unsigned(microaddress)));
        microinstruction.A0        <= current(84);
        microinstruction.B         <= current(83);
        microinstruction.C         <= current(82 downto 79);
        microinstruction.sel_a     <= current(78 downto 74);
        microinstruction.sel_b     <= current(73 downto 69);
        microinstruction.sel_c     <= current(68 downto 64);
        microinstruction.sel_cop   <= current(63 downto 59);
        microinstruction.maddr     <= current(78 downto 67);
        microinstruction.immediate <= current(58 downto 55);
        microinstruction.MR        <= current(54);
        microinstruction.MC        <= current(53);
        control_signals.C0         <= current(52);
        control_signals.C1         <= current(51);
        control_signals.C2         <= current(50);
        control_signals.C3         <= current(49);
        control_signals.C4         <= current(48);
        control_signals.C5         <= current(47);
        control_signals.C6         <= current(46);
        control_signals.C7         <= current(45);
        control_signals.T1         <= current(44);
        control_signals.T2         <= current(43);
        control_signals.T3         <= current(42);
        control_signals.T4         <= current(41);
        control_signals.T5         <= current(40);
        control_signals.T6         <= current(39);
        control_signals.T7         <= current(38);
        control_signals.T8         <= current(37);
        control_signals.T9         <= current(36);
        control_signals.T10        <= current(35);
        control_signals.T11        <= current(34);
        control_signals.T12        <= current(33);
        control_signals.M1         <= current(32);
        control_signals.M2         <= current(31);
        control_signals.M7         <= current(30);
        control_signals.MA         <= current(29);
        control_signals.MB         <= current(28 downto 27);
        control_signals.MH         <= current(26 downto 25);
        control_signals.sel_p      <= current(24 downto 23);
        control_signals.LC         <= current(22);
        control_signals.SE         <= current(21);
        control_signals.size       <= current(20 downto 16);
        control_signals.offset     <= current(15 downto 11);
        control_signals.BW         <= current(10 downto 9);
        control_signals.R          <= current(8);
        control_signals.W          <= current(7);
        control_signals.TA         <= current(6);
        control_signals.TD         <= current(5);
        control_signals.IOR        <= current(4);
        control_signals.IOW        <= current(3);
        control_signals.INTA       <= current(2);
        control_signals.I          <= current(1);
        control_signals.U          <= current(0);
    end process;
end architecture Rtl;
