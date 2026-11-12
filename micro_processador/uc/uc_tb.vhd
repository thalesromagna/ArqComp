library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uc_tb is
end entity;

architecture a_uc_tb of uc_tb is

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

    signal instrucao_s                                : unsigned(16 downto 0);
    signal estado_s                                   : std_logic;
    signal flag_zero_s, flag_sinal_s, flag_overflow_s : std_logic;
    signal pc_wr_en_s, jump_en_s                      : std_logic;
    signal jump_dest_s, delta_s                       : unsigned(6 downto 0);
    signal reg_wr_s, reg_r1_s, reg_r2_s               : unsigned(2 downto 0);
    signal wr_en_banco_s, sel_ula_b_s                 : std_logic;
    signal constante_s                                : unsigned(15 downto 0);
    signal ULA_ctrl_s, sel_data_wr_s                  : unsigned(1 downto 0);
    signal branch_en_s, wr_en_flags_s                 : std_logic;

begin

    uut: uc port map( instrucao     => instrucao_s,
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

    process
    begin
        flag_zero_s     <= '0';
        flag_sinal_s    <= '0';
        flag_overflow_s <= '0';

        -- NOP
        instrucao_s <= B"0000_000_000_0000000";
        estado_s    <= '0';
        wait for 50 ns;
        estado_s    <= '1';
        wait for 50 ns;

        -- LD R3,5
        instrucao_s <= B"0001_011_000_0000101";
        estado_s    <= '0';
        wait for 50 ns;
        estado_s    <= '1';
        wait for 50 ns;

        -- LD R1,-1
        instrucao_s <= B"0001_001_000_1111111";
        estado_s    <= '0';
        wait for 50 ns;
        estado_s    <= '1';
        wait for 50 ns;

        -- MOV R5,R3
        instrucao_s <= B"0010_101_011_0000000";
        estado_s    <= '0';
        wait for 50 ns;
        estado_s    <= '1';
        wait for 50 ns;

        -- ADD R5,R4
        instrucao_s <= B"0011_101_100_0000000";
        estado_s    <= '0';
        wait for 50 ns;
        estado_s    <= '1';
        wait for 50 ns;

        -- SUB R5,R1
        instrucao_s <= B"0100_101_001_0000000";
        estado_s    <= '0';
        wait for 50 ns;
        estado_s    <= '1';
        wait for 50 ns;

        -- SUBB R5,R1
        instrucao_s <= B"1001_101_001_0000000";
        estado_s    <= '0';
        wait for 50 ns;
        estado_s    <= '1';
        wait for 50 ns;

        -- CMPR R3,R4
        instrucao_s <= B"0111_011_100_0000000";
        estado_s    <= '0';
        wait for 50 ns;
        estado_s    <= '1';
        wait for 50 ns;

        -- CMPI R3,29
        instrucao_s <= B"1000_011_000_0011101";
        estado_s    <= '0';
        wait for 50 ns;
        estado_s    <= '1';
        wait for 50 ns;

        -- JMP 20
        instrucao_s <= B"1111_000_000_0010100";
        estado_s    <= '0';
        wait for 50 ns;
        estado_s    <= '1';
        wait for 50 ns;

        instrucao_s <= B"0101_000_000_1111100";
        estado_s    <= '1';
        flag_zero_s <= '0'; flag_sinal_s <= '0'; flag_overflow_s <= '0';
        wait for 50 ns;
        flag_zero_s <= '1'; flag_sinal_s <= '0'; flag_overflow_s <= '0';
        wait for 50 ns;
        flag_zero_s <= '0'; flag_sinal_s <= '1'; flag_overflow_s <= '0';
        wait for 50 ns;
        flag_zero_s <= '0'; flag_sinal_s <= '1'; flag_overflow_s <= '1';
        wait for 50 ns;
        flag_zero_s <= '0'; flag_sinal_s <= '0'; flag_overflow_s <= '1';
        wait for 50 ns;

        instrucao_s <= B"0110_000_000_0000010";
        flag_zero_s <= '0'; flag_sinal_s <= '0'; flag_overflow_s <= '0';
        wait for 50 ns;
        flag_overflow_s <= '1';
        wait for 50 ns;

        wait;
    end process;

end architecture;
