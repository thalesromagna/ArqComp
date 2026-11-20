library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity relogio is
    generic( DIV_MAX   : integer := 6749;
             PAUSA_MAX : integer := 40499999
    );
    port( clk_in     : in  std_logic;
          rst        : in  std_logic;
          r7_in      : in  unsigned(15 downto 0);
          clk_proc   : out std_logic;
          r7_amostra : out unsigned(15 downto 0)
    );
end entity;

architecture a_relogio of relogio is

    signal rst_s1     : std_logic := '1';
    signal rst_s2     : std_logic := '1';
    signal contador   : integer range 0 to DIV_MAX := 0;
    signal pausa      : integer range 0 to PAUSA_MAX := 0;
    signal clk_estado : std_logic := '0';
    signal amostra    : unsigned(15 downto 0) := (others => '0');

begin

    process(clk_in)
    begin
        if rising_edge(clk_in) then
            rst_s1 <= rst;
            rst_s2 <= rst_s1;
            if rst_s2 = '1' then
                contador   <= 0;
                pausa      <= 0;
                clk_estado <= '0';
                amostra    <= (others => '0');
            elsif pausa /= 0 then
                pausa <= pausa - 1;
            elsif contador = DIV_MAX then
                contador <= 0;
                if r7_in /= amostra then
                    amostra <= r7_in;
                    pausa   <= PAUSA_MAX;
                else
                    clk_estado <= not clk_estado;
                end if;
            else
                contador <= contador + 1;
            end if;
        end if;
    end process;

    clk_proc   <= clk_estado;
    r7_amostra <= amostra;

end architecture;
