library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity StateRegisterTB is
    generic(constant size: integer := 32);
end StateRegisterTB;

architecture Tests of StateRegisterTB is

    -- inputs 
    signal s_clk: std_logic := '0';
	signal s_rst: std_logic := '0';

	signal s_update: std_logic;
	signal s_selector: std_logic;
    signal s_in_data0, s_in_data1, s_mux_reg: std_logic_vector(size - 1 downto 0);

    -- output
    signal s_out_data: std_logic_vector(size - 1 downto 0);

    -- aux for test 
    signal kill_clock: std_logic := '0';

begin
    sr: entity work.StateRegister port map
        (s_clk, s_rst, s_in_data0, s_in_data1, s_update, s_selector, s_out_data, s_mux_reg);

    clock: process
    begin 
        wait for 5 ns;
        s_clk <= not s_clk; 
        if (kill_clock = '1') then wait; 
        end if;
    end process;
    
    process  
    type test_case is record 
    --inputs 
    in0, in1: std_logic_vector(size - 1 downto 0);
    S: std_logic;
    U: std_logic;
    -- output
    C: std_logic_vector(size - 1 downto 0);
    end record;

    type tests_arr is array (natural range <>) of test_case; 

    constant tests: tests_arr := (
        -- Update first value, output = 92
        (
        -- in
        std_logic_vector(to_unsigned(92, size)), std_logic_vector(to_unsigned(37, size)), '0', '1', 
        
        -- out
        std_logic_vector(to_unsigned(92, size))
        ),
        
        -- keep data 
        (
        -- in
        std_logic_vector(to_unsigned(57, size)), std_logic_vector(to_unsigned(45, size)), '1', '0', 
        
        -- out
        std_logic_vector(to_unsigned(92, size))
        ),
        (
        -- in
        std_logic_vector(to_unsigned(35, size)), std_logic_vector(to_unsigned(13, size)), '1', '0', 
        
        -- out
        std_logic_vector(to_unsigned(92, size))
        ),

        -- store another value
        (
        -- in
        std_logic_vector(to_unsigned(76, size)), std_logic_vector(to_unsigned(88, size)), '1', '1', 
        
        -- out
        std_logic_vector(to_unsigned(88, size))
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
            report "s_in_data1: " & integer'image(to_integer(signed(s_in_data1)));
            report "s_in_data0: " & integer'image(to_integer(signed(s_in_data0)));
            report "S: " & std_logic'image(s_selector) & " U:" & std_logic'image(s_update);
            report "interconexion value: " & integer'image(to_integer(signed(s_mux_reg)));



            assert s_out_data = tests(i).C report "failed test " & integer'image(i + 1) & " with out value:" & integer'image(to_integer(signed(s_out_data)))
            severity error;
        end loop;
        report "End test StateRegister";
        report "final value: " & integer'image(to_integer(signed(s_out_data)));
        kill_clock <= '1';
        wait;
            
    end process;

end architecture Tests; 