library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

library Src;
use Src.Constants;

-- A testbench has no ports
entity NextMicroaddressTB is
end NextMicroaddressTB;


architecture Rtl of NextMicroaddressTB is
    signal current, from_opcode, jump_target, next_addr:
        std_logic_vector(Constants.MICROADDRESS_SIZE - 1 downto 0)
        := (others => '0');
    signal jump_sel: std_logic_vector(1 downto 0) := "00";

    pure function microaddr(
        addr: natural range 0 to 2**Constants.MICROADDRESS_SIZE - 1
    ) return std_logic_vector is
    begin
        return std_logic_vector(to_unsigned(addr, Constants.MICROADDRESS_SIZE));
    end function;
begin
    -- Component instantiation
    uut: entity Src.NextMicroaddress port map (
        current, from_opcode, jump_target,
        jump_sel, next_addr
    );

    process
        type test_case is record
            -- Inputs
            current, from_opcode, jump_target:
                std_logic_vector(Constants.MICROADDRESS_SIZE - 1 downto 0);
            jump_sel: std_logic_vector(1 downto 0);
            -- Expected output
            next_addr: std_logic_vector(Constants.MICROADDRESS_SIZE - 1 downto 0);
        end record;
        -- The patterns to apply
        type tests_array is array (natural range <>) of test_case;
        constant TESTS : tests_array := (
            ( -- 1: Next address 1
                microaddr(0), microaddr(0), microaddr(0), "00",
                microaddr(1)
            ),
            ( -- 2: Next address 2
                microaddr(127), microaddr(0), microaddr(0), "00",
                microaddr(128)
            ),
            ( -- 3: Microaddress from opcode 1
                microaddr(0), microaddr(32), microaddr(0), "01",
                microaddr(32)
            ),
            ( -- 4: Microaddress from opcode 2
                microaddr(0), microaddr(127), microaddr(0), "01",
                microaddr(127)
            ),
            ( -- 5: Arbitrary address 1
                microaddr(0), microaddr(0), microaddr(3), "10",
                microaddr(3)
            ),
            ( -- 6: Arbitrary address 2
                microaddr(0), microaddr(0), microaddr(101), "10",
                microaddr(101)
            ),
            ( -- 7: Fetch 1
                microaddr(127), microaddr(32), microaddr(97), "11",
                microaddr(0)
            ),
            ( -- 8: Fetch 2
                microaddr(1024), microaddr(2048), microaddr(4095), "11",
                microaddr(0)
            )
        );
    begin
        report "start of test" severity note;
        -- Check each pattern
        for i in TESTS'range loop
            -- Set the inputs
            current <= TESTS(i).current;
            from_opcode <= TESTS(i).from_opcode;
            jump_target <= TESTS(i).jump_target;
            jump_sel <= TESTS(i).jump_sel;
            -- Wait for the results
            wait for 10 ns;
            -- Check the outputs
            assert next_addr = TESTS(i).next_addr
                report "bad result on test: " & integer'image(i + 1)
                    & ", result: "
                    & integer'image(to_integer(unsigned(next_addr)))
                    & ", expected: "
                    & integer'image(to_integer(unsigned(TESTS(i).next_addr)))
                severity error;
        end loop;
        report "end of test" severity note;
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end Rtl;
