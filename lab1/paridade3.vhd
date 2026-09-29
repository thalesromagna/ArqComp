library ieee;
use ieee.std_logic_1164.all;

entity paridade3 is
    port( entr0, entr1, entr2 : in  std_logic;
          impar               : out std_logic
    );
end entity;

architecture a_paridade3 of paridade3 is
begin
    impar <= (not entr2 and not entr1 and     entr0) or
             (not entr2 and     entr1 and not entr0) or
             (    entr2 and not entr1 and not entr0) or
             (    entr2 and     entr1 and     entr0);
end architecture;
