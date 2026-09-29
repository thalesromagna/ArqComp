# Lab 6 — Condicionais e Desvios (flags, CMPR/CMPI, SUBB, BLE, BVC)

Arquivos em `lab6/`. Base: PDF *µProcessador 6* ("Condicionais e Desvios"), documento *Características do
Projeto do µP* (arquivo `6996-EncargosdeIRRF-082026.pdf`) e o lab 5 (`docs/lab5.md`), do qual este lab é uma
evolução. Convenção de citação igual à do `docs/lab5.md` (livro P&H com página impressa; slides e PDFs com a
página do PDF).

## 1. O que o lab pede

- "Inclua no circuito instruções de desvio condicional e não condicional, de acordo com o assembly do
  processador sorteado." e "O processador deverá ser capaz de comparar dois números e descobrir qual deles é
  o menor." (*µProcessador 6*, introdução, p. 1)
- "saltos relativos têm que pular tanto para frente como para trás (branch ou jump “-5” volta cinco
  instruções). Utilize o operando em complemento de 2." (seção "Implementação", p. 1)
- Flags: "estes bits devem ser guardados em flip-flops, externos à ULA, normalmente no top-level (talvez na
  unidade de controle)." e "Os flip-flops só vão ser atualizados na execução de instruções específicas da ULA
  (ADD, SUB, CMP, p.ex.) mas não devem ser atualizados em outras instruções (LD/MOV, JMP, branches, etc)."
  (seção "Os Flip-flops das Flags", p. 1)
- "Para decidir se um salto condicional deve ser executado ou não, você deve consultar o valor de saída do
  flip-flop correspondente." (idem, p. 1)
- "Mantenha os pinos visíveis no top level como descritos no laboratório passado." e o programa A..F
  (seção "Testes", p. 2).
- Avaliação (p. 3): "Se executar instrução seguinte ao desvio: -10%", "Se a constante do salto não estiver em
  complemento de dois: -10%", "Se o salto não for absoluto/relativo como especificado: -10%".

Sorteio da equipe (ver `docs/00-especificacoes.md`, seção 1): saltos condicionais **BLE** e **BVC**, SUB e
**SUBB**, comparações **CMPR** e **CMPI**, ADD/SUB só entre registradores e com 2 operandos.

## 2. Arquivos

| Arquivo | Mudança em relação ao lab 5 |
|---|---|
| `reg1bit.vhd` | **novo**: flip-flop de 1 bit com reset e enable (modelo `reg8bits` do *µProcessador 3* com 1 bit) |
| `un_controle.vhd` | novas instruções SUBB, CMPR, CMPI, BLE, BVC; saídas `flags_wr_en` e `sel_ula_b`; entradas das flags |
| `processador.vhd` | 4 flip-flops de flag (Z, N, C, V) no top-level; mux na entrada B da ULA; `carry_in` da ULA = flag C |
| `rom.vhd` | programa do lab 6 + testes extras |
| `processador_tb.vhd` | só o tempo de simulação (50 µs) |
| `programa.asm` | listagem do programa |
| `reg16bits.vhd`, `pc.vhd`, `maq_estados.vhd`, `banco.vhd`, `ula.vhd` | iguais ao lab 5 |
| `processador_tb.gtkw`, `run.sh` | mesma lista de sinais; `run.sh` inclui `reg1bit.vhd` |

## 3. Instruções novas e codificação

Codificação completa em `docs/00-especificacoes.md`, seção 4. Instruções deste lab (as do lab 5 continuam):

```
MSB b15                      b0 LSB
SUBB Rd,Rs  0101 ddd sss xxxxxx     Rd <- Rd - Rs - C                  flags Z N C V
CMPR Rd,Rs  0110 ddd sss xxxxxx     Rd - Rs (só flags, não grava)      flags Z N C V
CMPI Rd,cte 0111 ddd ccccccccc      Rd - cte (só flags, não grava)     flags Z N C V
BLE  delta  1001 xxxxx eeeeeee      se Z=1 ou N/=V: PC <- PC + delta
BVC  delta  1010 xxxxx eeeeeee      se V=0:         PC <- PC + delta

eeeeeee = delta de 7 bits em complemento de 2 (-64..+63); ccccccccc = constante de 9 bits em complemento de 2
```

