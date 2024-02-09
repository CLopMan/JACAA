LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY register_testBench is
    generic(constant size: integer := 32);

END register_testBench;

ARCHITECTURE behavior of register_testBench is 
	COMPONENT reg is 
    

		PORT (
			clk: in std_logic;
            rst: in std_logic;
            update: in std_logic;
            in_data: in std_logic_vector(size - 1 downto 0);
            out_data: out std_logic_vector(size - 1 downto 0)
		);
	END COMPONENT;
	SIGNAL s_clk : std_logic := '0';
	SIGNAL s_rst : std_logic;
	SIGNAL s_update : std_logic;
    signal s_in_data: std_logic_vector(size - 1 downto 0);
    signal s_out_data: std_logic_vector(size - 1 downto 0);
    signal kill_clock: std_logic := '0';
	
	BEGIN 
		uut: reg port map ( -- unit under test
			clk => s_clk,
			rst => s_rst,
			update => s_update,
            out_data => s_out_data,
            in_data => s_in_data
		);

        clock: process
            begin 
                wait for 5 ns;
                s_clk <= not s_clk; 
                if (kill_clock = '1') then wait; 
                end if;
            end process;

		stim_proc: PROCESS --stimulation process 
		BEGIN 
            
            -- test1: store value
            s_in_data <= std_logic_vector(to_unsigned(92, size));
            s_update <= '1'; 
            wait for 10 ns; assert s_out_data = std_logic_vector(to_unsigned(92, size)) report "failed store 92: test 1";
            report "value: " & integer'image(to_integer(signed(s_out_data)));

            -- test2: reset value 
            s_rst <= '1'; 
            wait for 10 ns; assert s_out_data = std_logic_vector(to_unsigned(0, size)) report "failed rested: test 2";
            report "value: " & integer'image(to_integer(signed(s_out_data)));

            -- test3: read value while writing 
            s_update <= '1';
            s_rst <= '0'; 
            s_in_data <= std_logic_vector(to_unsigned(33, size));
            assert s_out_data = std_logic_vector(to_unsigned(0, size)) report "failed read-while-writing: test 3";
            report "value: " & integer'image(to_integer(signed(s_out_data)));
            wait for 10 ns; assert s_out_data = std_logic_vector(to_unsigned(33, size)) report "failed read-while-writing fase 2: test 3";
            report "value: " & integer'image(to_integer(signed(s_out_data)));
            -- test4: read twice 
            wait for 10 ns; assert s_out_data = std_logic_vector(to_unsigned(33, size)) report "failed store 33: test 4";
            report "value: " & integer'image(to_integer(signed(s_out_data)));
            wait for 10 ns; assert s_out_data = std_logic_vector(to_unsigned(33, size)) report "failed store 33: test 4";
            report "value: " & integer'image(to_integer(signed(s_out_data)));

		
		REPORT "finish";
        kill_clock <= '1';
		WAIT;
	END PROCESS;
END;
			
	
