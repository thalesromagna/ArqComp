library ieee;
use ieee.std_logic_1164.all;

entity decoder2x4_tb is
end;

architecture a_decoder2x4_tb of decoder2x4_tb is
    component decoder2x4
        port( sel0, sel1     : in  std_logic;
              saida0, saida1 : out std_logic;
              saida2, saida3 : out std_logic
        );
    end component;
    signal sel0, sel1                     : std_logic;
    signal saida0, saida1, saida2, saida3 : std_logic;
begin
    uut: decoder2x4 port map( sel0   => sel0,
                              sel1   => sel1,
                              saida0 => saida0,
                              saida1 => saida1,
                              saida2 => saida2,
                              saida3 => saida3 );

    process
    begin
        sel1 <= '0';
        sel0 <= '0';
        wait for 50 ns;
        sel1 <= '0';
        sel0 <= '1';
        wait for 50 ns;
        sel1 <= '1';
        sel0 <= '0';
        wait for 50 ns;
        sel1 <= '1';
        sel0 <= '1';
        wait for 50 ns;
        wait;
    end process;
end architecture;
