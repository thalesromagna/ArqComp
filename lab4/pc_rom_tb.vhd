library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_rom_tb is
end;

architecture a_pc_rom_tb of pc_rom_tb is
   component pc_rom is
      port( clk       : in std_logic;
            rst       : in std_logic;
            pc_saida  : out unsigned(6 downto 0);
            rom_saida : out unsigned(16 downto 0)
      );
   end component;

   constant period_time : time      := 100 ns;
   signal   finished    : std_logic := '0';
   signal   clk, reset  : std_logic;
   signal   pc_saida    : unsigned(6 downto 0);
   signal   rom_saida   : unsigned(16 downto 0);
begin
   uut: pc_rom port map(clk=>clk, rst=>reset, pc_saida=>pc_saida, rom_saida=>rom_saida);

   reset_global: process
   begin
      reset <= '1';
      wait for 220 ns;
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
