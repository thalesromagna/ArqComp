library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity banco_ula is
    port( clk, rst, wr_en          : in std_logic;
          reg_wr, reg_r1, reg_r2   : in unsigned(2 downto 0);
          controle                 : in unsigned(1 downto 0);
          sel_ula_b                : in std_logic;
          sel_dado                 : in unsigned(1 downto 0);
          constante                : in unsigned(15 downto 0);
          carry_in                 : in std_logic;
          ula_out                  : out unsigned(15 downto 0);
          zero, carry, overflow, sinal : out std_logic
    );
end entity;

architecture a_banco_ula of banco_ula is
    component banco is
        port( data_wr                : in unsigned(15 downto 0);
              reg_wr, reg_r1, reg_r2 : in unsigned(2 downto 0);
              clk, wr_en, rst        : in std_logic;
              data_r1, data_r2       : out unsigned(15 downto 0)
        );
    end component;

    component ula is
        port( A, B     : in  unsigned(15 downto 0);
              carry_in : in  std_logic;
              controle : in  unsigned(1 downto 0);
              ULA_Out  : out unsigned(15 downto 0);
              zero, carry, overflow, sinal : out std_logic
        );
    end component;

    signal dado_escrito, data_r1, data_r2, entrada_b, resultado_ula : unsigned(15 downto 0);
begin
    banco_regs: banco port map( data_wr => dado_escrito,
                                reg_wr  => reg_wr,
                                reg_r1  => reg_r1,
                                reg_r2  => reg_r2,
                                clk     => clk,
                                wr_en   => wr_en,
                                rst     => rst,
                                data_r1 => data_r1,
                                data_r2 => data_r2
                              );

    ula_principal: ula port map( A        => data_r1,
                                 B        => entrada_b,
                                 carry_in => carry_in,
                                 controle => controle,
                                 ULA_Out  => resultado_ula,
                                 zero     => zero,
                                 carry    => carry,
                                 overflow => overflow,
                                 sinal    => sinal
                               );

    entrada_b <= data_r2   when sel_ula_b = '0' else
                 constante when sel_ula_b = '1' else
                 "0000000000000000";

    dado_escrito <= resultado_ula when sel_dado = "00" else
                    constante     when sel_dado = "01" else
                    data_r2       when sel_dado = "10" else
                    "0000000000000000";

    ula_out <= resultado_ula;
end architecture;
