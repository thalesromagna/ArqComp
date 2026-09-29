library ieee;
use ieee.std_logic_1164.all;

entity paridade3_tb is
end;

architecture a_paridade3_tb of paridade3_tb is
    component paridade3
        port( entr0, entr1, entr2 : in  std_logic;
              impar               : out std_logic
        );
    end component;
    signal entr0, entr1, entr2, impar : std_logic;
begin
    uut: paridade3 port map( entr0 => entr0,
                             entr1 => entr1,
                             entr2 => entr2,
                             impar => impar );

    process
    begin
        entr2 <= '0'; entr1 <= '0'; entr0 <= '0';
        wait for 50 ns;
        entr2 <= '0'; entr1 <= '0'; entr0 <= '1';
        wait for 50 ns;
        entr2 <= '0'; entr1 <= '1'; entr0 <= '0';
        wait for 50 ns;
        entr2 <= '0'; entr1 <= '1'; entr0 <= '1';
        wait for 50 ns;
        entr2 <= '1'; entr1 <= '0'; entr0 <= '0';
        wait for 50 ns;
        entr2 <= '1'; entr1 <= '0'; entr0 <= '1';
        wait for 50 ns;
        entr2 <= '1'; entr1 <= '1'; entr0 <= '0';
        wait for 50 ns;
        entr2 <= '1'; entr1 <= '1'; entr0 <= '1';
        wait for 50 ns;
        wait;
    end process;
end architecture;
