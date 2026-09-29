ghdl -a mux8x1.vhd mux8x1_tb.vhd soma_e_subtrai.vhd soma_e_subtrai_tb.vhd ula.vhd ula_tb.vhd
ghdl -e mux8x1_tb
ghdl -e soma_e_subtrai_tb
ghdl -e ula_tb
ghdl -r mux8x1_tb --wave=mux8x1_tb.ghw
ghdl -r soma_e_subtrai_tb --wave=soma_e_subtrai_tb.ghw
ghdl -r ula_tb --wave=ula_tb.ghw
