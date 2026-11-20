import re
import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import schemdraw
import schemdraw.elements as elm
from matplotlib.patches import Circle, Polygon, Rectangle

AQUI = Path(__file__).resolve().parent
RAIZ = AQUI.parents[1]
CST = RAIZ / "fpga" / "tang_nano_20k" / "src" / "pinout.cst"
GUIA = RAIZ / "docs" / "fpga-tang-nano-20k.md"

DPI = 220
ESCALA = 0.6
SEGMENTOS = "abcdefg"
BIT = {"a": 0, "b": 1, "c": 2, "d": 3, "e": 4, "f": 5, "g": 6}
PINO_DISPLAY = {"a": 7, "b": 6, "c": 4, "d": 2, "e": 1, "f": 9, "g": 10, "DP": 5}
PINOS_COM = (3, 8)
GRUPOS = (
    ("seg_dezena", "dez", "DS1", "DEZENAS", "5161BS", True),
    ("seg_unidade", "uni", "DS2", "UNIDADES", "5161AS", False),
)
HEADER = {
    77: "E5", 15: "E6", 16: "E7", 27: "E8", 28: "E9", 25: "E10", 26: "E11",
    29: "E12", 30: "E13", 31: "E14", 17: "E15", 20: "E16", 19: "E17",
    18: "E18", 53: "D19",
}
HEADER_3V3 = "E19 ou D16"
HEADER_GND = "E20 ou D15"
HEADER_GND_LED = "E20"
OHMS = 330

AZUL = "#1f4e79"
VERMELHO = "#b3261e"
CINZA = "#555555"


def abortar(msg):
    print("ERRO: " + msg, file=sys.stderr)
    sys.exit(1)


def ler_pinout(caminho):
    if not caminho.is_file():
        abortar(f"pinout.cst não encontrado em {caminho}")
    padrao = re.compile(r'^\s*IO_LOC\s+"(\w+)(?:\[(\d+)\])?"\s+(\d+)\s*;')
    achados = {}
    for linha in caminho.read_text(encoding="utf-8").splitlines():
        m = padrao.match(linha)
        if m:
            nome, indice, pino = m.group(1), m.group(2), int(m.group(3))
            achados[(nome, None if indice is None else int(indice))] = pino
    return achados


def montar_ligacoes(achados):
    faltando = []
    ligacoes = []
    resistor = 0
    for nome, prefixo, ds, rotulo, _, _ in GRUPOS:
        for letra in SEGMENTOS:
            chave = (nome, BIT[letra])
            if chave not in achados:
                faltando.append(f"{nome}[{BIT[letra]}]")
                continue
            resistor += 1
            pino = achados[chave]
            if pino not in HEADER:
                abortar(f"pino {pino} ({nome}[{BIT[letra]}]) sem posição no header")
            ligacoes.append({
                "grupo": rotulo, "ds": ds, "sinal": f"{prefixo} {letra}",
                "letra": letra, "pino": pino, "header": HEADER[pino],
                "resistor": f"R{resistor}", "pino_display": PINO_DISPLAY[letra],
            })
    if ("halted", None) not in achados:
        faltando.append("halted")
    if faltando:
        abortar("sinais não encontrados em pinout.cst: " + ", ".join(faltando))
    pino_halt = achados[("halted", None)]
    if pino_halt not in HEADER:
        abortar(f"pino {pino_halt} (halted) sem posição no header")
    ligacoes.append({
        "grupo": "HALT", "ds": "LED", "sinal": "halted", "letra": None,
        "pino": pino_halt, "header": HEADER[pino_halt],
        "resistor": f"R{resistor + 1}", "pino_display": "-",
    })
    pinos = [l["pino"] for l in ligacoes]
    repetidos = sorted({p for p in pinos if pinos.count(p) > 1})
    if repetidos:
        abortar(f"pinos repetidos: {repetidos}")
    return ligacoes


