library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Src;

entity Multiplexor2To1TB is
    generic(constant size: integer := 32);
end Multiplexor2To1TB;

architecture Tests of Multiplexor2To1TB is
    
    signal s_in_data1: std_logic_vector(size - 1 downto 0); 
    signal s_in_data0: std_logic_vector(size - 1 downto 0); 
    signal s_selec: std_logic;
    signal s_out_data: std_logic_vector(size - 1 downto 0);
begin
    mux: entity Src.Multiplexor2To1 port map (s_in_data1, s_in_data0, s_selec, s_out_data);

    process  
    type test_case is record 
    --inputs 
    A, B:std_logic_vector(size - 1 downto 0);
    S: std_logic;
    -- output
    C: std_logic_vector(size - 1 downto 0);
    end record;

    type tests_arr is array (natural range <>) of test_case; 

    constant tests: tests_arr := (
        (
        std_logic_vector(to_unsigned(92, size)), std_logic_vector(to_unsigned(37, size)), '1',
        std_logic_vector(to_unsigned(92, size))
        ),
        (
        std_logic_vector(to_unsigned(88, size)), std_logic_vector(to_unsigned(29, size)), '0',
        std_logic_vector(to_unsigned(29, size))
        )
    );
    begin 
        report "Starting tests of multiplexor 2:1...";
        for i in tests'range loop
            s_in_data1 <= tests(i).A;
            s_in_data0 <= tests(i).B;
            s_selec <= tests(i).S;
            wait for 10 ns;
            assert s_out_data = tests(i).C report "failed test " & integer'image(i + 1) & " " & integer'image(to_integer(signed(s_out_data)))
            severity error;
        end loop;
        report "End test multiplexor 2:1";
        wait;
            
    end process;

end architecture Tests; 
