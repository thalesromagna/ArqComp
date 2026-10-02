library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_rom is
   port( clk       : in std_logic;
         rst       : in std_logic;
         pc_saida  : out unsigned(6 downto 0);
         rom_saida : out unsigned(16 downto 0)
   );
end entity;

architecture a_pc_rom of pc_rom is
   component pc is
      port( clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in unsigned(6 downto 0);
            data_out : out unsigned(6 downto 0)
      );
   end component;

   component rom is
      port( clk      : in std_logic;
            endereco : in unsigned(6 downto 0);
            dado     : out unsigned(16 downto 0)
      );
   end component;

   signal pc_s, pc_mais_um: unsigned(6 downto 0);
begin
   pc_inst: pc port map(clk=>clk, rst=>rst, wr_en=>'1', data_in=>pc_mais_um, data_out=>pc_s);
   rom_inst: rom port map(clk=>clk, endereco=>pc_s, dado=>rom_saida);

   pc_mais_um <= pc_s + 1;

   pc_saida <= pc_s;
end architecture;
