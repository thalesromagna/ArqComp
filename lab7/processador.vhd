library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador is
   port( clk       : in std_logic;
         rst       : in std_logic;
         estado    : out unsigned(1 downto 0);
         valor_pc  : out unsigned(6 downto 0);
         instrucao : out unsigned(15 downto 0);
         saida_ula : out unsigned(15 downto 0);
         r0, r1, r2, r3, r4, r5, r6, r7 : out unsigned(15 downto 0)
   );
end entity;

architecture a_processador of processador is
   component maq_estados is
      port( clk,rst: in std_logic;
            estado: out unsigned(1 downto 0)
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

   component reg16bits is
      port( clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in unsigned(15 downto 0);
            data_out : out unsigned(15 downto 0)
      );
   end component;

   component banco is
      port( data_wr                : in unsigned(15 downto 0);
            reg_wr, reg_r1, reg_r2 : in unsigned(2 downto 0);
            clk, wr_en, rst        : in std_logic;
            data_r1, data_r2       : out unsigned(15 downto 0);
            saida_r0, saida_r1, saida_r2, saida_r3 : out unsigned(15 downto 0);
            saida_r4, saida_r5, saida_r6, saida_r7 : out unsigned(15 downto 0)
      );
   end component;

   component ula is
      port( A, B     : in unsigned(15 downto 0);
            carry_in : in std_logic;
            controle : in unsigned(1 downto 0);
            ULA_Out  : out unsigned(15 downto 0);
            zero, carry, overflow, sinal : out std_logic
      );
   end component;

   component ram is
      port( clk      : in std_logic;
            endereco : in unsigned(6 downto 0);
            wr_en    : in std_logic;
            dado_in  : in unsigned(15 downto 0);
            dado_out : out unsigned(15 downto 0)
      );
   end component;

   component reg1bit is
      port( clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in std_logic;
            data_out : out std_logic
      );
   end component;

   component un_controle is
      port( instr          : in unsigned(15 downto 0);
            estado         : in unsigned(1 downto 0);
            pc_atual       : in unsigned(6 downto 0);
            flag_z         : in std_logic;
            flag_n         : in std_logic;
            flag_v         : in std_logic;
            pc_wr_en       : out std_logic;
            pc_prox        : out unsigned(6 downto 0);
            ir_wr_en       : out std_logic;
            banco_wr_en    : out std_logic;
            flags_wr_en    : out std_logic;
            ram_wr_en      : out std_logic;
            ula_controle   : out unsigned(1 downto 0);
            sel_ula_b      : out std_logic;
            sel_dado_banco : out unsigned(1 downto 0);
            cte_estendida  : out unsigned(15 downto 0);
            reg_r1         : out unsigned(2 downto 0);
            reg_r2         : out unsigned(2 downto 0);
            reg_wr         : out unsigned(2 downto 0)
      );
   end component;

   signal estado_s : unsigned(1 downto 0);
   signal pc_s, pc_prox_s : unsigned(6 downto 0);
   signal pc_wr_en_s, ir_wr_en_s, banco_wr_en_s, flags_wr_en_s, ram_wr_en_s, sel_ula_b_s : std_logic;
   signal rom_dado_s, instrucao_s : unsigned(15 downto 0);
   signal ula_controle_s, sel_dado_banco_s : unsigned(1 downto 0);
   signal cte_estendida_s : unsigned(15 downto 0);
   signal reg_r1_s, reg_r2_s, reg_wr_s : unsigned(2 downto 0);
   signal dado_r1_s, dado_r2_s, dado_banco_s, ula_b_s, ula_out_s, ram_dado_s : unsigned(15 downto 0);
   signal endereco_ram_s : unsigned(6 downto 0);
   signal zero_s, carry_s, overflow_s, sinal_s : std_logic;
   signal flag_z_s, flag_n_s, flag_c_s, flag_v_s : std_logic;
begin
   maq: maq_estados port map(clk=>clk, rst=>rst, estado=>estado_s);

   contador: pc port map(clk=>clk, rst=>rst, wr_en=>pc_wr_en_s, data_in=>pc_prox_s, data_out=>pc_s);

   memoria_rom: rom port map(clk=>clk, endereco=>pc_s, dado=>rom_dado_s);

   reg_instr: reg16bits port map(clk=>clk, rst=>rst, wr_en=>ir_wr_en_s, data_in=>rom_dado_s, data_out=>instrucao_s);

   uc: un_controle port map(instr=>instrucao_s, estado=>estado_s, pc_atual=>pc_s,
                            flag_z=>flag_z_s, flag_n=>flag_n_s, flag_v=>flag_v_s,
                            pc_wr_en=>pc_wr_en_s, pc_prox=>pc_prox_s, ir_wr_en=>ir_wr_en_s,
                            banco_wr_en=>banco_wr_en_s, flags_wr_en=>flags_wr_en_s, ram_wr_en=>ram_wr_en_s,
                            ula_controle=>ula_controle_s, sel_ula_b=>sel_ula_b_s,
                            sel_dado_banco=>sel_dado_banco_s, cte_estendida=>cte_estendida_s,
                            reg_r1=>reg_r1_s, reg_r2=>reg_r2_s, reg_wr=>reg_wr_s);

   bancoreg: banco port map(data_wr=>dado_banco_s, reg_wr=>reg_wr_s, reg_r1=>reg_r1_s, reg_r2=>reg_r2_s,
                            clk=>clk, wr_en=>banco_wr_en_s, rst=>rst,
                            data_r1=>dado_r1_s, data_r2=>dado_r2_s,
                            saida_r0=>r0, saida_r1=>r1, saida_r2=>r2, saida_r3=>r3,
                            saida_r4=>r4, saida_r5=>r5, saida_r6=>r6, saida_r7=>r7);

   ula_b_s <= dado_r2_s       when sel_ula_b_s='0' else
              cte_estendida_s when sel_ula_b_s='1' else
              "0000000000000000";

   alu: ula port map(A=>dado_r1_s, B=>ula_b_s, carry_in=>flag_c_s, controle=>ula_controle_s,
                     ULA_Out=>ula_out_s, zero=>zero_s, carry=>carry_s, overflow=>overflow_s, sinal=>sinal_s);

   ff_z: reg1bit port map(clk=>clk, rst=>rst, wr_en=>flags_wr_en_s, data_in=>zero_s, data_out=>flag_z_s);
   ff_n: reg1bit port map(clk=>clk, rst=>rst, wr_en=>flags_wr_en_s, data_in=>sinal_s, data_out=>flag_n_s);
   ff_c: reg1bit port map(clk=>clk, rst=>rst, wr_en=>flags_wr_en_s, data_in=>carry_s, data_out=>flag_c_s);
   ff_v: reg1bit port map(clk=>clk, rst=>rst, wr_en=>flags_wr_en_s, data_in=>overflow_s, data_out=>flag_v_s);

   endereco_ram_s <= dado_r2_s(6 downto 0);

   memoria_ram: ram port map(clk=>clk, endereco=>endereco_ram_s, wr_en=>ram_wr_en_s,
                             dado_in=>dado_r1_s, dado_out=>ram_dado_s);

   dado_banco_s <= ula_out_s       when sel_dado_banco_s="00" else
                   cte_estendida_s when sel_dado_banco_s="01" else
                   dado_r2_s       when sel_dado_banco_s="10" else
                   ram_dado_s      when sel_dado_banco_s="11" else
                   "0000000000000000";

   estado    <= estado_s;
   valor_pc  <= pc_s;
   instrucao <= instrucao_s;
   saida_ula <= ula_out_s;
end architecture;
