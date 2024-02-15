library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ProgramCounterTB is 
    generic(constant SIZE: integer := 32); 
end ProgramCounterTB; 


architecture Tests of ProgramCounterTB is
    signal s_m2, s_c2: std_logic;
    signal s_clk: std_logic := '0';
    signal s_rst: std_logic := '0';
    signal s_from_bus, s_out_data: std_logic_vector(SIZE - 1 downto 0);
    signal kill_clock: std_logic := '0';
    
begin
    pc: entity work.ProgramCounter port map(
        s_m2,
        s_c2,
        s_clk,
        s_rst,
        s_from_bus,
        s_out_data
    );

    clock: process 
    begin 
        wait for 5 ns;
        s_clk <= not s_clk;
        if (kill_clock = '1') then wait;
        end if;
    end process;

    stim_proc: process
    type test_case is record
        -- inputs
        S, U: std_logic;
        bus_data: std_logic_vector(SIZE - 1 downto 0);
       
        -- output 
        C: std_logic_vector(SIZE - 1 downto 0);
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
        -- +4 varias veces 
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
        report "starting pc tests...";
        -- reset
        report "test: " & integer'image(0);
        s_rst <= '1';
        wait for 10 ns;
        assert s_out_data = std_logic_vector(to_unsigned(0, SIZE)) report "test 0 failed: reset test" severity error;
        s_rst <= '0';

        for i in tests'range loop
            report "test: " & integer'image(i + 1);
            -- control signals
            s_c2 <= tests(i).U;
            s_m2 <= tests(i).S;
            -- inputs
            s_from_bus <= tests(i).bus_data;
            
            wait for 10 ns;
            -- output
            assert s_out_data = tests(i).C 
                report "failed test " 
                & integer'image(i + 1) & ": out value = " 
                & integer'image(to_integer(signed(s_out_data))) 
                severity error;

        end loop;
        report "test: " & integer'image(8);
        s_rst <= '1';
        wait for 10 ns;
        assert s_out_data = std_logic_vector(to_unsigned(0, SIZE)) report "test 0 failed: reset test" severity error;
        s_rst <= '0';
        report "finishing pc tests...";
        kill_clock <= '1';
        wait;
    end process;

end Tests;