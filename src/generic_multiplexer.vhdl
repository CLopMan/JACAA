library IEEE;
use IEEE.Std_Logic_1164.all; -- data types
use IEEE.Numeric_Std.all; -- to_integer function
use work.Constants; -- constants module

entity Multiplexer is
    generic ( -- mux params
        sel_size: positive := 5; -- number of bits of **sel**
        data_size: positive := Constants.WORD_SIZE -- size/width of mux inputs
                                                    -- to concat use:
                                                    -- data_in <= sig1 & sig2...
    );

    port (
        signal sel: in
            std_logic_vector (sel_size - 1 downto 0) := (others => '0');
        -- Std_logic_vector instead of array of std_logic_vectors 
        -- is used due to standard issues
        -- prev 2008 standard does not allow unconstrained vectors
        signal data_in: in
            std_logic_vector (2**sel_size * data_size - 1 downto 0);
        signal data_out: out
            std_logic_vector (data_size - 1 downto 0)
    );
end entity Multiplexer;


architecture behaviour of Multiplexer is
begin
    data_out <= data_in(data_size * (to_integer(unsigned(sel)) + 1) - 1
        downto to_integer(unsigned(sel)) * data_size);
end architecture behaviour;
