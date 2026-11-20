library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_7seg is
    generic( ANODO_DEZENA  : boolean := true;
             ANODO_UNIDADE : boolean := false
    );
    port( valor       : in  unsigned(15 downto 0);
          seg_dezena  : out std_logic_vector(6 downto 0);
          seg_unidade : out std_logic_vector(6 downto 0)
    );
end entity;

architecture a_display_7seg of display_7seg is

    signal fora    : std_logic;
    signal v       : unsigned(7 downto 0);
    signal dezena  : unsigned(3 downto 0);
    signal resto   : unsigned(7 downto 0);
    signal unidade : unsigned(3 downto 0);
    signal cod_dez : std_logic_vector(6 downto 0);
    signal cod_uni : std_logic_vector(6 downto 0);

begin

    fora <= '1' when valor > 99 else '0';
    v    <= valor(7 downto 0);

    dezena <= "1001" when v >= 90 else
              "1000" when v >= 80 else
              "0111" when v >= 70 else
              "0110" when v >= 60 else
              "0101" when v >= 50 else
              "0100" when v >= 40 else
              "0011" when v >= 30 else
              "0010" when v >= 20 else
              "0001" when v >= 10 else
              "0000";

    resto   <= v - (dezena * 10);
    unidade <= resto(3 downto 0);

    cod_dez <= "0111111" when fora = '1' else
               "1111111" when dezena = "0000" else
               "1111001" when dezena = "0001" else
               "0100100" when dezena = "0010" else
               "0110000" when dezena = "0011" else
               "0011001" when dezena = "0100" else
               "0010010" when dezena = "0101" else
               "0000010" when dezena = "0110" else
               "1111000" when dezena = "0111" else
               "0000000" when dezena = "1000" else
               "0010000" when dezena = "1001" else
               "1111111";

    cod_uni <= "0111111" when fora = '1' else
               "1000000" when unidade = "0000" else
               "1111001" when unidade = "0001" else
               "0100100" when unidade = "0010" else
               "0110000" when unidade = "0011" else
               "0011001" when unidade = "0100" else
               "0010010" when unidade = "0101" else
               "0000010" when unidade = "0110" else
               "1111000" when unidade = "0111" else
               "0000000" when unidade = "1000" else
               "0010000" when unidade = "1001" else
               "1111111";

    seg_dezena  <= cod_dez when ANODO_DEZENA else not cod_dez;
    seg_unidade <= cod_uni when ANODO_UNIDADE else not cod_uni;

end architecture;
