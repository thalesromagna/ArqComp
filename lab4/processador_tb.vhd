library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador_tb is
end;

architecture a_processador_tb of processador_tb is
   component processador is
      port( clk        : in std_logic;
            rst        : in std_logic;
            estado     : out std_logic;
            pc_wr_en   : out std_logic;
            pc_saida   : out unsigned(6 downto 0);
            instrucao  : out unsigned(16 downto 0)
      );
   end component;

   constant period_time : time      := 100 ns;
   signal   finished    : std_logic := '0';
   signal   clk, reset  : std_logic;
   signal   estado      : std_logic;
   signal   pc_wr_en    : std_logic;
   signal   pc_saida    : unsigned(6 downto 0);
   signal   instrucao   : unsigned(16 downto 0);
begin
   uut: processador port map(clk=>clk, rst=>reset, estado=>estado, pc_wr_en=>pc_wr_en,
                             pc_saida=>pc_saida, instrucao=>instrucao);

   reset_global: process
   begin
      reset <= '1';
      wait for period_time*2;
      reset <= '0';
      wait;
   end process;

   sim_time_proc: process
   begin
      wait for 4 us;
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
