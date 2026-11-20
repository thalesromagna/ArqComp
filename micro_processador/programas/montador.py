#!/usr/bin/env python3
import argparse
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

TAM_ROM = 128
TAM_RAM = 128
MASCARA = 0xFFFF

OPCODES = {
    "nop": 0b0000, "ld": 0b0001, "mov": 0b0010, "add": 0b0011, "sub": 0b0100,
    "ble": 0b0101, "bvc": 0b0110, "cmpr": 0b0111, "cmpi": 0b1000, "subb": 0b1001,
    "lw": 0b1010, "sw": 0b1011, "inc": 0b1100, "halt": 0b1101, "jmp": 0b1111,
}
FORMATOS = {
    "nop": "", "halt": "", "ld": "rc", "cmpi": "rc", "mov": "rr", "add": "rr",
    "sub": "rr", "cmpr": "rr", "subb": "rr", "lw": "rp", "sw": "rp", "inc": "r",
    "ble": "d", "bvc": "d", "jmp": "e", ".word": "w",
}
NOMES_OPCODE = {v: k for k, v in OPCODES.items()}
NOMES_OPCODE[0b1110] = "(1110 nao usado)"

ROTULO = re.compile(r"^\s*([A-Za-z_]\w*)\s*:")
IDENT = re.compile(r"^[A-Za-z_]\w*$")
REG = re.compile(r"^r([0-7])$")
PONT = re.compile(r"^\(\s*r([0-7])\s*\)$")


class ErroMontagem(Exception):
    pass


class ErroSimulacao(Exception):
    pass


@dataclass
class Instrucao:
    endereco: int
    palavra: int
    texto: str
    fonte: str
    linha: int
    rotulos: list[str] = field(default_factory=list)
    destino: int | None = None


def _numero(tok: str, linha: int) -> int:
    try:
        return int(tok, 0)
    except ValueError:
        raise ErroMontagem(f"linha {linha}: numero invalido '{tok}'") from None


def _reg(tok: str, linha: int) -> int:
    r = REG.match(tok)
    if not r:
        raise ErroMontagem(f"linha {linha}: registrador invalido '{tok}'")
    return int(r.group(1))


def _faixa(valor: int, mini: int, maxi: int, oque: str, linha: int) -> int:
    if not mini <= valor <= maxi:
        raise ErroMontagem(f"linha {linha}: {oque} {valor} fora de {mini}..{maxi}")
    return valor


def _separar(fonte: str) -> list[tuple[int, list[str], str, str]]:
    itens = []
    pendentes: list[str] = []
    for n, bruta in enumerate(fonte.splitlines(), 1):
        texto = bruta.split(";", 1)[0]
        while (r := ROTULO.match(texto)):
            pendentes.append(r.group(1))
            texto = texto[r.end():]
        texto = texto.strip()
        if texto:
            itens.append((n, pendentes, texto, bruta.strip()))
            pendentes = []
    if pendentes:
        raise ErroMontagem(f"rotulo(s) {pendentes} sem instrucao depois")
    return itens


