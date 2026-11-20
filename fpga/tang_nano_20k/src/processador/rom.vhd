library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- gerado por programas/montador.py a partir de programas/crivo.asm
entity rom is
   port( clk      : in std_logic;
         endereco : in unsigned(6 downto 0);
         dado     : out unsigned(16 downto 0) 
   );
end entity;
architecture a_rom of rom is
   type mem is array (0 to 127) of unsigned(16 downto 0);
   constant conteudo_rom : mem := (
        0 => B"0001_001_000_0000001", -- ld r1, 1
        1 => B"1011_001_001_0000000", -- sw r1, (r1)
        2 => B"1100_001_000_0000000", -- inc r1
        3 => B"1000_001_000_0100000", -- cmpi r1, 32
        4 => B"0101_000_000_1111101", -- ble -3
        5 => B"0001_001_000_0000010", -- ld r1, 2
        6 => B"0001_110_000_0000000", -- ld r6, 0
        7 => B"1010_101_001_0000000", -- lw r5, (r1)
        8 => B"1000_101_000_0000000", -- cmpi r5, 0
        9 => B"0101_000_000_0001000", -- ble 8
        10 => B"0010_100_001_0000000", -- mov r4, r1
        11 => B"0011_100_001_0000000", -- add r4, r1
        12 => B"1111_000_000_0001111", -- jmp 15
        13 => B"1011_110_100_0000000", -- sw r6, (r4)
        14 => B"0011_100_001_0000000", -- add r4, r1
        15 => B"1000_100_000_0100000", -- cmpi r4, 32
        16 => B"0101_000_000_1111101", -- ble -3
        17 => B"1100_001_000_0000000", -- inc r1
        18 => B"1000_001_000_0100000", -- cmpi r1, 32
        19 => B"0101_000_000_1110100", -- ble -12
        20 => B"0001_011_000_0000010", -- ld r3, 2
        21 => B"1010_101_011_0000000", -- lw r5, (r3)
        22 => B"1000_101_000_0000000", -- cmpi r5, 0
        23 => B"0101_000_000_0000010", -- ble 2
        24 => B"0010_111_101_0000000", -- mov r7, r5
        25 => B"1100_011_000_0000000", -- inc r3
        26 => B"1000_011_000_0100000", -- cmpi r3, 32
        27 => B"0101_000_000_1111010", -- ble -6
        28 => B"1101_000_000_0000000", -- halt
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
