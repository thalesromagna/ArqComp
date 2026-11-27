#!/bin/sh
set -e
OSS="${OSS_CAD_SUITE:-$HOME/.local/opt/oss-cad-suite}"
export PATH="$OSS/bin:$PATH"

P=$(cd "$(dirname "$0")" && pwd)
SAIDA="$P/build_aberto"
mkdir -p "$SAIDA"

GRAVAR=0
QUATRO=0
for a in "$@"; do
    case "$a" in
        gravar) GRAVAR=1 ;;
        4dig) QUATRO=1 ;;
    esac
done

if [ "$QUATRO" = "1" ]; then
    TOP=top_primos_4dig
    CST="$P/src/pinout_4dig.cst"
    SUF=_4dig
    EXTRA="$P/src/display_mux.vhd $P/src/top_primos_4dig.vhd"
else
    TOP=top_primos
    CST="$P/src/pinout.cst"
    SUF=""
    EXTRA="$P/src/top_primos.vhd"
fi

PROC="reg1bit reg16bits banco ula banco_ula pc somador proto_uc sm ram rom uc processador"
ARQS=""
for f in $PROC; do ARQS="$ARQS $P/src/processador/$f.vhd"; done
ARQS="$ARQS $P/src/display_7seg.vhd $P/src/relogio.vhd $EXTRA"

echo "== sintese (yosys + ghdl)"
yosys -q -m ghdl -l "$SAIDA/yosys$SUF.log" -p "ghdl --std=93c $ARQS -e $TOP; synth_gowin -top $TOP -family gw2a -json $SAIDA/primos$SUF.json"

echo "== posicionamento e roteamento (nextpnr)"
nextpnr-himbaechel --json "$SAIDA/primos$SUF.json" --write "$SAIDA/primos${SUF}_pnr.json" \
    --device GW2AR-LV18QN88C8/I7 --vopt family=GW2A-18C --vopt cst="$CST" \
    -l "$SAIDA/nextpnr$SUF.log" -q

echo "== bitstream (gowin_pack)"
gowin_pack -d GW2A-18C -o "$SAIDA/primos$SUF.fs" "$SAIDA/primos${SUF}_pnr.json"
echo "gerado: $SAIDA/primos$SUF.fs"

if [ "$GRAVAR" = "1" ]; then
    echo "== gravando na SRAM (nao grava na flash)"
    openFPGALoader -b tangnano20k -m "$SAIDA/primos$SUF.fs"
fi