def montar(fonte: str) -> list[Instrucao]:
    itens = _separar(fonte)
    if len(itens) > TAM_ROM:
        raise ErroMontagem(f"programa com {len(itens)} palavras nao cabe na ROM ({TAM_ROM})")
    rotulos: dict[str, int] = {}
    for end, (n, nomes, _, _) in enumerate(itens):
        for nome in nomes:
            if nome in rotulos or REG.match(nome) or nome in FORMATOS:
                raise ErroMontagem(f"linha {n}: rotulo '{nome}' repetido ou reservado")
            rotulos[nome] = end
    prog = []
    for end, (n, nomes, texto, bruta) in enumerate(itens):
        partes = texto.split(None, 1)
        mnem = partes[0].lower()
        ops = [o.strip() for o in partes[1].split(",")] if len(partes) > 1 else []
        if mnem not in FORMATOS:
            raise ErroMontagem(f"linha {n}: instrucao desconhecida '{mnem}'")
        fmt = FORMATOS[mnem]
        if len(ops) != len(fmt):
            raise ErroMontagem(f"linha {n}: '{mnem}' espera {len(fmt)} operando(s)")
        destino = None
        if mnem == ".word":
            palavra = _faixa(_numero(ops[0], n), 0, 2**17 - 1, "palavra", n)
            prog.append(Instrucao(end, palavra, f".word 0x{palavra:05X}", bruta, n, nomes))
            continue
        d = s = c = 0
        if fmt == "rc":
            d = _reg(ops[0], n)
            c = _faixa(_numero(ops[1], n), -64, 63, "constante", n)
            texto_c = f"{mnem} r{d}, {c}"
        elif fmt == "rr":
            d, s = _reg(ops[0], n), _reg(ops[1], n)
            texto_c = f"{mnem} r{d}, r{s}"
        elif fmt == "rp":
            d = _reg(ops[0], n)
            p = PONT.match(ops[1])
            if not p:
                raise ErroMontagem(f"linha {n}: ponteiro deve ser (rN), veio '{ops[1]}'")
            s = int(p.group(1))
            texto_c = f"{mnem} r{d}, (r{s})"
        elif fmt == "r":
            d = _reg(ops[0], n)
            texto_c = f"{mnem} r{d}"
        elif fmt == "d":
            if IDENT.match(ops[0]):
                if ops[0] not in rotulos:
                    raise ErroMontagem(f"linha {n}: rotulo '{ops[0]}' indefinido")
                c = rotulos[ops[0]] - end
            else:
                c = _numero(ops[0], n)
            c = _faixa(c, -64, 63, "delta", n)
            destino = (end + c) % TAM_ROM
            texto_c = f"{mnem} {c}"
        elif fmt == "e":
            if IDENT.match(ops[0]):
                if ops[0] not in rotulos:
                    raise ErroMontagem(f"linha {n}: rotulo '{ops[0]}' indefinido")
                c = rotulos[ops[0]]
            else:
                c = _numero(ops[0], n)
            c = _faixa(c, 0, TAM_ROM - 1, "endereco", n)
            destino = c
            texto_c = f"{mnem} {c}"
        else:
            texto_c = mnem
        palavra = (OPCODES[mnem] << 13) | (d << 10) | (s << 7) | (c & 0x7F)
        prog.append(Instrucao(end, palavra, texto_c, bruta, n, nomes, destino))
    return prog


def _grupos(palavra: int) -> str:
    b = format(palavra, "017b")
    return f"{b[0:4]}_{b[4:7]}_{b[7:10]}_{b[10:17]}"


def gerar_vhd(prog: list[Instrucao], origem: str = "") -> str:
    linhas = [
        "library ieee;",
        "use ieee.std_logic_1164.all;",
        "use ieee.numeric_std.all;",
    ]
    if origem:
        linhas.append(f"-- gerado por programas/montador.py a partir de programas/{origem}")
    linhas += [
        "entity rom is",
        "   port( clk      : in std_logic;",
        "         endereco : in unsigned(6 downto 0);",
        "         dado     : out unsigned(16 downto 0) ",
        "   );",
        "end entity;",
        "architecture a_rom of rom is",
        "   type mem is array (0 to 127) of unsigned(16 downto 0);",
        "   constant conteudo_rom : mem := (",
    ]
    for i in prog:
        linhas.append(f'        {i.endereco} => B"{_grupos(i.palavra)}", -- {i.texto}')
    linhas += [
        "        others => (others=>'0')",
        "   );",
        "begin",
        "   process(clk)",
        "   begin",
        "      if(rising_edge(clk)) then",
        "         dado <= conteudo_rom(to_integer(endereco));",
        "      end if;",
        "   end process;",
        "end architecture;",
        "",
    ]
    return "\n".join(linhas)


def ler_vhd(texto: str) -> list[int]:
    achados = {int(a): int(b.replace("_", ""), 2)
               for a, b in re.findall(r'(\d+)\s*=>\s*B"([01_]+)"', texto)}
    if not achados:
        return []
    return [achados.get(e, 0) for e in range(max(achados) + 1)]


def gerar_lst(prog: list[Instrucao], origem: str) -> str:
    linhas = [
        f"; {Path(origem).stem}.lst - gerado por montador.py a partir de {origem}",
        f"; {len(prog)} palavras de {TAM_ROM}",
        ";",
        "; end  opc  ddd sss ccccccc  hex    instrucao              destino          | fonte",
    ]
    nomes = {i.endereco: i.rotulos for i in prog}
    for i in prog:
        for r in i.rotulos:
            linhas.append(f";                                  {r}:")
        dest = ""
        if i.destino is not None:
            rot = nomes.get(i.destino) or []
            dest = f"-> {i.destino}" + (f" ({rot[0]})" if rot else "")
        linhas.append(f"  {i.endereco:3d}  {_grupos(i.palavra)}  {i.palavra:05X}  "
                      f"{i.texto:<22} {dest:<16} | {i.fonte}")
    return "\n".join(linhas) + "\n"


