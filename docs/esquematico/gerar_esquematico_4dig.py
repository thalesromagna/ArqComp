import argparse
import re
import sys
from itertools import pairwise
from pathlib import Path

import matplotlib

matplotlib.use("Agg")

AQUI = Path(__file__).resolve().parent
sys.path.insert(0, str(AQUI))

import matplotlib.pyplot as plt
import schemdraw
import schemdraw.elements as elm
from gerar_esquematico import (
    AZUL,
    BIT,
    CINZA,
    DPI,
    ESCALA,
    HEADER,
    OHMS,
    SEGMENTOS,
    VERMELHO,
    abortar,
    ler_pinout,
    pino_placa,
)
from matplotlib.patches import Circle, Polygon, Rectangle

RAIZ = AQUI.parents[1]
CST_PADRAO = Path("fpga") / "tang_nano_20k" / "src" / "pinout_4dig.cst"
GUIA = RAIZ / "docs" / "fpga-tang-nano-20k.md"
NUM_SECAO = 9
SECAO_GUIA = f"## {NUM_SECAO}. Variante: display de 4 dígitos (5641AS)"

PINO_5641 = {
    "a": 11, "b": 7, "c": 4, "d": 2, "e": 1, "f": 10, "g": 5, "DP": 3,
    "DIG1": 12, "DIG2": 9, "DIG3": 8, "DIG4": 6,
}
DIGITOS = (("DIG3", 1, "dezenas"), ("DIG4", 0, "unidades"))
NAO_CONECTADOS = ("DIG1", "DIG2", "DP")
HEADER_GND_LED = "E20"


def resistores_de(letra: str) -> tuple[str, str]:
    i = SEGMENTOS.index(letra)
    return f"R{2 * i + 1}", f"R{2 * i + 2}"


def montar_ligacoes(achados: dict) -> list[dict]:
    faltando = []
    ligacoes = []
    for letra in SEGMENTOS:
        chave = ("seg", BIT[letra])
        if chave not in achados:
            faltando.append(f"seg[{BIT[letra]}]")
            continue
        ligacoes.append({
            "tipo": "seg", "nome": letra, "sinal": f"seg[{BIT[letra]}]", "pino": achados[chave],
            "resistores": resistores_de(letra), "pino_display": PINO_5641[letra],
        })
    for dig, indice, funcao in DIGITOS:
        chave = ("dig", indice)
        if chave not in achados:
            faltando.append(f"dig[{indice}]")
            continue
        ligacoes.append({
            "tipo": "dig", "nome": dig, "sinal": f"dig[{indice}]", "pino": achados[chave],
            "resistores": (), "pino_display": PINO_5641[dig], "funcao": funcao,
        })
    if ("halted", None) not in achados:
        faltando.append("halted")
    if faltando:
        abortar("sinais não encontrados no cst: " + ", ".join(faltando))
    ligacoes.append({
        "tipo": "halt", "nome": "HALT", "sinal": "halted", "pino": achados[("halted", None)],
        "resistores": (f"R{2 * len(SEGMENTOS) + 1}",), "pino_display": None,
    })
    for l in ligacoes:
        if l["pino"] not in HEADER:
            abortar(f'pino {l["pino"]} ({l["sinal"]}) sem posição no header')
        l["header"] = HEADER[l["pino"]]
    pinos = [l["pino"] for l in ligacoes]
    repetidos = sorted({p for p in pinos if pinos.count(p) > 1})
    if repetidos:
        abortar(f"pinos repetidos: {repetidos}")
    return ligacoes


def texto_resistores(l: dict) -> str:
    if l["tipo"] == "seg":
        return f'{l["resistores"][0]} + {l["resistores"][1]} (2 x {OHMS} Ω)'
    if l["tipo"] == "dig":
        return "sem resistor"
    return f'{l["resistores"][0]} {OHMS} Ω'


