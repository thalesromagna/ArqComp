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
              wr_en_flags   : out std_logic;
              ram_wr_en     : out std_logic;
              halt          : out std_logic
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
    signal ram_wr_en_s, halt_s                        : std_logic;

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
                      wr_en_flags   => wr_en_flags_s,
                      ram_wr_en     => ram_wr_en_s,
                      halt          => halt_s );

    process
        procedure checa( nome  : in string;
                         pc, ram, hlt, banco, flags, ub, jmp, br : in std_logic;
                         sdw, ctrl : in unsigned(1 downto 0);
                         cte   : in unsigned(15 downto 0) ) is
        begin
            assert pc_wr_en_s    = pc    report nome & ": pc_wr_en errado"    severity error;
            assert ram_wr_en_s   = ram   report nome & ": ram_wr_en errado"   severity error;
            assert halt_s        = hlt   report nome & ": halt errado"        severity error;
            assert wr_en_banco_s = banco report nome & ": wr_en_banco errado" severity error;
            assert wr_en_flags_s = flags report nome & ": wr_en_flags errado" severity error;
            assert sel_ula_b_s   = ub    report nome & ": sel_ula_b errado"   severity error;
            assert jump_en_s     = jmp   report nome & ": jump_en errado"     severity error;
            assert branch_en_s   = br    report nome & ": branch_en errado"   severity error;
            assert sel_data_wr_s = sdw   report nome & ": sel_data_wr errado" severity error;
            assert ULA_ctrl_s    = ctrl  report nome & ": ULA_ctrl errado"    severity error;
            assert constante_s   = cte   report nome & ": constante errada"   severity error;
        end procedure;
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

        -- Lab 7: flags ligadas para garantir que nenhuma instrucao nova gera branch
        flag_zero_s <= '1'; flag_sinal_s <= '1'; flag_overflow_s <= '0';

        -- LW R2,(R5)
        instrucao_s <= B"1010_010_101_0000011";
        estado_s    <= '0';
        wait for 50 ns;
        checa("LW estado 0", '0', '0', '0', '0', '0', '0', '0', '0', "11", "00", x"0003");
        assert reg_wr_s = "010" and reg_r2_s = "101" report "LW: campos de registrador errados" severity error;
        estado_s    <= '1';
        wait for 50 ns;
        checa("LW estado 1", '1', '0', '0', '1', '0', '0', '0', '0', "11", "00", x"0003");

        -- SW R3,(R6)
        instrucao_s <= B"1011_011_110_0000000";
        estado_s    <= '0';
        wait for 50 ns;
        checa("SW estado 0", '0', '0', '0', '0', '0', '0', '0', '0', "00", "00", x"0000");
        assert reg_r1_s = "011" and reg_r2_s = "110" report "SW: campos de registrador errados" severity error;
        estado_s    <= '1';
        wait for 50 ns;
        checa("SW estado 1", '1', '1', '0', '0', '0', '0', '0', '0', "00", "00", x"0000");

        -- INC R4 (bits baixos com lixo: a constante tem que ser 1 mesmo assim)
        instrucao_s <= B"1100_100_000_1111111";
        estado_s    <= '0';
        wait for 50 ns;
        checa("INC estado 0", '0', '0', '0', '0', '0', '1', '0', '0', "00", "00", x"0001");
        assert reg_wr_s = "100" and reg_r1_s = "100" report "INC: campos de registrador errados" severity error;
        estado_s    <= '1';
        wait for 50 ns;
        checa("INC estado 1", '1', '0', '0', '1', '0', '1', '0', '0', "00", "00", x"0001");

        -- HALT
        instrucao_s <= B"1101_000_000_0000000";
        estado_s    <= '0';
        wait for 50 ns;
        checa("HALT estado 0", '0', '0', '1', '0', '0', '0', '0', '0', "00", "00", x"0000");
        estado_s    <= '1';
        wait for 50 ns;
        checa("HALT estado 1", '0', '0', '1', '0', '0', '0', '0', '0', "00", "00", x"0000");

        -- 1110 (nao usado: NOP)
        instrucao_s <= B"1110_000_000_0000000";
        estado_s    <= '0';
        wait for 50 ns;
        checa("1110 estado 0", '0', '0', '0', '0', '0', '0', '0', '0', "00", "00", x"0000");
        estado_s    <= '1';
        wait for 50 ns;
        checa("1110 estado 1", '1', '0', '0', '0', '0', '0', '0', '0', "00", "00", x"0000");

        -- ADD R5,R4 continua igual
        instrucao_s <= B"0011_101_100_0000000";
        estado_s    <= '0';
        wait for 50 ns;
        checa("ADD estado 0", '0', '0', '0', '0', '0', '0', '0', '0', "00", "00", x"0000");
        estado_s    <= '1';
        wait for 50 ns;
        checa("ADD estado 1", '1', '0', '0', '1', '1', '0', '0', '0', "00", "00", x"0000");

        report "uc_tb: fim dos testes" severity note;
        wait;
    end process;

end architecture;
