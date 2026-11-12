library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uc is
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
end entity;

architecture a_uc of uc is

    signal instr_s   : unsigned(16 downto 0);
    signal estado_s  : std_logic;
    signal opcode_s  : unsigned(3 downto 0);
    signal jump_en_s : std_logic;

begin

    opcode_s <= instr_s(16 downto 13);

    reg_wr <= instr_s(12 downto 10);

    reg_r1 <= instr_s(12 downto 10);

    reg_r2 <= instr_s(9 downto 7);

    constante <= instr_s(6) & instr_s(6) & instr_s(6) & instr_s(6) & instr_s(6) & instr_s(6) & instr_s(6) & instr_s(6) & instr_s(6) & instr_s(6 downto 0);

    ULA_ctrl <= "00" when opcode_s="0011" else -- ADD
                "01" when opcode_s="0100" else -- SUB
                "01" when opcode_s="0111" else -- CMPR
                "01" when opcode_s="1000" else -- CMPI
                "11" when opcode_s="1001" else -- SUBB
                "00";

    wr_en_banco <= '1' when estado_s='1' and opcode_s="0001" else -- LD
                   '1' when estado_s='1' and opcode_s="0010" else -- MOV
                   '1' when estado_s='1' and opcode_s="0011" else -- ADD
                   '1' when estado_s='1' and opcode_s="0100" else -- SUB
                   '1' when estado_s='1' and opcode_s="1001" else -- SUBB
                   '0';

    wr_en_flags <= '1' when estado_s='1' and opcode_s="0011" else -- ADD
                   '1' when estado_s='1' and opcode_s="0100" else -- SUB
                   '1' when estado_s='1' and opcode_s="0111" else -- CMPR
                   '1' when estado_s='1' and opcode_s="1000" else -- CMPI
                   '1' when estado_s='1' and opcode_s="1001" else -- SUBB
                   '0';

    sel_data_wr <= "01" when opcode_s="0001" else -- LD
                   "10" when opcode_s="0010" else -- MOV
                   "00"; -- ADD/SUB/SUBB

    sel_ula_b <= '1' when opcode_s="1000" else -- CMPI
                 '0';

    branch_en <= '1' when opcode_s="0101" and flag_zero='1' else
                 '1' when opcode_s="0101" and flag_sinal='1' and flag_overflow='0' else
                 '1' when opcode_s="0101" and flag_sinal='0' and flag_overflow='1' else
                 '1' when opcode_s="0110" and flag_overflow='0' else
                 '0';

    delta <= instr_s(6 downto 0);

    jump_en_s <= '1' when opcode_s="1111" else
                 '0';

    instr_s  <= instrucao;
    estado_s <= estado;

    pc_wr_en  <= estado_s;
    jump_en   <= jump_en_s;
    jump_dest <= instr_s(6 downto 0);

end architecture;