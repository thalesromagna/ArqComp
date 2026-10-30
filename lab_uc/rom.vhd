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
   
   
      0 => B"0001_011_000_0000101", -- ld r3, 5
      1 => B"0001_100_000_0001000", -- ld r4, 8
      2 => B"0010_101_011_0000000", -- mov r5, r3
      3 => B"0011_101_100_0000000", -- add r5, r4
      4 => B"0001_110_000_0000001", -- ld r6, 1
      5 => B"0100_101_110_0000000", -- sub r5, r6
      6 => B"1111_000_000_0010100", -- jmp 20
      7 => B"0001_101_000_0000000", -- ld r5, 0
      20 => B"0010_011_101_0000000", -- mov r3, r5
      21 => B"1111_000_000_0000010", -- jmp 2
	  22 => B"0001_011_000_0000000", -- ld r3, 0
     
      others => (others=>'0')
   );
begin
   process(clk)
   begin
      if(rising_edge(clk)) thenm
         dado <= conteudo_rom(to_integer(endereco));
      end if;
   end process;
end architecture;