ADD e SUB passam a gravar as flags. Opcodes 1011 a 1111 continuam sem efeito (PC+1).

Base de cada item:

- SUBB: "SUBB R1,R2 irá realizar R1 ← R1 − R2 − Cf" (*Características*, seção 4.3, p. 4).
- CMPR/CMPI: "realiza uma comparação subtraindo os dois operandos e alterando as flags de acordo, sem gravar o
  resultado da subtração em nenhum lugar. Se a instrução for CMP ela compara dois registradores; se a
  instrução for CMPI), a comparação é feita com uma constante imediata." (*Características*, seção 4.3, p. 4).
  Nosso nome é CMPR, como no sorteio ("Comparação tanto com regs quanto ctes (CMPR/CMPI)").
- Constante do CMPI "obrigatoriamente devem ser expressas em complemento de 2 e utilizar extensão de sinal
  antes da operação em si" (*Características*, seção 4.2, p. 4) — é a mesma `cte_estendida` do LD.
- Condições (padrão ARM): "LE Less than or equal Z = 1 or N != V" e "VC Now overflow V=0"
  (*Características*, Tabela 2, seção 5.2, p. 8). "As únicas duas instruções de desvio condicional sorteadas
  para a equipe estão identificadas na tabela 2; a equipe não pode implementar outras" (seção 5.2, p. 7).
- Branch relativo: "instruções JR ou branches B ou Bxx [...] utilizam um endereço relativo (a constante vai ser
  somada ao PC, especificando um “delta” de endereços que devem ser saltados)" (*Características*, seção 5.1,
  p. 7). O JMP continua absoluto.

## 4. Circuito

### 4.1 Flags: ULA e flip-flops

A ULA (sem mudança desde o lab 5) calcula as 4 flags para qualquer operação:

| Flag | Cálculo na ULA |
|---|---|
| Z (`zero`) | resultado = 0 |
| N (`sinal`) | bit 15 do resultado ("apenas uma cópia do MSB", *Características*, seção 4.4, p. 5) |
| C (`carry`) | bit 16 da conta em 17 bits: soma `('0'&A)+('0'&B)`; subtrações `('0'&A)-('0'&B)(-carry_in)` |
| V (`overflow`) | soma: A(15)=B(15) e res(15)/=A(15); subtrações: A(15)/=B(15) e res(15)/=A(15) |

- Carry com 17 bits, como no PDF: "Para detectar o carry numa soma em VHDL, somos obrigados a usar um bit
  adicional na operação" e `soma_17 <= in_a_17+in_b_17; carry_soma <= soma_17(16);` (*µProcessador 6*,
  "Detecção de Estouro (Carry)", p. 1–2).
- Na subtração o bit 16 vale 1 quando há "empresta-um" (A < B sem sinal). É o comportamento pedido: "se R3
  estiver com um valor menor do que 51, a conta gera um bit de “empresta-um,” [...] neste caso a flag de carry
  vai ser ativada" (*Características*, seção 4.4, p. 7). Também bate com o PDF do lab, que sugere
  `carry_subtr <= '0' when in_b<=in_a else '1'` (*µProcessador 6*, p. 2).
- Overflow: "Só há estouro de números signed se somarmos dois
  números que têm um mesmo sinal e se o resultado tiver o sinal contrário. Nos casos de subtração o
  raciocínio é análogo." (*Características*, seção 4.4, p. 5). O livro: "Overflow occurs in subtraction when
  we subtract a negative number from a positive number and get a negative result, or when we subtract a
  positive number from a negative number and get a positive result." (P&H, seção 3.2, p. 192; o mesmo
  parágrafo remete à Figure 3.2, "Overflow conditions for addition and subtraction", na mesma página).

