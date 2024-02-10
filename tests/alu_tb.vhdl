library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

library Src;
use Src.ALUPkg.all;

-- A testbench has no ports
entity ALUTB is
end ALUTB;


architecture Rtl of ALUTB is
    signal A, B: signed(31 downto 0) := (others => '0');
    signal op_code: std_logic_vector(4 downto 0) := (others => '0');
    signal C: signed(31 downto 0) := (others => '0');
    signal state: state_type := (others => '0');
begin
    -- Component instantiation
    alu: entity Src.ALU port map (A, B, op_code, C, state);

    process
        type test_case is record
            -- Inputs
            A, B: signed(31 downto 0);
            op_code: std_logic_vector(4 downto 0);
            -- Expected output
            C: signed(31 downto 0);
            state: state_type;
        end record;
        -- The patterns to apply
        type tests_array is array (natural range <>) of test_case;
        constant TESTS : tests_array := (
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
        for i in TESTS'range loop
            -- Set the inputs
            A <= TESTS(i).A;
            B <= TESTS(i).B;
            op_code <= TESTS(i).op_code;
            -- Wait for the results
            wait for 10 ns;
            -- Check the outputs
            assert C = TESTS(i).C and state = TESTS(i).state
                report "bad result on test: " & integer'image(i + 1)
                severity error;
        end loop;
        assert false report "end of test" severity note;
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end Rtl;
