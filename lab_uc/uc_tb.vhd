library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uc_tb is
end entity;

architecture a_uc_tb of uc_tb is

    component uc is
        port( clk         : in  std_logic;
          rst         : in  std_logic;
          endereco    : out unsigned(6 downto 0);
          instrucao   : out unsigned(16 downto 0);
          estado      : out std_logic;
          reg_wr      : out unsigned(2 downto 0);
          reg_r1      : out unsigned(2 downto 0);
          reg_r2      : out unsigned(2 downto 0);
          wr_en_banco : out std_logic;
          constante   : out unsigned(15 downto 0);
          controle    : out unsigned(1 downto 0);
          sel_ula_b   : out std_logic;
          sel_data_wr : out unsigned(1 downto 0)
    );
    end component;

    constant period_time : time      := 100 ns;
    signal   finished    : std_logic := '0';
    signal   clk, reset  : std_logic;

    signal estado_s                     : std_logic;
    signal endereco_s                   : unsigned(6 downto 0);
    signal instrucao_s                  : unsigned(16 downto 0);
    signal reg_wr_s, reg_r1_s, reg_r2_s : unsigned(2 downto 0);
    signal wr_en_banco_s, sel_ula_b_s   : std_logic;
    signal constante_s                  : unsigned(15 downto 0);
    signal controle_s, sel_data_wr_s    : unsigned(1 downto 0);

begin

    uut: uc port map(clk=>clk, rst=>reset,                     
					 endereco=>endereco_s,
                     instrucao=>instrucao_s,
                     estado=>estado_s,
                     reg_wr=>reg_wr_s,
                     reg_r1=>reg_r1_s,
                     reg_r2=>reg_r2_s,
                     wr_en_banco=>wr_en_banco_s,
                     constante=>constante_s,
                     controle=>controle_s,
                     sel_ula_b=>sel_ula_b_s,
                     sel_data_wr=>sel_data_wr_s);

    reset_global: process
    begin
        reset <= '1';
        wait for period_time*2; 
        reset <= '0';
        wait;
    end process;
    
    sim_time_proc: process
    begin
        wait for 10 us;         
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

end architecture;
