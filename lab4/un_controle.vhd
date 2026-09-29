library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity un_controle is
   port( instr    : in unsigned(15 downto 0);
         estado   : in std_logic;
         pc_atual : in unsigned(6 downto 0);
         pc_wr_en : out std_logic;
         pc_prox  : out unsigned(6 downto 0)
   );
end entity;

architecture a_un_controle of un_controle is
   signal opcode: unsigned(3 downto 0);
   signal jump_en: std_logic;
   signal pc_mais_um: unsigned(6 downto 0);
begin
   opcode <= instr(15 downto 12);

   jump_en <= '1' when opcode="1000" else
              '0';

   pc_mais_um <= pc_atual + 1;

   pc_prox <= instr(6 downto 0) when jump_en='1' else
              pc_mais_um        when jump_en='0' else
              "0000000";

   pc_wr_en <= '1' when estado='1' else
               '0';
end architecture;