def imprimir_tabela(ligacoes):
    cab = ("sinal", "pino FPGA", "header", "resistor", "pino do display")
    linhas = [cab] + [
        (l["sinal"] if l["grupo"] != "HALT" else "halted (LED)",
         str(l["pino"]), l["header"], l["resistor"],
         f'{l["ds"]} pino {l["pino_display"]}' if l["letra"] else f"LED + GND ({HEADER_GND_LED})")
        for l in ligacoes
    ]
    larg = [max(len(r[i]) for r in linhas) for i in range(len(cab))]
    for i, r in enumerate(linhas):
        print("  ".join(c.ljust(larg[j]) for j, c in enumerate(r)))
        if i == 0:
            print("  ".join("-" * w for w in larg))
    print(f"COM DS1 (5161BS, anodo comum, pinos {PINOS_COM[0]} e {PINOS_COM[1]}): 3V3 ({HEADER_3V3}), sem resistor, acende com '0'")
    print(f"COM DS2 (5161AS, catodo comum, pinos {PINOS_COM[0]} e {PINOS_COM[1]}): GND ({HEADER_GND}), sem resistor, acende com '1'")


def conferir_guia(ligacoes, caminho):
    if not caminho.is_file():
        return [f"guia não encontrado em {caminho}"]
    texto = caminho.read_text(encoding="utf-8")
    erros = []
    trechos = {}
    for _, _, ds, rotulo, _, _ in GRUPOS:
        marcador = "esquerda" if ds == "DS1" else "direita"
        m = re.search(rf"### Display da {marcador}.*?\n(.*?)(?=\n### |\n## )", texto, re.S)
        if not m:
            erros.append(f"seção do display da {marcador} não encontrada no guia")
            continue
        trechos[ds] = m.group(1)
    linha_re = re.compile(
        r"^\|\s*([a-g])\s*\|\s*(\d+)\s*\|\s*\**([ED]\d+)\**\s*\|\s*(R\d+)\s+(\d+)\s*\|\s*(\d+)\s*\|\s*$"
    )
    for ds, trecho in trechos.items():
        no_guia = {}
        for linha in trecho.splitlines():
            m = linha_re.match(linha.strip())
            if m:
                no_guia[m.group(1)] = (int(m.group(2)), m.group(3), m.group(4), int(m.group(5)), int(m.group(6)))
        for l in (x for x in ligacoes if x["ds"] == ds):
            esperado = (l["pino"], l["header"], l["resistor"], OHMS, l["pino_display"])
            if no_guia.get(l["letra"]) != esperado:
                erros.append(f'{ds} segmento {l["letra"]}: guia={no_guia.get(l["letra"])} esperado={esperado}')
        rede = "3V3" if ds == "DS1" else "GND"
        if not re.search(rf"\|\s*comum[^|]*\|\s*{rede}\s*\|[^|]*\|\s*sem resistor\s*\|\s*3 e 8\s*\|", trecho):
            erros.append(f"{ds}: linha do comum (3 e 8, {rede}, sem resistor) não confere no guia")
    return erros


def pino_placa(nome, lado, slot, ancora):
    return elm.IcPin(name=nome, side=lado, slot=slot, anchorname=ancora, lblsize=9.5)


