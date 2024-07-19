library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.Numeric_Std.all;

use Work.Constants;
use Work.Types;

entity CopDecoder is
    port (
        signal instruction: in Types.word;
        signal sel_cop: in std_logic_vector(4 downto 0);
        signal sel: in std_logic;
        signal cop: out std_logic_vector(4 downto 0)
    );
end entity CopDecoder;


architecture Rtl of CopDecoder is
    signal cop_options: std_logic_vector(9 downto 0);
    signal instruction_cop: std_logic_vector(4 downto 0);

    pure function ternary(cond: std_logic; if_0, if_1: std_logic_vector)
        return std_logic_vector is
    begin
        case (cond) is
            when '0' => return if_0;
            when '1' => return if_1;
            when others => return "-----";
        end case;
    end function;
begin
    mux: entity Work.Multiplexer generic map(1, 5)
        port map(
            sel(0) => sel,
            data_in => cop_options,
            data_out => cop
        );
    cop_options <= sel_cop & instruction_cop;

    cop_decoder: process(instruction)
        variable opcode: std_logic_vector(Constants.OPCODE_SIZE - 1 downto 0);
        variable funct3: std_logic_vector(2 downto 0);
    begin
        opcode := instruction(Constants.OPCODE_SIZE - 1 downto 0);
        funct3 := instruction(14 downto 12);
        case (opcode) is
            when "0010011" | "0110011" =>
                case (funct3) is
                    when "000" => -- ADDI or ADD/SUB
                        instruction_cop <= ternary(
                            opcode(5),
                            "01010", -- ADDI
                            ternary(instruction(30), "01010", "01011") -- ADD/SUB
                        );
                    when "010" => instruction_cop <= "11010"; -- SLT
                    when "011" => instruction_cop <= "11011"; -- SLTU
                    when "100" => instruction_cop <= "00100"; -- XOR
                    when "110" => instruction_cop <= "00010"; -- OR
                    when "111" => instruction_cop <= "00001"; -- AND
                    when "001" => instruction_cop <= "00111"; -- SLL
                    when "101" => -- SRL/SRA
                        instruction_cop <= ternary(instruction(30), "00101", "00110");
                    when others => instruction_cop <= "-----";
                end case;
            when "1100011" =>
                case (funct3) is
                    when "000" => instruction_cop <= "01011"; -- BEQ (a - b = 0)
                    when "001" => instruction_cop <= "01011"; -- TODO: BNE
                    when "100" => instruction_cop <= "11010"; -- BLT
                    when "101" => instruction_cop <= "01011"; -- TODO: BGE
                    when "110" => instruction_cop <= "11011"; -- BLTU
                    when "111" => instruction_cop <= "01011"; -- TODO: BGEU
                    when others => instruction_cop <= "-----";
                end case;
            when others => instruction_cop <= "-----";
        end case;
    end process cop_decoder;
end architecture Rtl;
