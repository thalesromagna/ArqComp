library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula_tb is
end;

architecture a_ula_tb of ula_tb is
    component ula
        port( A, B     : in  unsigned(15 downto 0);
              carry_in : in  std_logic;
              controle : in  unsigned(1 downto 0);
              ULA_Out  : out unsigned(15 downto 0);
              zero, carry, overflow, sinal : out std_logic
        );
    end component;
    signal A, B, ULA_Out                : unsigned(15 downto 0);
    signal carry_in                     : std_logic;
    signal controle                     : unsigned(1 downto 0);
    signal zero, carry, overflow, sinal : std_logic;
begin
    uut: ula port map( A        => A,
                       B        => B,
                       carry_in => carry_in,
                       controle => controle,
                       ULA_Out  => ULA_Out,
                       zero     => zero,
                       carry    => carry,
                       overflow => overflow,
                       sinal    => sinal );

    process
    begin
        A <= "0000000000000011";
        B <= "0000000000000101";
        carry_in <= '0';
        controle <= "00";
        wait for 50 ns;

        A <= "0111111111111111";
        B <= "0000000000000001";
        carry_in <= '0';
        controle <= "00";
        wait for 50 ns;

        A <= "1000000000000000";
        B <= "1111111111111111";
        carry_in <= '0';
        controle <= "00";
        wait for 50 ns;

        A <= "1111111111111111";
        B <= "0000000000000001";
        carry_in <= '0';
        controle <= "00";
        wait for 50 ns;

        A <= "0000000000010010";
        B <= "1111111111111101";
        carry_in <= '0';
        controle <= "00";
        wait for 50 ns;

        A <= "1111111111111011";
        B <= "1111111111111101";
        carry_in <= '0';
        controle <= "00";
        wait for 50 ns;

        A <= "0000000000000000";
        B <= "0000000000000000";
        carry_in <= '0';
        controle <= "00";
        wait for 50 ns;

        A <= "0000000000000011";
        B <= "0000000000000101";
        carry_in <= '1';
        controle <= "00";
        wait for 50 ns;

        A <= "0000000000000111";
        B <= "0000000000000101";
        carry_in <= '0';
        controle <= "01";
        wait for 50 ns;

        A <= "0000000000000101";
        B <= "0000000000000111";
        carry_in <= '0';
        controle <= "01";
        wait for 50 ns;

        A <= "0000000000110011";
        B <= "0000000000110011";
        carry_in <= '0';
        controle <= "01";
        wait for 50 ns;

        A <= "0111111111111111";
        B <= "1111111111111111";
        carry_in <= '0';
        controle <= "01";
        wait for 50 ns;

        A <= "1000000000000000";
        B <= "0000000000000001";
        carry_in <= '0';
        controle <= "01";
        wait for 50 ns;

        A <= "1111111111111011";
        B <= "1111111111111101";
        carry_in <= '0';
        controle <= "01";
        wait for 50 ns;

        A <= "0000000000000011";
        B <= "1111111111111110";
        carry_in <= '0';
        controle <= "01";
        wait for 50 ns;

        A <= "0000000000000111";
        B <= "0000000000000101";
        carry_in <= '1';
        controle <= "01";
        wait for 50 ns;

        A <= "0000000000000111";
        B <= "0000000000000101";
        carry_in <= '0';
        controle <= "10";
        wait for 50 ns;

        A <= "0000000000000111";
        B <= "0000000000000101";
        carry_in <= '1';
        controle <= "10";
        wait for 50 ns;

        A <= "0000000000000101";
        B <= "0000000000000101";
        carry_in <= '1';
        controle <= "10";
        wait for 50 ns;

        A <= "0000000000000110";
        B <= "0000000000000101";
        carry_in <= '1';
        controle <= "10";
        wait for 50 ns;

        A <= "0000000000000000";
        B <= "0000000000000000";
        carry_in <= '1';
        controle <= "10";
        wait for 50 ns;

        A <= "1000000000000000";
        B <= "0000000000000000";
        carry_in <= '1';
        controle <= "10";
        wait for 50 ns;

        A <= "0000000000000000";
        B <= "1000000000000000";
        carry_in <= '1';
        controle <= "10";
        wait for 50 ns;

        A <= "0000000000000000";
        B <= "1000000000000000";
        carry_in <= '0';
        controle <= "10";
        wait for 50 ns;

        A <= "0000000000000000";
        B <= "0000000000000001";
        carry_in <= '0';
        controle <= "01";
        wait for 50 ns;

        A <= "0000000000000001";
        B <= "0000000000000000";
        carry_in <= '1';
        controle <= "10";
        wait for 50 ns;

        A <= "1111000011110000";
        B <= "1111111100000000";
        carry_in <= '0';
        controle <= "11";
        wait for 50 ns;

        A <= "0000111100001111";
        B <= "1111000011110000";
        carry_in <= '0';
        controle <= "11";
        wait for 50 ns;

        A <= "1111111111111111";
        B <= "0001001000110100";
        carry_in <= '1';
        controle <= "11";
        wait for 50 ns;
        wait;
    end process;
end architecture;
