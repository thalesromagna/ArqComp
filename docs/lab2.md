# Lab 2 — Multiplexação, Barramentos, Números: a ULA (µProcessador 2)

Roteiro: `PDF dos labs/uprocessador 2 (1).pdf` ("µProcessador 2 Multiplexação, Barramentos, Números: a ULA").
Diretório: `lab2/`.

## 1. O que o lab pede

1. Exercício do mux (p. 2): "Construa um multiplexador 8x1 com as restrições: as entradas 0, 1 e 5 estão
   sempre em '0', e as entradas 3 e 7 estão sempre em '1'. Portanto, apenas as entradas 2, 4 e 6 terão
   entradas variáveis, o que dá 3 pinos de dados e 3 pinos de seleção na entidade. Faça um testbench adequado."
2. Exercício de aritmética (p. 4): "Construa um testbench para o circuito soma_e_subtrai e o simule ...
   Não esqueça de testar negativos, como 18+(-3)."
3. Tarefa para entregar (seção "Tarefa para Entregar: ULA", p. 7): a ULA, com
   - "duas entradas de dados de 16 bits";
   - "uma saída de resultado de 16 bits";
   - "duas ou mais saídas de sinalização de um bit (são as flags; implemente apenas as flags indicadas na
     tabela relativas ao seu sorteio)";
   - "entradas para seleção da operação";
   - "No mínimo 4 operações, incluindo: soma; subtração; duas outras quaisquer escolhidas pela equipe";
   - "Um testbench que cobre todas as operações ... incluindo números negativos nas entradas (basta usar
     complemento de 2, com unsigned mesmo)".

Entregáveis da tarefa: `lab2/ula.vhd` e `lab2/ula_tb.vhd` ("Entregue o .vhd e o _tb.vhd", p. 7).

