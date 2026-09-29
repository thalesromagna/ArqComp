#!/bin/sh
ghdl -a reg16bits.vhd banco.vhd ula.vhd banco_ula.vhd reg16bits_tb.vhd banco_tb.vhd banco_ula_tb.vhd
ghdl -e reg16bits_tb
ghdl -r reg16bits_tb --wave=reg16bits_tb.ghw
ghdl -e banco_tb
ghdl -r banco_tb --wave=banco_tb.ghw
ghdl -e banco_ula_tb
ghdl -r banco_ula_tb --wave=banco_ula_tb.ghw
