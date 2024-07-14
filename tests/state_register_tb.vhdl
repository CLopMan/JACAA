library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Src;
use Src.Constants;
use Src.Types;

entity StateRegisterTB is
end StateRegisterTB;

architecture Tests of StateRegisterTB is
    constant SIZE: positive := Constants.WORD_SIZE;

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
                std_logic_vector(to_unsigned(92, SIZE)),
                std_logic_vector(to_unsigned(37, SIZE)), '0', '1',

                -- out
                std_logic_vector(to_unsigned(92, SIZE))
            ),
            -- keep data
            (
                -- in
                std_logic_vector(to_unsigned(57, SIZE)),
                std_logic_vector(to_unsigned(45, SIZE)), '0', '0',

                -- out
                std_logic_vector(to_unsigned(92, SIZE))
            ),
            (
                -- in
                std_logic_vector(to_unsigned(35, SIZE)),
                std_logic_vector(to_unsigned(13, SIZE)), '1', '0',

                -- out
                std_logic_vector(to_unsigned(92, SIZE))
            ),
            -- store another value
            (
                -- in
                std_logic_vector(to_unsigned(76, SIZE)),
                std_logic_vector(to_unsigned(88, SIZE)), '1', '1',

                -- out
                std_logic_vector(to_unsigned(88, SIZE))
            )
        );
    begin
        report "Starting tests of StateRegister...";
        for i in tests'range loop
            report "test: " & integer'image(i + 1);

            s_in_data1 <= tests(i).in1;
            s_in_data0 <= tests(i).in0;
            s_selector <= tests(i).S;
            s_update <= tests(i).U;

            wait for 10 ns;
            assert s_out_data = tests(i).C
                report "failed test " & integer'image(i + 1)
                    & " with out value: "
                    & integer'image(to_integer(signed(s_out_data)))
                severity error;
        end loop;
        report "End test StateRegister";
        report "final value: " & integer'image(to_integer(signed(s_out_data)));
        clk_kill <= '1';
        wait;

    end process;

end architecture Tests;
