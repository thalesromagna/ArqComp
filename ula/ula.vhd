library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is
    port( A, B                         : in  unsigned(15 downto 0);
          zero, carry, overflow, sinal : out std_logic;
          controle                     : in  unsigned(1 downto 0);
          ULA_Out                      : out unsigned(15 downto 0)
    );
end entity;

architecture a_ULA of ULA is
begin
    ULA_Out <= A + B                when controle = "00" else
               A - B                when controle = "01" else
               A and B              when controle = "10" else
               '0' & A(15 downto 1) when controle = "11" else
               "0000000000000000";

    carry <= '1' when controle = "00" and (A + B) < A else
             '1' when controle = "01" and A < B else
             '0';

    overflow <= '1' when controle = "00" and A(15) = '0' and B(15) = '0' and (A + B) >= "1000000000000000" else
                '1' when controle = "00" and A(15) = '1' and B(15) = '1' and (A + B) <  "1000000000000000" else
                '1' when controle = "01" and A(15) = '0' and B(15) = '1' and (A - B) >= "1000000000000000" else
                '1' when controle = "01" and A(15) = '1' and B(15) = '0' and (A - B) <  "1000000000000000" else
                '0';

    sinal <= '1' when controle = "00" and (A + B)   >= "1000000000000000" else
             '1' when controle = "01" and (A - B)   >= "1000000000000000" else
             '1' when controle = "10" and (A and B) >= "1000000000000000" else
             '0';

    zero <= '1' when controle = "00" and (A + B)   = "0000000000000000" else
            '1' when controle = "01" and (A - B)   = "0000000000000000" else
            '1' when controle = "10" and (A and B) = "0000000000000000" else
            '1' when controle = "11" and ('0' & A(15 downto 1)) = "0000000000000000" else
            '0';

end architecture;