def imprimir_tabela(ligacoes: list[dict]) -> None:
    cab = ("sinal", "pino FPGA", "header", "resistores", "pino do display")
    linhas = [cab]
    for l in ligacoes:
        if l["tipo"] == "halt":
            destino = f"LED + GND ({HEADER_GND_LED})"
            rotulo = "halted (LED)"
        else:
            destino = f'5641AS pino {l["pino_display"]}'
            rotulo = f'{l["nome"]} ({l["sinal"]})'
        linhas.append((rotulo, str(l["pino"]), l["header"], texto_resistores(l), destino))
    larg = [max(len(r[i]) for r in linhas) for i in range(len(cab))]
    for i, r in enumerate(linhas):
        print("  ".join(c.ljust(larg[j]) for j, c in enumerate(r)))
        if i == 0:
            print("  ".join("-" * w for w in larg))
    nc = ", ".join(f"{n} (pino {PINO_5641[n]})" for n in NAO_CONECTADOS)
    print(f"Sem ligação: {nc}. O display não usa 3V3.")


def conferir_guia(ligacoes: list[dict], caminho: Path) -> list[str]:
    if not caminho.is_file():
        return [f"guia não encontrado em {caminho}"]
    texto = caminho.read_text(encoding="utf-8")
    m = re.search(re.escape(SECAO_GUIA) + r"\n(.*?)(?=\n## |\Z)", texto, re.DOTALL)
    if not m:
        return [f'seção "{SECAO_GUIA}" não encontrada no guia']
    trecho = m.group(1)
    seg_re = re.compile(
        r"^\|\s*([a-g])\s*\(`?seg\[(\d)\]`?\)\s*\|\s*(\d+)\s*\|\s*([ED]\d+)\s*\|"
        r"\s*(R\d+)\s*\+\s*(R\d+)\s*\(2 x 330\)\s*\|\s*(\d+)\s*\|$"
    )
    dig_re = re.compile(
        r"^\|\s*(DIG\d)[^|]*\(`?dig\[(\d)\]`?\)\s*\|\s*(\d+)\s*\|\s*([ED]\d+)\s*\|\s*sem resistor\s*\|\s*(\d+)\s*\|$"
    )
    halt_re = re.compile(r"^\|\s*HALT[^|]*\|\s*(\d+)\s*\|\s*([ED]\d+)\s*\|\s*(R\d+)\s+330\s*\|\s*[^|]*GND \((E\d+)\)[^|]*\|$")
    no_guia = {}
    for linha in trecho.splitlines():
        linha = linha.strip()
        if (s := seg_re.match(linha)):
            no_guia[s.group(1)] = (f"seg[{s.group(2)}]", int(s.group(3)), s.group(4), (s.group(5), s.group(6)), int(s.group(7)))
        elif (s := dig_re.match(linha)):
            no_guia[s.group(1)] = (f"dig[{s.group(2)}]", int(s.group(3)), s.group(4), (), int(s.group(5)))
        elif (s := halt_re.match(linha)):
            no_guia["HALT"] = ("halted", int(s.group(1)), s.group(2), (s.group(3),), s.group(4))
    erros = []
    for l in ligacoes:
        destino = HEADER_GND_LED if l["tipo"] == "halt" else l["pino_display"]
        esperado = (l["sinal"], l["pino"], l["header"], tuple(l["resistores"]), destino)
        if no_guia.get(l["nome"]) != esperado:
            erros.append(f'{l["nome"]}: guia={no_guia.get(l["nome"])} esperado={esperado}')
    return erros


