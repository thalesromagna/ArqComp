library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco_ula_tb is
end entity;

architecture a_banco_ula_tb of banco_ula_tb is
    component banco_ula is
        port( clk, rst, wr_en          : in std_logic;
              reg_wr, reg_r1, reg_r2   : in unsigned(2 downto 0);
              controle                 : in unsigned(1 downto 0);
              sel_ula_b                : in std_logic;
              sel_dado                 : in unsigned(1 downto 0);
              constante                : in unsigned(15 downto 0);
              carry_in                 : in std_logic;
              ula_out                  : out unsigned(15 downto 0);
              zero, carry, overflow, sinal : out std_logic
        );
    end component;

    constant period_time : time      := 100 ns;
    signal   finished    : std_logic := '0';
    signal   clk, rst, wr_en, sel_ula_b, carry_in : std_logic;
    signal   zero, carry, overflow, sinal : std_logic;
    signal   reg_wr, reg_r1, reg_r2 : unsigned(2 downto 0);
    signal   controle, sel_dado : unsigned(1 downto 0);
    signal   constante, ula_out : unsigned(15 downto 0);
begin
    uut: banco_ula port map( clk       => clk,
                             rst       => rst,
                             wr_en     => wr_en,
                             reg_wr    => reg_wr,
                             reg_r1    => reg_r1,
                             reg_r2    => reg_r2,
                             controle  => controle,
                             sel_ula_b => sel_ula_b,
                             sel_dado  => sel_dado,
                             constante => constante,
                             carry_in  => carry_in,
                             ula_out   => ula_out,
                             zero      => zero,
                             carry     => carry,
                             overflow  => overflow,
                             sinal     => sinal
                           );

    reset_global: process
    begin
        rst <= '1';
        wait for period_time*2;
        rst <= '0';
        wait;
    end process;

    sim_time_proc: process
    begin
        wait for 2500 ns;
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
        wr_en <= '1';
        reg_wr <= "001";
        reg_r1 <= "001";
        reg_r2 <= "001";
        controle <= "00";
        sel_ula_b <= '0';
        sel_dado <= "01";
        constante <= "0000000000001001";
        carry_in <= '0';
        wait for 200 ns;
        wr_en <= '1';
        reg_wr <= "011";
        reg_r1 <= "011";
        reg_r2 <= "011";
        controle <= "00";
        sel_ula_b <= '0';
        sel_dado <= "01";
        constante <= "0000000000000101";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "100";
        reg_r1 <= "100";
        reg_r2 <= "100";
        controle <= "00";
        sel_ula_b <= '0';
        sel_dado <= "01";
        constante <= "0000000000001000";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "101";
        reg_r1 <= "101";
        reg_r2 <= "011";
        controle <= "00";
        sel_ula_b <= '0';
        sel_dado <= "10";
        constante <= "0000000000000000";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "101";
        reg_r1 <= "101";
        reg_r2 <= "100";
        controle <= "00";
        sel_ula_b <= '0';
        sel_dado <= "00";
        constante <= "0000000000000000";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "101";
        reg_r1 <= "101";
        reg_r2 <= "011";
        controle <= "01";
        sel_ula_b <= '0';
        sel_dado <= "00";
        constante <= "0000000000000000";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '0';
        reg_wr <= "101";
        reg_r1 <= "101";
        reg_r2 <= "000";
        controle <= "01";
        sel_ula_b <= '1';
        sel_dado <= "00";
        constante <= "0000000000001000";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '0';
        reg_wr <= "101";
        reg_r1 <= "101";
        reg_r2 <= "000";
        controle <= "01";
        sel_ula_b <= '1';
        sel_dado <= "00";
        constante <= "0000000000010100";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '0';
        reg_wr <= "101";
        reg_r1 <= "101";
        reg_r2 <= "100";
        controle <= "01";
        sel_ula_b <= '0';
        sel_dado <= "00";
        constante <= "0000000000000000";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "101";
        reg_r1 <= "101";
        reg_r2 <= "011";
        controle <= "10";
        sel_ula_b <= '0';
        sel_dado <= "00";
        constante <= "0000000000000000";
        carry_in <= '1';
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "110";
        reg_r1 <= "110";
        reg_r2 <= "110";
        controle <= "00";
        sel_ula_b <= '0';
        sel_dado <= "01";
        constante <= "0111111111111111";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "111";
        reg_r1 <= "111";
        reg_r2 <= "111";
        controle <= "00";
        sel_ula_b <= '0';
        sel_dado <= "01";
        constante <= "0000000000000001";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "110";
        reg_r1 <= "110";
        reg_r2 <= "111";
        controle <= "00";
        sel_ula_b <= '0';
        sel_dado <= "00";
        constante <= "0000000000000000";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "001";
        reg_r1 <= "001";
        reg_r2 <= "001";
        controle <= "00";
        sel_ula_b <= '0';
        sel_dado <= "01";
        constante <= "1111111111111101";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '0';
        reg_wr <= "101";
        reg_r1 <= "101";
        reg_r2 <= "001";
        controle <= "00";
        sel_ula_b <= '0';
        sel_dado <= "01";
        constante <= "0001001000110100";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "000";
        reg_r1 <= "000";
        reg_r2 <= "000";
        controle <= "00";
        sel_ula_b <= '0';
        sel_dado <= "01";
        constante <= "0000000000000010";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "010";
        reg_r1 <= "010";
        reg_r2 <= "010";
        controle <= "00";
        sel_ula_b <= '0';
        sel_dado <= "01";
        constante <= "0000000000000110";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "000";
        reg_r1 <= "000";
        reg_r2 <= "001";
        controle <= "00";
        sel_ula_b <= '0';
        sel_dado <= "10";
        constante <= "0000000000000000";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '0';
        reg_wr <= "000";
        reg_r1 <= "000";
        reg_r2 <= "010";
        controle <= "11";
        sel_ula_b <= '0';
        sel_dado <= "00";
        constante <= "0000000000000000";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '0';
        reg_wr <= "000";
        reg_r1 <= "011";
        reg_r2 <= "100";
        controle <= "00";
        sel_ula_b <= '0';
        sel_dado <= "00";
        constante <= "0000000000000000";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '0';
        reg_wr <= "000";
        reg_r1 <= "101";
        reg_r2 <= "110";
        controle <= "00";
        sel_ula_b <= '0';
        sel_dado <= "00";
        constante <= "0000000000000000";
        carry_in <= '0';
        wait for 100 ns;
        wr_en <= '0';
        reg_wr <= "000";
        reg_r1 <= "111";
        reg_r2 <= "001";
        controle <= "00";
        sel_ula_b <= '0';
        sel_dado <= "00";
        constante <= "0000000000000000";
        carry_in <= '0';
        wait for 100 ns;
        wait;
    end process;
end architecture;
