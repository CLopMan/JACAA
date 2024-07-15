library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_std.all;

library Src;
use Work.Debug.all;


entity TriStateTB is
end TriStateTB;

architecture Tests of TriStateTB is
    constant SIZE: integer := 8;
    constant SIZE2: integer := 16;
    signal s_data_in8, s_data_out8: std_logic_vector(SIZE - 1 downto 0)
        := (others => '0');
    signal s_data_in16, s_data_out16: std_logic_vector(SIZE2 - 1 downto 0)
        := (others => '0');
    signal s_activate: std_logic := '0';
begin
    T8: entity Src.Tristate
        generic map(
            data_size => SIZE
        )
        port map(
            activate => s_activate,
            data_in => s_data_in8,
            data_out => s_data_out8
        );

    T16: entity Src.Tristate
        generic map(
            data_size => SIZE2
        )
        port map(
            activate => s_activate,
            data_in => s_data_in16,
            data_out => s_data_out16
        );

    stim_proc: process
        type test_case is record
            -- inputs
            activate: std_logic;
            data_in8: std_logic_vector(SIZE - 1 downto 0);
            data_in16: std_logic_vector(SIZE2 - 1 downto 0);
            -- output
            data_out8: std_logic_vector(SIZE - 1 downto 0);
            data_out16: std_logic_vector(SIZE2 - 1 downto 0);
        end record;

        type test_arr is array(natural range <>) of test_case;
        constant tests: test_arr := (
            -- replicate input in output
            (
                -- in
                '1',
                std_logic_vector(to_unsigned(4, SIZE)),
                std_logic_vector(to_unsigned(8, SIZE2)),
                -- out
                std_logic_vector(to_unsigned(4, SIZE)),
                std_logic_vector(to_unsigned(8, SIZE2))
            ),
            -- high impedance
            (
                -- in
                '0',
                std_logic_vector(to_unsigned(1, SIZE)),
                std_logic_vector(to_unsigned(1, SIZE2)),
                -- out
                "ZZZZZZZZ",
                "ZZZZZZZZZZZZZZZZ"
            ),
            -- change input
            (
                -- in
                '1',
                std_logic_vector(to_unsigned(5, SIZE)),
                std_logic_vector(to_unsigned(10, SIZE2)),
                -- out
                std_logic_vector(to_unsigned(5, SIZE)),
                std_logic_vector(to_unsigned(10, SIZE2))
            )
        );
    begin
        report "starting triState tests...";
        for i in tests'range loop
            report "test: " & integer'image(i + 1);
            -- inputs
            s_data_in8 <= tests(i).data_in8;
            s_data_in16 <= tests(i).data_in16;
            s_activate <= tests(i).activate;

            wait for 10 ns;
            -- output
            --report "debug::: " &  to_string(internal);
            assert s_data_out16 = tests(i).data_out16
                report "[size2: " & integer'image(SIZE2) & "] failed test "
                    & integer'image(i + 1)
                    & " expected: " & to_string(tests(i).data_out16)
                    & " real: " & to_string(s_data_out16)
                severity error;
            assert s_data_out8 = tests(i).data_out8
                report "[size1: " & integer'image(SIZE) & "] failed test "
                    & integer'image(i + 1)
                    & " expected: " & to_string(tests(i).data_out8)
                    & " real: " & to_string(s_data_out8)
                severity error;

        end loop;

        report "finishing triState tests...";
        wait;
    end process;
end Tests;
