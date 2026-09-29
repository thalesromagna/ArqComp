#!/bin/sh
ghdl -a reg16bits.vhd pc.vhd maq_estados.vhd rom.vhd banco.vhd ula.vhd un_controle.vhd processador.vhd processador_tb.vhd
ghdl -e processador_tb
ghdl -r processador_tb --wave=processador_tb.ghw
gtkwave processador_tb.ghw processador_tb.gtkw
