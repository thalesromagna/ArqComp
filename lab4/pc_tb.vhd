library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_tb is
end;

architecture a_pc_tb of pc_tb is
   component pc is
      port( clk      : in std_logic;
            rst      : in std_logic;
            wr_en    : in std_logic;
            data_in  : in unsigned(6 downto 0);
            data_out : out unsigned(6 downto 0)
      );
   end component;

   constant period_time : time      := 100 ns;
   signal   finished    : std_logic := '0';
   signal   clk, reset  : std_logic;
   signal   wr_en       : std_logic;
   signal   data_in     : unsigned(6 downto 0);
   signal   data_out    : unsigned(6 downto 0);
begin
   uut: pc port map(clk=>clk, rst=>reset, wr_en=>wr_en, data_in=>data_in, data_out=>data_out);

   reset_global: process
   begin
      reset <= '1';
      wait for period_time*2;
      reset <= '0';
      wait for period_time*6;
      reset <= '1';
      wait for period_time;
      reset <= '0';
      wait;
   end process;

   sim_time_proc: process
   begin
      wait for 2 us;
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
      wr_en <= '1';
      data_in <= "0000101";
      wait for 200 ns;
      wr_en <= '1';
      data_in <= "0000001";
      wait for 100 ns;
      wr_en <= '1';
      data_in <= "0000010";
      wait for 100 ns;
      wr_en <= '0';
      data_in <= "1111111";
      wait for 200 ns;
      wr_en <= '1';
      data_in <= "1010101";
      wait for 100 ns;
      wr_en <= '1';
      data_in <= "0001100";
      wait for 200 ns;
      wr_en <= '1';
      data_in <= "0000011";
      wait;
   end process;
end architecture;
