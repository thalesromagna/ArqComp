#!/bin/sh

cd "$(dirname "$0")" || exit 2

if ! command -v ghdl > /dev/null 2>&1; then
    echo "ghdl nao encontrado no PATH"
    exit 2
fi

if [ -z "$1" ]; then
    ROM=rom.vhd
    ESPERADO=programas/crivo.esperado
else
    ROM=programas/rom_$1.vhd
    ESPERADO=programas/$1.esperado
fi

if [ ! -f "$ROM" ]; then
    echo "ROM nao encontrada: $ROM"
    exit 2
fi

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

for f in reg1bit.vhd banco_ula/banco/reg16bits.vhd banco_ula/banco/banco.vhd banco_ula/ula/ula.vhd \
         banco_ula/banco_ula.vhd proto_uc/pc.vhd proto_uc/somador.vhd proto_uc/proto_uc.vhd sm.vhd \
         ram.vhd "$ROM" uc/uc.vhd processador.vhd processador_tb.vhd; do
    ghdl -a --workdir="$WORK" "$f" || { echo "erro compilando $f"; exit 2; }
done
ghdl -e --workdir="$WORK" processador_tb || exit 2
ghdl -r --workdir="$WORK" processador_tb --wave=processador_tb.ghw > "$WORK/sim.log" 2>&1

sed -n 's/.*(report note): R7 //p' "$WORK/sim.log" > "$WORK/r7.txt"

echo "ROM: $ROM"
echo "r7: $(tr '\n' ' ' < "$WORK/r7.txt")"

HALT=0
if grep -q '(report note): HALTED' "$WORK/sim.log"; then
    HALT=1
    echo "HALTED"
else
    echo "TIMEOUT (sem HALT em 2 ms)"
fi
echo "formas de onda: $(pwd)/processador_tb.ghw"

if [ ! -f "$ESPERADO" ]; then
    echo "sem $ESPERADO, nada para comparar"
    exit 0
fi

tr -d '\r' < "$ESPERADO" | grep -v '^[[:space:]]*$' > "$WORK/esperado.txt"
echo "esperado: $(tr '\n' ' ' < "$WORK/esperado.txt")"

if cmp -s "$WORK/r7.txt" "$WORK/esperado.txt" && [ $HALT -eq 1 ]; then
    echo "OK"
    exit 0
fi
echo "FALHA"
exit 1
