library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco_tb is
end;

architecture a_banco_tb of banco_tb is
	component banco
		port (data_wr 					: in unsigned (15 downto 0);
		      reg_wr, reg_r1, reg_r2 	: in unsigned (2 downto 0);
			  clk, wr_en, rst			: in std_logic;
			  data_r1, data_r2			: out unsigned (15 downto 0)
		);
	end component;
	
	constant period_time : time      := 100 ns;
	signal   finished    : std_logic := '0';
	signal   clk, reset  : std_logic;
	signal   wr_en       : std_logic;
	signal   reg_wr      : unsigned(2 downto 0) := "000";
	signal   reg_r1      : unsigned(2 downto 0) := "000";
	signal   reg_r2      : unsigned(2 downto 0) := "000";
	signal   data_wr     : unsigned(15 downto 0);
	signal   data_r1     : unsigned(15 downto 0);
	signal   data_r2     : unsigned(15 downto 0);
begin
	uut: banco port map ( data_wr => data_wr,
	                      reg_wr  => reg_wr,
	                      reg_r1  => reg_r1,
	                      reg_r2  => reg_r2,
	                      clk     => clk,
	                      wr_en   => wr_en,
	                      rst     => reset,
	                      data_r1 => data_r1,
	                      data_r2 => data_r2
	                    );
    
    reset_global: process
    begin
        reset <= '1';
        wait for period_time*2; -- espera 2 clocks, pra garantir
        reset <= '0';
        wait;
    end process;
    
    sim_time_proc: process
    begin
        wait for 10 us;         -- <== TEMPO TOTAL DA SIMULAÇÃO!!!
        finished <= '1';
        wait;
    end process sim_time_proc;
    clk_proc: process
    begin                       -- gera clock até que sim_time_proc termine
        while finished /= '1' loop
            clk <= '0';
            wait for period_time/2;
            clk <= '1';
            wait for period_time/2;
        end loop;
        wait;
    end process clk_proc;
	
		process                          -- casos de teste
	begin
		wr_en   <= '0';
		reg_wr  <= "000";
		reg_r1  <= "000";
		reg_r2  <= "000";
		data_wr <= "0000000000000000";
		wait for 200 ns;

		wr_en   <= '1';
		reg_wr  <= "001";
		data_wr <= "0000000000001010";
		reg_r1  <= "001";
		wait for 100 ns;

		reg_wr  <= "010";
		data_wr <= "0000000000010100";
		reg_r2  <= "010";
		wait for 100 ns;
		
		
		reg_wr  <= "111";
		data_wr <= "1111111111111111";
		wait for 100 ns;
		
		wr_en <= '0';
		reg_wr <= "001";
		data_wr <= "1111111111111111";
		reg_r1 <= "001";
		wait 100 ns;
		
	 
      wait;
   end process;
		
end architecture a_banco_tb;
	
	