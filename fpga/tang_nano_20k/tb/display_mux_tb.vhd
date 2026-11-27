library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity display_mux_tb is
end entity;

architecture a_display_mux_tb of display_mux_tb is

    component display_mux is
        generic( DIV_MUX     : integer := 13499;
                 ANODO_COMUM : boolean := false
        );
        port( clk   : in  std_logic;
              rst   : in  std_logic;
              valor : in  unsigned(15 downto 0);
              seg   : out std_logic_vector(6 downto 0);
              dig   : out std_logic_vector(1 downto 0)
        );
    end component;

    constant periodo : time    := 37 ns;
    constant DIV_TB  : integer := 3;
    constant FASE    : integer := DIV_TB + 1;

    constant APAGADO : std_logic_vector(6 downto 0) := "1111111";
    constant TRACO   : std_logic_vector(6 downto 0) := "0111111";

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '1';
    signal fim   : std_logic := '0';
    signal valor : unsigned(15 downto 0) := (others => '0');
    signal seg_c : std_logic_vector(6 downto 0);
    signal dig_c : std_logic_vector(1 downto 0);
    signal seg_a : std_logic_vector(6 downto 0);
    signal dig_a : std_logic_vector(1 downto 0);

begin

    catodo: display_mux
        generic map( DIV_MUX => DIV_TB, ANODO_COMUM => false )
        port map( clk => clk, rst => rst, valor => valor, seg => seg_c, dig => dig_c );

    anodo: display_mux
        generic map( DIV_MUX => DIV_TB, ANODO_COMUM => true )
        port map( clk => clk, rst => rst, valor => valor, seg => seg_a, dig => dig_a );

    clk <= not clk after periodo / 2 when fim = '0' else '0';

    process

        procedure confere(v : integer; d, u : std_logic_vector(6 downto 0)) is
            variable viu_d_c, viu_u_c, viu_d_a, viu_u_a : boolean;
            variable seq_c, seq_a : integer;
            variable ant_c, ant_a : std_logic_vector(1 downto 0);
        begin
            valor <= to_unsigned(v, 16);
            for k in 1 to 3 loop
                wait until rising_edge(clk);
            end loop;
            viu_d_c := false; viu_u_c := false; viu_d_a := false; viu_u_a := false;
            seq_c := -1000; seq_a := -1000;
            ant_c := "00"; ant_a := "00";
            for k in 1 to 6 * FASE loop
                wait until falling_edge(clk);
                if dig_c = "01" then
                    viu_d_c := true;
                    assert seg_c = not d
                        report "catodo: dezena errada para " & integer'image(v) severity error;
                elsif dig_c = "10" then
                    viu_u_c := true;
                    assert seg_c = not u
                        report "catodo: unidade errada para " & integer'image(v) severity error;
                else
                    assert false
                        report "catodo: dig invalido para " & integer'image(v) severity error;
                end if;
                if dig_a = "10" then
                    viu_d_a := true;
                    assert seg_a = d
                        report "anodo: dezena errada para " & integer'image(v) severity error;
                elsif dig_a = "01" then
                    viu_u_a := true;
                    assert seg_a = u
                        report "anodo: unidade errada para " & integer'image(v) severity error;
                else
                    assert false
                        report "anodo: dig invalido para " & integer'image(v) severity error;
                end if;
                if k > 1 and dig_c /= ant_c then
                    assert seq_c < 0 or seq_c = FASE
                        report "catodo: fase com duracao " & integer'image(seq_c) severity error;
                    seq_c := 0;
                end if;
                if k > 1 and dig_a /= ant_a then
                    assert seq_a < 0 or seq_a = FASE
                        report "anodo: fase com duracao " & integer'image(seq_a) severity error;
                    seq_a := 0;
                end if;
                seq_c := seq_c + 1;
                seq_a := seq_a + 1;
                ant_c := dig_c;
                ant_a := dig_a;
            end loop;
            assert viu_d_c and viu_u_c
                report "catodo: as duas fases nao apareceram para " & integer'image(v) severity error;
            assert viu_d_a and viu_u_a
                report "anodo: as duas fases nao apareceram para " & integer'image(v) severity error;
            report "valor " & integer'image(v) & " conferido";
        end procedure;

    begin
        rst <= '1';
        for k in 1 to 3 * FASE loop
            wait until falling_edge(clk);
            assert dig_c = "10" and dig_a = "01"
                report "reset: deveria ficar parado no digito das unidades" severity error;
        end loop;
        rst <= '0';

        confere(0,    APAGADO,   "1000000");
        confere(2,    APAGADO,   "0100100");
        confere(10,   "1111001", "1000000");
        confere(31,   "0110000", "1111001");
        confere(99,   "0010000", "0010000");
        confere(100,  TRACO,     TRACO);
        confere(1000, TRACO,     TRACO);

        report "FIM display_mux_tb";
        fim <= '1';
        wait;
    end process;

end architecture;
