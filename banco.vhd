library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco is
	port (data_wr 					: in unsigned (15 downto 0);
		  reg_wr, reg_r1, reg_r2 	: in unsigned (2 downto 0);
		  clk, wr_en, rst			: in std_logic;
		  data_r1, data_r2			: out unsigned (15 downto 0)
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
   
   signal reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7 	: unsigned (15 downto 0);
   signal wr_en_reg0, wr_en_reg1, wr_en_reg2, wr_en_reg3, wr_en_reg4, wr_en_reg5, wr_en_reg6, wr_en_reg7 : std_logic;
begin
	reg16bits0: reg16bits port map (clk=>clk, rst=>rst, wr_en=>wr_en_reg0, data_in=>data_wr, data_out=>reg0);
	reg16bits1: reg16bits port map (clk=>clk, rst=>rst, wr_en=>wr_en_reg1, data_in=>data_wr, data_out=>reg1);
	reg16bits2: reg16bits port map (clk=>clk, rst=>rst, wr_en=>wr_en_reg2, data_in=>data_wr, data_out=>reg2);
	reg16bits3: reg16bits port map (clk=>clk, rst=>rst, wr_en=>wr_en_reg3, data_in=>data_wr, data_out=>reg3);
	reg16bits4: reg16bits port map (clk=>clk, rst=>rst, wr_en=>wr_en_reg4, data_in=>data_wr, data_out=>reg4);
	reg16bits5: reg16bits port map (clk=>clk, rst=>rst, wr_en=>wr_en_reg5, data_in=>data_wr, data_out=>reg5);
	reg16bits6: reg16bits port map (clk=>clk, rst=>rst, wr_en=>wr_en_reg6, data_in=>data_wr, data_out=>reg6);
	reg16bits7: reg16bits port map (clk=>clk, rst=>rst, wr_en=>wr_en_reg7, data_in=>data_wr, data_out=>reg7);

	wr_en_reg0 <= '1' when wr_en='1' and reg_wr="000" else 
				  '0';
				  
	wr_en_reg1 <= '1' when wr_en='1' and reg_wr="001" else 
				  '0';
				  
	wr_en_reg2 <= '1' when wr_en='1' and reg_wr="010" else 
				  '0';
				  
	wr_en_reg3 <= '1' when wr_en='1' and reg_wr="011" else 
				  '0';
				  
	wr_en_reg4 <= '1' when wr_en='1' and reg_wr="100" else 
				  '0';
				  
	wr_en_reg5 <= '1' when wr_en='1' and reg_wr="101" else 
				  '0';
			
	wr_en_reg6 <= '1' when wr_en='1' and reg_wr="110" else 
				  '0';
				  
	wr_en_reg7 <= '1' when wr_en='1' and reg_wr="111" else 
				  '0';
				  
	data_r1 <= reg0 when reg_r1 = "000" else
			   reg1 when reg_r1 = "001" else
			   reg2 when reg_r1 = "010" else
			   reg3 when reg_r1 = "011" else
			   reg4 when reg_r1 = "100" else
			   reg5 when reg_r1 = "101" else
			   reg6 when reg_r1 = "110" else
			   reg7 when reg_r1 = "111" else
			   "0000000000000000";
	
	data_r2 <= reg0 when reg_r2 = "000" else
			   reg1 when reg_r2 = "001" else
			   reg2 when reg_r2 = "010" else
			   reg3 when reg_r2 = "011" else
			   reg4 when reg_r2 = "100" else
			   reg5 when reg_r2 = "101" else
			   reg6 when reg_r2 = "110" else
			   reg7 when reg_r2 = "111" else
			   "0000000000000000";
	
end architecture;