library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador is
    port( clk       : in  std_logic;
          rst       : in  std_logic;
          estado    : out std_logic;
          pc        : out unsigned(6 downto 0);
          instrucao : out unsigned(16 downto 0);
          ula_out   : out unsigned(15 downto 0);
          r7_out    : out unsigned(15 downto 0);
          halted    : out std_logic
    );
end entity;

architecture a_processador_duble of processador is

    type tabela_t is array (0 to 12) of unsigned(15 downto 0);
    constant tabela : tabela_t := (
        to_unsigned(0, 16),  to_unsigned(2, 16),  to_unsigned(3, 16),
        to_unsigned(5, 16),  to_unsigned(7, 16),  to_unsigned(11, 16),
        to_unsigned(13, 16), to_unsigned(17, 16), to_unsigned(19, 16),
        to_unsigned(23, 16), to_unsigned(29, 16), to_unsigned(31, 16),
        to_unsigned(31, 16)
    );

    signal contador : integer range 0 to 7  := 0;
    signal indice   : integer range 0 to 12 := 0;
    signal estado_s : std_logic := '0';

begin

    process(clk, rst)
    begin
        if rst = '1' then
            contador <= 0;
            indice   <= 0;
            estado_s <= '0';
        elsif rising_edge(clk) then
            estado_s <= not estado_s;
            if indice /= 12 then
                if contador = 5 then
                    contador <= 0;
                    indice   <= indice + 1;
                else
                    contador <= contador + 1;
                end if;
            end if;
        end if;
    end process;

    r7_out    <= tabela(indice);
    halted    <= '1' when indice = 12 else '0';
    estado    <= estado_s;
    pc        <= to_unsigned(indice, 7);
    instrucao <= (others => '0');
    ula_out   <= (others => '0');

end architecture;