def desenhar_esquematico(ligacoes: list[dict], saida_svg: Path, saida_png: Path) -> None:
    P = 1.4
    N = 12
    LARG_PLACA = 5.8
    LEAD = 0.5
    L_RES = 2.3
    X_DS = LARG_PLACA + LEAD + 2 * L_RES + 2.3
    H = 0.6
    L_LED = 1.7
    topo = N * P
    linha_de = {"DIG3": 8, "DIG4": 9, "HALT": 11}
    for i, letra in enumerate(SEGMENTOS):
        linha_de[letra] = i

    def y_linha(r: int) -> float:
        return topo - P / 2 - r * P

    x_anodo = {"DIG3": X_DS + 1.1}
    x_catodo = {"DIG3": x_anodo["DIG3"] + L_LED}
    x_anodo["DIG4"] = x_catodo["DIG3"] + 1.1
    x_catodo["DIG4"] = x_anodo["DIG4"] + L_LED
    x_dir = x_catodo["DIG4"] + 1.2
    y_topo_ds = y_linha(0) + 1.5
    y_base_ds = y_linha(6) - H - 0.85

    pinos_placa = []
    for l in ligacoes:
        if l["tipo"] == "seg" or l["tipo"] == "dig":
            nome = f'{l["nome"]} = {l["sinal"]} — pino {l["pino"]} ({l["header"]})'
        else:
            nome = f'HALT = halted — pino {l["pino"]} ({l["header"]})'
        r = linha_de[l["nome"]]
        pinos_placa.append(pino_placa(nome, "right", f"{N - r}/{N}", f'p_{l["nome"]}'))

    d = schemdraw.Drawing(show=False)
    d.config(fontsize=9, lw=1.3)
    placa = elm.Ic(size=(LARG_PLACA, topo), pinspacing=P, pins=pinos_placa, leadlen=LEAD, lsize=9.5)
    d += placa.at((0, 0))
    d += elm.Label().at((LARG_PLACA / 2, topo + 0.25)).label(
        "Tang Nano 20K (FPGA GW2AR-18)", fontsize=13, halign="center", valign="bottom", color=AZUL)

    cantos = [(X_DS, y_base_ds), (x_dir, y_base_ds), (x_dir, y_topo_ds), (X_DS, y_topo_ds), (X_DS, y_base_ds)]
    for c0, c1 in pairwise(cantos):
        d += elm.Line().at(c0).to(c1)
    d += elm.Label().at((X_DS, y_topo_ds + 0.3)).label(
        "DS1 = 5641AS, 4 dígitos, catodo comum (multiplexado)\n"
        "segmento acende com o seu pino em '1' e o pino do dígito em '0'",
        fontsize=11, halign="left", valign="bottom", color=AZUL)
    for dig, _, funcao in DIGITOS:
        xc = (x_anodo[dig] + x_catodo[dig]) / 2
        d += elm.Label().at((xc, y_topo_ds - 0.2)).label(
            f"{dig} = {funcao}", fontsize=10, halign="center", valign="top", color=AZUL)

    for letra in SEGMENTOS:
        l = next(x for x in ligacoes if x["nome"] == letra)
        y = y_linha(linha_de[letra])
        ini = getattr(placa, f"p_{letra}")
        r1, r2 = l["resistores"]
        d += elm.Resistor().at(ini).right(L_RES).label(f"{r1}  {OHMS} Ω", loc="top", fontsize=8.5, ofst=0.04)
        d += elm.Resistor().right(L_RES).label(f"{r2}  {OHMS} Ω", loc="top", fontsize=8.5, ofst=0.04)
        d += elm.Line().tox(X_DS)
        d += elm.Label().at((X_DS - 0.2, y - 0.1)).label(
            f"{letra} (pino {PINO_5641[letra]})", fontsize=9, halign="right", valign="top", color=CINZA)
        d += elm.Line().at((X_DS, y)).tox(x_anodo["DIG4"])
        for dig, _, _ in DIGITOS:
            xa, xk = x_anodo[dig], x_catodo[dig]
            d += elm.Dot().at((xa, y))
            d += elm.Line().at((xa, y)).to((xa, y - H))
            d += elm.Diode().at((xa, y - H)).to((xk, y - H))
            xm = (xa + xk) / 2
            for deslocamento in (0.0, 0.17):
                d += elm.Arrow().at((xm + deslocamento - 0.02, y - H - 0.3)).to(
                    (xm + deslocamento + 0.14, y - H - 0.5)).linewidth(1.0)
            d += elm.Dot().at((xk, y - H))

    for dig, _, _ in DIGITOS:
        l = next(x for x in ligacoes if x["nome"] == dig)
        y_fio = y_linha(linha_de[dig])
        xk = x_catodo[dig]
        d += elm.Line().at((xk, y_linha(0) - H)).to((xk, y_fio))
        d += elm.Line().at(getattr(placa, f"p_{dig}")).tox(xk)
        d += elm.Label().at((xk + 0.15, y_base_ds - 0.15)).label(
            f"pino {l['pino_display']}", fontsize=9, halign="left", valign="top", color=AZUL)
        d += elm.Label().at((LARG_PLACA + LEAD + L_RES, y_fio + 0.08)).label(
            f"{dig} (pino {l['pino_display']} do display): direto, sem resistor",
            fontsize=9, halign="center", valign="bottom", color=AZUL)

    for nome, r in zip(NAO_CONECTADOS, (1, 3, 5)):
        y = y_linha(r)
        d += elm.Line().at((x_dir, y)).right(0.6).dot(open=True)
        d += elm.Label().at((x_dir + 0.8, y)).label(
            f"{nome} (pino {PINO_5641[nome]}): não conectado", fontsize=9, halign="left", valign="center", color=CINZA)

    halt = next(l for l in ligacoes if l["tipo"] == "halt")
    d += elm.Resistor().at(placa.p_HALT).right(L_RES).label(
        f'{halt["resistores"][0]}  {OHMS} Ω', loc="top", fontsize=8.5, ofst=0.04)
    d += elm.Line().tox(X_DS)
    d += elm.LED().right().length(2.0).label("LED de HALT (opcional)", loc="bottom", fontsize=9)
    d += elm.Line().right(0.4)
    d += elm.Line().down(0.4)
    d += elm.Ground().label(f"GND ({HEADER_GND_LED})", loc="right", fontsize=9)

    d += elm.Label().at(((x_dir + 3.0) / 2, topo + 2.6)).label(
        "Tang Nano 20K: display de 4 dígitos 5641AS (catodo comum, multiplexado)",
        fontsize=15, halign="center", color=AZUL)

    notas = (
        "Os 4 dígitos compartilham os 7 segmentos (anodos); cada dígito tem o seu catodo (DIG1 a DIG4). Só DIG3 e DIG4 são usados.\n"
        "Segmento aceso = pino do segmento em '1' e pino do dígito em '0'. A FPGA alterna DIG3 e DIG4 a cada 0,5 ms (1 kHz cada).\n"
        "2 x 330 Ω em série por segmento (660 Ω): (3,3 - 1,9) / 660 ≈ 2,1 mA por segmento; até ≈ 15 mA no pino do dígito (DRIVE=16).\n"
        "NUNCA um só resistor de 330 Ω por segmento (o pico no pino do dígito passaria de 29 mA).   NUNCA 5V.   O display não usa 3V3.\n"
        "LEDs 0 a 5 da placa (pinos 15 a 20) piscam ou brilham fraco com o complemento dos segmentos: é esperado.\n"
        "DIG1 (12), DIG2 (9) e DP (3) sem ligação.   Linhas que se cruzam sem ponto não estão ligadas.\n"
        f"Pinagem das pernas: [VALIDAR] com o teste da seção {NUM_SECAO} do guia."
    )
    d += elm.Label().at((0, -1.0)).label(notas, fontsize=10, halign="left", valign="top", color=VERMELHO)

    figura = d.draw(show=False)
    caixa = d.get_bbox()
    figura.fig.set_size_inches(
        ESCALA * (caixa.xmax - caixa.xmin + 0.2), ESCALA * (caixa.ymax - caixa.ymin + 0.2))
    d.fig.fig.savefig(saida_svg, metadata={"Date": None}, bbox_inches="tight")
    d.fig.fig.savefig(saida_png, dpi=DPI, bbox_inches="tight", facecolor="white")
    plt.close(d.fig.fig)


