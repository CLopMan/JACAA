library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

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

    -- 2 Tristates one Bus
    signal bus8b: std_logic_vector(SIZE - 1 downto 0)
        := (others => '0');
    signal st1: std_logic_vector(SIZE - 1 downto 0)
        := x"01";
    signal st2: std_logic_vector(SIZE - 1 downto 0)
        := x"FF";
    signal activateT1, activateT2: std_logic := '0';
begin
    -- for individual tests diff sizes
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

    -- various to one bus
    T1: entity Src.Tristate
        generic map(
            data_size => SIZE
        )
        port map(
            activate => activateT1,
            data_in => st1,
            data_out => bus8b
        );

    T2: entity Src.Tristate
        generic map(
            data_size => SIZE
        )
        port map(
            activate => activateT2,
            data_in => st2,
            data_out => bus8b
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

        type test_case2 is record
            -- inputs
            activatet1: std_logic;
            activatet2: std_logic;
            -- output
            expected_bus_data: std_logic_vector(SIZE - 1 downto 0);
        end record;
        
        type test_arr is array(natural range <>) of test_case;
        type test_arr2 is array(natural range <>) of test_case2;
        constant indiv_tests: test_arr := (
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
    
    constant bus_tests: test_arr2 := (
        -- allow t1
        (
            -- input
            '1', '0',
            -- output
            st1

        ),
        -- allow t2
        (
            -- input
            '0', '1',
            -- output
            st2
        )
    );

    begin
        report "starting triState tests...";
        for i in indiv_tests'range loop
            report "test: " & integer'image(i + 1);
            -- inputs
            s_data_in8 <= indiv_tests(i).data_in8;
            s_data_in16 <= indiv_tests(i).data_in16;
            s_activate <= indiv_tests(i).activate;

            wait for 10 ns;
            -- output
            --report "debug::: " &  to_string(internal);
            assert s_data_out16 = indiv_tests(i).data_out16
                report "[size2: " & integer'image(SIZE2) & "] failed test "
                    & integer'image(i + 1)
                    & " expected: " & to_string(indiv_tests(i).data_out16)
                    & " real: " & to_string(s_data_out16)
                severity error;
            assert s_data_out8 = indiv_tests(i).data_out8
                report "[size1: " & integer'image(SIZE) & "] failed test "
                    & integer'image(i + 1)
                    & " expected: " & to_string(indiv_tests(i).data_out8)
                    & " real: " & to_string(s_data_out8)
                severity error;

        end loop;
        wait for 10 ns; -- just because
        -- various triestates connected to one bus
        report "2 Tristates to one bus";

        for i in bus_tests'range loop

        -- inputs
        activatet1 <= bus_tests(i).activatet1;
        activatet2 <= bus_tests(i).activatet2;
        wait for 10 ns;
        -- output
        assert bus8b = bus_tests(i).expected_bus_data
            report "[2T1B] failed test " & integer'image(i + 1)
            & " expected: " & to_string(st1)
            & " real: " & to_string(bus8b);

        end loop;
        report "finishing triState tests...";
        wait;
    end process;
end Tests;
