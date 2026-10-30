library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uc is
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
end entity;

architecture a_uc of uc is

    component proto_uc is
        port( clk       : in  std_logic;
              rst       : in  std_logic;
              wr_en     : in  std_logic;
              jump_en   : in  std_logic;
              jump_dest : in  unsigned(6 downto 0);
              data_out  : out unsigned(6 downto 0)
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

    signal pc_out_s  : unsigned(6 downto 0);
    signal instr_s   : unsigned(16 downto 0);
    signal estado_s  : std_logic;
    signal opcode_s  : unsigned(3 downto 0);
    signal jump_en_s : std_logic;

begin

    proto_uc1: proto_uc port map(clk=>clk, rst=>rst, wr_en=>estado_s, jump_en=>jump_en_s, jump_dest=>instr_s(6 downto 0), data_out=>pc_out_s);

    sm1: sm port map(clk=>clk, rst=>rst, estado=>estado_s);

    rom1: rom port map(clk=>clk, endereco=>pc_out_s, dado=>instr_s);

    opcode_s <= instr_s(16 downto 13);
	
	reg_wr <= instr_s(12 downto 10);
	
	reg_r1 <= instr_s(12 downto 10);
	
	reg_r2 <= instr_s(9 downto 7);
	
	constante <= instr_s(6) & instr_s(6) & instr_s(6) & instr_s(6) & instr_s(6) & instr_s(6) & instr_s(6) & instr_s(6) & instr_s(6) & instr_s(6 downto 0);

	controle <= "00" when opcode_s="0011" else  -- ADD
				"01" when opcode_s="0100" else  -- SUB
				"00";

	wr_en_banco <= '1' when estado_s='1' and opcode_s="0001" else  -- LD
				   '1' when estado_s='1' and opcode_s="0010" else  -- MOV
				   '1' when estado_s='1' and opcode_s="0011" else  -- ADD
				   '1' when estado_s='1' and opcode_s="0100" else  -- SUB
				   '0';
	
	sel_data_wr <= "01" when opcode_s="0001" else  -- LD
				   "10" when opcode_s="0010" else  -- MOV
                   "00";                           -- ADD/SUB

	sel_ula_b <= '0';

    jump_en_s <= '1' when opcode_s="1111" else
                 '0';

    endereco  <= pc_out_s;
    instrucao <= instr_s;
    estado    <= estado_s;

end architecture;
