library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Src;
use Src.Constants;
use Src.Types;

use Work.TestingPkg.assert_eq;
use Work.TestingPkg.to_word;

entity StateRegisterTB is
end StateRegisterTB;

architecture Tests of StateRegisterTB is
    -- inputs
    signal clk: std_logic := '0';
	signal s_rst: std_logic := '0';

	signal s_update: std_logic;
	signal s_selector: std_logic;
    signal s_in_data0, s_in_data1: Types.word;

    -- output
    signal s_out_data: Types.word;

    -- aux for test
    signal clk_kill: std_logic := '0';
begin
    sr: entity src.StateRegister port map (
        clk, s_rst,
        s_in_data0, s_in_data1,
        s_update, s_selector,
        s_out_data
    );

    clock: entity work.Clock port map (clk_kill, clk);

    process
        type test_case is record
            --inputs
            in0, in1: Types.word;
            S: std_logic;
            U: std_logic;
            -- output
            C: Types.word;
        end record;

        type tests_arr is array (natural range <>) of test_case;

        constant tests: tests_arr := (
            -- Update first value, output = 92
            (
                -- in
                to_word(92), to_word(37), '0', '1',
                -- out
                to_word(92)
            ),
            -- keep data
            (
                -- in
                to_word(57), to_word(45), '0', '0',
                -- out
                to_word(92)
            ),
            (
                -- in
                to_word(35), to_word(13), '1', '0',
                -- out
                to_word(92)
            ),
            -- store another value
            (
                -- in
                to_word(76), to_word(88), '1', '1',
                -- out
                to_word(88)
            )
        );
    begin
        for i in tests'range loop
            s_in_data1 <= tests(i).in1;
            s_in_data0 <= tests(i).in0;
            s_selector <= tests(i).S;
            s_update <= tests(i).U;
            wait for 10 ns;
            assert_eq(s_out_data, tests(i).C, i, int => true);
        end loop;
        clk_kill <= '1';
        wait;
    end process;
end architecture Tests;
