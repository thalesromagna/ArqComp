library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco_tb is
end entity;

architecture a_banco_tb of banco_tb is
    component banco is
        port( data_wr                : in unsigned(15 downto 0);
              reg_wr, reg_r1, reg_r2 : in unsigned(2 downto 0);
              clk, wr_en, rst        : in std_logic;
              data_r1, data_r2       : out unsigned(15 downto 0)
        );
    end component;

    constant period_time : time      := 100 ns;
    signal   finished    : std_logic := '0';
    signal   clk, rst, wr_en : std_logic;
    signal   reg_wr, reg_r1, reg_r2 : unsigned(2 downto 0);
    signal   data_wr, data_r1, data_r2 : unsigned(15 downto 0);
begin
    uut: banco port map( data_wr => data_wr,
                         reg_wr  => reg_wr,
                         reg_r1  => reg_r1,
                         reg_r2  => reg_r2,
                         clk     => clk,
                         wr_en   => wr_en,
                         rst     => rst,
                         data_r1 => data_r1,
                         data_r2 => data_r2
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
        wait for 2 us;
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
        reg_wr <= "011";
        data_wr <= "0111011101110111";
        reg_r1 <= "011";
        reg_r2 <= "011";
        wait for 200 ns;
        wr_en <= '1';
        reg_wr <= "000";
        data_wr <= "0000000100000001";
        reg_r1 <= "000";
        reg_r2 <= "111";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "001";
        data_wr <= "0001000100010001";
        reg_r1 <= "001";
        reg_r2 <= "000";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "010";
        data_wr <= "0010001000100010";
        reg_r1 <= "010";
        reg_r2 <= "001";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "011";
        data_wr <= "0011001100110011";
        reg_r1 <= "011";
        reg_r2 <= "010";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "100";
        data_wr <= "0100010001000100";
        reg_r1 <= "100";
        reg_r2 <= "011";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "101";
        data_wr <= "0101010101010101";
        reg_r1 <= "101";
        reg_r2 <= "100";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "110";
        data_wr <= "0110011001100110";
        reg_r1 <= "110";
        reg_r2 <= "101";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "111";
        data_wr <= "1111111111111111";
        reg_r1 <= "111";
        reg_r2 <= "110";
        wait for 100 ns;
        wr_en <= '0';
        reg_wr <= "101";
        data_wr <= "1010101010101010";
        reg_r1 <= "101";
        reg_r2 <= "000";
        wait for 100 ns;
        wr_en <= '0';
        reg_r1 <= "000";
        reg_r2 <= "111";
        wait for 100 ns;
        wr_en <= '0';
        reg_r1 <= "001";
        reg_r2 <= "110";
        wait for 100 ns;
        wr_en <= '0';
        reg_r1 <= "010";
        reg_r2 <= "101";
        wait for 100 ns;
        wr_en <= '0';
        reg_r1 <= "011";
        reg_r2 <= "100";
        wait for 100 ns;
        wr_en <= '0';
        reg_r1 <= "100";
        reg_r2 <= "100";
        wait for 100 ns;
        wr_en <= '1';
        reg_wr <= "010";
        data_wr <= "0000101010111100";
        reg_r1 <= "010";
        reg_r2 <= "010";
        wait for 100 ns;
        wr_en <= '0';
        wait for 100 ns;
        wait;
    end process;
end architecture;
