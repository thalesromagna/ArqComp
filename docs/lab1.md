# Lab 1 — Tutorial de Introdução ao VHDL (µProcessador 1)

Roteiro: `PDF dos labs/uprocessador 1 v6.3.pdf` ("µProcessador 1 Tutorial de Introdução ao VHDL").
Diretório: `lab1/`.

O próprio roteiro diz, na seção "Entrega/Apresentação" (p. 5): "Este laboratório não precisa ser entregue
nem apresentado ao professor". Os drills são "É necessário fazer, não é necessário entregar, não vale nota"
(seção "Drills (Exercícios de Fixação)", p. 5). Mesmo assim foram feitos, pois o método é reaproveitado nos
laboratórios seguintes.

## 1. O que o lab pede

1. Digitar e simular a porta AND do tutorial (`porta.vhd`) e seu testbench (`porta_tb.vhd`), seções
   "Básico: Uma Porta Lógica" e "Arquivo de Simulação" (p. 1 a 3).
2. Drill 1: "Projete e simule um decoder 2x4. Faça a tabela verdade, extraia as expressões lógicas e daí
   sintetize o código VHDL. Teste." (p. 5).
3. Drill 2: "Projete e simule um detector de paridade de 3 bits de entrada, ou seja, se houver número ímpar
   de bits em 1, o resultado é 1; caso contrário a saída é 0." (p. 5).

O roteiro também pede, só para os drills, "construa o testbench antes de construir a arquitetura" (p. 5).
Foi o que fizemos: a tabela verdade de cada drill (abaixo) foi escrita primeiro, depois o testbench que
percorre todas as linhas dela e só então a arquitetura.

## 2. Arquivos

| Arquivo | Conteúdo |
|---|---|
| `lab1/porta.vhd` | porta AND de 2 entradas (código do roteiro) |
| `lab1/porta_tb.vhd` | testbench da porta (código do roteiro) |
| `lab1/decoder2x4.vhd` | decoder 2x4 |
| `lab1/decoder2x4_tb.vhd` | testbench do decoder |
| `lab1/paridade3.vhd` | detector de paridade ímpar de 3 bits |
| `lab1/paridade3_tb.vhd` | testbench do detector de paridade |
| `lab1/run.sh` | compila e simula os três testbenches |

