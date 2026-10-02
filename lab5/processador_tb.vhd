library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador_tb is
end entity;

architecture a_processador_tb of processador_tb is
   component processador is
      port( clk       : in std_logic;
            rst       : in std_logic;
            estado    : out unsigned(1 downto 0);
            valor_pc  : out unsigned(6 downto 0);
            instrucao : out unsigned(16 downto 0);
            saida_ula : out unsigned(15 downto 0);
            r0, r1, r2, r3, r4, r5, r6, r7 : out unsigned(15 downto 0)
      );
   end component;

   constant period_time : time := 100 ns;
   signal reset, clk : std_logic;
   signal estado : unsigned(1 downto 0);
   signal pc : unsigned(6 downto 0);
   signal instrucao : unsigned(16 downto 0);
   signal saida_ula : unsigned(15 downto 0);
   signal r0, r1, r2, r3, r4, r5, r6, r7 : unsigned(15 downto 0);
   signal finished : std_logic := '0';
begin
   uut: processador port map(clk=>clk, rst=>reset, estado=>estado, valor_pc=>pc,
                             instrucao=>instrucao, saida_ula=>saida_ula,
                             r0=>r0, r1=>r1, r2=>r2, r3=>r3, r4=>r4, r5=>r5, r6=>r6, r7=>r7);

   reset_global: process
   begin
      reset <= '1';
      wait for period_time*2;
      reset <= '0';
      wait;
   end process;

   sim_time_proc: process
   begin
      wait for 30 us;
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
