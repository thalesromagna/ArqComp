library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_mux is
    generic( DIV_MUX     : integer := 13499;
             ANODO_COMUM : boolean := false
    );
    port( clk   : in  std_logic;
          rst   : in  std_logic;
          valor : in  unsigned(15 downto 0);
          seg   : out std_logic_vector(6 downto 0);
          dig   : out std_logic_vector(1 downto 0)
    );
end entity;

architecture a_display_mux of display_mux is

    component display_7seg is
        generic( ANODO_DEZENA  : boolean := true;
                 ANODO_UNIDADE : boolean := false
        );
        port( valor       : in  unsigned(15 downto 0);
              seg_dezena  : out std_logic_vector(6 downto 0);
              seg_unidade : out std_logic_vector(6 downto 0)
        );
    end component;

    signal cod_dez  : std_logic_vector(6 downto 0);
    signal cod_uni  : std_logic_vector(6 downto 0);
    signal contador : integer range 0 to DIV_MUX := 0;
    signal fase     : std_logic := '0';
    signal seg_r    : std_logic_vector(6 downto 0) := (others => '0');
    signal dig_r    : std_logic_vector(1 downto 0) := (others => '0');

begin

    conversor: display_7seg
        generic map( ANODO_DEZENA => true, ANODO_UNIDADE => true )
        port map( valor       => valor,
                  seg_dezena  => cod_dez,
                  seg_unidade => cod_uni );

    process(clk)
        variable cod : std_logic_vector(6 downto 0);
        variable sel : std_logic_vector(1 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                contador <= 0;
                fase     <= '0';
            elsif contador = DIV_MUX then
                contador <= 0;
                fase     <= not fase;
            else
                contador <= contador + 1;
            end if;

            if fase = '1' then
                cod := cod_dez;
                sel := "10";
            else
                cod := cod_uni;
                sel := "01";
            end if;

            if ANODO_COMUM then
                seg_r <= cod;
                dig_r <= sel;
            else
                seg_r <= not cod;
                dig_r <= not sel;
            end if;
        end if;
    end process;

    seg <= seg_r;
    dig <= dig_r;

end architecture;