Os 4 flip-flops (`ff_z`, `ff_n`, `ff_c`, `ff_v`, entidade `reg1bit`) estão no `processador.vhd`, fora da ULA:
"Estes flip-flops ficam no top-level ou na UC, nunca dentro da ULA." (*Características*, seção 4.4,
"Armazenamento das flags", p. 6). Todos usam o mesmo enable:

```
flags_wr_en <= '1' quando estado="10" e a instrução é ADD, SUB, SUBB, CMPR ou CMPI (when-else, uma linha por instrução)
```

"quando houver ADD, SUB,CMP ou similares, o valor indicado pela ULA será guardado, mas quando houver branches,
MOV, NOP, LW, SW, o valor dos flip-flops fica inalterado." (*Características*, seção 4.4, p. 6). LD também não
altera as flags.

**Por que 4 flags:** BLE usa Z, N e V; BVC usa V; SUBB usa C ("Flag C também é necessária", ver
`docs/00-especificacoes.md`, seção 1).

**SUBB:** a saída do flip-flop C vai direto no `carry_in` da ULA (`carry_in=>flag_c_s`), e a UC manda
`ula_controle="10"` (A−B−carry_in). Assim o SUBB usa o C da **última instrução de ULA**, como pede o
"R1 ← R1 − R2 − Cf".

### 4.2 Mux da entrada B da ULA (CMPI)

Novo sinal `sel_ula_b` (UC) e mux no top-level:

```
ula_b_s <= dado_r2_s       when sel_ula_b_s='0' else
           cte_estendida_s when sel_ula_b_s='1' else
           "0000000000000000";
```

`sel_ula_b = 1` só no CMPI. É o mesmo mux dos slides: "O primeiro operando é sempre um registrador e o segundo
pode ser um registrador ou uma constante" (`cap2-ciclo-unico.pdf`, "Seletores para os Muxes",
p. 11) e o ALUSrc do livro (P&H, seção 4.4, Figure 4.21, p. 277: "two 1-bit signals that are used to control
multiplexors (ALUSrc and MemtoReg)"). No lab 6 só o CMPI usa constante na ULA (não há ADDI/SUBI no sorteio).

### 4.3 Desvios na unidade de controle

```
salta_ble <= '1' when eh_ble='1' and flag_z='1' else
             '1' when eh_ble='1' and flag_n/=flag_v else
             '0';
salta_bvc <= '1' when eh_bvc='1' and flag_v='0' else
             '0';
desvia    <= salta_ble or salta_bvc;
pc_desvio <= pc_atual + delta;            (delta = instr(6 downto 0))
pc_prox   <= endereco_jmp when eh_jmp='1' else
             pc_desvio    when desvia='1' else
             pc_mais_um   when eh_jmp='0' and desvia='0' else
             "0000000";
```

- As flags lidas são as **saídas dos flip-flops** (entradas `flag_z`, `flag_n`, `flag_v` da UC), nunca as da
  ULA, conforme o PDF ("consultar o valor de saída do flip-flop correspondente").
- **Base do endereço relativo = endereço do próprio branch.** O PC só é escrito no fim do estado 2, então
  `pc_atual` ainda é o endereço do BLE/BVC. Isso segue a nota do PDF: "“branch 5” vai pular cinco instruções
  pra frente de onde ele está" (*µProcessador 6*, nota 1, p. 1) e o livro: "The instruction set architecture
  specifies that the base for the branch address calculation is the address of the branch instruction."
  (P&H, seção 4.3, p. 264). Ex.: `BLE -3` no endereço 6 vai para 3; `BLE 2` no endereço 12 vai para 14.
- **Complemento de 2:** o delta tem 7 bits e o PC também, então a soma `pc_atual + delta` em 7 bits (módulo
  128) já dá o resultado certo para delta negativo: como o delta já tem a largura do PC, a "extensão de sinal"
  para 7 bits não acrescenta nenhum bit, e por isso não há circuito de extensão (escolha da equipe). O PDF
  garante que a soma funciona com o delta em complemento de 2: "Se for feita extensão de sinal do operando,
  basta fazer normalmente a soma ao PC: ela vai funcionar, pelas propriedades de complemento de 2"
  (*µProcessador 6*, p. 1) e "Pode continuar usando signals UNSIGNED normalmente no VHDL, vai funcionar, confie"
  (p. 3). O livro chama isso de "PC-relative addressing", "An addressing regime in which the address is the
  sum of the program counter (PC) and a constant in the instruction" (P&H, seção 2.10, p. 122). Diferença para o RISC-V: lá o offset é deslocado 1 bit (meia
  palavra); aqui cada endereço é uma instrução, então o delta é em instruções.
