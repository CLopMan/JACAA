library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library src;
use src.alu_pkg.all;

-- A testbench has no ports
entity alu_tb is
end alu_tb;

architecture rtl of alu_tb is
    signal A, B: signed(31 downto 0) := (others => '0');
    signal OpCode: std_logic_vector(4 downto 0) := (others => '0');
    signal C: signed(31 downto 0) := (others => '0');
    signal State: StateType := (others => '0');
begin
    -- Component instantiation
    alu: entity src.alu port map (A, B, OpCode, C, State);

    process
        type pattern_type is record
            -- Inputs
            A, B: signed(31 downto 0);
            OpCode: std_logic_vector(4 downto 0);
            -- Expected output
            C: signed(31 downto 0);
            State: StateType;
        end record;
        -- The patterns to apply
        type tests_array is array (natural range <>) of pattern_type;
        constant tests : tests_array := (
            (
                x"00000001", x"00000003", "00000",
                x"00000000", (Zero => '1', others => '0')
            ),
            (
                "00000000000000000000000000000001",
                "00000000000000000000000000000011", "00001",
                "00000000000000000000000000000001", (others => '0')
            ),
            (
                "00000000000000000000000000000011",
                "00000000000000000000000000000101", "00010",
                "00000000000000000000000000000111", (others => '0')
            ),
            (
                "00000000000000000000000000000011",
                "00000000000000000000000000000101", "00011",
                "00000000000000000000000000000110", (others => '0')
            ),
            (
                "00000000000000000000000000010101",
                "00000000000000000000000000000010", "00100",
                "11111111111111111111111111101010",
                (Zero => '0', others => '1')
            ),
            (
                to_signed(3, 32), to_signed(5, 32), "00101",
                to_signed(8, 32), (others => '0')
            ),
            (
                to_signed(5, 32), to_signed(3, 32), "00110",
                to_signed(2, 32), (others => '0')
            ),
            (
                "01000000000000000000000000000010",
                "00000000000000000000000000000001", "00111",
                "10000000000000000000000000000100",
                (Negative => '1', Overflow => '1', others => '0')
            ),
            (
                "01000000000000000000000000000010",
                "00000000000000000000000000000001", "01000",
                "00100000000000000000000000000001", (others => '0')
            ),
            (
                "11000000000000000000000000000010",
                "00000000000000000000000000000001", "01000",
                "01100000000000000000000000000001", (others => '0')
            )
        );
    begin
        assert false report "start of test" severity note;
        -- Check each pattern
        for i in tests'range loop
            -- Set the inputs
            A <= tests(i).A;
            B <= tests(i).B;
            OpCode <= tests(i).OpCode;
            -- Wait for the results
            wait for 10 ns;
            -- Check the outputs
            assert C = tests(i).C and State = tests(i).State
                report "bad result on test: " & integer'image(i + 1)
                severity error;
        end loop;
        assert false report "end of test" severity note;
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end rtl;
