#!/bin/sh

RAIZ=$(cd "$(dirname "$0")/.." && pwd)
ORIGEM="${1:-$RAIZ/micro_processador}"
DESTINO="${2:-$RAIZ/fpga/tang_nano_20k/src/processador}"

LISTA="reg1bit.vhd
banco_ula/banco/reg16bits.vhd
banco_ula/banco/banco.vhd
banco_ula/ula/ula.vhd
banco_ula/banco_ula.vhd
proto_uc/pc.vhd
proto_uc/somador.vhd
proto_uc/proto_uc.vhd
sm.vhd
ram.vhd
rom.vhd
uc/uc.vhd
processador.vhd"

if [ ! -d "$ORIGEM" ]; then
    echo "ERRO: pasta de origem nao existe: $ORIGEM"
    exit 1
fi

for f in $LISTA; do
    if [ ! -f "$ORIGEM/$f" ]; then
        echo "ERRO: FALTA $ORIGEM/$f; nada foi apagado nem copiado."
        exit 1
    fi
done

mkdir -p "$DESTINO"
rm -f "$DESTINO"/*.vhd

COPIADOS=0
FALTANDO=0
for f in $LISTA; do
    if [ -f "$ORIGEM/$f" ]; then
        cp "$ORIGEM/$f" "$DESTINO/"
        echo "copiado  $f"
        COPIADOS=$((COPIADOS + 1))
    else
        echo "AVISO: FALTA $ORIGEM/$f (o Gowin vai acusar erro ate esse arquivo existir)"
        FALTANDO=$((FALTANDO + 1))
    fi
done

if [ -f "$DESTINO/processador.vhd" ]; then
    for p in r7_out halted; do
        if ! grep -q "$p" "$DESTINO/processador.vhd"; then
            echo "AVISO: processador.vhd nao tem a porta '$p' (interface antiga; o top_primos precisa de r7_out e halted)"
            FALTANDO=$((FALTANDO + 1))
        fi
    done
fi

echo "$COPIADOS de 13 arquivos copiados para $DESTINO"
if [ "$FALTANDO" -ne 0 ]; then
    echo "INCOMPLETO: corrija os avisos acima e rode de novo."
    exit 1
fi
echo "OK: pronto para abrir fpga/tang_nano_20k/primos.gprj no Gowin."