- Seleção do PC por mux, como nos slides: "o PC deve ser escrito com o valor PC+delta endereços quando ambos
  é igual==1 e instr beq==1; caso contrário, devemos escrever PC+4 no PC. Isso nos dá um simples mux"
  (`cap2-ciclo-unico.pdf`, seção 6.2, p. 14), e "No caso de incluirmos outras instruções de saltos, podemos
  gerar mais sinais pela ULA e combiná-los, dentro ou fora da ULA" (p. 15). No livro, "An AND gate is used to
  combine the branch control signal and the Zero output from the ALU; the AND gate output controls the
  selection of the next PC." (P&H, Figure 4.21, p. 277). No nosso caso a "AND" é entre `eh_ble`/`eh_bvc` e a
  condição das flags guardadas.

### 4.4 Tabela de controle (estado 2)

| Instrução | banco_wr_en | flags_wr_en | ula_controle | sel_ula_b | sel_dado_banco | pc_prox |
|---|---|---|---|---|---|---|
| NOP | 0 | 0 | – | – | – | PC+1 |
| LD | 1 | 0 | – | – | 01 | PC+1 |
| MOV | 1 | 0 | – | – | 10 | PC+1 |
| ADD | 1 | 1 | 00 | 0 | 00 | PC+1 |
| SUB | 1 | 1 | 01 | 0 | 00 | PC+1 |
| SUBB | 1 | 1 | 10 | 0 | 00 | PC+1 |
| CMPR | 0 | 1 | 01 | 0 | – | PC+1 |
| CMPI | 0 | 1 | 01 | 1 | – | PC+1 |
| JMP | 0 | 0 | – | – | – | `instr(6..0)` |
| BLE | 0 | 0 | – | – | – | PC+delta se Z=1 ou N/=V, senão PC+1 |
| BVC | 0 | 0 | – | – | – | PC+delta se V=0, senão PC+1 |
| outros | 0 | 0 | – | – | – | PC+1 |

Em todos os estados diferentes de 2 os enables `pc_wr_en`, `banco_wr_en` e `flags_wr_en` ficam em 0.

## 5. Programa (`lab6/programa.asm`)

### 5.1 Programa obrigatório (endereços 0 a 7)

| End. | Passo | Assembly | Hexa | Comentário |
|---|---|---|---|---|
| 0 | A | `LD R3,0` | 1600 | |
| 1 | B | `LD R4,0` | 1800 | |
| 2 | (aux.) | `LD R1,1` | 1201 | não há ADDI: a constante 1 fica em R1 |
| 3 | C | `ADD R4,R3` | 38C0 | R4 ← R4 + R3 |
| 4 | D | `ADD R3,R1` | 3640 | R3 ← R3 + 1 |
| 5 | E | `CMPI R3,29` | 761D | flags de R3 − 29 |
| 6 | E | `BLE -3` | 907D | delta −3 = `1111101`: volta para 3 se R3 ≤ 29 |
| 7 | F | `MOV R5,R4` | 2B00 | |

