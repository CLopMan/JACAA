library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Src;
use Src.Constants;

entity GenMultiplexerTB is
end GenMultiplexerTB;

architecture Tests of GenMultiplexerTB is
    constant DATA_SIZE: positive := 4;
    constant SEL_SIZE : positive := 2;
    signal s0 : std_logic_vector (DATA_SIZE - 1 downto 0) := "0000";
    signal s1 : std_logic_vector (DATA_SIZE - 1 downto 0):= "0001";
    signal s2 : std_logic_vector (DATA_SIZE - 1 downto 0):= "0010";
    signal s3 : std_logic_vector (DATA_SIZE - 1 downto 0):= "0011";
    signal signals_in : std_logic_vector(DATA_SIZE * 2**SEL_SIZE - 1 downto 0) := s0 & s1 & s2 & s3;
    signal sel : std_logic_vector(SEL_SIZE - 1 downto 0) := (others => '0');
    signal data_out : std_logic_vector (DATA_SIZE - 1 downto 0);
begin

    mux: entity Src.Multiplexer
    generic map (
        sel_size => SEL_SIZE,
        data_size => DATA_SIZE
    )
    port map (
        sel => sel,
        data_in => signals_in,
        data_out => data_out
    );

    process

    begin
        report "Starting tests of genmultiplexer";
        sel <= "10";
        wait for 10 ns;
        report ">>> " & integer'image(to_integer((signed(data_out))));
        wait;

    end process;
end architecture Tests;
