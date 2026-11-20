#!/usr/bin/env python3
import re
import sys
from pathlib import Path

TABELA = {
    "0000": ("nop", ""), "0001": ("ld", "dc"), "0010": ("mov", "ds"), "0011": ("add", "ds"),
    "0100": ("sub", "ds"), "0101": ("ble", "c"), "0110": ("bvc", "c"), "0111": ("cmpr", "ds"),
    "1000": ("cmpi", "dc"), "1001": ("subb", "ds"), "1010": ("lw", "dp"), "1011": ("sw", "dp"),
    "1100": ("inc", "d"), "1101": ("halt", ""), "1111": ("jmp", "e"),
}


def com_sinal(campo: str) -> int:
    return int(campo, 2) - (128 if campo[0] == "1" else 0)


def desmontar(bits: str) -> str:
    op, d, s, c = bits[0:4], bits[4:7], bits[7:10], bits[10:17]
    if op not in TABELA:
        return f".word 0x{int(bits, 2):05X}"
    nome, fmt = TABELA[op]
    rd, rs = f"r{int(d, 2)}", f"r{int(s, 2)}"
    return {
        "": nome,
        "dc": f"{nome} {rd}, {com_sinal(c)}",
        "ds": f"{nome} {rd}, {rs}",
        "dp": f"{nome} {rd}, ({rs})",
        "d": f"{nome} {rd}",
        "c": f"{nome} {com_sinal(c)}",
        "e": f"{nome} {int(c, 2)}",
    }[fmt]


def ler_rom(texto: str) -> list[tuple[int, str, str]]:
    linhas = re.findall(r'^\s*(\d+)\s*=>\s*B"([01_]+)"\s*,\s*--\s*(.*?)\s*$', texto, re.M)
    return [(int(e), b.replace("_", ""), coment) for e, b, coment in linhas]


def ler_fonte(texto: str) -> tuple[list[str], dict[str, int]]:
    instrucoes, rotulos = [], {}
    for bruta in texto.splitlines():
        resto = bruta.split(";")[0]
        while m := re.match(r"\s*(\w+):", resto):
            rotulos[m.group(1)] = len(instrucoes)
            resto = resto[m.end():]
        if resto.strip():
            instrucoes.append(" ".join(resto.lower().split()))
    return instrucoes, rotulos


def normalizar(instr: str, end: int, rotulos: dict[str, int]) -> str:
    nome, _, ops = instr.partition(" ")
    partes = [p.strip() for p in ops.split(",")] if ops else []
    saida = []
    for p in partes:
        if p in rotulos:
            p = str(rotulos[p] - end if nome in ("ble", "bvc") else rotulos[p])
        elif re.fullmatch(r"-?(0x[0-9a-f]+|\d+)", p):
            v = int(p, 0)
            p = f"0x{v:05X}" if nome == ".word" else str(v)
        elif p.startswith("("):
            p = "(" + p.strip("() ") + ")"
        saida.append(p)
    return nome + (" " + ", ".join(saida) if saida else "")


def main(rom: Path, asm: Path) -> int:
    palavras = ler_rom(rom.read_text(encoding="utf-8"))
    fonte, rotulos = ler_fonte(asm.read_text(encoding="utf-8"))
    divergencias = 0
    if [e for e, _, _ in palavras] != list(range(len(palavras))):
        print("enderecos da ROM fora de sequencia")
        divergencias += 1
    if len(palavras) != len(fonte):
        print(f"ROM tem {len(palavras)} palavras, fonte tem {len(fonte)} instrucoes")
        divergencias += 1
    for (end, bits, coment), instr in zip(palavras, fonte):
        texto = desmontar(bits)
        esperado = normalizar(instr, end, rotulos)
        marca = "ok" if texto == esperado == coment else "DIVERGE"
        if marca != "ok":
            divergencias += 1
            print(f"{end:3d} {bits} desmontado='{texto}' fonte='{esperado}' comentario='{coment}' {marca}")
    print(f"{rom.name} x {asm.name}: {len(palavras)} palavras, {divergencias} divergencia(s)")
    return 1 if divergencias else 0


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("uso: desmontador.py ROM.vhd PROGRAMA.asm")
        sys.exit(2)
    sys.exit(main(Path(sys.argv[1]), Path(sys.argv[2])))
