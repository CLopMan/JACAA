library IEEE;
use IEEE.Std_Logic_1164.all;

use Work.Types;

package ControlMemoryPkg is
    type microinstruction_record is record
        C: std_logic_vector(3 downto 0);
        B, A0, MR, MC, MH: std_logic;
        sel_a, sel_b, sel_c, sel_cop: std_logic_vector(4 downto 0);
        maddr: Types.microaddress;
        immediate: std_logic_vector(3 downto 0);
        other: std_logic_vector(46 downto 0);
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
    -- Microinstruction from memory signal type
    subtype microinstruction_raw is std_logic_vector(79 downto 0);
    -- Max amount of microinstructions in the control memory
    constant CONTROL_MEMORY_SIZE: positive := 256;
    -- TODO: should we represent this with a vector in case we want to swap to a
    -- ROM or use the `microinstruction_record` type?
    signal current: microinstruction_raw;
    type memory is array(natural range <>) of microinstruction_raw;
    -- TODO: fill memory
    constant CONTROL_MEMORY: memory(0 to CONTROL_MEMORY_SIZE - 1) := (
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
begin
    current <= CONTROL_MEMORY(to_integer(unsigned(microaddress)));
    microinstruction.C <= current(79 downto 76);
    microinstruction.B <= current(75);
    microinstruction.A0 <= current(74);
    microinstruction.MR <= current(73);
    microinstruction.sel_a <= current(72 downto 68);
    microinstruction.sel_b <= current(67 downto 63);
    microinstruction.sel_c <= current(62 downto 58);
    microinstruction.maddr <= current(72 downto 61);
    microinstruction.other <= current(57 downto 11);
    microinstruction.MH <= current(10);
    microinstruction.MC <= current(9);
    microinstruction.sel_cop <= current(8 downto 4);
    microinstruction.immediate <= current(3 downto 0);
end architecture Rtl;
