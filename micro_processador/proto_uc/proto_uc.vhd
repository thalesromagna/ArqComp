library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity proto_uc is
    port( clk       : in  std_logic;
          rst       : in  std_logic;
          wr_en     : in  std_logic;
          jump_en   : in  std_logic;
          jump_dest : in  unsigned(6 downto 0);
          data_out  : out unsigned(6 downto 0);
          branch_en : in  std_logic;
          delta     : in  unsigned(6 downto 0)
    );
end entity;

architecture a_proto_uc of proto_uc is

    component pc is
        port( clk      : in std_logic;
              rst      : in std_logic;
              wr_en    : in std_logic;
              data_in  : in unsigned(6 downto 0);
              data_out : out unsigned(6 downto 0)
        );
    end component;

    component somador is
        port( data_in  : in unsigned(6 downto 0);
              data_out : out unsigned(6 downto 0)
        );
    end component;

    signal pc_out_s      : unsigned(6 downto 0);
    signal soma_out_s    : unsigned(6 downto 0);
    signal branch_dest_s : unsigned(6 downto 0);
    signal pc_prox_s     : unsigned(6 downto 0);

begin

    pc1: pc port map(clk=>clk, rst=>rst, wr_en=>wr_en,
                    data_in=>pc_prox_s, data_out=>pc_out_s);

    somador1: somador port map(data_in=>pc_out_s, data_out=>soma_out_s);

   
    branch_dest_s <= pc_out_s + delta;

    pc_prox_s <= jump_dest     when jump_en='1'   else  -- JMP
                 branch_dest_s when branch_en='1' else  -- BLE/BVC
                 soma_out_s;

    data_out <= pc_out_s;

end architecture;