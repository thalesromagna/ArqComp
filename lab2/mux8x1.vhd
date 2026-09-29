library ieee;
use ieee.std_logic_1164.all;

entity mux8x1 is
    port( sel0, sel1, sel2    : in  std_logic;
          entr2, entr4, entr6 : in  std_logic;
          saida               : out std_logic
    );
end entity;

architecture a_mux8x1 of mux8x1 is
begin
    saida <= '0'   when sel2='0' and sel1='0' and sel0='0' else
             '0'   when sel2='0' and sel1='0' and sel0='1' else
             entr2 when sel2='0' and sel1='1' and sel0='0' else
             '1'   when sel2='0' and sel1='1' and sel0='1' else
             entr4 when sel2='1' and sel1='0' and sel0='0' else
             '0'   when sel2='1' and sel1='0' and sel0='1' else
             entr6 when sel2='1' and sel1='1' and sel0='0' else
             '1'   when sel2='1' and sel1='1' and sel0='1' else
             '0';
end architecture;
