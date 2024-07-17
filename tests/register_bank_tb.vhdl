library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

library Src;
use Src.Types;

use Work.TestingPkg.assert_eq;

-- A testbench has no ports
entity RegisterBankTB is
end RegisterBankTB;


architecture Rtl of RegisterBankTB is
    signal RA, RB, RC: unsigned(4 downto 0) := (others => '0');
    signal C: Types.word := (others => '0');
    signal clk, rst, load, clk_kill: std_logic := '0';
    signal A, B: Types.word := (others => '0');
begin
    -- Component instantiation
    register_bank: entity Src.RegisterBank port map (
        RA, RB, RC,
        C,
        clk, rst, load,
        A, B
    );
    clock: entity work.Clock generic map (10 ns) port map (clk_kill, clk);

    process
        type tests_case is record
            -- Inputs
            RA, RB, RC: unsigned(4 downto 0);
            load: std_logic;
            C: Types.word;
            -- Expected output
            A, B: Types.word;
        end record;
        -- The patterns to apply
        type tests_array is array (natural range <>) of tests_case;
        constant TESTS: tests_array := (
            ( -- 1: Set C input but don't load value
                "00000", "00001", "00001", '0',
                x"0000007f",
                x"00000000", x"00000000"
            ),
            ( -- 2: Set C input and load value
                "00000", "00001", "00001", '1',
                x"0000007f",
                x"00000000", x"0000007f"
            ),
            ( -- 3: Modify C input and load value again
                "00000", "00001", "00001", '1',
                x"7f000000",
                x"00000000", x"7f000000"
            ),
            ( -- 4: Load different value into a different register and read both
                "00010", "00001", "00010", '1',
                x"11111111",
                x"11111111", x"7f000000"
            ),
            ( -- 5: Modify C input but don't load value
                "00010", "00001", "00010", '0',
                x"00ff0000",
                x"11111111", x"7f000000"
            ),
            ( -- 6: Read the same register through A and B
                "00010", "00010", "00010", '0',
                x"00000000",
                x"11111111", x"11111111"
            ),
            ( -- 7: Read older values stored in different registers
                "00001", "00000", "00010", '0',
                x"00000000",
                x"7f000000", x"00000000"
            ),
            ( -- 8: Read zero register
                "00000", "00001", "00000", '0',
                x"00000000",
                x"00000000", x"7f000000"
            ),
            ( -- 9: Try to modify the zero register
                "00000", "00001", "00000", '1',
                x"33333333",
                x"00000000", x"7f000000"
            ),
            ( -- 10: Read zero register again
                "00001", "00000", "00000", '0',
                x"00000000",
                x"7f000000", x"00000000"
            )
        );
    begin
        -- Check each pattern
        for i in TESTS'range loop
            -- Set the inputs
            C <= TESTS(i).C;
            RA <= TESTS(i).RA;
            RB <= TESTS(i).RB;
            RC <= TESTS(i).RC;
            load <= TESTS(i).load;
            -- Wait for the next clock cycle
            wait for 10 ns;
            -- Check the outputs
            assert_eq(A, TESTS(i).A, i);
            assert_eq(B, TESTS(i).B, i);
        end loop;
        clk_kill <= '1';
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end Rtl;
