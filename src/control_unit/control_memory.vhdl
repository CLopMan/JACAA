library IEEE;
use IEEE.Std_Logic_1164.all;

library IEEE;
use IEEE.Std_Logic_1164.all;

use Work.ControlUnitPkg;
use Work.Types;

package ControlMemoryPkg is
    type microinstruction_record is record
        C: std_logic_vector(3 downto 0);
        B, A0, MR, MC: std_logic;
        sel_a, sel_b, sel_c, sel_cop: std_logic_vector(4 downto 0);
        maddr: Types.microaddress;
        immediate: std_logic_vector(3 downto 0);
        external: ControlUnitPkg.control_signals;
    end record;
end package ControlMemoryPkg;

library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use Work.ControlMemoryPkg.all;
use Work.Constants;
use Work.Types;

entity ControlMemory is
    port (
        signal microaddress: in Types.microaddress;
        signal microinstruction: out microinstruction_record
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
    signal current: microinstruction_raw;
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
    current <= CONTROL_MEMORY(to_integer(unsigned(microaddress)));
    microinstruction.A0              <= current(84);
    microinstruction.B               <= current(83);
    microinstruction.C               <= current(82 downto 79);
    microinstruction.sel_a           <= current(78 downto 74);
    microinstruction.sel_b           <= current(73 downto 69);
    microinstruction.sel_c           <= current(68 downto 64);
    microinstruction.sel_cop         <= current(63 downto 59);
    microinstruction.maddr           <= current(78 downto 67);
    microinstruction.immediate       <= current(58 downto 55);
    microinstruction.MR              <= current(54);
    microinstruction.MC              <= current(53);
    microinstruction.external.C0     <= current(52);
    microinstruction.external.C1     <= current(51);
    microinstruction.external.C2     <= current(50);
    microinstruction.external.C3     <= current(49);
    microinstruction.external.C4     <= current(48);
    microinstruction.external.C5     <= current(47);
    microinstruction.external.C6     <= current(46);
    microinstruction.external.C7     <= current(45);
    microinstruction.external.T1     <= current(44);
    microinstruction.external.T2     <= current(43);
    microinstruction.external.T3     <= current(42);
    microinstruction.external.T4     <= current(41);
    microinstruction.external.T5     <= current(40);
    microinstruction.external.T6     <= current(39);
    microinstruction.external.T7     <= current(38);
    microinstruction.external.T8     <= current(37);
    microinstruction.external.T9     <= current(36);
    microinstruction.external.T10    <= current(35);
    microinstruction.external.T11    <= current(34);
    microinstruction.external.T12    <= current(33);
    microinstruction.external.M1     <= current(32);
    microinstruction.external.M2     <= current(31);
    microinstruction.external.M7     <= current(30);
    microinstruction.external.MA     <= current(29);
    microinstruction.external.MB     <= current(28 downto 27);
    microinstruction.external.MH     <= current(26 downto 25);
    microinstruction.external.sel_p  <= current(24 downto 23);
    microinstruction.external.LC     <= current(22);
    microinstruction.external.SE     <= current(21);
    microinstruction.external.size   <= current(20 downto 16);
    microinstruction.external.offset <= current(15 downto 11);
    microinstruction.external.BW     <= current(10 downto 9);
    microinstruction.external.R      <= current(8);
    microinstruction.external.W      <= current(7);
    microinstruction.external.TA     <= current(6);
    microinstruction.external.TD     <= current(5);
    microinstruction.external.IOR    <= current(4);
    microinstruction.external.IOW    <= current(3);
    microinstruction.external.INTA   <= current(2);
    microinstruction.external.I      <= current(1);
    microinstruction.external.U      <= current(0);
end architecture Rtl;
