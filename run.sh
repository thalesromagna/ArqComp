#!/bin/sh
set -e
cd "$(dirname "$0")"
ghdl -a reg16bits.vhd banco.vhd ula.vhd banco_ula.vhd lab_uc/pc.vhd lab_uc/somador.vhd lab_uc/proto_uc.vhd lab_uc/sm.vhd lab_uc/rom.vhd lab_uc/uc.vhd processador.vhd processador_tb.vhd
ghdl -e processador_tb
ghdl -r processador_tb --wave=processador_tb.ghw
gtkwave processador_tb.ghw processador_tb.gtkw
