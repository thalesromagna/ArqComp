library ieee;
use ieee.std_logic_1164.all;

entity decoder2x4 is
    port( sel0, sel1     : in  std_logic;
          saida0, saida1 : out std_logic;
          saida2, saida3 : out std_logic
    );
end entity;

architecture a_decoder2x4 of decoder2x4 is
begin
    saida0 <= not sel1 and not sel0;
    saida1 <= not sel1 and sel0;
    saida2 <= sel1 and not sel0;
    saida3 <= sel1 and sel0;
end architecture;