Restrição de VHDL (seção "Avaliação", p. 7): "Você só pode usar o VHDL visto neste PDF e no anterior" e
"se aparecer process e/ou if, a nota será zero". Por isso todos os circuitos deste lab usam só atribuições
concorrentes, `when-else`, `and`, `&`, recorte de bits, `+`, `-` e comparações. `process` aparece apenas
dentro dos testbenches, como no lab 1. Todo `when-else` termina com `else` para zero ("ATENÇÃO: Numa
estrutura when-else sempre termine com else '0';", p. 2). Não há comentários no código.

## 2. Arquivos

| Arquivo | Conteúdo |
|---|---|
| `lab2/mux8x1.vhd`, `lab2/mux8x1_tb.vhd` | mux 8x1 com restrições e testbench |
| `lab2/soma_e_subtrai.vhd`, `lab2/soma_e_subtrai_tb.vhd` | circuito do roteiro (8 bits) e testbench |
| `lab2/ula.vhd`, `lab2/ula_tb.vhd` | ULA de 16 bits (entrega) e testbench |
| `lab2/run.sh` | compila e simula os três testbenches |

## 3. Mux 8x1 com restrições

Interface:

| Pino | Direção | Tipo | Função |
|---|---|---|---|
| `sel0`, `sel1`, `sel2` | in | std_logic | seleção (`sel2` é o MSB) |
| `entr2`, `entr4`, `entr6` | in | std_logic | únicas entradas variáveis |
| `saida` | out | std_logic | entrada selecionada |

Tabela verdade reduzida (no formato da tabela do mux 4x1 do roteiro, p. 1):

| sel2 | sel1 | sel0 | saida |
|---|---|---|---|
| 0 | 0 | 0 | '0' (entrada 0, fixa) |
| 0 | 0 | 1 | '0' (entrada 1, fixa) |
| 0 | 1 | 0 | entr2 |
| 0 | 1 | 1 | '1' (entrada 3, fixa) |
| 1 | 0 | 0 | entr4 |
| 1 | 0 | 1 | '0' (entrada 5, fixa) |
| 1 | 1 | 0 | entr6 |
| 1 | 1 | 1 | '1' (entrada 7, fixa) |

A arquitetura é o `when-else` do mux 4x1 do roteiro (p. 1) estendido para 3 bits de seleção, com as
entradas fixas trocadas pelas constantes `'0'` e `'1'` e terminando em `else '0'`.

Testbench: percorre as 8 seleções duas vezes, a primeira com `entr2=1, entr4=0, entr6=1` e a segunda com
os valores invertidos (`entr2=0, entr4=1, entr6=0`). Assim se vê que só as posições 2, 4 e 6 mudam e as
fixas não.

Resultado observado:

| sel2 sel1 sel0 | saida (entr2,4,6 = 1,0,1) | saida (entr2,4,6 = 0,1,0) |
|---|---|---|
| 000 | 0 | 0 |
| 001 | 0 | 0 |
| 010 | 1 | 0 |
| 011 | 1 | 1 |
| 100 | 0 | 1 |
| 101 | 0 | 0 |
| 110 | 1 | 0 |
| 111 | 1 | 1 |

## 4. soma_e_subtrai

O circuito é o do roteiro (seção "Operações Aritméticas", p. 4), já com as saídas extras `maior` e
`x_negativo` que o próprio roteiro sugere acrescentar:

| Pino | Direção | Tipo |
|---|---|---|
| `x`, `y` | in | unsigned(7 downto 0) |
| `soma`, `subt` | out | unsigned(7 downto 0) |
| `maior`, `x_negativo` | out | std_logic |

```
soma <= x + y;
subt <= x - y;
maior <= '1' when x > y else '0' when x <= y else '0';
x_negativo <= x(7);
```

Casos escolhidos seguindo a orientação do roteiro ("se você testou 3+5, não há necessidade de testar
13+15, mas talvez seja interessante testar 100+100 e 200+200 ... Não esqueça de testar negativos, como
18+(-3)", p. 4). Valores observados na simulação (binário; entre parênteses a leitura sem sinal / com sinal):

| x | y | soma | subt | maior | x_negativo | Observação |
|---|---|---|---|---|---|---|
| 00000011 (3) | 00000101 (5) | 00001000 (8) | 11111110 (254 / −2) | 0 | 0 | caso simples, subt negativa |
| 01100100 (100) | 01100100 (100) | 11001000 (200 / −56) | 00000000 | 0 | 0 | 100+100 cabe sem sinal, mas não com sinal |
| 11001000 (200) | 11001000 (200) | 10010000 (144) | 00000000 | 0 | 1 | 200+200 = 400 perde o 9º bit |
| 00010010 (18) | 11111101 (−3) | 00001111 (15) | 00010101 (21) | 0 | 0 | 18+(−3) = 15; `maior` = 0 pois 18 < 253 sem sinal |
| 11001000 (200) | 01100100 (100) | 00101100 (44) | 01100100 (100) | 1 | 1 | exemplo da seção "Flags" (200+100) |
| 11111011 (−5) | 11111101 (−3) | 11111000 (−8) | 11111110 (−2) | 0 | 1 | dois negativos |
| 00000000 | 00000000 | 00000000 | 00000000 | 0 | 0 | zeros |
| 11111111 (255) | 00000001 (1) | 00000000 | 11111110 (254) | 1 | 1 | 255+1 dá a volta |

Os casos com 18+(−3) e 18 > −3 mostram o que o roteiro avisa: "A comparação acima também só aceita
números positivos (pois x e y são unsigned)" (p. 4). A soma e a subtração, por outro lado, dão o
resultado certo em complemento de 2, porque "para soma e subtração, podemos representar negativos em
complemento de 2 usando este unsigned mesmo" (nota de rodapé 4, p. 3).

## 5. A ULA

### 5.1 Interface

Esta interface é a definitiva do projeto; os labs 3 a 7 reutilizam `ula.vhd` sem alteração.

```
entity ula is
    port( A, B     : in  unsigned(15 downto 0);
          carry_in : in  std_logic;
          controle : in  unsigned(1 downto 0);
          ULA_Out  : out unsigned(15 downto 0);
          zero, carry, overflow, sinal : out std_logic
    );
end entity;
```

| Pino | Largura | Função |
|---|---|---|
| `A`, `B` | 16 | operandos ("duas entradas de dados de 16 bits") |
| `carry_in` | 1 | carry/borrow de entrada, usado só pelo SUBB (virá do flip-flop da flag C a partir do lab 6) |
| `controle` | 2 | seleção da operação ("entradas para seleção da operação") |
| `ULA_Out` | 16 | resultado ("uma saída de resultado de 16 bits") |
| `zero`, `sinal`, `carry`, `overflow` | 1 cada | flags Z, N, C e V |

### 5.2 Operações

| controle | Operação | Uso no processador |
|---|---|---|
| 00 | `A + B` | ADD |
| 01 | `A - B` | SUB, CMPR, CMPI |
| 10 | `A - B - carry_in` | SUBB |
| 11 | `A and B` bit a bit | operação extra escolhida pela equipe |
| outro (X, U ...) | `0000000000000000` | "else zero" |

Soma e subtração são obrigatórias (p. 7). As "duas outras quaisquer escolhidas pela equipe" são:

- **subtração com borrow**: não é escolha livre, é consequência do sorteio ("Tanto SUB sem borrow quanto
  SUBB com borrow estão presentes", email 2, ver `docs/00-especificacoes.md`). O documento *Características
  do Projeto do µP*, seção 4.3 (p. 4), define: "SUBB R1,R2 irá realizar R1 ← R1 − R2 − Cf. O propósito
  disto é fazer operações com mais bits do que um registrador tem disponível, cascateando subtrações."
  Colocá-la já na ULA evita alterar a interface nos labs seguintes.
- **AND bit a bit**: escolha da equipe. É a operação lógica mais simples; o livro (Patterson & Hennessy,
  *Computer Organization and Design RISC-V Edition*, Apêndice A, seção A.5 "Constructing a Basic Arithmetic
  Logic Unit", p. A-26) descreve a ULA como "the device that performs the arithmetic operations like
  addition and subtraction or logical operations like AND and OR", e a tabela de controle da Figura A.5.13
  (p. A-35) tem AND, OR, add e subtract. Nenhuma instrução do nosso conjunto usa AND hoje; ela fica
  disponível para a validação (lab 7), que "poderá exigir operações especiais sorteadas" (p. 7).

Não há divisão, como pede o roteiro ("não implemente divisão", p. 7).

### 5.3 Circuito

"Ou seja, tem que fazer as operações e botar um mux na saída. É assim que se faz." (p. 7). O circuito
segue exatamente isso:

```
            A ─┬──────────────┬───────────────┬──────────┐
            B ─┼─┬────────────┼─┬─────────────┼─┬────────┼─┐
               │ │            │ │  carry_in ─┐│ │        │ │
             ['0'&A]+['0'&B] ['0'&A]-['0'&B] ['0'&A]-['0'&B]-cin   A and B
                 │ soma_17       │ subt_17         │ subt_borrow_17   │
                 │(15..0)        │(15..0)          │(15..0)           │
                 └──────┐  ┌─────┘   ┌─────────────┘   ┌──────────────┘
                       00  01        10                11
                      ┌──────────────────────────────────┐
         controle ───>│          mux 4x1 (16 bits)        │── resultado ──> ULA_Out
                      └──────────────────────────────────┘
                                                   │
          zero  = (resultado = 0)       sinal = resultado(15)
          carry = bit 16 da operação escolhida (0 no AND)
          overflow = regra de sinais (abaixo)
```

As três contas aritméticas são feitas com 17 bits, como na seção "Detecção de Estouro (Carry)" do
roteiro *µProcessador 6* (p. 1 e 2):

```
in_a_17 <= '0' & in_a;      -- passamos in_a para 17 bits
in_b_17 <= '0' & in_b;      -- idem in_b
soma_17 <= in_a_17+in_b_17;
carry_soma <= soma_17(16); -- o carry eh o MSB da soma 17 bits
```

(trecho copiado do roteiro do lab 6; no nosso `ula.vhd` os sinais se chamam `A_17`, `B_17`, `soma_17`,
`subt_17` e `subt_borrow_17`). O `carry_in` é estendido para 17 bits com
`"0000000000000000" & carry_in`, usando só a concatenação vista no lab 2 (p. 4). O resultado de 16 bits é o
recorte `(15 downto 0)` de cada conta.

Todas as flags são calculadas sobre o sinal interno `resultado`, isto é, sobre a mesma saída do mux que
vai para `ULA_Out`. O sinal interno segue o padrão dos modelos do professor, que calculam num `signal` e só
depois ligam na porta de saída (`data_out <= registro;`, *µProcessador 3*, "VHDL Sequencial"), e a dica do
*µProcessador 4*: "é comum usar os sufixos _i, _o e _s ... “dado_s” para o signal interno".

### 5.4 Flags

Flags sorteadas: o email 1 sorteou os saltos **BLE** e **BVC**. Na tabela do apêndice do lab 2 (p. 8)
e na Tabela 2 do *Características*, seção 5.2 (p. 8):

| Salto | Significado | Condição |
|---|---|---|
| LE | "Less than or equal" | "Z = 1 or N != V" |
| VC | "Not overflow" (no *Características*: "Now overflow") | "V=0" |

Logo precisamos de **Z, N e V**. Além disso o sorteio tem SUBB, que usa **C** ("R1 ← R1 − R2 − Cf",
*Características* 4.3, p. 4). As quatro flags são implementadas. O roteiro manda implementar "apenas as
flags indicadas na tabela relativas ao seu sorteio" (p. 7); a flag C não aparece em BLE/BVC, mas é
necessária pelo SUBB, que também foi sorteado.

As definições, iguais no lab 2 (seção "Flags", p. 6) e no *Características* seção 4.4 (p. 4 e 5):

- "Carry, que indica se houve estouro em uma operação não sinalizada na ULA";
- "Overflow, que indica se houve estouro em uma operação sinalizada na ULA (ou seja, que inclui número negativos)";
- "Zero, que indica que o resultado da operação mais recente da ULA foi zero";
- "Sinal (ou Negativo), que indica o sinal do resultado ... sendo apenas uma cópia do MSB".

Como cada uma foi feita:

**zero (Z)**: `'1' when resultado = "0000000000000000" else '0'`. Vale para todas as operações. É o mesmo
detector do livro: "if we add hardware to test if the result is 0 ... The simplest way is to OR all the
outputs together and then send that signal through an inverter" (P&H, seção A.5, p. A-34).

**sinal (N)**: `resultado(15)`. Em complemento de 2 "leading 0s mean positive, and leading 1s mean
negative" (P&H, seção 2.4 "Signed and Unsigned Numbers", p. 82) e "hardware needs to test only this bit to
see if a number is positive or negative" (seção 2.4, p. 83).

**carry (C)**:

- Soma: bit 16 de `('0'&A) + ('0'&B)`, o vai-um (lab 6, "o carry eh o MSB da soma 17 bits"). É o
  exemplo do lab 2, p. 6: "O (1) entre parênteses indica o vai-um na saída do circuito somador ... este é
  o valor da carry flag".
- Subtrações: bit 16 de `('0'&A) - ('0'&B)` (ou `- carry_in` estendido). Quando `A < B` (sem sinal), a
  conta em 17 bits fica negativa e o bit 16 vale 1; é o "empresta-um". Esta é a convenção do
  *Características*, seção 4.4 (p. 7): "se R3 estiver com um valor menor do que 51, a conta gera um
  bit de empresta-um, ou seja, um indicador de que o resultado foi negativo. Isso indica que houve um
  estouro unsigned e portanto neste caso a flag de carry vai ser ativada". O PDF de complemento de 2 do
  Moodle (`cpl2.pdf`, seção 2.1.1, p. 4) diz o mesmo: "20-40=236 ... Se o resultado é negativo, há carry".
  Para `A - B` sem borrow isso é exatamente a comparação sugerida no lab 6 ("carry_subtr <= '0' when
  in_b<=in_a else '1'"); o truque dos 17 bits foi preferido porque continua certo no SUBB, em que há
  empresta-um também quando `A = B` e `carry_in = 1`.
- AND: `'0'` (lab 6: "Para outras operações ... os estouros podem ser ignorados").

Com esta convenção, C = 1 significa "houve empresta-um", e o SUBB subtrai exatamente esse C. Assim uma
subtração de 32 bits é feita com SUB na parte baixa e SUBB na parte alta (casos 25 e 26 do testbench:
`0x0001_0000 − 0x0000_0001 = 0x0000_FFFF`).

**overflow (V)**:

- Soma: `A(15) = B(15)` e `resultado(15) /= A(15)`. Lab 2, p. 7: "Só há estouro de números signed se
  somarmos dois números que têm um mesmo sinal e se o resultado tiver o sinal contrário." O livro:
  "overflow occurs when adding two positive numbers and the sum is negative, or vice versa" (P&H, seção
  3.2 "Addition and Subtraction", p. 192, Figura 3.2).
- Subtrações: `A(15) /= B(15)` e `resultado(15) /= A(15)`. O lab 2 só diz "Nos casos de subtração o
  raciocínio é análogo" (p. 7); a regra exata está no livro: "Overflow occurs in subtraction when we
  subtract a negative number from a positive number and get a negative result, or when we subtract a
  positive number from a negative number and get a positive result" (P&H, seção 3.2, p. 192), e "when the
  signs of the operands are the same, overflow cannot occur" (p. 191). A mesma regra serve para o SUBB:
  se A e B têm o mesmo sinal, `A − B` fica entre −32767 e +32767 e subtrair mais 1 ainda cabe em 16 bits.
- AND: `'0'`.

A definição geral do livro, que justifica as duas regras, é: "Overflow occurs when the leftmost retained
bit of the binary bit pattern is not the same as the infinite number of digits to the left (the sign bit is
incorrect)" (P&H, seção 2.4, p. 83).

Relação com os saltos (lab 6): os valores destas flags serão guardados em flip-flops fora da ULA
("Estes flip-flops ficam no top-level ou na UC, nunca dentro da ULA", *Características* 4.4, p. 6). BLE
consulta Z, N e V; BVC consulta V; o SUBB lê o flip-flop C pela entrada `carry_in`. Por exemplo, depois de
`CMPR R1,R2` (controle 01), BLE salta quando R1 ≤ R2 com sinal: se R1 = R2 o resultado é zero (Z = 1); se
R1 < R2 o resultado é negativo (N = 1) a não ser que a subtração tenha estourado, caso em que o sinal
vem trocado e V = 1 corrige (N ≠ V).

### 5.5 A ULA do colega (arquivo `ula.vhd` na raiz do repositório)

O Thales havia feito uma primeira versão, que está em `ula.vhd` e `ula_tb.vhd` na raiz (não foram
alterados). Conteúdo original:

- entidade `ULA` com `A, B : unsigned(15 downto 0)`, `controle : unsigned(1 downto 0)`, `ULA_Out` e as
  quatro flags; **sem** `carry_in`;
- operações: `00` soma, `01` subtração, `10` AND, `11` deslocamento à direita de 1 bit
  (`'0' & A(15 downto 1)`);
- `carry`: `(A + B) < A` na soma e `A < B` na subtração;
- `overflow`: quatro linhas testando o sinal de A, de B e se `(A + B)` ou `(A - B)` é `>= "1000000000000000"`;
- `sinal` e `zero`: uma linha por operação, cada uma recalculando `A + B`, `A - B`, `A and B` ou o
  deslocamento e comparando com uma constante;
- testbench com 7 casos: 1+1, (−2)+(−3), 1−3, 3−1, 1−(−4), 0 and FFFF, deslocamento de 1.

Simulamos a versão original: os 7 casos do testbench dele e também os 17 casos de soma e subtração do
nosso testbench (sem o `carry_in`). Resultado, sem nenhuma divergência. O cálculo das flags dele estava
**correto** para soma e subtração. Por exemplo, `(A + B) < A` é exatamente o teste de estouro sem sinal do
livro: "Addition has overflowed if the sum is less than either of the addends" (P&H, seção 3.2, p. 192).

O que foi alterado, e por quê:

| Original | Nova versão | Motivo |
|---|---|---|
| Sem `carry_in`, sem SUBB | entrada `carry_in` e operação `10` = `A − B − carry_in` | SUBB é sorteado (*Características* 4.3). Sem isso a interface da ULA mudaria no lab 6. |
| `11` = deslocamento à direita | `11` = AND; o deslocamento saiu | O SHIFT RIGHT só é usado se for sorteado o final de loop "Detecção do MSB setado usando SHIFT RIGHT" (*Características* 6.2), que ainda não foi sorteado; e o *Características* seção 1 diz que "O processador não deverá executar opcodes fora do que foi explicitamente pedido". Com 2 bits de controle só cabem 4 operações. |
| `10` = AND | `10` = SUBB, AND passou para `11` | reorganização decorrente da linha acima. |
| Cada flag recalcula `A + B`, `A - B` etc. (`A + B` aparece 6 vezes e `A - B` 5 vezes) | Cada operação é calculada uma única vez; as flags são tiradas do `resultado` que sai do mux | "tem que fazer as operações e botar um mux na saída" (lab 2, p. 7). Evita circuitos duplicados e garante que as flags correspondem exatamente ao valor em `ULA_Out`. |
| `sinal` e `overflow` por comparação `>= "1000000000000000"` | `sinal <= resultado(15)` e comparação direta dos bits 15 | a flag é "apenas uma cópia do MSB" (lab 2, p. 6); mais simples de ler. |
| carry por comparação (`(A + B) < A`, `A < B`) | bit 16 das contas em 17 bits | método do lab 6, "Detecção de Estouro (Carry)"; `A < B` não serve para o SUBB (com `carry_in = 1` há empresta-um também quando `A = B`). |
| `zero` só era '1' em cada operação conhecida | `zero` compara o próprio `resultado` | mesma função, uma linha só. |
| Entidade `ULA`, portas em outra ordem | entidade `ula`, com a interface definitiva da seção 5.1 | nome igual ao do arquivo ("use um nome idêntico para o arquivo e para a entity", lab 1, p. 1) e interface fixa para os labs 3 a 7. |
| Testbench com 7 casos, sem nenhum caso de overflow, sem zero em soma/subtração | 29 casos (tabela abaixo) | o roteiro pede "um conjunto de testes razoável, que cobre todos os casos de interesse, incluindo números negativos" (p. 7). |

### 5.6 Testbench da ULA e resultados

O testbench (`ula_tb.vhd`) aplica 29 combinações, 50 ns cada, no modelo de testbench do lab 1 (um
`process` com `wait for 50 ns` e `wait;` final). As constantes são escritas em binário de 16 bits, como
exige o lab 2 ("As constantes devem ser obrigatoriamente representadas por um vetor de bits", p. 3); na
tabela abaixo estão em hexadecimal só para caber. Os valores "obtidos" foram lidos da simulação no GHDL
4.1 (amostrados no meio de cada intervalo) e comparados automaticamente com os valores esperados,
calculados à parte: **os 29 casos bateram em resultado e nas quatro flags**. Por isso cada linha mostra um
único valor (esperado = obtido).

| # | t (ns) | op | A | B | cin | Resultado | Z | C | V | N | O que testa |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0 | ADD | 0003 (3) | 0005 (5) | 0 | 0008 (8) | 0 | 0 | 0 | 0 | soma simples |
| 2 | 50 | ADD | 7FFF (32767) | 0001 (1) | 0 | 8000 | 0 | 0 | 1 | 1 | overflow positivo (+ + + dá −) |
| 3 | 100 | ADD | 8000 (−32768) | FFFF (−1) | 0 | 7FFF | 0 | 1 | 1 | 0 | overflow negativo (− + − dá +) e carry |
| 4 | 150 | ADD | FFFF (−1) | 0001 (1) | 0 | 0000 | 1 | 1 | 0 | 0 | zero com carry, sem overflow |
| 5 | 200 | ADD | 0012 (18) | FFFD (−3) | 0 | 000F (15) | 0 | 1 | 0 | 0 | 18+(−3) do roteiro |
| 6 | 250 | ADD | FFFB (−5) | FFFD (−3) | 0 | FFF8 (−8) | 0 | 1 | 0 | 1 | dois negativos, sem overflow |
| 7 | 300 | ADD | 0000 | 0000 | 0 | 0000 | 1 | 0 | 0 | 0 | zero |
| 8 | 350 | ADD | 0003 | 0005 | 1 | 0008 | 0 | 0 | 0 | 0 | ADD ignora `carry_in` |
| 9 | 400 | SUB | 0007 (7) | 0005 (5) | 0 | 0002 | 0 | 0 | 0 | 0 | subtração simples |
| 10 | 450 | SUB | 0005 (5) | 0007 (7) | 0 | FFFE (−2) | 0 | 1 | 0 | 1 | A < B: empresta-um |
| 11 | 500 | SUB | 0033 (51) | 0033 (51) | 0 | 0000 | 1 | 0 | 0 | 0 | iguais (CMP com 51, *Características* 4.4) |
| 12 | 550 | SUB | 7FFF (32767) | FFFF (−1) | 0 | 8000 | 0 | 1 | 1 | 1 | overflow positivo (+ − − dá −) |
| 13 | 600 | SUB | 8000 (−32768) | 0001 (1) | 0 | 7FFF | 0 | 0 | 1 | 0 | overflow negativo (− − + dá +) |
| 14 | 650 | SUB | FFFB (−5) | FFFD (−3) | 0 | FFFE (−2) | 0 | 1 | 0 | 1 | negativos, sem overflow |
| 15 | 700 | SUB | 0003 (3) | FFFE (−2) | 0 | 0005 (5) | 0 | 1 | 0 | 0 | 3−(−2) |
| 16 | 750 | SUB | 0007 | 0005 | 1 | 0002 | 0 | 0 | 0 | 0 | SUB ignora `carry_in` |
| 17 | 800 | SUBB | 0007 | 0005 | 0 | 0002 | 0 | 0 | 0 | 0 | SUBB com C = 0 igual ao SUB |
| 18 | 850 | SUBB | 0007 | 0005 | 1 | 0001 | 0 | 0 | 0 | 0 | SUBB com C = 1 subtrai mais 1 |
| 19 | 900 | SUBB | 0005 | 0005 | 1 | FFFF (−1) | 0 | 1 | 0 | 1 | A = B com C = 1: empresta-um |
| 20 | 950 | SUBB | 0006 | 0005 | 1 | 0000 | 1 | 0 | 0 | 0 | zero no SUBB |
| 21 | 1000 | SUBB | 0000 | 0000 | 1 | FFFF | 0 | 1 | 0 | 1 | 0 − 0 − 1 |
| 22 | 1050 | SUBB | 8000 (−32768) | 0000 | 1 | 7FFF | 0 | 0 | 1 | 0 | overflow só por causa do `carry_in` |
| 23 | 1100 | SUBB | 0000 | 8000 (−32768) | 1 | 7FFF (32767) | 0 | 1 | 0 | 0 | 0−(−32768)−1 cabe: sem overflow |
| 24 | 1150 | SUBB | 0000 | 8000 (−32768) | 0 | 8000 | 0 | 1 | 1 | 1 | mesmo caso com C = 0: overflow |
| 25 | 1200 | SUB | 0000 | 0001 | 0 | FFFF | 0 | 1 | 0 | 1 | 32 bits, parte baixa de 0x00010000 − 0x00000001 |
| 26 | 1250 | SUBB | 0001 | 0000 | 1 | 0000 | 1 | 0 | 0 | 0 | parte alta, usando o C = 1 do caso 25 |
| 27 | 1300 | AND | F0F0 | FF00 | 0 | F000 | 0 | 0 | 0 | 1 | AND com MSB 1 |
| 28 | 1350 | AND | 0F0F | F0F0 | 0 | 0000 | 1 | 0 | 0 | 0 | AND que zera |
| 29 | 1400 | AND | FFFF | 1234 | 1 | 1234 | 0 | 0 | 0 | 0 | AND: C e V sempre 0 |

Cobertura: todas as operações; números negativos em complemento de 2 (casos 3, 5, 6, 12 a 15, 22 a 24);
carry na soma (3 a 6) e empresta-um nas subtrações (10, 12, 14, 15, 19, 21, 23 a 25); overflow positivo
(2, 12, 24) e negativo (3, 13, 22); zero em todas as operações (4, 7, 11, 20, 26, 28); SUBB com
`carry_in` 0 e 1 (17 a 24, 26).

Na simulação, o GHDL imprime avisos "metavalue detected" apenas em t = 0 ms, antes da primeira atribuição
do testbench, quando as entradas ainda valem 'U'. Não afetam os resultados.

## 6. Como rodar

```
cd lab2
sh run.sh
gtkwave ula_tb.ghw
```

O `run.sh` faz `ghdl -a` de todos os fontes, `ghdl -e` e `ghdl -r <tb> --wave=<tb>.ghw` de cada testbench
(mesmos comandos do lab 1). Os arquivos `.ghw` e `work-obj*.cf` gerados não devem ser versionados.