Passo E ("Se R3<30 salta para a instrução do passo C") só com as instruções sorteadas: não existe "BLT", então
usamos a equivalência, para inteiros, R3 < 30 ⇔ R3 ≤ 29, e `CMPI R3,29` + `BLE`. O BLE é o "menor ou igual"
**com sinal** (Z=1 ou N≠V), correto aqui pois R3 fica entre 0 e 30. Resultado esperado: R4 = 0+1+...+29 =
**435** e R5 = **435**; R3 termina em 30.

### 5.2 Testes extras (endereços 8 a 40) — decisão da equipe

O PDF exige também comparar dois números e achar o menor, saltos para frente e para trás e complemento de 2
no delta. O programa obrigatório só testa BLE para trás. Decidimos **continuar o programa depois do passo F**
na mesma ROM (não atrapalha: R3, R4 e R5 não são mais escritos, e os testes só usam R0, R1 (lido), R2, R6 e
R7). O programa termina num laço `JMP 40`.

| End. | Assembly | O que testa | Esperado |
|---|---|---|---|
| 8–13 | `LD R6,37`; `LD R7,-20`; `MOV R0,R6`; `CMPR R6,R7`; `BLE 2`; `MOV R0,R7` | menor de dois (37 e −20), BLE para frente **não** tomado, CMPR | 37−(−20)=57: Z=0 N=0 V=0 → não salta; R0 = −20 (menor) |
| 14–19 | `LD R6,-90`; `LD R7,12`; `MOV R2,R6`; `CMPR R6,R7`; `BLE 2`; `MOV R2,R7` | menor de dois (−90 e 12), BLE para frente **tomado** por N≠V | −102: N=1 V=0 → salta para 20; endereço 19 não executa; R2 = −90 |
| 20–29 | `LD R6,-256`; 7 x `ADD R6,R6`; `BVC 2`; `LD R7,-1` | ADD com carry, BVC **tomado** (V=0) | R6 = 0x8000 (−32768), C=1 V=0 → salta para 30; 29 não executa |
| 30–32 | `SUB R6,R1`; `BVC 2`; `LD R7,77` | overflow na subtração, BVC **não tomado** (V=1) | 0x8000−1 = 0x7FFF: V=1 → não salta; 32 executa (R7=77) |
| 33–36 | `LD R6,200`; `SUBB R6,R7`; `CMPI R6,124`; `SUBB R6,R7` | SUBB com C=0 e com C=1; CMPI gerando empresta-um | C=0 (do SUB anterior): 200−77−0 = 123; CMPI 123−124 = −1 → C=1; 123−77−1 = **45** |
| 37–40 | `CMPI R6,45`; `BLE 2`; `LD R6,0`; `JMP 40` | BLE tomado por **Z=1** | salta para 40; 39 não executa; R6 fica 45 |

Deltas: `BLE 2`/`BVC 2` = `0000010`, `BLE -3` = `1111101`, todos em complemento de 2.

## 6. Resultados da simulação

GHDL 4.1, `processador_tb` com 50 µs; VCD conferido por script Python da equipe (fora do repositório). Tempos
= borda de subida em que o PC/registrador/flag foi gravado. Flags na ordem Z N C V, depois da instrução.

### 6.1 Programa obrigatório

