#!/bin/sh
set -e

TB_DIR=$(cd "$(dirname "$0")" && pwd)
PROJ=$(dirname "$TB_DIR")
SRC="$PROJ/src"
PROC="$SRC/processador"
WORK="$TB_DIR/work"
MODO="${1:-auto}"

if ! command -v ghdl >/dev/null 2>&1; then
    echo "ERRO: ghdl nao encontrado no PATH."
    exit 1
fi

LISTA="reg1bit.vhd reg16bits.vhd banco.vhd ula.vhd banco_ula.vhd pc.vhd somador.vhd proto_uc.vhd sm.vhd ram.vhd rom.vhd uc.vhd processador.vhd"

if [ "$MODO" = "auto" ]; then
    if [ -d "$PROC" ]; then MODO=real; else MODO=duble; fi
fi

rm -rf "$WORK"
mkdir -p "$WORK"
G="ghdl -a --std=93c --workdir=$WORK"

if [ "$MODO" = "real" ]; then
    echo "== usando o processador real de $PROC"
    for f in $LISTA; do
        if [ ! -f "$PROC/$f" ]; then
            echo "ERRO: falta $PROC/$f (rode fpga/sincronizar.sh)"
            exit 1
        fi
        $G "$PROC/$f"
    done
elif [ "$MODO" = "duble" ]; then
    echo "== usando o processador-duble (tb/processador_duble.vhd)"
    $G "$TB_DIR/processador_duble.vhd"
else
    echo "uso: sh run_tb.sh [auto|duble|real]"
    exit 1
fi

$G "$TB_DIR/bufg_sim.vhd" "$SRC/display_7seg.vhd" "$SRC/relogio.vhd" "$SRC/top_primos.vhd"
$G "$SRC/display_mux.vhd" "$SRC/top_primos_4dig.vhd"
$G "$TB_DIR/display_7seg_tb.vhd" "$TB_DIR/top_primos_tb.vhd"
$G "$TB_DIR/display_mux_tb.vhd" "$TB_DIR/top_primos_4dig_tb.vhd"

FALHA=0
for tb in display_7seg_tb top_primos_tb display_mux_tb top_primos_4dig_tb; do
    echo "== $tb"
    if ! (cd "$WORK" && ghdl -e --std=93c --workdir="$WORK" "$tb" && ghdl -r --std=93c --workdir="$WORK" "$tb" --ieee-asserts=disable --assert-level=error) > "$WORK/$tb.log" 2>&1; then
        FALHA=1
    fi
    grep -v "^$" "$WORK/$tb.log" | sed 's/^.*(report note): //'
    if grep -q -E "error|failure" "$WORK/$tb.log"; then FALHA=1; fi
done

if [ "$FALHA" = "0" ]; then
    echo "OK"
else
    echo "FALHA"
    exit 1
fi
