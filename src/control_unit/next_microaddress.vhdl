library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use Work.Constants;

-- Determines the next microaddress
entity NextMicroaddress is
    port (
        signal current, from_opcode, jump_target: in
            std_logic_vector(Constants.MICROADDRESS_SIZE - 1 downto 0);
        signal jump_sel: in std_logic_vector(1 downto 0);
        signal next_addr: out std_logic_vector(Constants.MICROADDRESS_SIZE - 1 downto 0)
    );
end entity NextMicroaddress;


architecture Rtl of NextMicroaddress is
    constant FETCH: std_logic_vector(Constants.MICROADDRESS_SIZE - 1 downto 0)
        := (others => '0');
    signal addrs: std_logic_vector(Constants.MICROADDRESS_SIZE * 4 - 1 downto 0);
begin
    addr_selector: entity Work.Multiplexer generic map (2, Constants.MICROADDRESS_SIZE)
        port map (jump_sel, addrs, next_addr);
    addrs <= FETCH & jump_target & from_opcode & std_logic_vector(unsigned(current) + 1);
end architecture Rtl;
