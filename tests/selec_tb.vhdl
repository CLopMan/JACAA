library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library Src;
use Src.Constants;
use Src.Types;

use Work.TestingPkg.all;

entity SelecTB is
end SelecTB;

architecture Tests of SelecTB is
    -- inputs
    signal s_data_in: Types.word;
    signal s_size: integer;
    signal s_offset: integer;
    signal s_se: std_logic;
    -- output
    signal s_data_out: Types.word;

begin
    selec: entity Src.Selec port map (
        se => s_se,
        size => s_size,
        offset => s_offset,
        data_in => s_data_in,
        data_out => s_data_out
    );

    process
        type test_case is record
            --inputs
            se: std_logic;
            offset, size: integer;
            -- output
            data_in, data_out: Types.word;
        end record;

        type tests_arr is array (natural range <>) of test_case;

        constant tests: tests_arr := (
            -- get 4 bits with se
            (
                -- in
                '1',
                12, 4,
                -- out
                x"bbbb8bbb", x"FFFFFFF8"
            ),
            -- get 4 bits without se
            (
                -- in
                '0',
                12, 4,
                -- out
                x"ffff8fff", x"00000008"
            ),
            -- get 1 bit with se
            (
                -- in
                '1',
                0, 1,
                -- out
                x"00000001", x"FFFFFFFF"
            ),
            -- get 1 bit with se
            (
                -- in
                '0',
                0, 1,
                -- out
                x"00000001", x"00000001"
            ),
            -- get every bit bit with se
            (
                -- in
                '0',
                0, Constants.WORD_SIZE,
                -- out
                x"00000001", x"00000001"
            )
        );
    begin
        for i in tests'range loop
            s_data_in <= tests(i).data_in;
            s_se <= tests(i).se;
            s_offset <= tests(i).offset;
            s_size <= tests(i).size;
            wait for 10 ns;
            assert_eq(s_data_out, tests(i).data_out, i);
        end loop;
        wait;
    end process;
end architecture Tests;
