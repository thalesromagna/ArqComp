library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_7seg_tb is
end entity;

architecture a_display_7seg_tb of display_7seg_tb is

    component display_7seg is
        generic( ANODO_DEZENA  : boolean := true;
                 ANODO_UNIDADE : boolean := false
        );
        port( valor       : in  unsigned(15 downto 0);
              seg_dezena  : out std_logic_vector(6 downto 0);
              seg_unidade : out std_logic_vector(6 downto 0)
        );
    end component;

    signal valor  : unsigned(15 downto 0) := (others => '0');
    signal dez_a  : std_logic_vector(6 downto 0);
    signal uni_a  : std_logic_vector(6 downto 0);
    signal dez_c  : std_logic_vector(6 downto 0);
    signal uni_c  : std_logic_vector(6 downto 0);
    signal dez_m  : std_logic_vector(6 downto 0);
    signal uni_m  : std_logic_vector(6 downto 0);

begin

    anodo: display_7seg
        generic map( ANODO_DEZENA => true, ANODO_UNIDADE => true )
        port map( valor => valor, seg_dezena => dez_a, seg_unidade => uni_a );

    catodo: display_7seg
        generic map( ANODO_DEZENA => false, ANODO_UNIDADE => false )
        port map( valor => valor, seg_dezena => dez_c, seg_unidade => uni_c );

    misto: display_7seg
        port map( valor => valor, seg_dezena => dez_m, seg_unidade => uni_m );

    process
        procedure confere(v : integer; d, u : std_logic_vector(6 downto 0)) is
        begin
            valor <= to_unsigned(v, 16);
            wait for 10 ns;
            assert dez_a = d and uni_a = u
                report "anodo comum errado para " & integer'image(v) severity error;
            assert dez_c = not d and uni_c = not u
                report "catodo comum errado para " & integer'image(v) severity error;
            assert dez_m = d and uni_m = not u
                report "padrao (dezena anodo, unidade catodo) errado para " & integer'image(v) severity error;
        end procedure;
    begin
        confere(0,     "1111111", "1000000");
        confere(2,     "1111111", "0100100");
        confere(9,     "1111111", "0010000");
        confere(10,    "1111001", "1000000");
        confere(31,    "0110000", "1111001");
        confere(47,    "0011001", "1111000");
        confere(58,    "0010010", "0000000");
        confere(60,    "0000010", "1000000");
        confere(99,    "0010000", "0010000");
        confere(100,   "0111111", "0111111");
        confere(1000,  "0111111", "0111111");
        confere(65535, "0111111", "0111111");
        report "FIM display_7seg_tb";
        wait;
    end process;

end architecture;
