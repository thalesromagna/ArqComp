library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity maq_estados_tb is
end;

architecture a_maq_estados_tb of maq_estados_tb is
   component maq_estados is
      port( clk,rst: in std_logic;
            estado: out std_logic
      );
   end component;

   constant period_time : time      := 100 ns;
   signal   finished    : std_logic := '0';
   signal   clk, reset  : std_logic;
   signal   estado      : std_logic;
begin
   uut: maq_estados port map(clk=>clk, rst=>reset, estado=>estado);

   reset_global: process
   begin
      reset <= '1';
      wait for period_time*2;
      reset <= '0';
      wait for period_time*5;
      reset <= '1';
      wait for period_time;
      reset <= '0';
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
end architecture;
