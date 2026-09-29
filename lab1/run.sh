ghdl -a porta.vhd porta_tb.vhd decoder2x4.vhd decoder2x4_tb.vhd paridade3.vhd paridade3_tb.vhd
ghdl -e porta_tb
ghdl -e decoder2x4_tb
ghdl -e paridade3_tb
ghdl -r porta_tb --wave=porta_tb.ghw
ghdl -r decoder2x4_tb --wave=decoder2x4_tb.ghw
ghdl -r paridade3_tb --wave=paridade3_tb.ghw