def _s16(v: int) -> int:
    return v - 0x10000 if v & 0x8000 else v


def _sext7(c: int) -> int:
    return (c | 0xFF80) if c & 0x40 else c


@dataclass
class Resultado:
    regs: list[int]
    ram: list[int | None]
    z: int = 0
    n: int = 0
    c: int = 0
    v: int = 0
    pc: int = 0
    halt: bool = False
    instrucoes: int = 0
    saida_r7: list[int] = field(default_factory=list)
    contagem: dict[int, int] = field(default_factory=dict)
    saltos: dict[int, list[int]] = field(default_factory=dict)


def _ula(op: str, a: int, b: int, cin: int) -> tuple[int, int, int, int, int]:
    if op == "add":
        res = (a + b) & MASCARA
        c = int(res < a)
        v = int((a & 0x8000) == (b & 0x8000) and (res & 0x8000) != (a & 0x8000))
    elif op == "sub":
        res = (a - b) & MASCARA
        c = int(a < b)
        v = int((a & 0x8000) != (b & 0x8000) and (res & 0x8000) != (a & 0x8000))
    else:
        s17 = (a - b - cin) & 0x1FFFF
        res = s17 & MASCARA
        c = (s17 >> 16) & 1
        v = int((a & 0x8000) != (b & 0x8000) and (res & 0x8000) != (a & 0x8000))
    return res, int(res == 0), int(res >= 0x8000), c, v


def simular(palavras: list[int], max_passos: int = 100000) -> Resultado:
    rom = (list(palavras) + [0] * TAM_ROM)[:TAM_ROM]
    r = Resultado(regs=[0] * 8, ram=[None] * TAM_RAM)

    def escreve(d: int, valor: int) -> None:
        valor &= MASCARA
        if d == 7:
            if valor == r.regs[7]:
                raise ErroSimulacao(f"end {r.pc}: r7 recebe {_s16(valor)} igual ao valor atual "
                                    "(o testbench nao detecta)")
            r.saida_r7.append(_s16(valor))
        r.regs[d] = valor

    while r.instrucoes < max_passos:
        w = rom[r.pc]
        op, d, s, c = w >> 13, (w >> 10) & 7, (w >> 7) & 7, w & 0x7F
        r.instrucoes += 1
        r.contagem[op] = r.contagem.get(op, 0) + 1
        prox = (r.pc + 1) % TAM_ROM
        a, b = r.regs[d], r.regs[s]
        nome = NOMES_OPCODE.get(op, "")
        if nome == "ld":
            escreve(d, _sext7(c))
        elif nome == "mov":
            escreve(d, b)
        elif nome in ("add", "sub", "subb", "cmpr", "cmpi"):
            oper = {"cmpr": "sub", "cmpi": "sub"}.get(nome, nome)
            bb = _sext7(c) if nome == "cmpi" else b
            res, r.z, r.n, r.c, r.v = _ula(oper, a, bb, r.c)
            if nome in ("add", "sub", "subb"):
                escreve(d, res)
        elif nome in ("ble", "bvc"):
            tomado = (r.z or r.n != r.v) if nome == "ble" else not r.v
            r.saltos.setdefault(r.pc, [0, 0])[0 if tomado else 1] += 1
            if tomado:
                prox = (r.pc + c) % TAM_ROM
        elif nome == "jmp":
            prox = c
        elif nome == "lw":
            valor = r.ram[b & 0x7F]
            if valor is None:
                raise ErroSimulacao(f"end {r.pc}: leitura da RAM[{b & 0x7F}] nao inicializada")
            escreve(d, valor)
        elif nome == "sw":
            r.ram[b & 0x7F] = a
        elif nome == "inc":
            escreve(d, a + 1)
        elif nome == "halt":
            r.halt = True
            return r
        r.pc = prox
    return r


