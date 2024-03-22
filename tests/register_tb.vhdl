library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Src;
use Src.Constants;

entity RegisterTB is
end RegisterTB;


architecture behavior of RegisterTB is
    constant SIZE: positive := Constants.WORD_SIZE;

	signal clk : std_logic := '0';
	signal s_rst : std_logic;
	signal s_update : std_logic;
    signal s_in_data: std_logic_vector(SIZE - 1 downto 0);
    signal s_out_data: std_logic_vector(SIZE - 1 downto 0);
    signal clk_kill: std_logic := '0';
begin
    uut: entity Src.Reg port map ( -- unit under test
        clk => clk,
        rst => s_rst,
        update => s_update,
        out_data => s_out_data,
        in_data => s_in_data
    );

    clock: entity work.Clock port map (clk_kill, clk);

    stim_proc: process -- stimulation process
        type test_case is record
            -- inputs
            s_in_data: std_logic_vector(SIZE - 1 downto 0);
            s_update, s_rst: std_logic;
            -- output
            s_out_data: std_logic_vector(SIZE - 1 downto 0);
        end record;

        type tests_array is array (natural range <>) of test_case;

        constant TESTS: tests_array := (
            -- test1: store value
            (
                std_logic_vector(to_unsigned(92, SIZE)), '1', '0',
                std_logic_vector(to_unsigned(92, SIZE))
            ),
            -- test2: reset value
            (
                std_logic_vector(to_unsigned(92, SIZE)), '0', '1',
                std_logic_vector(to_unsigned(0, SIZE))
            ),
            -- test3: read value while writing
            (
                std_logic_vector(to_unsigned(33, SIZE)), '1', '0',
                std_logic_vector(to_unsigned(33, SIZE))
            ),
            -- test4: read twice
            (
                std_logic_vector(to_unsigned(0, SIZE)), '0', '0',
                std_logic_vector(to_unsigned(33, SIZE))
            )
        );
    begin
        assert false report "start of test" severity note;
        for i in TESTS'range loop
            -- Set the inputs
            s_in_data <= TESTS(i).s_in_data;
            s_update <= TESTS(i).s_update;
            s_rst <= TESTS(i).s_rst;
            -- Wait for the results
            wait for 10 ns;
            -- Check the outputs
            assert s_out_data = TESTS(i).s_out_data
                report "bad result on test: " & integer'image(i + 1)
                    & ", result: "
                    & integer'image(to_integer(signed(s_out_data)))
                    & ", expected: "
                    & integer'image(to_integer(signed(TESTS(i).s_out_data)))
                severity error;
        end loop;
        assert false report "end of test" severity note;
        clk_kill <= '1';
        -- Wait forever; this will finish the simulation
        wait;
    end process;
end behavior;
