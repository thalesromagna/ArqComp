library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador is
    port( clk       : in  std_logic;
          rst       : in  std_logic;
          estado    : out std_logic;
          pc        : out unsigned(6 downto 0);
          instrucao : out unsigned(16 downto 0);
          ula_out   : out unsigned(15 downto 0)
    );
end entity;

architecture a_processador of processador is

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

    component banco_ula is
        port( reg_wr, reg_r1, reg_r2       : in  unsigned(2 downto 0);
              clk, wr_en, rst              : in  std_logic;
              ula_out                      : out unsigned(15 downto 0);
              data_r1, data_r2             : out unsigned(15 downto 0);
              constante                    : in  unsigned(15 downto 0);
              controle                     : in  unsigned(1 downto 0);
              sel_ula_b                    : in  std_logic;
              sel_data_wr                  : in  unsigned(1 downto 0);
              zero, carry, overflow, sinal : out std_logic
        );
    end component;

    signal reg_wr_s, reg_r1_s, reg_r2_s : unsigned(2 downto 0);
    signal wr_en_banco_s, sel_ula_b_s   : std_logic;
    signal constante_s                  : unsigned(15 downto 0);
    signal controle_s, sel_data_wr_s    : unsigned(1 downto 0);

    signal data_r1_s, data_r2_s                 : unsigned(15 downto 0);
    signal zero_s, carry_s, overflow_s, sinal_s : std_logic;

begin

    uc1: uc port map( clk         => clk,
                      rst         => rst,
                      endereco    => pc,
                      instrucao   => instrucao,
                      estado      => estado,
                      reg_wr      => reg_wr_s,
                      reg_r1      => reg_r1_s,
                      reg_r2      => reg_r2_s,
                      wr_en_banco => wr_en_banco_s,
                      constante   => constante_s,
                      controle    => controle_s,
                      sel_ula_b   => sel_ula_b_s,
                      sel_data_wr => sel_data_wr_s );

    banco_ula1: banco_ula port map( reg_wr      => reg_wr_s,
                                    reg_r1      => reg_r1_s,
                                    reg_r2      => reg_r2_s,
                                    clk         => clk,
                                    wr_en       => wr_en_banco_s,
                                    rst         => rst,
                                    ula_out     => ula_out,
                                    data_r1     => data_r1_s,
                                    data_r2     => data_r2_s,
                                    constante   => constante_s,
                                    controle    => controle_s,
                                    sel_ula_b   => sel_ula_b_s,
                                    sel_data_wr => sel_data_wr_s,
                                    zero        => zero_s,
                                    carry       => carry_s,
                                    overflow    => overflow_s,
                                    sinal       => sinal_s );

end architecture;