def _carregar(caminho: Path) -> tuple[list[int], list[Instrucao] | None]:
    texto = caminho.read_text(encoding="utf-8")
    if caminho.suffix == ".vhd":
        return ler_vhd(texto), None
    prog = montar(texto)
    return [i.palavra for i in prog], prog


def relatorio(nome: str, palavras: list[int], r: Resultado, cobertura: bool) -> str:
    out = [f"programa: {nome} ({len(palavras)} palavras de {TAM_ROM})"]
    if r.halt:
        tempo = (r.instrucoes + 1) * 200
        out.append(f"HALT no endereco {r.pc} apos {r.instrucoes} instrucoes executadas "
                   f"(~{tempo / 1000:.1f} us de simulacao com reset; limite 2000 us)")
    else:
        out.append(f"SEM HALT apos {r.instrucoes} instrucoes")
    out.append("sequencia r7: " + " ".join(str(x) for x in r.saida_r7))
    out.append("registradores: " + "  ".join(f"r{i}={_s16(x)}" for i, x in enumerate(r.regs)))
    out.append(f"flags: Z={r.z} N={r.n} C={r.c} V={r.v}")
    out.append("RAM (posicoes escritas, end: valor):")
    usados = [(e, x) for e, x in enumerate(r.ram) if x is not None]
    for k in range(0, len(usados), 8):
        out.append("  " + "  ".join(f"{e:3d}:{_s16(x):6d}" for e, x in usados[k:k + 8]))
    if cobertura:
        out.append("cobertura de opcodes (vezes executado):")
        for op in range(16):
            out.append(f"  {op:04b} {NOMES_OPCODE[op]:<16} {r.contagem.get(op, 0)}")
        out.append("saltos condicionais (end: tomado / nao tomado):")
        for e in sorted(r.saltos):
            t, nt = r.saltos[e]
            out.append(f"  {e:3d} {NOMES_OPCODE[palavras[e] >> 13]:<4} {t} / {nt}")
    return "\n".join(out)


PROGRAMAS = {"crivo": "../rom.vhd", "teste_ram": "rom_teste_ram.vhd",
             "instrucoes": "rom_instrucoes.vhd"}


def _gerar(asm: Path, rom: Path) -> None:
    prog = montar(asm.read_text(encoding="utf-8"))
    asm.with_suffix(".lst").write_text(gerar_lst(prog, asm.name), encoding="utf-8")
    rom.write_text(gerar_vhd(prog, asm.name), encoding="utf-8", newline="\r\n")
    r = simular([i.palavra for i in prog])
    if not r.halt:
        raise ErroSimulacao(f"{asm.name}: sem HALT")
    asm.with_suffix(".esperado").write_text("".join(f"{x}\n" for x in r.saida_r7), encoding="utf-8")
    print(f"{asm.name}: {len(prog)} palavras -> {rom.name}, {asm.with_suffix('.lst').name}, "
          f"{asm.with_suffix('.esperado').name} ({r.instrucoes} instrucoes ate o HALT)")


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Montador e simulador de ISA do processador (lab 7)")
    sub = ap.add_subparsers(dest="cmd", required=True)
    pm = sub.add_parser("montar", help="gera .lst e ROM VHDL")
    pm.add_argument("asm", type=Path)
    pm.add_argument("--rom", type=Path)
    ps = sub.add_parser("simular", help="executa .asm ou .vhd ate o HALT")
    ps.add_argument("arquivo", type=Path)
    ps.add_argument("--cobertura", action="store_true")
    ps.add_argument("--r7", action="store_true", help="imprime so a sequencia de r7")
    sub.add_parser("todos", help="regera os tres programas (ROM, .lst, .esperado)")
    a = ap.parse_args(argv)
    try:
        if a.cmd == "montar":
            _gerar(a.asm, a.rom or a.asm.with_name(f"rom_{a.asm.stem}.vhd"))
        elif a.cmd == "todos":
            aqui = Path(__file__).resolve().parent
            for nome, rom in PROGRAMAS.items():
                _gerar(aqui / f"{nome}.asm", (aqui / rom).resolve())
        else:
            palavras, _ = _carregar(a.arquivo)
            r = simular(palavras)
            if a.r7:
                print("\n".join(str(x) for x in r.saida_r7))
            else:
                print(relatorio(a.arquivo.name, palavras, r, a.cobertura))
            return 0 if r.halt else 1
    except (ErroMontagem, ErroSimulacao) as e:
        print(f"erro: {e}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
