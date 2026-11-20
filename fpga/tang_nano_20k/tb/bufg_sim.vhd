library ieee;
use ieee.std_logic_1164.all;

entity BUFG is
    port( O : out std_logic;
          I : in  std_logic
    );
end entity;

architecture a_bufg of BUFG is
begin
    O <= I;
end architecture;