def desenhar_esquematico(ligacoes, saida_svg, saida_png):
    P = 0.7
    N = 20
    LARG_PLACA = 5.6
    LARG_DS = 2.7
    X_DS = LARG_PLACA + 0.5 + 4.2
    base_de = {"DS1": 0, "DS2": 10}
    linha_halt = 19
    topo = N * P

    def y_linha(r):
        return topo - P / 2 - r * P

    pinos_placa = []
    linha_de = {}
    for l in ligacoes:
        if l["grupo"] == "HALT":
            r = linha_halt
            nome = f'HALT — pino {l["pino"]} ({l["header"]})'
        else:
            r = base_de[l["ds"]] + SEGMENTOS.index(l["letra"])
            nome = f'{l["sinal"]} — pino {l["pino"]} ({l["header"]})'
        linha_de[l["sinal"]] = r
        pinos_placa.append(pino_placa(nome, "right", f"{N - r}/{N}", l["sinal"].replace(" ", "_")))
    pinos_placa.append(pino_placa(f"3V3 ({HEADER_3V3})", "left", f"{N - 9}/{N}", "v33"))
    pinos_placa.append(pino_placa(f"GND ({HEADER_GND})", "left", f"{N - 10}/{N}", "gnd"))

    d = schemdraw.Drawing(show=False)
    d.config(fontsize=9, lw=1.3)
    placa = elm.Ic(size=(LARG_PLACA, topo), pinspacing=P, pins=pinos_placa, leadlen=0.5, lsize=9.5)
    d += placa.at((0, 0))
    d += elm.Label().at((LARG_PLACA / 2, topo + 0.25)).label(
        "Tang Nano 20K (FPGA GW2AR-18)", fontsize=13, halign="center", valign="bottom", color=AZUL)

    d += elm.Line().at(placa.v33).left(0.5)
    d += elm.Vdd().label("3V3", loc="top", fontsize=10)
    d += elm.Line().at(placa.gnd).left(0.5)
    d += elm.Ground().label("GND", loc="bottom", fontsize=10)

    for _, _, ds, rotulo, modelo, anodo in GRUPOS:
        base = base_de[ds]
        y_topo = topo - base * P
        y_base = y_topo - 8 * P
        x_bus = X_DS + LARG_DS - 0.45
        cantos = [(X_DS, y_base), (X_DS + LARG_DS, y_base), (X_DS + LARG_DS, y_topo), (X_DS, y_topo), (X_DS, y_base)]
        for c0, c1 in zip(cantos, cantos[1:]):
            d += elm.Line().at(c0).to(c1)
        tipo = "anodo comum" if anodo else "catodo comum"
        rede = "3V3" if anodo else "GND"
        acende = "0" if anodo else "1"
        d += elm.Label().at((X_DS, y_topo + 0.3)).label(
            f"{ds} = {rotulo}\n{modelo}, {tipo}: COM no {rede}\nsegmento acende com '{acende}'",
            fontsize=11, halign="left", valign="bottom", color=AZUL)

        ys = []
        for i, letra in enumerate(SEGMENTOS):
            y = y_topo - P / 2 - i * P
            ys.append(y)
            l = next(x for x in ligacoes if x["ds"] == ds and x["letra"] == letra)
            ini = getattr(placa, l["sinal"].replace(" ", "_"))
            d += elm.Resistor().at(ini).tox(X_DS).label(f'{l["resistor"]}  {OHMS} Ω', loc="top", fontsize=8.5, ofst=0.04)
            d += elm.Label().at((X_DS - 0.2, y - 0.1)).label(
                f"{letra} (pino {PINO_DISPLAY[letra]})", fontsize=9, halign="right", valign="top", color=CINZA)
            if anodo:
                d += elm.Diode().at((x_bus, y)).tox(X_DS)
            else:
                d += elm.Diode().at((X_DS, y)).tox(x_bus)
            xc = (X_DS + x_bus) / 2
            for deslocamento in (0.0, 0.17):
                d += elm.Arrow().at((xc + deslocamento - 0.02, y + 0.2)).to((xc + deslocamento + 0.14, y + 0.4)).linewidth(1.0)
            d += elm.Dot().at((x_bus, y))
        d += elm.Line().at((x_bus, ys[0])).to((x_bus, ys[-1]))

        y_dp = y_topo - P / 2 - 7 * P
        d += elm.Line().at((X_DS, y_dp)).left(0.8).dot(open=True)
        d += elm.Label().at((X_DS - 0.95, y_dp)).label(
            f"DP (pino {PINO_DISPLAY['DP']}): não conectado", fontsize=9, halign="right", valign="center", color=CINZA)

        y_com = ys[3]
        x_saida = X_DS + LARG_DS + 0.6
        d += elm.Line().at((x_bus, y_com)).tox(x_saida)
        d += elm.Label().at((X_DS + LARG_DS + 0.05, y_com + (-0.13 if anodo else 0.13))).label(
            "COM (3 e 8)", fontsize=9, halign="left", valign="top" if anodo else "bottom", color=AZUL)
        if anodo:
            d += elm.Line().up(0.5)
            d += elm.Vdd().label(f"3V3 ({HEADER_3V3})\nsem resistor", loc="right", fontsize=9, ofst=0.1)
        else:
            d += elm.Line().down(0.5)
            d += elm.Ground().label(f"GND ({HEADER_GND})\nsem resistor", loc="right", fontsize=9, ofst=0.1)

    halt = next(l for l in ligacoes if l["grupo"] == "HALT")
    d += elm.Resistor().at(getattr(placa, halt["sinal"])).tox(X_DS).label(f'{halt["resistor"]}  {OHMS} Ω', loc="top", fontsize=8.5, ofst=0.04)
    d += elm.LED().right().length(2.0).label("LED de HALT (opcional)", loc="bottom", fontsize=9)
    d += elm.Line().right(0.4)
    d += elm.Line().down(0.4)
    d += elm.Ground().label(f"GND ({HEADER_GND_LED})", loc="right", fontsize=9)

    d += elm.Label().at((X_DS / 2 + 1.0, topo + 1.7)).label(
        "Tang Nano 20K: 2 displays de 7 segmentos (DS1 anodo comum, DS2 catodo comum)",
        fontsize=15, halign="center", color=AZUL)

    notas = (
        "DS1 (dezenas) = 5161BS, anodo comum: COM (3 e 8) no 3V3; acende com '0' (ANODO_DEZENA = true).\n"
        "DS2 (unidades) = 5161AS, catodo comum: COM (3 e 8) no GND; acende com '1' (ANODO_UNIDADE = false).\n"
        "NUNCA ligue 5V.   NUNCA ligue um segmento sem resistor (um resistor por segmento, nunca um só no COM).\n"
        "DP (pino 5) fica sem ligação.   Pinagem das pernas: [VALIDAR] com o teste da seção 2 do guia."
    )
    d += elm.Label().at((0, -1.0)).label(notas, fontsize=10, halign="left", valign="top", color=VERMELHO)

    figura = d.draw(show=False)
    caixa = d.get_bbox()
    figura.fig.set_size_inches(
        ESCALA * (caixa.xmax - caixa.xmin + 0.2), ESCALA * (caixa.ymax - caixa.ymin + 0.2))
    d.fig.fig.savefig(saida_svg, metadata={"Date": None}, bbox_inches="tight")
    d.fig.fig.savefig(saida_png, dpi=DPI, bbox_inches="tight", facecolor="white")
    plt.close(d.fig.fig)