| Borda (ns) | PC | Instrução | Depois | ZNCV |
|---|---|---|---|---|
| 450 | 0 | LD R3,0 | R3=0 | 0000 |
| 750 | 1 | LD R4,0 | R4=0 | 0000 |
| 1050 | 2 | LD R1,1 | R1=1 | 0000 |
| 1350 | 3 | ADD R4,R3 | R4=0 | 1000 |
| 1650 | 4 | ADD R3,R1 | R3=1 | 0000 |
| 1950 | 5 | CMPI R3,29 | ULA = −28 | 0110 |
| 2250 | 6 | BLE -3 | PC → 3 (tomado, N≠V) | 0110 |
| ... | | | | |
| 35550 | 5 | CMPI R3,29 (R3=29) | ULA = 0 | 1000 |
| 35850 | 6 | BLE -3 | PC → 3 (tomado, Z=1) | 1000 |
| 36150 | 3 | ADD R4,R3 | R4 = 435 | 0000 |
| 36450 | 4 | ADD R3,R1 | R3 = 30 | 0000 |
| 36750 | 5 | CMPI R3,29 | ULA = 1 | 0000 |
| 37050 | 6 | BLE -3 | PC → 7 (não tomado) | 0000 |
| 37350 | 7 | MOV R5,R4 | **R5 = 435** | 0000 |

- O BLE foi executado 30 vezes: 29 tomado (para trás) e 1 não tomado.
- Veja que as flags não mudam no BLE nem no LD (ex.: 2250 ns mantém 0110 do CMPI), como exigido.
- Sanidade de clocks: o passo F é a 124ª instrução executada (3 + 30 x 4 + 1); a n-ésima instrução grava na
  borda 150 + 300·n ns, logo 150 + 300·124 = 37350 ns, exatamente o medido.

### 6.2 Testes extras (valores medidos)

| Borda (ns) | PC | Instrução | Resultado | ZNCV | PC seguinte |
|---|---|---|---|---|---|
| 38550 | 11 | CMPR R6,R7 (37, −20) | 57 | 0010 | 12 |
| 38850 | 12 | BLE 2 | não tomado | 0010 | 13 |
| 39150 | 13 | MOV R0,R7 | **R0 = −20** | 0010 | 14 |
| 40350 | 17 | CMPR R6,R7 (−90, 12) | −102 | 0100 | 18 |
| 40650 | 18 | BLE 2 | tomado | 0100 | **20** |
| 43050 | 27 | ADD R6,R6 | R6 = −32768 (0x8000) | 0110 | 28 |
| 43350 | 28 | BVC 2 | tomado (V=0) | 0110 | **30** |
| 43650 | 30 | SUB R6,R1 | R6 = 32767 (0x7FFF) | 0001 | 31 |
| 43950 | 31 | BVC 2 | não tomado (V=1) | 0001 | 32 |
| 44250 | 32 | LD R7,77 | R7 = 77 | 0001 | 33 |
| 44850 | 34 | SUBB R6,R7 (C=0) | R6 = 123 | 0000 | 35 |
| 45150 | 35 | CMPI R6,124 | −1 | 0110 | 36 |
| 45450 | 36 | SUBB R6,R7 (C=1) | **R6 = 45** | 0000 | 37 |
| 45750 | 37 | CMPI R6,45 | 0 | 1000 | 38 |
| 46050 | 38 | BLE 2 | tomado (Z=1) | 1000 | **40** |
| 46350.. | 40 | JMP 40 | laço | 1000 | 40 |

- Endereços **nunca executados**: 19, 29 e 39 — exatamente as instruções logo após os desvios tomados. Todos
  os outros de 0 a 40 foram executados.
- Estado final (50 µs): R0 = −20, R1 = 1, R2 = −90, R3 = 30, **R4 = 435, R5 = 435**, R6 = 45, R7 = 77.
- O "menor de dois" ficou em R0 (−20, entre 37 e −20) e em R2 (−90, entre −90 e 12).

## 7. Como rodar

```
cd lab6
./run.sh
```

Mesma lista de sinais do lab 5 (`processador_tb.gtkw`). Para ver as flags, adicione no gtkwave
`top.processador_tb.uut.flag_z_s`, `flag_n_s`, `flag_c_s`, `flag_v_s` e `flags_wr_en_s` (sinais internos do
top-level; não são pinos, para manter os pinos iguais aos do lab 5 como o PDF pede).
