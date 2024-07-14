library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_std.all;
use Work.Debug.all;


entity ProgramCounterTB is
end ProgramCounterTB;

library Src;
architecture Tests of ProgramCounterTB is
    constant SIZE: integer := 32;
    signal s_m2, s_c2: std_logic := '0';
    signal s_clk: std_logic := '0';
    signal s_rst: std_logic := '0';
    signal s_from_bus, s_out_data: std_logic_vector(SIZE - 1 downto 0) := (others => '0');
    signal kill_clock: std_logic := '0';
    --signal internal: std_logic_vector(63 downto 0);
begin
    pc: entity Src.ProgramCounter port map(
        s_m2,
        s_c2,
        s_clk,
        s_rst,
        s_from_bus,
        -- internal,
        s_out_data
    );

    clock: entity work.Clock port map (kill_clock, s_clk);

    stim_proc: process
        type test_case is record
            -- inputs
            m2, c2: std_logic;
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
            -- +4 more than one time
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
        assert s_out_data = std_logic_vector(to_unsigned(0, SIZE))
            report "test 0 failed: reset test" severity error;
        s_rst <= '0';

        for i in tests'range loop
            report "test: " & integer'image(i + 1);
            -- control signals
            s_c2 <= tests(i).c2;
            s_m2 <= tests(i).m2;
            -- inputs
            s_from_bus <= tests(i).bus_data;

            wait for 10 ns;
            -- output
            --report "debug::: " &  to_string(internal);
            assert s_out_data = tests(i).C
                report "failed test "
                    & integer'image(i + 1) & ": out value = "
                    & integer'image(to_integer(signed(s_out_data)))
                severity error;
        end loop;
        report "test: " & integer'image(8);
        s_rst <= '1';
        wait for 10 ns;
        assert s_out_data = std_logic_vector(to_unsigned(0, SIZE))
            report "test 0 failed: reset test" severity error;
        s_rst <= '0';
        report "finishing pc tests...";
        kill_clock <= '1';
        wait;
    end process;
end Tests;