def desenhar_pinagem(saida_svg: Path, saida_png: Path) -> None:
    fig, ax = plt.subplots(figsize=(16, 7.6))
    ax.set_aspect("equal")
    ax.axis("off")
    ax.set_xlim(-0.8, 21.6)
    ax.set_ylim(-1.6, 10.4)

    largura = 11.6
    ax.add_patch(Rectangle((0, 1.6), largura, 6.4, fc="#f4f4f4", ec="#222222", lw=2))

    esp = 0.32
    ya, yg, yd = 6.6, 4.6, 2.6
    usados = {"DIG3": "dezenas", "DIG4": "unidades"}

    def horizontal(x0: float, x1: float, yc: float) -> list:
        return [(x0 + esp * 0.7, yc), (x0 + esp * 1.2, yc + esp / 2), (x1 - esp * 1.2, yc + esp / 2),
                (x1 - esp * 0.7, yc), (x1 - esp * 1.2, yc - esp / 2), (x0 + esp * 1.2, yc - esp / 2)]

    def vertical(xc: float, y_ini: float, y_fim: float) -> list:
        return [(xc, y_fim - esp * 0.7), (xc + esp / 2, y_fim - esp * 1.2), (xc + esp / 2, y_ini + esp * 1.2),
                (xc, y_ini + esp * 0.7), (xc - esp / 2, y_ini + esp * 1.2), (xc - esp / 2, y_fim - esp * 1.2)]

    for k in range(4):
        dig = f"DIG{k + 1}"
        x0 = 0.75 + k * 2.75
        x1 = x0 + 1.75
        ativo = dig in usados
        preench = VERMELHO if ativo else "#e6c4c1"
        borda = "#7a1712" if ativo else "#b08a87"
        forma = {
            "a": (horizontal(x0, x1, ya), ((x0 + x1) / 2, ya)),
            "g": (horizontal(x0, x1, yg), ((x0 + x1) / 2, yg)),
            "d": (horizontal(x0, x1, yd), ((x0 + x1) / 2, yd)),
            "f": (vertical(x0, yg, ya), (x0, (yg + ya) / 2)),
            "b": (vertical(x1, yg, ya), (x1, (yg + ya) / 2)),
            "e": (vertical(x0, yd, yg), (x0, (yd + yg) / 2)),
            "c": (vertical(x1, yd, yg), (x1, (yd + yg) / 2)),
        }
        for letra, (pontos, centro) in forma.items():
            ax.add_patch(Polygon(pontos, closed=True, fc=preench, ec=borda, lw=1))
            ax.text(*centro, letra, color="white", ha="center", va="center", fontsize=11, fontweight="bold")
        ax.add_patch(Circle((x1 + 0.5, yd), 0.15, fc=CINZA, ec="#222222"))
        rotulo = f"{dig}\n({usados[dig]})" if ativo else f"{dig}\n(sem uso)"
        ax.text((x0 + x1) / 2, 7.4, rotulo, ha="center", va="center", fontsize=10,
                fontweight="bold" if ativo else "normal", color=AZUL if ativo else CINZA)

    superior = [(12, "DIG1"), (11, "a"), (10, "f"), (9, "DIG2"), (8, "DIG3"), (7, "b")]
    inferior = [(1, "e"), (2, "d"), (3, "DP"), (4, "c"), (5, "g"), (6, "DIG4")]
    passo = largura / 6

    def cor_de(func: str) -> str:
        if func in usados:
            return AZUL
        if func in NAO_CONECTADOS:
            return CINZA
        return "#222222"

    for fileira, y_corpo, y_ponta, y_bola, y_num, y_func in (
        (superior, 8.0, 8.55, 8.7, 9.35, 9.85),
        (inferior, 1.6, 1.05, 0.9, 0.25, -0.3),
    ):
        for i, (num, func) in enumerate(fileira):
            x = passo / 2 + i * passo
            cor = cor_de(func)
            texto_func = f"({func}, n.c.)" if func in NAO_CONECTADOS else f"({func})"
            ax.plot([x, x], [y_corpo, y_ponta], color="#222222", lw=2.5)
            ax.add_patch(Circle((x, y_bola), 0.17, fc="white", ec=cor, lw=1.5))
            ax.text(x, y_num, f"{num}", ha="center", va="center", fontsize=14, fontweight="bold", color=cor)
            ax.text(x, y_func, texto_func, ha="center", va="center", fontsize=11, color=cor)

    ax.text(largura / 2, -1.1, "Vista de frente (pontos decimais embaixo). n.c. = não conectado",
            ha="center", fontsize=10, color=CINZA)

    texto = (
        "Display 5641AS: 4 dígitos, 12 pinos,\n"
        "catodo comum, multiplexado\n\n"
        "Fileira de cima (esq. para dir.):\n"
        "   12 = DIG1   11 = a   10 = f\n"
        "   9 = DIG2   8 = DIG3   7 = b\n"
        "Fileira de baixo (esq. para dir.):\n"
        "   1 = e   2 = d   3 = DP\n"
        "   4 = c   5 = g   6 = DIG4\n\n"
        "Os segmentos a..g e o DP são comuns aos\n"
        "4 dígitos; DIGn é o catodo do dígito n.\n"
        "Usados: DIG3 (dezenas) e DIG4 (unidades).\n"
        "Sem ligação: DIG1, DIG2 e DP.\n\n"
        "[VALIDAR] Pinagem padrão do 5641AS.\n"
        f"Confirme com o teste da seção {NUM_SECAO} do guia\n"
        "(330 Ω do 3V3 no segmento, dígito no GND)."
    )
    ax.text(12.6, 9.9, texto, ha="left", va="top", fontsize=11, linespacing=1.45,
            bbox={"boxstyle": "round,pad=0.6", "fc": "#fbfbf4", "ec": CINZA})
    ax.set_title("Pinagem do display de 4 dígitos 5641AS (vista frontal)", fontsize=14, color=AZUL, pad=8)
    fig.savefig(saida_svg, metadata={"Date": None}, bbox_inches="tight")
    fig.savefig(saida_png, dpi=DPI, bbox_inches="tight", facecolor="white")
    plt.close(fig)


