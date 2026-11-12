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
        port( instrucao     : in  unsigned(16 downto 0);
              estado        : in  std_logic;
              flag_zero     : in  std_logic;
              flag_sinal    : in  std_logic;
              flag_overflow : in  std_logic;
              pc_wr_en      : out std_logic;
              jump_en       : out std_logic;
              jump_dest     : out unsigned(6 downto 0);
              reg_wr        : out unsigned(2 downto 0);
              reg_r1        : out unsigned(2 downto 0);
              reg_r2        : out unsigned(2 downto 0);
              wr_en_banco   : out std_logic;
              constante     : out unsigned(15 downto 0);
              ULA_ctrl      : out unsigned(1 downto 0);
              sel_ula_b     : out std_logic;
              sel_data_wr   : out unsigned(1 downto 0);
              branch_en     : out std_logic;
              delta         : out unsigned(6 downto 0);
              wr_en_flags   : out std_logic
        );
    end component;

    component banco_ula is
        port( reg_wr, reg_r1, reg_r2       : in  unsigned(2 downto 0);
              clk, wr_en, rst              : in  std_logic;
              ula_out                      : out unsigned(15 downto 0);
              data_r1, data_r2             : out unsigned(15 downto 0);
              constante                    : in  unsigned(15 downto 0);
              ULA_ctrl                     : in  unsigned(1 downto 0);
              carry_in                     : in  std_logic;
              sel_ula_b                    : in  std_logic;
              sel_data_wr                  : in  unsigned(1 downto 0);
              zero, carry, overflow, sinal : out std_logic
        );
    end component;

    component proto_uc is
        port( clk       : in  std_logic;
              rst       : in  std_logic;
              wr_en     : in  std_logic;
              jump_en   : in  std_logic;
              jump_dest : in  unsigned(6 downto 0);
              data_out  : out unsigned(6 downto 0);
              branch_en : in  std_logic;
              delta     : in  unsigned(6 downto 0)
        );
    end component;

    component sm is
        port( clk    : in  std_logic;
              rst    : in  std_logic;
              estado : out std_logic
        );
    end component;

    component rom is
        port( clk      : in  std_logic;
              endereco : in  unsigned(6 downto 0);
              dado     : out unsigned(16 downto 0)
        );
    end component;

    component reg1bit is
        port( clk      : in  std_logic;
              rst      : in  std_logic;
              wr_en    : in  std_logic;
              data_in  : in  std_logic;
              data_out : out std_logic
        );
    end component;


    signal pc_s, jump_dest_s     : unsigned(6 downto 0);
    signal instr_s               : unsigned(16 downto 0);
    signal estado_s              : std_logic;
    signal pc_wr_en_s, jump_en_s : std_logic;

    signal branch_en_s : std_logic;
    signal delta_s     : unsigned(6 downto 0);

    signal reg_wr_s, reg_r1_s, reg_r2_s : unsigned(2 downto 0);
    signal wr_en_banco_s, sel_ula_b_s   : std_logic;
    signal constante_s                  : unsigned(15 downto 0);
    signal ULA_ctrl_s, sel_data_wr_s    : unsigned(1 downto 0);

    signal data_r1_s, data_r2_s                 : unsigned(15 downto 0);
    signal zero_s, carry_s, overflow_s, sinal_s : std_logic;

    signal wr_en_flags_s                                            : std_logic;
    signal flag_zero_s, flag_sinal_s, flag_overflow_s, flag_carry_s : std_logic;

begin

    Z: reg1bit port map( clk      => clk,
                         rst      => rst,
                         wr_en    => wr_en_flags_s,
                         data_in  => zero_s,
                         data_out => flag_zero_s );

    N: reg1bit port map( clk      => clk,
                         rst      => rst,
                         wr_en    => wr_en_flags_s,
                         data_in  => sinal_s,
                         data_out => flag_sinal_s );

    V: reg1bit port map( clk      => clk,
                         rst      => rst,
                         wr_en    => wr_en_flags_s,
                         data_in  => overflow_s,
                         data_out => flag_overflow_s );

    C: reg1bit port map( clk      => clk,
                         rst      => rst,
                         wr_en    => wr_en_flags_s,
                         data_in  => carry_s,
                         data_out => flag_carry_s );

    uc1: uc port map( instrucao     => instr_s,
                      estado        => estado_s,
                      flag_zero     => flag_zero_s,
                      flag_sinal    => flag_sinal_s,
                      flag_overflow => flag_overflow_s,
                      pc_wr_en      => pc_wr_en_s,
                      jump_en       => jump_en_s,
                      jump_dest     => jump_dest_s,
                      reg_wr        => reg_wr_s,
                      reg_r1        => reg_r1_s,
                      reg_r2        => reg_r2_s,
                      wr_en_banco   => wr_en_banco_s,
                      constante     => constante_s,
                      ULA_ctrl      => ULA_ctrl_s,
                      sel_ula_b     => sel_ula_b_s,
                      sel_data_wr   => sel_data_wr_s,
                      branch_en     => branch_en_s,
                      delta         => delta_s,
                      wr_en_flags   => wr_en_flags_s );

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
                                    ULA_ctrl    => ULA_ctrl_s,
                                    carry_in    => flag_carry_s,
                                    sel_ula_b   => sel_ula_b_s,
                                    sel_data_wr => sel_data_wr_s,
                                    zero        => zero_s,
                                    carry       => carry_s,
                                    overflow    => overflow_s,
                                    sinal       => sinal_s );

    proto_uc1: proto_uc port map( clk       => clk,
                                  rst       => rst,
                                  wr_en     => pc_wr_en_s,
                                  jump_en   => jump_en_s,
                                  jump_dest => jump_dest_s,
                                  data_out  => pc_s,
                                  branch_en => branch_en_s,
                                  delta     => delta_s );

    sm1: sm port map( clk    => clk,
                      rst    => rst,
                      estado => estado_s );

    rom1: rom port map( clk      => clk,
                        endereco => pc_s,
                        dado     => instr_s );

    pc        <= pc_s;
    instrucao <= instr_s;
    estado    <= estado_s;

end architecture;
