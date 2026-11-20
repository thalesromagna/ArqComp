library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador_tb is
end entity;

architecture a_processador_tb of processador_tb is

    component processador is
        port( clk       : in  std_logic;
              rst       : in  std_logic;
              estado    : out std_logic;
              pc        : out unsigned(6 downto 0);
              instrucao : out unsigned(16 downto 0);
              ula_out   : out unsigned(15 downto 0);
              r7_out    : out unsigned(15 downto 0);
              halted    : out std_logic
        );
    end component;

    constant period_time : time      := 100 ns;
    signal   finished    : std_logic := '0';
    signal   clk, reset  : std_logic;

    signal estado    : std_logic;
    signal pc        : unsigned(6 downto 0);
    signal instrucao : unsigned(16 downto 0);
    signal ula_out   : unsigned(15 downto 0);
    signal r7_out    : unsigned(15 downto 0);
    signal halted    : std_logic;

begin

    uut: processador port map( clk       => clk,
                               rst       => reset,
                               estado    => estado,
                               pc        => pc,
                               instrucao => instrucao,
                               ula_out   => ula_out,
                               r7_out    => r7_out,
                               halted    => halted );

    reset_global: process
    begin
        reset <= '1';
        wait for period_time*2;
        reset <= '0';
        wait;
    end process;

    sim_time_proc: process
    begin
        wait until halted='1' and reset='0' for 2 ms;
        if halted='1' then
            report "HALTED";
            wait for period_time*10;
        else
            report "TIMEOUT" severity error;
        end if;
        finished <= '1';
        wait;
    end process sim_time_proc;

    r7_proc: process(r7_out)
    begin
        if reset='0' then
            report "R7 " & integer'image(to_integer(signed(r7_out)));
        end if;
    end process r7_proc;

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

end architecture;
