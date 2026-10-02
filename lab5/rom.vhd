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
      0  => B"00001_011_000000101",
      1  => B"00001_100_000001000",
      2  => B"00001_001_000000001",
      3  => B"00010_101_011_000000",
      4  => B"00011_101_100_000000",
      5  => B"00100_101_001_000000",
      6  => B"01000_00000_0010100",
      7  => B"00001_101_000000000",
      20 => B"00010_011_101_000000",
      21 => B"01000_00000_0000011",
      22 => B"00001_011_000000000",
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
