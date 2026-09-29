#!/bin/sh
ghdl -a rom.vhd maq_estados.vhd pc.vhd un_controle.vhd pc_rom.vhd processador.vhd
ghdl -a rom_tb.vhd maq_estados_tb.vhd pc_tb.vhd un_controle_tb.vhd pc_rom_tb.vhd processador_tb.vhd
for tb in rom_tb maq_estados_tb pc_tb un_controle_tb pc_rom_tb processador_tb
do
   ghdl -e $tb
   ghdl -r $tb --wave=$tb.ghw
done
