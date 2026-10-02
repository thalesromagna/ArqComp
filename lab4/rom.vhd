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
      0  => B"00000_000000000000",
      1  => B"01000_00000_0000101",
      2  => B"00000_000000000000",
      3  => B"00000_000000000000",
      4  => B"00000_000000000000",
      5  => B"00000_000000000000",
      6  => B"00000_000000000000",
      7  => B"01000_00000_0001010",
      8  => B"00000_000000000000",
      9  => B"00000_000000000000",
      10 => B"01111_00000_0000011",
      11 => B"01000_00000_0000101",
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
