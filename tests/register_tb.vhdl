library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Src;

entity RegTB is
end RegTB;


architecture behavior of RegTB is
    constant SIZE32: positive := 32;
    constant SIZE5: positive := 5;

	signal clk: std_logic := '0';
	signal s_rst: std_logic;
	signal s_update: std_logic;
    signal s_in_data_32: std_logic_vector(SIZE32 - 1 downto 0);
    signal s_out_data_32: std_logic_vector(SIZE32 - 1 downto 0);
    signal s_in_data_5: std_logic_vector(SIZE5 - 1 downto 0);
    signal s_out_data_5: std_logic_vector(SIZE5 - 1 downto 0);
    signal clk_kill: std_logic := '0';
begin
    uut1: entity Src.Reg -- reg 32 updated rising edge
        generic map(
            reg_size => SIZE32,
            updt_rising => '1'
        )
        port map ( -- unit under test
            clk => clk,
            rst => s_rst,
            update => s_update,
            out_data => s_out_data_32,
            in_data => s_in_data_32
        );

    uut2: entity Src.Reg -- reg 5 updated falling edge
        generic map(
            reg_size => SIZE5,
            updt_rising => '0'
        )
        port map ( -- unit under test
            clk => clk,
            rst => s_rst,
            update => s_update,
            out_data => s_out_data_5,
            in_data => s_in_data_5
        );

    clock: entity work.Clock port map (clk_kill, clk);

    stim_proc: process -- stimulation process
        type test_case is record
            -- inputs
            s_in_data_32: std_logic_vector(SIZE32 - 1 downto 0);
            s_in_data_5: std_logic_vector(SIZE5 - 1 downto 0);
            s_update, s_rst: std_logic;
            -- output
            -- value in rising edge
            rise_out_data_32: std_logic_vector(SIZE32 - 1 downto 0);
            rise_out_data_5: std_logic_vector(SIZE5 - 1 downto 0);
            -- value in falling edge
            fall_out_data_32: std_logic_vector(SIZE32 - 1 downto 0);
            fall_out_data_5: std_logic_vector(SIZE5 - 1 downto 0);
        end record;

        type tests_array is array (natural range <>) of test_case;

        constant TESTS: tests_array := (
            -- test1: store value
            (
                std_logic_vector(to_unsigned(92, SIZE32)),
                std_logic_vector(to_unsigned(2, SIZE5)),
                '1', '0',
                std_logic_vector(to_unsigned(92, SIZE32)),
                std_logic_vector(to_unsigned(2, SIZE5)),
                std_logic_vector(to_unsigned(0, SIZE32)),
                std_logic_vector(to_unsigned(2, SIZE5))
            ),
            -- test2: reset value
            (
                std_logic_vector(to_unsigned(92, SIZE32)),
                std_logic_vector(to_unsigned(31, SIZE5)),
                '0', '1',
                std_logic_vector(to_unsigned(0, SIZE32)),
                std_logic_vector(to_unsigned(0, SIZE5)),
                std_logic_vector(to_unsigned(0, SIZE32)),
                std_logic_vector(to_unsigned(0, SIZE5))
            ),
            -- test3: update value
            (
                std_logic_vector(to_unsigned(33, SIZE32)),
                std_logic_vector(to_unsigned(1, SIZE5)),
                '1', '0',
                std_logic_vector(to_unsigned(33, SIZE32)),
                std_logic_vector(to_unsigned(1, SIZE5)),
                std_logic_vector(to_unsigned(0, SIZE32)),
                std_logic_vector(to_unsigned(1, SIZE5))
            ),
            -- test4: read twice
            (
                std_logic_vector(to_unsigned(0, SIZE32)),
                std_logic_vector(to_unsigned(0, SIZE5)),
                '0', '0',
                std_logic_vector(to_unsigned(33, SIZE32)),
                std_logic_vector(to_unsigned(1, SIZE5)),
                std_logic_vector(to_unsigned(33, SIZE32)),
                std_logic_vector(to_unsigned(1, SIZE5))
            )
        );
    begin
        report "start of test" severity note;
        s_rst <= '1';
        wait for 10 ns; -- wait for the signal to propagate 
        s_rst <= '0';
        for i in TESTS'range loop
            -- Set the inputs
            s_in_data_32 <= TESTS(i).s_in_data_32;
            s_in_data_5 <= TESTS(i).s_in_data_5;
            s_update <= TESTS(i).s_update;
            s_rst <= TESTS(i).s_rst;
            -- Read before falling edge
            if i > 1 then
                assert s_out_data_32 = TESTS(i - 1).rise_out_data_32
                    report "[before fall edge] error on reg32 on test: " & integer'image(i + 1)
                        & ", result32: "
                        & integer'image(to_integer(signed(s_out_data_32)))
                        & ", expected32: "
                        & integer'image(to_integer(signed(TESTS(i - 1).rise_out_data_32)))
                    severity error;

                assert s_out_data_5 = TESTS(i - 1).rise_out_data_5
                    report "[before fall edge] error on reg5 on test: " & integer'image(i + 1)
                        & ", result5: "
                        & integer'image(to_integer(signed(s_out_data_5)))
                        & ", expected5: "
                        & integer'image(to_integer(signed(TESTS(i - 1).rise_out_data_5)))
                    severity error;
            end if;
            -- Read on falling edge
            wait for 1 ns;
            assert s_out_data_32 = TESTS(i).fall_out_data_32
                report "[fall edge] error on reg32 on test: " & integer'image(i + 1)
                    & ", result32: "
                    & integer'image(to_integer(signed(s_out_data_32)))
                    & ", expected32: "
                    & integer'image(to_integer(signed(TESTS(i).fall_out_data_32)))
                severity error;

            assert s_out_data_5 = TESTS(i).fall_out_data_5
                report "[fall edge] error on reg5 on test: " & integer'image(i + 1)
                    & ", result5: "
                    & integer'image(to_integer(signed(s_out_data_5)))
                    & ", expected5: "
                    & integer'image(to_integer(signed(TESTS(i).fall_out_data_5)))
                severity error;
            -- Read before rising edge
            if i > 1 then
                assert s_out_data_32 = TESTS(i).fall_out_data_32
                    report "[before rise edge] error on reg32 on test: " & integer'image(i + 1)
                        & ", result32: "
                        & integer'image(to_integer(signed(s_out_data_32)))
                        & ", expected32: "
                        & integer'image(to_integer(signed(TESTS(i - 1).fall_out_data_32)))
                    severity error;

                assert s_out_data_5 = TESTS(i).fall_out_data_5
                    report "[before rise edge] error on reg5 on test: " & integer'image(i + 1)
                        & ", result5: "
                        & integer'image(to_integer(signed(s_out_data_5)))
                        & ", expected5: "
                        & integer'image(to_integer(signed(TESTS(i).fall_out_data_5)))
                    severity error;
            end if;
            wait for 4 ns;
            -- Wait for rising edge
            wait for 1 ns;
            -- Check the outputs
            assert s_out_data_32 = TESTS(i).rise_out_data_32
                report "[rise edge] error on reg32 on test: " & integer'image(i + 1)
                    & ", result32: "
                    & integer'image(to_integer(signed(s_out_data_32)))
                    & ", expected32: "
                    & integer'image(to_integer(signed(TESTS(i).rise_out_data_32)))
                severity error;
            assert s_out_data_5 = TESTS(i).rise_out_data_5
                report "[rise edge] error on reg5 on test: " & integer'image(i + 1)
                    & ", result5: "
                    & integer'image(to_integer(signed(s_out_data_5)))
                    & ", expected5: "
                    & integer'image(to_integer(signed(TESTS(i).rise_out_data_5)))
                severity error;
            wait for 4 ns; -- end cycle
        end loop;
        report "end of test" severity note;
        clk_kill <= '1';
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end behavior;
