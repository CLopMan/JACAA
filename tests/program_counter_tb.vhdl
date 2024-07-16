library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_std.all;

library Src;
use Src.Constants;
use Src.Types;

use Work.Tests.assert_eq;


entity ProgramCounterTB is
end ProgramCounterTB;

architecture Tests of ProgramCounterTB is
    constant SIZE: integer := Constants.WORD_SIZE;
    signal s_m2, s_c2: std_logic := '0';
    signal s_clk: std_logic := '0';
    signal s_rst: std_logic := '0';
    signal s_from_bus, s_out_data: Types.word := (others => '0');
    signal kill_clock: std_logic := '0';
begin
    pc: entity Src.ProgramCounter port map(
        s_m2,
        s_c2,
        s_clk,
        s_rst,
        s_from_bus,
        s_out_data
    );

    clock: entity work.Clock port map (kill_clock, s_clk);

    stim_proc: process
        type test_case is record
            -- inputs
            m2, c2: std_logic;
            bus_data: Types.word;
            -- output
            C: Types.word;
        end record;

        type test_arr is array(natural range <>) of test_case;
        constant tests: test_arr := (
            -- +4
            (
                -- in
                '1', '1',
                std_logic_vector(to_unsigned(92, SIZE)),
                -- out
                std_logic_vector(to_unsigned(4, SIZE))
            ),
            -- update from bus
            (
                -- in
                '0', '1',
                std_logic_vector(to_unsigned(1, SIZE)),
                -- out
                std_logic_vector(to_unsigned(1, SIZE))
            ),
            -- do not update
            (
                -- in
                '0', '0',
                std_logic_vector(to_unsigned(5, SIZE)),
                -- out
                std_logic_vector(to_unsigned(1, SIZE))
            ),
            (
                -- in
                '1', '0',
                std_logic_vector(to_unsigned(8, SIZE)),
                -- out
                std_logic_vector(to_unsigned(1, SIZE))
            ),
            -- +4 more than one time
            (
            -- in
                '1', '1',
                std_logic_vector(to_unsigned(7, SIZE)),
                --out
                std_logic_vector(to_unsigned(5, SIZE))
            ),
            (
                -- in
                '1', '1',
                std_logic_vector(to_unsigned(7, SIZE)),
                --out
                std_logic_vector(to_unsigned(9, SIZE))
            ),
            (
                -- in
                '1', '1',
                std_logic_vector(to_unsigned(7, SIZE)),
                --out
                std_logic_vector(to_unsigned(13, SIZE))
            )
        );
    begin
        -- reset
        s_rst <= '1';
        wait for 10 ns;
        assert_eq(s_out_data, std_logic_vector(to_unsigned(0, SIZE)), 1,
                  "reset test");
        s_rst <= '0';
        for i in tests'range loop
            -- control signals
            s_c2 <= tests(i).c2;
            s_m2 <= tests(i).m2;
            -- inputs
            s_from_bus <= tests(i).bus_data;
            wait for 10 ns;
            -- output
            assert_eq(s_out_data, tests(i).C, i);
        end loop;
        s_rst <= '1';
        wait for 10 ns;
        assert_eq(s_out_data, std_logic_vector(to_unsigned(0, SIZE)), 2,
                  "reset test");
        s_rst <= '0';
        kill_clock <= '1';
        wait;
    end process;
end Tests;
