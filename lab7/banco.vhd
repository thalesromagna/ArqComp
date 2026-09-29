library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco is
   port( data_wr                : in unsigned(15 downto 0);
         reg_wr, reg_r1, reg_r2 : in unsigned(2 downto 0);
         clk, wr_en, rst        : in std_logic;
         data_r1, data_r2       : out unsigned(15 downto 0);
         saida_r0, saida_r1, saida_r2, saida_r3 : out unsigned(15 downto 0);
         saida_r4, saida_r5, saida_r6, saida_r7 : out unsigned(15 downto 0)
   );
end entity;

architecture a_banco of banco is
   component reg16bits is
      port( clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in unsigned(15 downto 0);
            data_out : out unsigned(15 downto 0)
      );
   end component;

   signal reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7 : unsigned(15 downto 0);
   signal wr_en0, wr_en1, wr_en2, wr_en3, wr_en4, wr_en5, wr_en6, wr_en7 : std_logic;
begin
   r0: reg16bits port map(clk=>clk, rst=>rst, wr_en=>wr_en0, data_in=>data_wr, data_out=>reg0);
   r1: reg16bits port map(clk=>clk, rst=>rst, wr_en=>wr_en1, data_in=>data_wr, data_out=>reg1);
   r2: reg16bits port map(clk=>clk, rst=>rst, wr_en=>wr_en2, data_in=>data_wr, data_out=>reg2);
   r3: reg16bits port map(clk=>clk, rst=>rst, wr_en=>wr_en3, data_in=>data_wr, data_out=>reg3);
   r4: reg16bits port map(clk=>clk, rst=>rst, wr_en=>wr_en4, data_in=>data_wr, data_out=>reg4);
   r5: reg16bits port map(clk=>clk, rst=>rst, wr_en=>wr_en5, data_in=>data_wr, data_out=>reg5);
   r6: reg16bits port map(clk=>clk, rst=>rst, wr_en=>wr_en6, data_in=>data_wr, data_out=>reg6);
   r7: reg16bits port map(clk=>clk, rst=>rst, wr_en=>wr_en7, data_in=>data_wr, data_out=>reg7);

   wr_en0 <= '1' when wr_en='1' and reg_wr="000" else '0';
   wr_en1 <= '1' when wr_en='1' and reg_wr="001" else '0';
   wr_en2 <= '1' when wr_en='1' and reg_wr="010" else '0';
   wr_en3 <= '1' when wr_en='1' and reg_wr="011" else '0';
   wr_en4 <= '1' when wr_en='1' and reg_wr="100" else '0';
   wr_en5 <= '1' when wr_en='1' and reg_wr="101" else '0';
   wr_en6 <= '1' when wr_en='1' and reg_wr="110" else '0';
   wr_en7 <= '1' when wr_en='1' and reg_wr="111" else '0';

   data_r1 <= reg0 when reg_r1="000" else
              reg1 when reg_r1="001" else
              reg2 when reg_r1="010" else
              reg3 when reg_r1="011" else
              reg4 when reg_r1="100" else
              reg5 when reg_r1="101" else
              reg6 when reg_r1="110" else
              reg7 when reg_r1="111" else
              "0000000000000000";

   data_r2 <= reg0 when reg_r2="000" else
              reg1 when reg_r2="001" else
              reg2 when reg_r2="010" else
              reg3 when reg_r2="011" else
              reg4 when reg_r2="100" else
              reg5 when reg_r2="101" else
              reg6 when reg_r2="110" else
              reg7 when reg_r2="111" else
              "0000000000000000";

   saida_r0 <= reg0;
   saida_r1 <= reg1;
   saida_r2 <= reg2;
   saida_r3 <= reg3;
   saida_r4 <= reg4;
   saida_r5 <= reg5;
   saida_r6 <= reg6;
   saida_r7 <= reg7;
end architecture;