def desenhar_pinagem(saida_svg, saida_png):
    fig, ax = plt.subplots(figsize=(9, 7.4))
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-1.2, 12.4)
    ax.set_ylim(-1.6, 10.2)

    corpo = Rectangle((0, 1.6), 5, 6.4, fc="#f4f4f4", ec="#222222", lw=2)
    ax.add_patch(corpo)

    esp = 0.4
    x0, x1 = 1.0, 3.8
    ya, yg, yd = 7.0, 4.8, 2.6
    def horizontal(yc):
        return [(x0 + esp * 0.7, yc), (x0 + esp * 1.2, yc + esp / 2), (x1 - esp * 1.2, yc + esp / 2),
                (x1 - esp * 0.7, yc), (x1 - esp * 1.2, yc - esp / 2), (x0 + esp * 1.2, yc - esp / 2)]
    def vertical(xc, y_ini, y_fim):
        return [(xc, y_fim - esp * 0.7), (xc + esp / 2, y_fim - esp * 1.2), (xc + esp / 2, y_ini + esp * 1.2),
                (xc, y_ini + esp * 0.7), (xc - esp / 2, y_ini + esp * 1.2), (xc - esp / 2, y_fim - esp * 1.2)]
    forma = {
        "a": (horizontal(ya), (2.4, ya)),
        "g": (horizontal(yg), (2.4, yg)),
        "d": (horizontal(yd), (2.4, yd)),
        "f": (vertical(x0, yg, ya), (x0, (yg + ya) / 2)),
        "b": (vertical(x1, yg, ya), (x1, (yg + ya) / 2)),
        "e": (vertical(x0, yd, yg), (x0, (yd + yg) / 2)),
        "c": (vertical(x1, yd, yg), (x1, (yd + yg) / 2)),
    }
    for letra, (pontos, centro) in forma.items():
        ax.add_patch(Polygon(pontos, closed=True, fc=VERMELHO, ec="#7a1712", lw=1))
        ax.text(*centro, letra, color="white", ha="center", va="center", fontsize=15, fontweight="bold")
    ax.add_patch(Circle((4.45, 2.6), 0.2, fc=CINZA, ec="#222222"))
    ax.text(4.45, 3.15, "DP", color=CINZA, ha="center", va="center", fontsize=10, fontweight="bold")

    superior = [(10, "g"), (9, "f"), (8, "COM"), (7, "a"), (6, "b")]
    inferior = [(1, "e"), (2, "d"), (3, "COM"), (4, "c"), (5, "DP")]
    for i, (num, func) in enumerate(superior):
        x = 0.5 + i
        cor = AZUL if func == "COM" else "#222222"
        ax.plot([x, x], [8.0, 8.55], color="#222222", lw=2.5)
        ax.add_patch(Circle((x, 8.7), 0.17, fc="white", ec=cor, lw=1.5))
        ax.text(x, 9.35, f"{num}", ha="center", va="center", fontsize=14, fontweight="bold", color=cor)
        ax.text(x, 9.85, f"({func})", ha="center", va="center", fontsize=11, color=cor)
    for i, (num, func) in enumerate(inferior):
        x = 0.5 + i
        cor = AZUL if func == "COM" else "#222222"
        ax.plot([x, x], [1.6, 1.05], color="#222222", lw=2.5)
        ax.add_patch(Circle((x, 0.9), 0.17, fc="white", ec=cor, lw=1.5))
        ax.text(x, 0.25, f"{num}", ha="center", va="center", fontsize=14, fontweight="bold", color=cor)
        ax.text(x, -0.3, f"({func})", ha="center", va="center", fontsize=11, color=cor)

    ax.text(2.5, -1.1, "Vista de frente (ponto decimal embaixo, à direita)", ha="center", fontsize=10, color=CINZA)

    texto = (
        "Display 5161, 10 pinos\n\n"
        "Fileira de cima (esq. para dir.):\n"
        "   10 = g   9 = f   8 = COM   7 = a   6 = b\n"
        "Fileira de baixo (esq. para dir.):\n"
        "   1 = e   2 = d   3 = COM   4 = c   5 = DP\n\n"
        "Os pinos 3 e 8 (COM) são ligados\n"
        "por dentro: use qualquer um deles.\n\n"
        "5161BS = anodo comum (DS1, dezenas)\n"
        "5161AS = catodo comum (DS2, unidades)\n\n"
        "[VALIDAR] Pinagem padrão da família 5161.\n"
        "Confirme com o teste da seção 2 do guia\n"
        "(resistor de 330 Ω entre COM e 3V3/GND)."
    )
    ax.text(6.2, 9.8, texto, ha="left", va="top", fontsize=11, linespacing=1.5,
            bbox=dict(boxstyle="round,pad=0.6", fc="#fbfbf4", ec=CINZA))
    ax.set_title("Pinagem do display de 7 segmentos 5161 (vista frontal)", fontsize=14, color=AZUL, pad=8)
    fig.savefig(saida_svg, metadata={"Date": None}, bbox_inches="tight")
    fig.savefig(saida_png, dpi=DPI, bbox_inches="tight", facecolor="white")
    plt.close(fig)


def principal():
    achados = ler_pinout(CST)
    ligacoes = montar_ligacoes(achados)
    imprimir_tabela(ligacoes)
    plt.rcParams["svg.hashsalt"] = "esquematico"
    desenhar_esquematico(ligacoes, AQUI / "esquematico_displays.svg", AQUI / "esquematico_displays.png")
    desenhar_pinagem(AQUI / "pinagem_display.svg", AQUI / "pinagem_display.png")
    print("Gerados: esquematico_displays.svg/.png, pinagem_display.svg/.png em " + str(AQUI))
    erros = conferir_guia(ligacoes, GUIA)
    if erros:
        print("CONFERÊNCIA COM O GUIA: FALHOU", file=sys.stderr)
        for e in erros:
            print("  - " + e, file=sys.stderr)
        sys.exit(2)
    print("CONFERÊNCIA COM O GUIA: OK (14 segmentos + comum batem com a seção 3)")


if __name__ == "__main__":
    principal()
