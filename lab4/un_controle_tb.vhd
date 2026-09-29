library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity un_controle_tb is
end;

architecture a_un_controle_tb of un_controle_tb is
   component un_controle is
      port( instr    : in unsigned(15 downto 0);
            estado   : in std_logic;
            pc_atual : in unsigned(6 downto 0);
            pc_wr_en : out std_logic;
            pc_prox  : out unsigned(6 downto 0)
      );
   end component;

   signal instr    : unsigned(15 downto 0);
   signal estado   : std_logic;
   signal pc_atual : unsigned(6 downto 0);
   signal pc_wr_en : std_logic;
   signal pc_prox  : unsigned(6 downto 0);
begin
   uut: un_controle port map(instr=>instr, estado=>estado, pc_atual=>pc_atual,
                             pc_wr_en=>pc_wr_en, pc_prox=>pc_prox);

   process
   begin
      instr <= "0000000000000000";
      estado <= '0';
      pc_atual <= "0000000";
      wait for 50 ns;
      estado <= '1';
      wait for 50 ns;
      instr <= "1000000000000101";
      pc_atual <= "0000001";
      wait for 50 ns;
      estado <= '0';
      wait for 50 ns;
      instr <= "1111000000000011";
      estado <= '1';
      pc_atual <= "0001010";
      wait for 50 ns;
      instr <= "0000000000000000";
      pc_atual <= "1111111";
      wait for 50 ns;
      instr <= "1000111111111111";
      pc_atual <= "0000011";
      wait for 50 ns;
      wait;
   end process;
end architecture;
