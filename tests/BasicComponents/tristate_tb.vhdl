library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

library Src;

use Work.TestingPkg.assert_eq;
use Work.TestingPkg.to_vec;


entity TriStateTB is
end TriStateTB;

architecture Tests of TriStateTB is
    constant SIZE1: integer := 8;
    constant SIZE2: integer := 16;
    signal s_data_in8, s_data_out8: std_logic_vector(SIZE1 - 1 downto 0)
        := (others => '0');
    signal s_data_in16, s_data_out16: std_logic_vector(SIZE2 - 1 downto 0)
        := (others => '0');
    signal s_activate: std_logic := '0';

    -- 2 Tristates one Bus
    signal bus8b: std_logic_vector(SIZE1 - 1 downto 0) := (others => '0');
    signal st1: std_logic_vector(SIZE1 - 1 downto 0) := x"01";
    signal st2: std_logic_vector(SIZE1 - 1 downto 0) := x"FF";
    signal activateT1, activateT2: std_logic := '0';
begin
    -- for individual tests diff sizes
    T8: entity Src.Tristate generic map(SIZE1) port map(
        activate => s_activate,
        data_in => s_data_in8,
        data_out => s_data_out8
    );

    T16: entity Src.Tristate generic map(SIZE2) port map(
        activate => s_activate,
        data_in => s_data_in16,
        data_out => s_data_out16
    );

    -- various to one bus
    T1: entity Src.Tristate generic map(SIZE1) port map(
        activate => activateT1,
        data_in => st1,
        data_out => bus8b
    );

    T2: entity Src.Tristate generic map(SIZE1) port map(
        activate => activateT2,
        data_in => st2,
        data_out => bus8b
    );

    stim_proc: process
        type test_case is record
            -- inputs
            activate: std_logic;
            data_in8: std_logic_vector(SIZE1 - 1 downto 0);
            data_in16: std_logic_vector(SIZE2 - 1 downto 0);
            -- output
            data_out8: std_logic_vector(SIZE1 - 1 downto 0);
            data_out16: std_logic_vector(SIZE2 - 1 downto 0);
        end record;

        type test_case2 is record
            -- inputs
            activatet1: std_logic;
            activatet2: std_logic;
            -- output
            expected_bus_data: std_logic_vector(SIZE1 - 1 downto 0);
        end record;
        type test_arr is array(natural range <>) of test_case;
        type test_arr2 is array(natural range <>) of test_case2;
        constant indiv_tests: test_arr := (
            -- replicate input in output
            (
                -- in
                '1',
                to_vec(4, SIZE1), to_vec(8, SIZE2),
                -- out
                to_vec(4, SIZE1), to_vec(8, SIZE2)
            ),
            -- high impedance
            (
                -- in
                '0',
                to_vec(1, SIZE1), to_vec(1, SIZE2),
                -- out
                "ZZZZZZZZ", "ZZZZZZZZZZZZZZZZ"
            ),
            -- change input
            (
                -- in
                '1',
                to_vec(5, SIZE1), to_vec(10, SIZE2),
                -- out
                to_vec(5, SIZE1), to_vec(10, SIZE2)
            ),
            -- change input while its still activated
            (
                -- in
                '1',
                to_vec(8, SIZE1), to_vec(16, SIZE2),
                -- out
                to_vec(8, SIZE1), to_vec(16, SIZE2)
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
        for i in indiv_tests'range loop
            -- inputs
            s_data_in8 <= indiv_tests(i).data_in8;
            s_data_in16 <= indiv_tests(i).data_in16;
            s_activate <= indiv_tests(i).activate;
            wait for 10 ns;
            -- output
            assert_eq(s_data_out16, indiv_tests(i).data_out16, i, "size16");
            assert_eq(s_data_out8, indiv_tests(i).data_out8, i, "size8");
        end loop;
        wait for 10 ns; -- just because
        -- various triestates connected to one bus
        for i in bus_tests'range loop
            -- inputs
            activatet1 <= bus_tests(i).activatet1;
            activatet2 <= bus_tests(i).activatet2;
            wait for 10 ns;
            -- output
            assert_eq(bus8b, bus_tests(i).expected_bus_data, i, "2T1B");
        end loop;
        wait;
    end process;
end Tests;