Todo o VHDL usa apenas o que aparece no roteiro: `library ieee; use ieee.std_logic_1164.all;`,
`entity`/`architecture`, `std_logic`, atribuição concorrente `<=`, `and`, `or`, `not`, `component` +
`port map`, e no testbench `process`, `wait for ... ns` e `wait;` ("O process deve terminar com um wait;
sem tempo", p. 3). Não há comentários no código; as explicações estão neste documento.

## 3. Porta AND

Interface (idêntica ao roteiro, p. 1):

| Pino | Direção | Tipo |
|---|---|---|
| `in_a` | in | std_logic |
| `in_b` | in | std_logic |
| `a_e_b` | out | std_logic |

Circuito: `a_e_b <= in_a and in_b;`. O testbench aplica as quatro combinações, 50 ns cada, como no roteiro.

Resultado observado na simulação (valores amostrados no meio de cada intervalo de 50 ns):

| t (ns) | in_a | in_b | a_e_b |
|---|---|---|---|
| 0–50 | 0 | 0 | 0 |
| 50–100 | 0 | 1 | 0 |
| 100–150 | 1 | 0 | 0 |
| 150–200 | 1 | 1 | 1 |

## 4. Drill 1 — decoder 2x4

"um decoder 2x4 possui dois bits de seleção (entrada) e vai manter apenas em uma das 4 saídas em nível 1
(ligada), que é aquela selecionada pelos bits de entrada" (p. 5).

Interface:

| Pino | Direção | Tipo | Função |
|---|---|---|---|
| `sel0`, `sel1` | in | std_logic | bits de seleção (`sel1` é o mais significativo) |
| `saida0` .. `saida3` | out | std_logic | uma única saída em 1 |

Tabela verdade:

| sel1 | sel0 | saida3 | saida2 | saida1 | saida0 |
|---|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 | 1 |
| 0 | 1 | 0 | 0 | 1 | 0 |
| 1 | 0 | 0 | 1 | 0 | 0 |
| 1 | 1 | 1 | 0 | 0 | 0 |

Cada saída tem um único 1 na tabela, portanto cada expressão é o próprio mintermo:

```
saida0 = not sel1 and not sel0
saida1 = not sel1 and     sel0
saida2 =     sel1 and not sel0
saida3 =     sel1 and     sel0
```

São quatro linhas concorrentes em `decoder2x4.vhd`, no mesmo estilo do exemplo do roteiro
(`y2 <= x2 and not x3;`, seção "Circuitos Maiores", p. 4). Como lembra o roteiro, "todas as linhas acima
são executadas em paralelo! ... Isto não é um programa" (p. 4).

Resultado observado (saídas escritas como saida3 saida2 saida1 saida0):

| t (ns) | sel1 sel0 | saídas |
|---|---|---|
| 0–50 | 00 | 0001 |
| 50–100 | 01 | 0010 |
| 100–150 | 10 | 0100 |
| 150–200 | 11 | 1000 |

Forma de onda (ASCII):

```
          0    50   100  150  200 ns
sel1   ___________/‾‾‾‾‾‾‾‾‾‾
sel0   ______/‾‾‾‾\____/‾‾‾‾‾
saida0 ‾‾‾‾‾‾\_______________
saida1 ______/‾‾‾‾\__________
saida2 ___________/‾‾‾‾\_____
saida3 ________________/‾‾‾‾‾
```

## 5. Drill 2 — detector de paridade de 3 bits

Interface:

| Pino | Direção | Tipo |
|---|---|---|
| `entr0`, `entr1`, `entr2` | in | std_logic |
| `impar` | out | std_logic |

Tabela verdade ("se houver número ímpar de bits em 1, o resultado é 1", p. 5):

| entr2 | entr1 | entr0 | nº de 1s | impar |
|---|---|---|---|---|
| 0 | 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 1 | 1 |
| 0 | 1 | 0 | 1 | 1 |
| 0 | 1 | 1 | 2 | 0 |
| 1 | 0 | 0 | 1 | 1 |
| 1 | 0 | 1 | 2 | 0 |
| 1 | 1 | 0 | 2 | 0 |
| 1 | 1 | 1 | 3 | 1 |

Expressão extraída da tabela (soma dos quatro mintermos em que `impar = 1`):

```
impar = (not entr2 and not entr1 and     entr0) or
        (not entr2 and     entr1 and not entr0) or
        (    entr2 and not entr1 and not entr0) or
        (    entr2 and     entr1 and     entr0)
```

No mapa de Karnaugh os quatro 1s ficam em diagonal (nenhum par adjacente), então a soma de produtos não
se simplifica. A mesma função é `entr2 xor entr1 xor entr0`; mantivemos a forma em soma de produtos
porque o roteiro pede para "extrair uma expressão lógica" da tabela verdade e o tutorial só apresenta
`and`, `or` e `not`.

Resultado observado:

| t (ns) | entr2 entr1 entr0 | impar |
|---|---|---|
| 0–50 | 000 | 0 |
| 50–100 | 001 | 1 |
| 100–150 | 010 | 1 |
| 150–200 | 011 | 0 |
| 200–250 | 100 | 1 |
| 250–300 | 101 | 0 |
| 300–350 | 110 | 0 |
| 350–400 | 111 | 1 |

## 6. Verificação

Os três testbenches foram compilados e simulados com GHDL 4.1. Os valores das tabelas acima foram lidos do
arquivo de formas de onda gerado pela simulação (amostrados em 25 ns, 75 ns, ... ) e conferidos
automaticamente contra a tabela verdade: todas as 16 amostras (4 da porta, 4 do decoder, 8 da paridade)
bateram com o esperado.

## 7. Como rodar

```
cd lab1
sh run.sh
gtkwave decoder2x4_tb.ghw
```

O `run.sh` faz `ghdl -a` de todos os fontes, `ghdl -e` de cada testbench e `ghdl -r <tb> --wave=<tb>.ghw`,
exatamente os comandos do roteiro (seção "Como Simular", p. 3). Os arquivos `.ghw` e `work-obj*.cf`
gerados não devem ser versionados.
