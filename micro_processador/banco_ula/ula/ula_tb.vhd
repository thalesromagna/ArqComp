library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula_tb is
end entity;

architecture a_ula_tb of ula_tb is

    component ula is
        port( A, B                         : in  unsigned(15 downto 0);
              carry_in                     : in  std_logic;
              zero, carry, overflow, sinal : out std_logic;
              ULA_ctrl                     : in  unsigned(1 downto 0);
              ULA_Out                      : out unsigned(15 downto 0)
        );
    end component;

    signal A, B, ULA_Out                : unsigned(15 downto 0);
    signal carry_in                     : std_logic := '0';
    signal ULA_ctrl                     : unsigned(1 downto 0);
    signal zero, carry, overflow, sinal : std_logic;

begin

    uut: ula port map( A => A, B => B,
                       carry_in => carry_in,
                       zero => zero, carry => carry, overflow => overflow, sinal => sinal,
                       ULA_ctrl => ULA_ctrl,
                       ULA_Out => ULA_Out );

    process
    begin
        A <= "0000000000000001";
        B <= "0000000000000001";
        ULA_ctrl <= "00";
        wait for 50 ns;

        A <= "1111111111111110";
        B <= "1111111111111101";
        ULA_ctrl <= "00";
        wait for 50 ns;

        A <= "0000000000000001";
        B <= "0000000000000011";
        ULA_ctrl <= "01";
        wait for 50 ns;

        A <= "0000000000000011";
        B <= "0000000000000001";
        ULA_ctrl <= "01";
        wait for 50 ns;

        A <= "0000000000000001";
        B <= "1111111111111100";
        ULA_ctrl <= "01";
        wait for 50 ns;

        A <= "0000000000000000";
        B <= "1111111111111111";
        ULA_ctrl <= "10";
        wait for 50 ns;

        A <= "0000000000000101";
        B <= "0000000000000011";
        carry_in <= '0';
        ULA_ctrl <= "11";
        wait for 50 ns;

        carry_in <= '1';
        wait for 50 ns;

        A <= "0000000000000011";
        wait for 50 ns;

        A <= "1000000000000000";
        B <= "0000000000000000";
        wait for 50 ns;

        wait;
    end process;

end architecture;