def principal() -> None:
    parser = argparse.ArgumentParser(description="Esquemático do display de 4 dígitos 5641AS na Tang Nano 20K")
    parser.add_argument("--cst", type=Path, default=RAIZ / CST_PADRAO,
                        help=f"arquivo de pinos (padrão: {CST_PADRAO})")
    args = parser.parse_args()
    if not args.cst.is_file():
        abortar(f"cst não encontrado em {args.cst}")
    ligacoes = montar_ligacoes(ler_pinout(args.cst))
    imprimir_tabela(ligacoes)
    plt.rcParams["svg.hashsalt"] = "esquematico_4dig"
    desenhar_esquematico(ligacoes, AQUI / "esquematico_4dig.svg", AQUI / "esquematico_4dig.png")
    desenhar_pinagem(AQUI / "pinagem_5641.svg", AQUI / "pinagem_5641.png")
    print("Gerados: esquematico_4dig.svg/.png, pinagem_5641.svg/.png em " + str(AQUI))
    erros = conferir_guia(ligacoes, GUIA)
    if erros:
        print("CONFERÊNCIA COM O GUIA: FALHOU", file=sys.stderr)
        for e in erros:
            print("  - " + e, file=sys.stderr)
        sys.exit(2)
    print(f"CONFERÊNCIA COM O GUIA: OK (7 segmentos + 2 dígitos + HALT batem com a seção {NUM_SECAO})")


if __name__ == "__main__":
    principal()
