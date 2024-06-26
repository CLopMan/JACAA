library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity GenMultiplexerTB is
end GenMultiplexerTB;

architecture Tests of GenMultiplexerTB is
    type tuple is array (1 downto 0) of positive;
    constant DATA_SIZE : tuple := (5, 4);
    constant SEL_SIZE : tuple := (3, 2);
    ---------------------
    -- signal naming:
    -- s<index>_<sel_size>
    -- name_<sel_size>
    ----------------------
    -- mutex (2, 4)
    signal s0_2 : std_logic_vector (DATA_SIZE(0) - 1 downto 0) := "0000";
    signal s1_2 : std_logic_vector (DATA_SIZE(0) - 1 downto 0) := "0001";
    signal s2_2 : std_logic_vector (DATA_SIZE(0) - 1 downto 0) := "0010";
    signal s3_2 : std_logic_vector (DATA_SIZE(0) - 1 downto 0) := "0011";
    signal signals_in_2 :
        std_logic_vector(DATA_SIZE(0) * 2**SEL_SIZE(0) - 1 downto 0);
    signal sel_2 :
        std_logic_vector(SEL_SIZE(0) - 1 downto 0) := (others => '0');
    signal data_out_2 : std_logic_vector (DATA_SIZE(0) - 1 downto 0);

    -- mutex (3, 5)
    signal s0_3 : std_logic_vector (DATA_SIZE(1) - 1 downto 0) := "01111";
    signal s1_3 : std_logic_vector (DATA_SIZE(1) - 1 downto 0) := "01110";
    signal s2_3 : std_logic_vector (DATA_SIZE(1) - 1 downto 0) := "01101";
    signal s3_3 : std_logic_vector (DATA_SIZE(1) - 1 downto 0) := "01100";
    signal s4_3 : std_logic_vector (DATA_SIZE(1) - 1 downto 0) := "01011";
    signal s5_3 : std_logic_vector (DATA_SIZE(1) - 1 downto 0) := "01010";
    signal s6_3 : std_logic_vector (DATA_SIZE(1) - 1 downto 0) := "01001";
    signal s7_3 : std_logic_vector (DATA_SIZE(1) - 1 downto 0) := "01000";
    signal signals_in_3 : std_logic_vector(DATA_SIZE(1) * 2**SEL_SIZE(1) - 1 downto 0);
    signal sel_3 : std_logic_vector(SEL_SIZE(1) - 1 downto 0) := (others => '0');
    signal data_out_3 : std_logic_vector (DATA_SIZE(1) - 1 downto 0);

begin
    signals_in_2 <= s3_2 & s2_2 & s1_2 & s0_2; -- invert order cause bigEndian
    signals_in_3 <= s7_3 & s6_3 & s5_3 & s4_3 & s3_3 & s2_3 & s1_3 & s0_3;
    mux_2: entity Src.Multiplexer
        generic map (
            sel_size => SEL_SIZE(0),
            data_size => DATA_SIZE(0)
        )
        port map (
            sel => sel_2,
            data_in => signals_in_2,
            data_out => data_out_2
        );

    mux_3: entity Src.Multiplexer
        generic map (
            sel_size => SEL_SIZE(1),
            data_size => DATA_SIZE(1)
        )
        port map (
            sel => sel_3,
            data_in => signals_in_3,
            data_out => data_out_3
        );

    process
        type tests_case is record
            -- Inputs
            sel_2: std_logic_vector(SEL_SIZE(0) - 1 downto 0);
            sel_3: std_logic_vector(SEL_SIZE(1) - 1 downto 0);
            -- Expected output
            data_out_2: std_logic_vector(DATA_SIZE(0) - 1 downto 0);
            data_out_3: std_logic_vector(DATA_SIZE(1) - 1 downto 0);
        end record;
        -- The patterns to apply
        type tests_array is array (natural range <>) of tests_case;
        constant TESTS : tests_array := (
            ("00", "000", "0000", "01111"),
            ("01", "001", "0001", "01110"),
            ("10", "010", "0010", "01101"),
            ("11", "011", "0011", "01100"),
            ("11", "100", "0011", "01011"),
            ("11", "101", "0011", "01010"),
            ("11", "110", "0011", "01001"),
            ("11", "111", "0011", "01000")
        );

    begin
        report "Starting tests of GenMultiplexer";
        for i in TESTS'range loop
            sel_2 <= TESTS(i).sel_2;
            sel_3 <= TESTS(i).sel_3;
            wait for 10 ns;
            assert data_out_2 = TESTS(i).data_out_2
                and data_out_3 = TESTS(i).data_out_3
                report "bad result on test: " & integer'image(i + 1)
                severity error;
            -- DEBUG
            -- report ">>> " & integer'image(to_integer((signed(data_out_2))))
            -- & " | "
            -- & integer'image(to_integer((signed(data_out_3))));
        end loop;
        -- change singals_in
        s3_2 <= "1111";
        wait for 10 ns;
        assert data_out_2 = "1111"
            report "bad result change signals_in";
        -- report ">>> " & integer'image(to_integer((signed(data_out))));
        report "End of tests of GenMultiplexer";
        wait;

    end process;

end architecture Tests;
