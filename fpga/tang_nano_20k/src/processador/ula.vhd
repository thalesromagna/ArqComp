library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ULA is
    port( A, B                         : in  unsigned(15 downto 0);
          carry_in                     : in  std_logic;
          zero, carry, overflow, sinal : out std_logic;
          ULA_ctrl                     : in  unsigned(1 downto 0);
          ULA_Out                      : out unsigned(15 downto 0)
    );
end entity;

architecture a_ULA of ULA is
   
    signal A_17, B_17, carry_in_17, subb_17 : unsigned(16 downto 0);
    signal subb_res                         : unsigned(15 downto 0);
	
begin
    A_17        <= '0' & A;
    B_17        <= '0' & B;
    carry_in_17 <= "0000000000000000" & carry_in;
    subb_17     <= A_17 - B_17 - carry_in_17;
    subb_res    <= subb_17(15 downto 0);

    ULA_Out <= A + B    when ULA_ctrl = "00" else
               A - B    when ULA_ctrl = "01" else
               A and B  when ULA_ctrl = "10" else
               subb_res when ULA_ctrl = "11" else
               "0000000000000000";

    carry <= '1'         when ULA_ctrl = "00" and (A + B) < A else
             '1'         when ULA_ctrl = "01" and A < B else
             subb_17(16) when ULA_ctrl = "11" else
             '0';

    overflow <= '1' when ULA_ctrl = "00" and A(15) = '0' and B(15) = '0' and (A + B) >= "1000000000000000" else
                '1' when ULA_ctrl = "00" and A(15) = '1' and B(15) = '1' and (A + B) <  "1000000000000000" else
                '1' when ULA_ctrl = "01" and A(15) = '0' and B(15) = '1' and (A - B) >= "1000000000000000" else
                '1' when ULA_ctrl = "01" and A(15) = '1' and B(15) = '0' and (A - B) <  "1000000000000000" else
                '1' when ULA_ctrl = "11" and A(15) = '0' and B(15) = '1' and subb_res(15) = '1' else
                '1' when ULA_ctrl = "11" and A(15) = '1' and B(15) = '0' and subb_res(15) = '0' else
                '0';

    sinal <= '1' when ULA_ctrl = "00" and (A + B)   >= "1000000000000000" else
             '1' when ULA_ctrl = "01" and (A - B)   >= "1000000000000000" else
             '1' when ULA_ctrl = "10" and (A and B) >= "1000000000000000" else
             '1' when ULA_ctrl = "11" and subb_res(15) = '1' else
             '0';

    zero <= '1' when ULA_ctrl = "00" and (A + B)   = "0000000000000000" else
            '1' when ULA_ctrl = "01" and (A - B)   = "0000000000000000" else
            '1' when ULA_ctrl = "10" and (A and B) = "0000000000000000" else
            '1' when ULA_ctrl = "11" and subb_res  = "0000000000000000" else
            '0';

end architecture;