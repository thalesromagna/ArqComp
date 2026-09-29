library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity banco_ula is
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
end entity;


architecture a_banco_ula of banco_ula is
	
	component banco
		port (data_wr 				: in unsigned (15 downto 0);
		  reg_wr, reg_r1, reg_r2 	: in unsigned (2 downto 0);
		  clk, wr_en, rst			: in std_logic;
		  data_r1, data_r2			: out unsigned (15 downto 0)
	);
	end component;
	
	component ula
		port( A, B                     : in  unsigned(15 downto 0);
          zero, carry, overflow, sinal : out std_logic;
          controle                     : in  unsigned(1 downto 0);
          ULA_Out                      : out unsigned(15 downto 0)
		);
	end component;


	signal data_wr 					: unsigned(15 downto 0);
	signal data_r1_int, data_r2_int : unsigned(15 downto 0);
	signal ula_b                    : unsigned(15 downto 0);
	signal ula_out_int              : unsigned(15 downto 0);
	
begin

	banco1: banco port map(data_wr => data_wr, reg_wr => reg_wr, reg_r1 => reg_r1, reg_r2 => reg_r2, clk => clk, wr_en => wr_en, rst => rst, data_r1 => data_r1_int, data_r2 => data_r2_int);

	ula_b <= data_r2_int when sel_ula_b='0' else
	         constante   when sel_ula_b='1' else
	         "0000000000000000";

	ula1: ula port map(A => data_r1_int, B => ula_b, zero => zero, carry => carry, overflow => overflow, sinal => sinal, controle => controle, ULA_Out => ula_out_int);

	data_wr <= ula_out_int when sel_data_wr='0' else
	           constante   when sel_data_wr='1' else
	           "0000000000000000";

	data_r1 <= data_r1_int;
	data_r2 <= data_r2_int;
	ula_out <= ula_out_int;

end architecture;