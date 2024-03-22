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
    begin
        -- test1: store value
        s_in_data <= std_logic_vector(to_unsigned(92, SIZE));
        s_update <= '1';
        wait for 10 ns; assert s_out_data = std_logic_vector(to_unsigned(92, SIZE)) report "failed store 92: test 1";
        report "value: " & integer'image(to_integer(signed(s_out_data)));

        -- test2: reset value
        s_rst <= '1';
        wait for 10 ns; assert s_out_data = std_logic_vector(to_unsigned(0, SIZE)) report "failed rested: test 2";
        report "value: " & integer'image(to_integer(signed(s_out_data)));

        -- test3: read value while writing
        s_update <= '1';
        s_rst <= '0';
        s_in_data <= std_logic_vector(to_unsigned(33, SIZE));
        assert s_out_data = std_logic_vector(to_unsigned(0, SIZE)) report "failed read-while-writing: test 3";
        report "value: " & integer'image(to_integer(signed(s_out_data)));
        wait for 10 ns; assert s_out_data = std_logic_vector(to_unsigned(33, SIZE)) report "failed read-while-writing fase 2: test 3";
        report "value: " & integer'image(to_integer(signed(s_out_data)));
        -- test4: read twice
        wait for 10 ns; assert s_out_data = std_logic_vector(to_unsigned(33, SIZE)) report "failed store 33: test 4";
        report "value: " & integer'image(to_integer(signed(s_out_data)));
        wait for 10 ns; assert s_out_data = std_logic_vector(to_unsigned(33, SIZE)) report "failed store 33: test 4";
        report "value: " & integer'image(to_integer(signed(s_out_data)));

        report "finish";
        clk_kill <= '1';
        wait;
    end process;
end behavior;
