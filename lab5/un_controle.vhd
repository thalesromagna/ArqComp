library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity un_controle is
   port( instr          : in unsigned(16 downto 0);
         estado         : in unsigned(1 downto 0);
         pc_atual       : in unsigned(6 downto 0);
         pc_wr_en       : out std_logic;
         pc_prox        : out unsigned(6 downto 0);
         banco_wr_en    : out std_logic;
         ula_controle   : out unsigned(1 downto 0);
         sel_dado_banco : out unsigned(1 downto 0);
         cte_estendida  : out unsigned(15 downto 0);
         reg_r1         : out unsigned(2 downto 0);
         reg_r2         : out unsigned(2 downto 0);
         reg_wr         : out unsigned(2 downto 0)
   );
end entity;

architecture a_un_controle of un_controle is
   signal opcode : unsigned(4 downto 0);
   signal eh_ld, eh_mov, eh_add, eh_sub, eh_jmp : std_logic;
   signal pc_mais_um, endereco_jmp : unsigned(6 downto 0);
begin
   opcode <= instr(16 downto 12);

   eh_ld  <= '1' when opcode="00001" else '0';
   eh_mov <= '1' when opcode="00010" else '0';
   eh_add <= '1' when opcode="00011" else '0';
   eh_sub <= '1' when opcode="00100" else '0';
   eh_jmp <= '1' when opcode="01000" else '0';

   pc_wr_en <= '1' when estado="10" else '0';

   pc_mais_um   <= pc_atual + "0000001";
   endereco_jmp <= instr(6 downto 0);

   pc_prox <= endereco_jmp when eh_jmp='1' else
              pc_mais_um   when eh_jmp='0' else
              "0000000";

   banco_wr_en <= '1' when estado="10" and eh_ld='1' else
                  '1' when estado="10" and eh_mov='1' else
                  '1' when estado="10" and eh_add='1' else
                  '1' when estado="10" and eh_sub='1' else
                  '0';

   ula_controle <= "00" when eh_add='1' else
                   "01" when eh_sub='1' else
                   "00";

   sel_dado_banco <= "01" when eh_ld='1' else
                     "10" when eh_mov='1' else
                     "00";

   cte_estendida <= "0000000" & instr(8 downto 0) when instr(8)='0' else
                    "1111111" & instr(8 downto 0) when instr(8)='1' else
                    "0000000000000000";

   reg_r1 <= instr(11 downto 9);
   reg_r2 <= instr(8 downto 6);
   reg_wr <= instr(11 downto 9);
end architecture;
