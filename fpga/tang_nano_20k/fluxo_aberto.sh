#!/bin/sh
set -e
OSS="${OSS_CAD_SUITE:-$HOME/.local/opt/oss-cad-suite}"
export PATH="$OSS/bin:$PATH"

P=$(cd "$(dirname "$0")" && pwd)
SAIDA="$P/build_aberto"
mkdir -p "$SAIDA"

PROC="reg1bit reg16bits banco ula banco_ula pc somador proto_uc sm ram rom uc processador"
ARQS=""
for f in $PROC; do ARQS="$ARQS $P/src/processador/$f.vhd"; done
ARQS="$ARQS $P/src/display_7seg.vhd $P/src/relogio.vhd $P/src/top_primos.vhd"

echo "== sintese (yosys + ghdl)"
yosys -q -m ghdl -l "$SAIDA/yosys.log" -p "ghdl --std=93c $ARQS -e top_primos; synth_gowin -top top_primos -family gw2a -json $SAIDA/primos.json"

echo "== posicionamento e roteamento (nextpnr)"
nextpnr-himbaechel --json "$SAIDA/primos.json" --write "$SAIDA/primos_pnr.json" \
    --device GW2AR-LV18QN88C8/I7 --vopt family=GW2A-18C --vopt cst="$P/src/pinout.cst" \
    -l "$SAIDA/nextpnr.log" -q

echo "== bitstream (gowin_pack)"
gowin_pack -d GW2A-18C -o "$SAIDA/primos.fs" "$SAIDA/primos_pnr.json"
echo "gerado: $SAIDA/primos.fs"

if [ "$1" = "gravar" ]; then
    echo "== gravando na SRAM (nao grava na flash)"
    openFPGALoader -b tangnano20k -m "$SAIDA/primos.fs"
fi
