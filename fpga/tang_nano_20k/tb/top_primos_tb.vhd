library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_primos_tb is
end entity;

architecture a_top_primos_tb of top_primos_tb is

    component top_primos is
        generic( DIV_MAX     : integer := 6749;
                 PAUSA_MAX   : integer := 40499999;
                 ANODO_COMUM : boolean := true
        );
        port( clk         : in  std_logic;
              rst         : in  std_logic;
              seg_dezena  : out std_logic_vector(6 downto 0);
              seg_unidade : out std_logic_vector(6 downto 0);
              halted      : out std_logic
        );
    end component;

    constant periodo   : time    := 37 ns;
    constant DIV_TB    : integer := 1;
    constant PAUSA_TB  : integer := 300;
    constant pausa_min : time    := PAUSA_TB * periodo;
    constant limite    : time    := 400000 * periodo;

    constant APAGADO : std_logic_vector(6 downto 0) := "1111111";
    constant TRACO   : std_logic_vector(6 downto 0) := "0111111";

    type primos_t is array (1 to 11) of integer;
    constant primos : primos_t := (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31);

    signal clk         : std_logic := '0';
    signal rst         : std_logic := '1';
    signal fim         : std_logic := '0';
    signal seg_dezena  : std_logic_vector(6 downto 0);
    signal seg_unidade : std_logic_vector(6 downto 0);
    signal halted      : std_logic;

    function digito(s : std_logic_vector(6 downto 0)) return integer is
    begin
        if    s = "1000000" then return 0;
        elsif s = "1111001" then return 1;
        elsif s = "0100100" then return 2;
        elsif s = "0110000" then return 3;
        elsif s = "0011001" then return 4;
        elsif s = "0010010" then return 5;
        elsif s = "0000010" then return 6;
        elsif s = "1111000" then return 7;
        elsif s = "0000000" then return 8;
        elsif s = "0010000" then return 9;
        elsif s = APAGADO   then return -1;
        elsif s = TRACO     then return -2;
        else                     return -3;
        end if;
    end function;

    function valor(d, u : std_logic_vector(6 downto 0)) return integer is
    begin
        if digito(u) < 0 then
            return -1;
        elsif digito(d) = -1 then
            return digito(u);
        elsif digito(d) >= 0 then
            return 10 * digito(d) + digito(u);
        else
            return -1;
        end if;
    end function;

begin

    uut: top_primos
        generic map( DIV_MAX => DIV_TB, PAUSA_MAX => PAUSA_TB, ANODO_COMUM => true )
        port map( clk => clk, rst => rst, seg_dezena => seg_dezena,
                  seg_unidade => seg_unidade, halted => halted );

    clk <= not clk after periodo / 2 when fim = '0' else '0';

    process
        variable atual     : integer;
        variable ultimo    : integer;
        variable t_mudanca : time;
        variable t_ant     : time;
        variable mudancas  : integer;

        procedure espera_mudanca is
            variable t0 : time;
        begin
            t0 := now;
            loop
                wait on seg_dezena, seg_unidade for limite;
                assert now - t0 < limite
                    report "TIMEOUT esperando mudanca do display" severity failure;
                wait for 1 ns;
                exit when valor(seg_dezena, seg_unidade) /= ultimo;
            end loop;
            atual := valor(seg_dezena, seg_unidade);
            t_mudanca := now;
        end procedure;

    begin
        rst <= '1';
        wait for 5 * periodo;
        wait for 1 ns;
        assert seg_dezena = APAGADO and seg_unidade = "1000000"
            report "reset: display deveria mostrar ' 0'" severity error;
        rst <= '0';
        ultimo := 0;
        t_ant := now;

        for i in 1 to 11 loop
            espera_mudanca;
            report "display = " & integer'image(atual);
            assert atual = primos(i)
                report "esperado " & integer'image(primos(i)) & ", veio " & integer'image(atual)
                severity error;
            if i > 1 then
                assert t_mudanca - t_ant >= pausa_min
                    report "sem pausa antes de " & integer'image(atual) severity error;
            end if;
            if atual = 2 then
                assert seg_dezena = APAGADO and seg_unidade = "0100100"
                    report "codigo de 2 errado" severity error;
            end if;
            if atual = 7 then
                assert seg_dezena = APAGADO and seg_unidade = "1111000"
                    report "codigo de 7 errado" severity error;
            end if;
            if atual = 13 then
                assert seg_dezena = "1111001" and seg_unidade = "0110000"
                    report "codigo de 13 errado" severity error;
            end if;
            if atual = 31 then
                assert seg_dezena = "0110000" and seg_unidade = "1111001"
                    report "codigo de 31 errado" severity error;
            end if;
            ultimo := atual;
            t_ant := t_mudanca;
        end loop;

        if halted /= '1' then
            wait until halted = '1' for limite;
        end if;
        assert halted = '1' report "halted nao subiu" severity error;
        report "HALTED";

        mudancas := 0;
        for k in 1 to 5 * PAUSA_TB loop
            wait until rising_edge(clk);
            if valor(seg_dezena, seg_unidade) /= 31 then
                mudancas := mudancas + 1;
            end if;
        end loop;
        assert mudancas = 0 report "display saiu de 31 apos halted" severity error;
        assert seg_dezena = "0110000" and seg_unidade = "1111001"
            report "apos halted o display deveria ficar em 31" severity error;
        assert halted = '1' report "halted caiu sem reset" severity error;

        rst <= '1';
        wait for 5 * periodo;
        wait for 1 ns;
        assert seg_dezena = APAGADO and seg_unidade = "1000000"
            report "reset (S1) nao zerou o display" severity error;
        rst <= '0';
        ultimo := 0;
        espera_mudanca;
        assert atual = 2 report "apos reset o primeiro deveria ser 2" severity error;
        assert halted = '0' report "halted nao caiu apos o reset" severity error;
        report "reinicio por S1: display = " & integer'image(atual);

        report "FIM top_primos_tb";
        fim <= '1';
        wait;
    end process;

end architecture;
