library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_primos_4dig is
    generic( DIV_MAX     : integer := 6749;
             PAUSA_MAX   : integer := 40499999;
             DIV_MUX     : integer := 13499;
             ANODO_COMUM : boolean := false
    );
    port( clk    : in  std_logic;
          rst    : in  std_logic;
          seg    : out std_logic_vector(6 downto 0);
          dig    : out std_logic_vector(1 downto 0);
          halted : out std_logic
    );
end entity;

architecture a_top_primos_4dig of top_primos_4dig is

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

    component display_mux is
        generic( DIV_MUX     : integer := 13499;
                 ANODO_COMUM : boolean := false
        );
        port( clk   : in  std_logic;
              rst   : in  std_logic;
              valor : in  unsigned(15 downto 0);
              seg   : out std_logic_vector(6 downto 0);
              dig   : out std_logic_vector(1 downto 0)
        );
    end component;

    component BUFG is
        port( O : out std_logic;
              I : in  std_logic
        );
    end component;

    signal clk_proc   : std_logic;
    signal clk_proc_g : std_logic;
    signal r7         : unsigned(15 downto 0);
    signal r7_amostra : unsigned(15 downto 0);
    signal estado     : std_logic;
    signal pc         : unsigned(6 downto 0);
    signal instrucao  : unsigned(16 downto 0);
    signal ula_out    : unsigned(15 downto 0);

begin

    bufg_inst: BUFG
        port map( O => clk_proc_g,
                  I => clk_proc );

    relogio_inst: relogio
        generic map( DIV_MAX => DIV_MAX, PAUSA_MAX => PAUSA_MAX )
        port map( clk_in     => clk,
                  rst        => rst,
                  r7_in      => r7,
                  clk_proc   => clk_proc,
                  r7_amostra => r7_amostra );

    processador_inst: processador
        port map( clk       => clk_proc_g,
                  rst       => rst,
                  estado    => estado,
                  pc        => pc,
                  instrucao => instrucao,
                  ula_out   => ula_out,
                  r7_out    => r7,
                  halted    => halted );

    display_inst: display_mux
        generic map( DIV_MUX => DIV_MUX, ANODO_COMUM => ANODO_COMUM )
        port map( clk   => clk,
                  rst   => rst,
                  valor => r7_amostra,
                  seg   => seg,
                  dig   => dig );

end architecture;
