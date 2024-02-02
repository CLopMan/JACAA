library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library src;

-- A testbench has no ports
entity register_bank_tb is
end register_bank_tb;

architecture rtl of register_bank_tb is
    signal DATA_IN: std_logic_vector(31 downto 0) := (others => '0');
    signal RA, RB, RC: unsigned(4 downto 0) := (others => '0');
    signal clk, rst, L, clk_kill: std_logic := '0';
    signal DATA_OUT_A, DATA_OUT_B: std_logic_vector(31 downto 0) := (others => '0');
begin
    -- Component instantiation
    register_bank: entity src.register_bank port map (
        RA, RB, RC,
        DATA_IN,
        clk, rst, L,
        DATA_OUT_A, DATA_OUT_B
    );
    clock: entity work.clock generic map (10 ns) port map (clk_kill, clk);

    process
        type pattern_type is record
            -- Inputs
            RA, RB, RC: unsigned(4 downto 0);
            L: std_logic;
            DATA_IN: std_logic_vector(31 downto 0);
            -- Expected output
            DATA_OUT_A, DATA_OUT_B: std_logic_vector(31 downto 0);
        end record;
        -- The patterns to apply
        type tests_array is array (natural range <>) of pattern_type;
        constant tests : tests_array := (
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
        assert false report "start of test" severity note;
        -- Check each pattern
        for i in tests'range loop
            -- Set the inputs
            DATA_IN <= tests(i).DATA_IN;
            RA <= tests(i).RA;
            RB <= tests(i).RB;
            RC <= tests(i).RC;
            L <= tests(i).L;
            -- Wait for the next clock cycle
            wait for 10 ns;
            -- Check the outputs
            assert DATA_OUT_A = tests(i).DATA_OUT_A and DATA_OUT_B = tests(i).DATA_OUT_B
                report "bad result on test: " & integer'image(i + 1)
                severity error;
        end loop;
        clk_kill <= '1';
        assert false report "end of test" severity note;
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end rtl;
