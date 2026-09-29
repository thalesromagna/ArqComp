library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco_ula_tb is
end entity;

architecture a_banco_ula_tb of banco_ula_tb is
    component banco_ula is
        port( reg_wr, reg_r1, reg_r2 : in unsigned(2 downto 0);
              clk, wr_en, rst        : in std_logic;
              ula_out                : out unsigned(15 downto 0);
              data_r1, data_r2       : out unsigned(15 downto 0);
              constante              : in unsigned(15 downto 0);
              controle               : in unsigned(1 downto 0);
              sel_ula_b              : in std_logic;
              sel_data_wr            : in std_logic;
              zero, carry, overflow, sinal : out std_logic
        );
    end component;

    constant period_time : time      := 100 ns;
    signal   finished    : std_logic := '0';
    signal   clk, rst, wr_en, sel_ula_b, sel_data_wr : std_logic;
    signal   zero, carry, overflow, sinal : std_logic;
    signal   reg_wr, reg_r1, reg_r2 : unsigned(2 downto 0);
    signal   controle : unsigned(1 downto 0);
    signal   constante, ula_out, data_r1, data_r2 : unsigned(15 downto 0);
begin
    uut: banco_ula port map( reg_wr      => reg_wr,
                             reg_r1      => reg_r1,
                             reg_r2      => reg_r2,
                             clk         => clk,
                             wr_en       => wr_en,
                             rst         => rst,
                             ula_out     => ula_out,
                             data_r1     => data_r1,
                             data_r2     => data_r2,
                             constante   => constante,
                             controle    => controle,
                             sel_ula_b   => sel_ula_b,
                             sel_data_wr => sel_data_wr,
                             zero        => zero,
                             carry       => carry,
                             overflow    => overflow,
                             sinal       => sinal
                           );

    reset_global: process
    begin
        rst <= '1';
        wait for period_time*2;
        rst <= '0';
        wait for period_time*25;
        rst <= '1';
        wait for period_time;
        rst <= '0';
        wait;
    end process;

    sim_time_proc: process
    begin
        wait for 3000 ns;
        finished <= '1';
        wait;
    end process sim_time_proc;

    clk_proc: process
    begin
        while finished /= '1' loop
            clk <= '0';
            wait for period_time/2;
            clk <= '1';
            wait for period_time/2;
        end loop;
        wait;
    end process clk_proc;

    process
    begin
        wr_en <= '0';
        reg_wr <= "000";
        reg_r1 <= "000";
        reg_r2 <= "000";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '0';
        constante <= "0000000000000000";
        wait for 200 ns;
        wr_en <= '1';
        reg_wr <= "011";
        reg_r1 <= "011";
        reg_r2 <= "100";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '1';
        constante <= "0000000000000101";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "100";
        reg_r1 <= "011";
        reg_r2 <= "100";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '1';
        constante <= "0000000000001000";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "011";
        reg_r1 <= "011";
        reg_r2 <= "100";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '0';
        constante <= "0000000000000000";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "011";
        reg_r1 <= "011";
        reg_r2 <= "100";
        controle <= "01";
        sel_ula_b <= '0';
        sel_data_wr <= '0';
        constante <= "0000000000000000";
        wait for 100 ns;
        wr_en <= '0';
        reg_wr <= "011";
        reg_r1 <= "011";
        reg_r2 <= "100";
        controle <= "01";
        sel_ula_b <= '1';
        sel_data_wr <= '0';
        constante <= "0000000000000101";
        wait for 100 ns;
        wr_en <= '0';
        reg_wr <= "011";
        reg_r1 <= "011";
        reg_r2 <= "100";
        controle <= "01";
        sel_ula_b <= '1';
        sel_data_wr <= '0';
        constante <= "0000000000000111";
        wait for 100 ns;
        wr_en <= '0';
        reg_wr <= "011";
        reg_r1 <= "011";
        reg_r2 <= "100";
        controle <= "01";
        sel_ula_b <= '1';
        sel_data_wr <= '0';
        constante <= "0000000000000011";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "000";
        reg_r1 <= "000";
        reg_r2 <= "111";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '1';
        constante <= "0000000100000001";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "001";
        reg_r1 <= "001";
        reg_r2 <= "000";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '1';
        constante <= "0001000100010001";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "010";
        reg_r1 <= "010";
        reg_r2 <= "001";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '1';
        constante <= "0010001000100010";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "011";
        reg_r1 <= "011";
        reg_r2 <= "010";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '1';
        constante <= "0011001100110011";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "100";
        reg_r1 <= "100";
        reg_r2 <= "011";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '1';
        constante <= "0100010001000100";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "101";
        reg_r1 <= "101";
        reg_r2 <= "100";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '1';
        constante <= "0101010101010101";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "110";
        reg_r1 <= "110";
        reg_r2 <= "101";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '1';
        constante <= "0110011001100110";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "111";
        reg_r1 <= "111";
        reg_r2 <= "110";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '1';
        constante <= "0111011101110111";
        wait for 100 ns;
        wr_en <= '0';
        reg_wr <= "101";
        reg_r1 <= "101";
        reg_r2 <= "000";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '1';
        constante <= "1010101010101010";
        wait for 100 ns;
        wr_en <= '0';
        reg_wr <= "101";
        reg_r1 <= "001";
        reg_r2 <= "110";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '1';
        constante <= "1010101010101010";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "110";
        reg_r1 <= "110";
        reg_r2 <= "011";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '1';
        constante <= "1111111111111101";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "110";
        reg_r1 <= "110";
        reg_r2 <= "011";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '0';
        constante <= "0000000000000000";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "001";
        reg_r1 <= "001";
        reg_r2 <= "010";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '1';
        constante <= "0111111111111111";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "010";
        reg_r1 <= "001";
        reg_r2 <= "010";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '1';
        constante <= "0000000000000001";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "001";
        reg_r1 <= "001";
        reg_r2 <= "010";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '0';
        constante <= "0000000000000000";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "101";
        reg_r1 <= "101";
        reg_r2 <= "100";
        controle <= "10";
        sel_ula_b <= '0';
        sel_data_wr <= '0';
        constante <= "0000000000000000";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "111";
        reg_r1 <= "111";
        reg_r2 <= "000";
        controle <= "11";
        sel_ula_b <= '0';
        sel_data_wr <= '0';
        constante <= "0000000000000000";
        wait for 100 ns;
        wr_en <= '0';
        reg_wr <= "111";
        reg_r1 <= "101";
        reg_r2 <= "111";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '0';
        constante <= "0000000000000000";
        wait for 100 ns;
        wr_en <= '0';
        reg_wr <= "111";
        reg_r1 <= "101";
        reg_r2 <= "111";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '0';
        constante <= "0000000000000000";
        wait for 100 ns;
        wr_en <= '0';
        reg_wr <= "111";
        reg_r1 <= "001";
        reg_r2 <= "011";
        controle <= "00";
        sel_ula_b <= '0';
        sel_data_wr <= '0';
        constante <= "0000000000000000";
        wait for 100 ns;
        wait;
    end process;
end architecture;
