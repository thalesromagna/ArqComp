library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity rom is
   port( clk      : in std_logic;
         endereco : in unsigned(6 downto 0);
         dado     : out unsigned(16 downto 0) 
   );
end entity;
architecture a_rom of rom is
   type mem is array (0 to 127) of unsigned(16 downto 0);
   constant conteudo_rom : mem := (
   
   
		0 => B"0001_011_000_0000000", -- ld r3, 0
        1 => B"0001_100_000_0000000", -- ld r4, 0
        2 => B"0011_100_011_0000000", -- add r4, r3
        3 => B"0001_110_000_0000001", -- ld r6, 1
        4 => B"0011_011_110_0000000", -- add r3, r6
        5 => B"1000_011_000_0011101", -- cmpi r3, 29
        6 => B"0101_000_000_1111100", -- ble -4
        7 => B"0010_101_100_0000000", -- mov r5, r4
     
      others => (others=>'0')
   );
begin
   process(clk)
   begin
      if(rising_edge(clk)) then
         dado <= conteudo_rom(to_integer(endereco));
      end if;
   end process;
end architecture;