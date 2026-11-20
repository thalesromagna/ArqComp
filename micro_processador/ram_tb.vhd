library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram_tb is
end;

architecture a_ram_tb of ram_tb is
	component ram
		port( clk      : in std_logic;
		      endereco : in unsigned(6 downto 0);
		      wr_en    : in std_logic;
		      dado_in  : in unsigned(15 downto 0);
		      dado_out : out unsigned(15 downto 0)
		);
	end component;

	constant period_time : time      := 100 ns;
	signal   finished    : std_logic := '0';
	signal   clk         : std_logic;
	signal   wr_en       : std_logic := '0';
	signal   endereco    : unsigned(6 downto 0)  := "0000000";
	signal   dado_in     : unsigned(15 downto 0) := "0000000000000000";
	signal   dado_out    : unsigned(15 downto 0);

	type tab_end  is array (0 to 12) of integer range 0 to 127;
	type tab_dado is array (0 to 12) of unsigned(15 downto 0);

	constant enderecos : tab_end  := (0, 127, 1, 2, 4, 8, 16, 32, 64, 126, 63, 95, 45);
	constant dados     : tab_dado := (x"1234", x"ABCD", x"8001", x"0F0F", x"F0F0", x"5A5A", x"A5A5",
	                                  x"00FF", x"FF00", x"7FFE", x"C3C3", x"3C3C", x"DEAD");
begin
	uut: ram port map ( clk      => clk,
	                    endereco => endereco,
	                    wr_en    => wr_en,
	                    dado_in  => dado_in,
	                    dado_out => dado_out
	                  );

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
		-- escritas em enderecos espalhados (0, 127 e pares que diferem em um bit)
		for i in 0 to 12 loop
			endereco <= to_unsigned(enderecos(i), 7);
			dado_in  <= dados(i);
			wr_en    <= '1';
			wait for 100 ns;
			assert dado_out = dados(i)
				report "escrita: endereco " & integer'image(enderecos(i)) & " nao gravou o dado" severity error;
		end loop;

		-- leitura assincrona: troca o endereco sem borda de clock no meio
		wr_en   <= '0';
		dado_in <= x"0000";
		wait for 10 ns;
		for i in 0 to 12 loop
			endereco <= to_unsigned(enderecos(i), 7);
			wait for 2 ns;
			assert clk'stable(2 ns)
				report "leitura: houve evento de clock durante a leitura" severity error;
			assert dado_out = dados(i)
				report "leitura: endereco " & integer'image(enderecos(i)) & " com dado errado" severity error;
		end loop;
		wait for 64 ns;

		-- wr_en='0' nao grava, mesmo com borda de subida
		endereco <= to_unsigned(0, 7);
		dado_in  <= x"FFFF";
		wr_en    <= '0';
		wait for 100 ns;
		assert dado_out = x"1234"
			report "wr_en=0: endereco 0 foi sobrescrito" severity error;

		endereco <= to_unsigned(127, 7);
		dado_in  <= x"0000";
		wait for 100 ns;
		assert dado_out = x"ABCD"
			report "wr_en=0: endereco 127 foi sobrescrito" severity error;

		-- escrita sincrona: antes da borda o dado antigo continua
		endereco <= to_unsigned(45, 7);
		dado_in  <= x"BEEF";
		wr_en    <= '1';
		wait for 10 ns;
		assert dado_out = x"DEAD"
			report "sincrona: gravou antes da borda de subida" severity error;
		wait for 90 ns;
		assert dado_out = x"BEEF"
			report "sobrescrita: endereco 45 nao recebeu o dado novo" severity error;

		-- sobrescrita do endereco 1 sem afetar 0 (difere no bit 0), 127 e 45
		endereco <= to_unsigned(1, 7);
		dado_in  <= x"4321";
		wr_en    <= '1';
		wait for 100 ns;
		assert dado_out = x"4321"
			report "sobrescrita: endereco 1 nao recebeu o dado novo" severity error;

		wr_en    <= '0';
		endereco <= to_unsigned(0, 7);
		wait for 10 ns;
		assert dado_out = x"1234"
			report "sobrescrita: endereco 0 mudou ao gravar no 1" severity error;
		endereco <= to_unsigned(127, 7);
		wait for 10 ns;
		assert dado_out = x"ABCD"
			report "sobrescrita: endereco 127 mudou" severity error;
		endereco <= to_unsigned(45, 7);
		wait for 10 ns;
		assert dado_out = x"BEEF"
			report "sobrescrita: endereco 45 mudou ao gravar no 1" severity error;

		report "ram_tb: fim dos testes" severity note;
		wait;
	end process;

end architecture a_ram_tb;
