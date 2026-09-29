library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador is
   port( clk        : in std_logic;
         rst        : in std_logic;
         estado     : out std_logic;
         pc_wr_en   : out std_logic;
         pc_saida   : out unsigned(6 downto 0);
         instrucao  : out unsigned(15 downto 0)
   );
end entity;

architecture a_processador of processador is
   component maq_estados is
      port( clk,rst: in std_logic;
            estado: out std_logic
      );
   end component;

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
            dado     : out unsigned(15 downto 0)
      );
   end component;

   component un_controle is
      port( instr    : in unsigned(15 downto 0);
            estado   : in std_logic;
            pc_atual : in unsigned(6 downto 0);
            pc_wr_en : out std_logic;
            pc_prox  : out unsigned(6 downto 0)
      );
   end component;

   signal estado_s, pc_wr_en_s: std_logic;
   signal pc_s, pc_prox_s: unsigned(6 downto 0);
   signal instrucao_s: unsigned(15 downto 0);
begin
   maq_inst: maq_estados port map(clk=>clk, rst=>rst, estado=>estado_s);
   pc_inst: pc port map(clk=>clk, rst=>rst, wr_en=>pc_wr_en_s, data_in=>pc_prox_s, data_out=>pc_s);
   rom_inst: rom port map(clk=>clk, endereco=>pc_s, dado=>instrucao_s);
   uc_inst: un_controle port map(instr=>instrucao_s, estado=>estado_s, pc_atual=>pc_s,
                                 pc_wr_en=>pc_wr_en_s, pc_prox=>pc_prox_s);

   estado <= estado_s;
   pc_wr_en <= pc_wr_en_s;
   pc_saida <= pc_s;
   instrucao <= instrucao_s;
end architecture;
