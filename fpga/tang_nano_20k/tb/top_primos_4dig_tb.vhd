library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_primos_4dig_tb is
end entity;

architecture a_top_primos_4dig_tb of top_primos_4dig_tb is

    component top_primos_4dig is
        generic( DIV_MAX     : integer := 6749;
                 PAUSA_MAX   : integer := 40499999;
                 DIV_MUX     : integer := 13499;
                 ANODO_COMUM : boolean := false
        );
        port( clk    : in  std_logic;
              rst    : in  std_logic;
              seg    : out std_logic_vector(6 downto 0);
              dig    : out std_logic_vector(1 downto 0);
              halted : out std_logic
        );
    end component;

    constant periodo   : time    := 37 ns;
    constant DIV_TB    : integer := 1;
    constant PAUSA_TB  : integer := 300;
    constant MUX_TB    : integer := 3;
    constant ciclo_mux : time    := 2 * (MUX_TB + 1) * periodo;
    constant pausa_min : time    := PAUSA_TB * periodo - 2 * ciclo_mux;
    constant limite    : time    := 400000 * periodo;

    constant APAGADO     : std_logic_vector(6 downto 0) := "1111111";
    constant TRACO       : std_logic_vector(6 downto 0) := "0111111";
    constant SEM_LEITURA : integer := -100;

    type primos_t is array (1 to 11) of integer;
    constant primos : primos_t := (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31);

    signal clk     : std_logic := '0';
    signal rst     : std_logic := '1';
    signal fim     : std_logic := '0';
    signal seg     : std_logic_vector(6 downto 0);
    signal dig     : std_logic_vector(1 downto 0);
    signal halted  : std_logic;
    signal pub_d   : std_logic_vector(6 downto 0) := APAGADO;
    signal pub_u   : std_logic_vector(6 downto 0) := APAGADO;
    signal numero  : integer := SEM_LEITURA;

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

    uut: top_primos_4dig
        generic map( DIV_MAX => DIV_TB, PAUSA_MAX => PAUSA_TB, DIV_MUX => MUX_TB, ANODO_COMUM => false )
        port map( clk => clk, rst => rst, seg => seg, dig => dig, halted => halted );

    clk <= not clk after periodo / 2 when fim = '0' else '0';

    leitor: process(clk)
        variable d_cur, u_cur   : std_logic_vector(6 downto 0);
        variable d_ant, u_ant   : std_logic_vector(6 downto 0);
        variable tem_d, tem_u   : boolean := false;
        variable tem_ant        : boolean := false;
        variable dig_ant        : std_logic_vector(1 downto 0) := "11";
    begin
        if rising_edge(clk) then
            if rst = '1' then
                tem_d   := false;
                tem_u   := false;
                tem_ant := false;
                numero  <= SEM_LEITURA;
            elsif dig = "01" then
                if dig_ant = "10" and tem_d and tem_u then
                    if tem_ant and d_cur = d_ant and u_cur = u_ant then
                        pub_d  <= d_cur;
                        pub_u  <= u_cur;
                        numero <= valor(d_cur, u_cur);
                    end if;
                    d_ant   := d_cur;
                    u_ant   := u_cur;
                    tem_ant := true;
                    tem_u   := false;
                end if;
                d_cur := not seg;
                tem_d := true;
            elsif dig = "10" then
                if tem_d then
                    u_cur := not seg;
                    tem_u := true;
                end if;
            else
                assert false report "dig com mais de um digito habilitado ou nenhum" severity error;
            end if;
            dig_ant := dig;
        end if;
    end process;

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
                wait on numero for limite;
                assert now - t0 < limite
                    report "TIMEOUT esperando mudanca do display" severity failure;
                wait for 1 ns;
                exit when numero /= ultimo and numero /= SEM_LEITURA;
            end loop;
            atual := numero;
            t_mudanca := now;
        end procedure;

    begin
        rst <= '1';
        wait for 5 * periodo;
        wait for 1 ns;
        assert dig = "10" and seg = not std_logic_vector'("1000000")
            report "reset: display deveria mostrar ' 0' parado nas unidades" severity error;
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
                assert pub_d = APAGADO and pub_u = "0100100"
                    report "codigo de 2 errado" severity error;
            end if;
            if atual = 7 then
                assert pub_d = APAGADO and pub_u = "1111000"
                    report "codigo de 7 errado" severity error;
            end if;
            if atual = 13 then
                assert pub_d = "1111001" and pub_u = "0110000"
                    report "codigo de 13 errado" severity error;
            end if;
            if atual = 31 then
                assert pub_d = "0110000" and pub_u = "1111001"
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
            if numero /= 31 then
                mudancas := mudancas + 1;
            end if;
        end loop;
        assert mudancas = 0 report "display saiu de 31 apos halted" severity error;
        assert pub_d = "0110000" and pub_u = "1111001"
            report "apos halted o display deveria ficar em 31" severity error;
        assert halted = '1' report "halted caiu sem reset" severity error;

        rst <= '1';
        wait for 5 * periodo;
        wait for 1 ns;
        assert dig = "10" and seg = not std_logic_vector'("1000000")
            report "reset (S1) nao zerou o display" severity error;
        rst <= '0';
        ultimo := 0;
        espera_mudanca;
        assert atual = 2 report "apos reset o primeiro deveria ser 2" severity error;
        assert halted = '0' report "halted nao caiu apos o reset" severity error;
        report "reinicio por S1: display = " & integer'image(atual);

        report "FIM top_primos_4dig_tb";
        fim <= '1';
        wait;
    end process;

end architecture;
