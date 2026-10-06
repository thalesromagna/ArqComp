library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco_ula_tb is
end;

architecture a_banco_ula_tb of banco_ula_tb is
	component banco_ula is
		port ( reg_wr, reg_r1, reg_r2 	: in unsigned (2 downto 0);
			  clk, wr_en, rst			: in std_logic;
			  ula_out					: out unsigned(15 downto 0);
			  data_r1, data_r2			: out unsigned(15 downto 0);
			  constante 				: in unsigned(15 downto 0);
			  controle                  : in unsigned(1 downto 0);
			  sel_ula_b					: in std_logic;
			  sel_data_wr				: in std_logic;
			  zero, carry, overflow, sinal : out std_logic
		);
	end component;

	constant period_time : time      := 100 ns;
	signal   finished    : std_logic := '0';

	signal clk, rst, wr_en               : std_logic;
	signal sel_ula_b, sel_data_wr        : std_logic;
	signal zero, carry, overflow, sinal  : std_logic;
	signal reg_wr, reg_r1, reg_r2        : unsigned(2 downto 0) := "000";
	signal controle                      : unsigned(1 downto 0) := "00";
	signal constante                     : unsigned(15 downto 0);
	signal ula_out, data_r1, data_r2     : unsigned(15 downto 0);

begin

	uut: banco_ula port map ( reg_wr      => reg_wr,
	                          reg_r1      => reg_r1,
	                          reg_r2      => reg_r2,
	                          clk         => clk,
	                          wr_en       => wr_en,
	                          rst         => rst,
	                          ula_out     => ula_out,
	                          data_r1     => data_r1,
	                          data_r2     => data_r2,
	                          constante   => constante,
	                          controle    => controle,
	                          sel_ula_b   => sel_ula_b,
	                          sel_data_wr => sel_data_wr,
	                          zero        => zero,
	                          carry       => carry,
	                          overflow    => overflow,
	                          sinal       => sinal
	                        );

	reset_global: process
	begin
		rst <= '1';
		wait for period_time*2;      
		rst <= '0';
		wait;
	end process;

	sim_time_proc: process
	begin
		wait for 3 us;               
		finished <= '1';
		wait;
	end process sim_time_proc;

	clk_proc: process
	begin                            
		while finished /= '1' loop
			clk <= '0';
			wait for period_time/2;
			clk <= '1';
			wait for period_time/2;
		end loop;
		wait;
	end process clk_proc;

	process                          
	begin
		wr_en       <= '0';
		reg_wr      <= "000";
		reg_r1      <= "000";
		reg_r2      <= "000";
		controle    <= "00";
		sel_ula_b   <= '0';
		sel_data_wr <= '0';
		constante   <= "0000000000000000";
		wait for 200 ns;

		-- LD R1,10
		wr_en       <= '1';
		sel_data_wr <= '1';
		reg_wr      <= "001";
		constante   <= "0000000000001010";
		reg_r1      <= "001";
		wait for 100 ns;
 
		-- LD R2,3
		reg_wr      <= "010";
		constante   <= "0000000000000011";
		reg_r2      <= "010";
		wait for 100 ns;
 
		-- ADD R1,R2 
		sel_data_wr <= '0';
		sel_ula_b   <= '0';
		controle    <= "00";
		reg_wr      <= "001";
		reg_r1      <= "001";
		reg_r2      <= "010";
		wait for 100 ns;
 
		-- SUB R1,R2
		controle    <= "01";
		wait for 100 ns;
 
		-- CMPR R1,R2
		wr_en       <= '0';
		controle    <= "01";
		wait for 100 ns;
 
		-- CMPI R1,10
		sel_ula_b   <= '1';
		constante   <= "0000000000001010";
		wait for 100 ns;
 
		-- CMPI R1,20
		constante   <= "0000000000010100";
		wait for 100 ns;
 
		-- LD R3,1
		wr_en       <= '1';
		sel_ula_b   <= '0';
		sel_data_wr <= '1';
		reg_wr      <= "011";
		constante   <= "0000000000000001";
		reg_r1      <= "011";
		wait for 100 ns;
 
		-- LD R4,1
		reg_wr      <= "100";
		constante   <= "1111111111111111";
		reg_r2      <= "100";
		wait for 100 ns;
 
		-- ADD R3,R4
		sel_data_wr <= '0';
		controle    <= "00";
		reg_wr      <= "011";
		reg_r1      <= "011";
		reg_r2      <= "100";
		wait for 100 ns;
 
		-- LD R5,-3
		sel_data_wr <= '1';
		reg_wr      <= "101";
		constante   <= "1111111111111101";
		reg_r2      <= "101";
		wait for 100 ns;
 
		-- ADD R1,R5
		sel_data_wr <= '0';
		controle    <= "00";
		reg_wr      <= "001";
		reg_r1      <= "001";
		reg_r2      <= "101";
		wait for 100 ns;
 
		-- leitura R1 e R2
		wr_en       <= '0';
		reg_r1      <= "001";
		reg_r2      <= "010";
		wait for 100 ns;
 
		-- leitura R3 e R5
		reg_r1      <= "011";
		reg_r2      <= "101";
		wait for 100 ns;
 
		-- leitura depois do reset R1 e R2
		reg_r1      <= "001";
		reg_r2      <= "010";
		wait for 100 ns;
	
	
		wait;                        
	end process;

end architecture a_banco_ula_tb;