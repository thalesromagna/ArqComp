library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg16bits_tb is
end entity;

architecture a_reg16bits_tb of reg16bits_tb is
    component reg16bits is
        port( clk      : in std_logic;
              rst      : in std_logic;
              wr_en    : in std_logic;
              data_in  : in unsigned(15 downto 0);
              data_out : out unsigned(15 downto 0)
        );
    end component;

    constant period_time : time      := 100 ns;
    signal   finished    : std_logic := '0';
    signal   clk, rst, wr_en : std_logic;
    signal   data_in, data_out : unsigned(15 downto 0);
begin
    uut: reg16bits port map( clk => clk, rst => rst, wr_en => wr_en, data_in => data_in, data_out => data_out );

    reset_global: process
    begin
        rst <= '1';
        wait for period_time*2;
        rst <= '0';
        wait;
    end process;

    sim_time_proc: process
    begin
        wait for 1 us;
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
        data_in <= "1111111111111111";
        wait for 200 ns;
        wr_en <= '1';
        data_in <= "0001001000110100";
        wait for 100 ns;
        wr_en <= '0';
        data_in <= "1111111111111111";
        wait for 100 ns;
        wr_en <= '1';
        data_in <= "1010101111001101";
        wait for 100 ns;
        wr_en <= '1';
        data_in <= "0000000011111111";
        wait for 100 ns;
        wr_en <= '0';
        data_in <= "0101010101010101";
        wait for 100 ns;
        wr_en <= '0';
        data_in <= "0000000000000000";
        wait for 100 ns;
        wait;
    end process;
end architecture;
