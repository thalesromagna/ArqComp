library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_primos is
    generic( DIV_MAX     : integer := 6749;
             PAUSA_MAX   : integer := 40499999;
             ANODO_COMUM : boolean := true
    );
    port( clk         : in  std_logic;
          rst         : in  std_logic;
          seg_dezena  : out std_logic_vector(6 downto 0);
          seg_unidade : out std_logic_vector(6 downto 0);
          halted      : out std_logic
    );
end entity;

architecture a_top_primos of top_primos is

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

    component relogio is
        generic( DIV_MAX   : integer := 6749;
                 PAUSA_MAX : integer := 40499999
        );
        port( clk_in     : in  std_logic;
              rst        : in  std_logic;
              r7_in      : in  unsigned(15 downto 0);
              clk_proc   : out std_logic;
              r7_amostra : out unsigned(15 downto 0)
        );
    end component;

    component display_7seg is
        generic( ANODO_COMUM : boolean := true );
        port( valor       : in  unsigned(15 downto 0);
              seg_dezena  : out std_logic_vector(6 downto 0);
              seg_unidade : out std_logic_vector(6 downto 0)
        );
    end component;

    signal clk_proc   : std_logic;
    signal r7         : unsigned(15 downto 0);
    signal r7_amostra : unsigned(15 downto 0);
    signal estado     : std_logic;
    signal pc         : unsigned(6 downto 0);
    signal instrucao  : unsigned(16 downto 0);
    signal ula_out    : unsigned(15 downto 0);

begin

    relogio_inst: relogio
        generic map( DIV_MAX => DIV_MAX, PAUSA_MAX => PAUSA_MAX )
        port map( clk_in     => clk,
                  rst        => rst,
                  r7_in      => r7,
                  clk_proc   => clk_proc,
                  r7_amostra => r7_amostra );

    processador_inst: processador
        port map( clk       => clk_proc,
                  rst       => rst,
                  estado    => estado,
                  pc        => pc,
                  instrucao => instrucao,
                  ula_out   => ula_out,
                  r7_out    => r7,
                  halted    => halted );

    display_inst: display_7seg
        generic map( ANODO_COMUM => ANODO_COMUM )
        port map( valor       => r7_amostra,
                  seg_dezena  => seg_dezena,
                  seg_unidade => seg_unidade );

end architecture;
