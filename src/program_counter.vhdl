library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Src;
use work.Constants;

entity ProgramCounter is 
    port(
        -- control signal
        m2: in std_logic; -- mutex selector
        c2: in std_logic; -- update signal

        -- clk & reset 
        clk: in std_logic;
        rst: in std_logic;

        -- data lines 
        from_bus: in std_logic_vector(Constants.WORD_SIZE - 1 downto 0) := (others => '0'); 
        -- output 
        -- internal: out std_logic_vector(63 downto 0); -- TODO: DELETE
        out_data: out std_logic_vector(Constants.WORD_SIZE - 1 downto 0) := (others => '0')
    );
end ProgramCounter;

architecture behaviour of ProgramCounter is 
    constant addr_size: positive := Constants.WORD_SIZE / 8;
    -- cable + 4
    signal next_addr: std_logic_vector(Constants.WORD_SIZE * 2 - 1 downto 0)
        := (others => '0');
    -- mux -> reg
    signal reg_in: std_logic_vector(Constants.WORD_SIZE - 1 downto 0) := (others => '0');
    signal reg_out: std_logic_vector(Constants.WORD_SIZE - 1 downto 0) := (others => '0');
begin
    next_addr
    <= std_logic_vector(
        unsigned(
           reg_out 
        )    
        + addr_size) & from_bus;

    mux: entity work.Multiplexer
        generic map (
            sel_size => 1,
            data_size => Constants.WORD_SIZE
        )
        port map (
            sel(0) => m2,
            data_in => next_addr,
            data_out => reg_in
        );

    pc: entity work.Reg
        port map (clk, rst, c2, reg_in, reg_out);

    out_data <= reg_out;
    -- internal <= next_addr; -- TODO: DELETE
        
end behaviour;
