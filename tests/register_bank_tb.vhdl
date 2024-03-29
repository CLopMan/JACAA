library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

library Src;

-- A testbench has no ports
entity RegisterBankTB is
end RegisterBankTB;


architecture Rtl of RegisterBankTB is
    signal RA, RB, RC: unsigned(4 downto 0) := (others => '0');
    signal C: std_logic_vector(31 downto 0) := (others => '0');
    signal clk, rst, load, clk_kill: std_logic := '0';
    signal A, B: std_logic_vector(31 downto 0) := (others => '0');
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
            C: std_logic_vector(31 downto 0);
            -- Expected output
            A, B: std_logic_vector(31 downto 0);
        end record;
        -- The patterns to apply
        type tests_array is array (natural range <>) of tests_case;
        constant TESTS : tests_array := (
            (
                "00000", "00001", "00001", '0',
                x"0000007f",
                x"00000000", x"00000000"
            ),
            (
                "00000", "00001", "00001", '1',
                x"0000007f",
                x"00000000", x"0000007f"
            ),
            (
                "00000", "00001", "00001", '1',
                x"7f000000",
                x"00000000", x"7f000000"
            ),
            (
                "00010", "00001", "00010", '1',
                x"11111111",
                x"11111111", x"7f000000"
            ),
            (
                "00010", "00001", "00010", '0',
                x"00ff0000",
                x"11111111", x"7f000000"
            ),
            (
                "00010", "00010", "00010", '0',
                x"00000000",
                x"11111111", x"11111111"
            ),
            (
                "00001", "00000", "00010", '0',
                x"00000000",
                x"7f000000", x"00000000"
            )
        );
    begin
        report "start of test" severity note;
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
            assert A = TESTS(i).A and B = TESTS(i).B
                report "bad result on test: " & integer'image(i + 1)
                severity error;
        end loop;
        clk_kill <= '1';
        report "end of test" severity note;
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end Rtl;
