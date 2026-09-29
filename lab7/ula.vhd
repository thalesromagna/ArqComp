library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ula is
    port( A, B     : in  unsigned(15 downto 0);
          carry_in : in  std_logic;
          controle : in  unsigned(1 downto 0);
          ULA_Out  : out unsigned(15 downto 0);
          zero, carry, overflow, sinal : out std_logic
    );
end entity;

architecture a_ula of ula is
    signal A_17, B_17, carry_in_17          : unsigned(16 downto 0);
    signal soma_17, subt_17, subt_borrow_17 : unsigned(16 downto 0);
    signal resultado                        : unsigned(15 downto 0);
begin
    A_17        <= '0' & A;
    B_17        <= '0' & B;
    carry_in_17 <= "0000000000000000" & carry_in;

    soma_17        <= A_17 + B_17;
    subt_17        <= A_17 - B_17;
    subt_borrow_17 <= A_17 - B_17 - carry_in_17;

    resultado <= soma_17(15 downto 0)        when controle = "00" else
                 subt_17(15 downto 0)        when controle = "01" else
                 subt_borrow_17(15 downto 0) when controle = "10" else
                 A and B                     when controle = "11" else
                 "0000000000000000";

    ULA_Out <= resultado;

    zero <= '1' when resultado = "0000000000000000" else
            '0';

    sinal <= resultado(15);

    carry <= soma_17(16)        when controle = "00" else
             subt_17(16)        when controle = "01" else
             subt_borrow_17(16) when controle = "10" else
             '0';

    overflow <= '1' when controle = "00" and A(15) = B(15)  and resultado(15) /= A(15) else
                '1' when controle = "01" and A(15) /= B(15) and resultado(15) /= A(15) else
                '1' when controle = "10" and A(15) /= B(15) and resultado(15) /= A(15) else
                '0';
end architecture;
