library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula_tb is
end entity;

architecture a_ula_tb of ula_tb is

    component ula is
        port( A, B                         : in  unsigned(15 downto 0);
              zero, carry, overflow, sinal : out std_logic;
              controle                     : in  unsigned(1 downto 0);
              ULA_Out                      : out unsigned(15 downto 0)
        );
    end component;

    signal A, B, ULA_Out                : unsigned(15 downto 0);
    signal controle                     : unsigned(1 downto 0);
    signal zero, carry, overflow, sinal : std_logic;

begin

    uut: ula port map( A => A, B => B,
                       zero => zero, carry => carry, overflow => overflow, sinal => sinal,
                       controle => controle,
                       ULA_Out => ULA_Out );

    process
    begin
        A <= "0000000000000001";
        B <= "0000000000000001";
        controle <= "00";
        wait for 50 ns;

        A <= "1111111111111110";
        B <= "1111111111111101";
        controle <= "00";
        wait for 50 ns;

        A <= "0000000000000001";
        B <= "0000000000000011";
        controle <= "01";
        wait for 50 ns;

        A <= "0000000000000011";
        B <= "0000000000000001";
        controle <= "01";
        wait for 50 ns;

        A <= "0000000000000001";
        B <= "1111111111111100";
        controle <= "01";
        wait for 50 ns;

        A <= "0000000000000000";
        B <= "1111111111111111";
        controle <= "10";
        wait for 50 ns;

        A <= "0000000000000001";
        controle <= "11";
        wait for 50 ns;

        wait;
    end process;

end architecture;