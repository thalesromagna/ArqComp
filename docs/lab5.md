# Lab 5 — "Calculadora Programável" (ROM + PC + UC + banco + ULA executando um programa)

Arquivos em `lab5/`. Base: PDF *µProcessador 5* ("Calculadora Programável"), mais os modelos de VHDL
dos PDFs *µProcessador 3* (registrador e testbench) e *µProcessador 4* (ROM). As decisões gerais (16 bits,
PC de 7 bits, 3 estados, registrador de instrução, codificação) estão em `docs/00-especificacoes.md`.

Convenção de citação: PDF dos labs = nome do PDF + seção + página do PDF; slides `cap2-ciclo-unico.pdf` =
página do PDF (coincide com o número do rodapé); livro = Patterson & Hennessy, *Computer Organization and
Design RISC-V Edition* (P&H), seção, figura e **página impressa**.

## 1. O que o lab pede

- "Partindo da ROM, PC, UC, ULA e Banco de Registradores dos laboratórios anteriores, executar um programa
  para executar uma lista de instruções aritméticas." (*µProcessador 5*, introdução, p. 1)
- "Implemente apenas instruções da ULA, de carga de constantes, transferência de valores entre registradores,
  salto incondicional e nop; outras instruções ficam para depois." (idem, p. 1)
- Máquina de estados: "O código acima produz uma contagem de 0 a 2. Reproduza-o ipsis literis, não invente
  mudanças." (seção "Contadores em VHDL", p. 1)
- "Sugiro fazer uma máquina de 3 estados: fetch, decode e execute" e "Caso o seu sorteio especifique um
  Registrador de Instrução, basta adicionar no circuito um registrador comum que apenas armazena a instrução
  lida da ROM, instrução esta que será executada nos clocks seguintes." (seção "Implementação", p. 2)
- Pinos no gtkwave, "preferencialmente nesta ordem": reset; clock; estado; PC; instrução (saída do
  Registrador de Instrução); saída da ULA; "saídas do acumulador e valores internos de todos os registradores,
  em ordem." (seção "Testes", p. 2)
- Programa obrigatório A..I a partir do endereço zero (seção "Testes", p. 2) e "A sequência de valores de R5
  observada na execução é 12, 19, 26, 33, 40, 47,... [...] Confira, por favor." (p. 3)
- Entregar "o testbench principal (top-level) deverá ser chamado “processador_tb.vhd”", a especificação da
  codificação e o assembly: "eu quero as instruções em assembly, não apenas os opcodes" (seção "Arquivos a
  Entregar", p. 3).
- Avaliação (p. 4): "Se executar instrução seguinte ao desvio: -10%", "Se a instrução com o binário 0x00 não
  for NOP: -10%", "Se a instrução no endereço 0x0 for NOP: -10%", "Se não executar a instrução no endereço
  0x0: -10%", "Se não fizer o desenho das formas de onda esperadas (ver abaixo): -20%".
- Sugestão: "faça um script (no bash ou um .bat) ou makefile para compilar e simular, e use um arquivo para a
  lista de sinais do gtkwave como mencionado no laboratório #3." (p. 1)

## 2. Arquivos

| Arquivo | Conteúdo |
|---|---|
| `reg16bits.vhd` | registrador de 16 bits (modelo `reg8bits` do *µProcessador 3*); usado nos 8 registradores do banco **e** como registrador de instrução (IR) |
| `pc.vhd` | PC: registrador de 7 bits, mesmo modelo |
| `maq_estados.vhd` | contador 0,1,2 do *µProcessador 5* |
| `rom.vhd` | ROM síncrona de 128 x 16 bits (modelo do *µProcessador 4*) com o programa |
| `banco.vhd` | banco com 8 registradores de 16 bits (R0..R7) |
| `ula.vhd` | ULA de 16 bits com flags |
| `un_controle.vhd` | unidade de controle, só combinacional |
| `processador.vhd` | top-level |
| `processador_tb.vhd` | testbench top-level (nome exigido pelo PDF) |
| `programa.asm` | listagem do programa: endereço, assembly, binário, hexa |
| `processador_tb.gtkw` | lista de sinais do gtkwave, já na ordem pedida |
| `run.sh` | compila, simula e abre o gtkwave |

O diretório é autocontido: todos os `.vhd` necessários estão nele.

## 3. Regras de VHDL respeitadas

- `process`/`if` só em: `reg16bits`, `pc` (registradores, modelo do *µProcessador 3*: "O if-then só deve ser
  usado nesta disciplina para criar um registrador!", seção "Registrador Padrão", p. 2), `rom` (modelo do
  *µProcessador 4*) e `maq_estados` (modelo do *µProcessador 5*) e no testbench.
- Todo o resto é `when-else` terminado em `else` zero (*µProcessador 2*: "Numa estrutura when-else sempre
  termine com else '0';"), `&`, recortes, `+`, `-`, `and`, `port map`.
- Sem comentários no código. **Desvio consciente:** o `maq_estados.vhd` é o código do PDF linha por linha,
  mas sem os dois comentários `-- se agora esta em 2`, `-- o prox vai voltar ao zero`, `-- senao avanca`,
  porque a regra da equipe é não ter comentários nos fontes. Nenhum comando foi alterado.

## 4. Codificação das instruções (formato de 16 bits)

Codificação completa em `docs/00-especificacoes.md`, seção 4. As instruções implementadas **neste lab** são:

```
MSB b15                     b0 LSB
NOP        0000 xxxxxxxxxxxx          nada
LD  Rd,cte 0001 ddd ccccccccc         Rd <- cte (9 bits, complemento de 2, com extensão de sinal)
MOV Rd,Rs  0010 ddd sss xxxxxx        Rd <- Rs
ADD Rd,Rs  0011 ddd sss xxxxxx        Rd <- Rd + Rs
SUB Rd,Rs  0100 ddd sss xxxxxx        Rd <- Rd - Rs
JMP end    1000 xxxxx aaaaaaa         PC <- end (endereço absoluto de 7 bits)

ddd = registrador destino/primeiro operando, sss = registrador fonte, ccccccccc = constante,
aaaaaaa = endereço absoluto, x = irrelevante (gravado como 0)
```

Todos os outros opcodes (0101 a 0111, 1001 a 1111) **não fazem nada** neste lab: não escrevem no banco e o
PC avança 1, como um NOP. Isso segue "O processador não deverá executar opcodes fora do que foi
explicitamente pedido" (*Características do Projeto do µP*, seção 1, p. 2). O código `0x0000` é NOP
(opcode 0000), como pede a avaliação do *µProcessador 5* (p. 4).

Por que cada instrução tem essa forma (sorteio, *Características*):

- LD direto: "Instrução LD exclusiva de carga (por ex., LD R5,131), caso em que a constante deverá ser
  conduzida diretamente da instrução para o banco de registradores" (seção 3, p. 3).
- Constante com sinal: "As constantes deverão ser sinalizadas e estar em complemento de 2, exigindo
  portanto extensão de sinal no circuito." (seção 3, p. 3). Com 9 bits a faixa é −256..255.
- MOV entre registradores (ortogonal): "No caso ortogonal, deverá ser implementada uma instrução MOV Rn,Rm"
  (seção 2, p. 3).
- ADD/SUB com 2 operandos: "o primeiro operando é tanto fonte quanto destino, e o segundo operando é uma
  outra fonte, como em SUB R3,R6 que realiza R3 ← R3 − R6" (seção 4.1, p. 4).
- JMP absoluto: "instruções JMP devem saltar para um endereço absoluto (ou seja, a constante especificada na
  instrução vai ser escrita no PC)" (seção 5.1, p. 7).

## 5. Circuito

### 5.1 Diagrama de blocos

```
            +-----------+  estado
  clk,rst ->|maq_estados|----------------------------------+
            +-----------+                                  |
                                                           v
   +----+ pc_s  +-----+ rom_dado +------+ instrucao +-------------+
   | PC |------>| ROM |--------->|  IR  |---------->| un_controle |--> pc_wr_en, pc_prox
   +----+       |sinc.|          |(reg16)|           | (when-else) |--> ir_wr_en
     ^          +-----+          +------+           |             |--> banco_wr_en
     |  pc_prox                                     |             |--> ula_controle
     +----------------------------------------------|             |--> sel_dado_banco
                                                    |             |--> cte_estendida
                                                    |             |--> reg_r1/reg_r2/reg_wr
                                                    +-------------+
                  reg_r1,reg_r2,reg_wr
                          v
                    +-----------+ data_r1  +-----+
   dado_banco ----->|   banco   |--------->|  A  |
        ^           | R0 .. R7  | data_r2  | ULA |---> ula_out
        |           +-----------+----+---->|  B  |
        |                            |     +-----+
        |    mux (sel_dado_banco):   |
        +--- "00" ula_out            |
             "01" cte_estendida (LD) |
             "10" data_r2 (MOV) <----+
```

É o caminho de dados do livro sem a memória de dados: "The simple datapath for the core RISC-V architecture
combines the elements required by different instruction classes" (P&H, seção 4.3, Figure 4.11, p. 268) e
"The simple datapath with the control unit" (P&H, seção 4.4, Figure 4.21, p. 277). Os slides do professor
mostram a mesma divisão: "o assim chamado caminho de dados está em preto e vermelho, com o caminho de
controle em azul" (`cap2-ciclo-unico.pdf`, seção 7.1, p. 15), e "a unidade de controle é apenas
combinacional, não possuindo nenhum estado ou flip-flop" (idem, p. 16) — por isso a `un_controle` só tem
`when-else`; o único estado (a contagem 0,1,2) fica no `maq_estados`.

### 5.2 Multiciclo de 3 estados e registrador de instrução

O nosso processador não é ciclo único: cada instrução leva 3 clocks. Base:

- Slides: "Uma maneira simples de dividir a execução de uma instrução é quebrá-la em alguns estados
  padronizados. [...] Fetch (busca) [...] Decode [...] Execute: realiza a operação em si e grava os
  resultados de acordo." e "O estado inicial no reset é fetch, e a cada clock temos uma transição,
  ciclicamente. Isso pode ser facilmente implementado como um simples contador." (`cap2-ciclo-unico.pdf`,
  seção 8.2, Figura 12, p. 19).
- Livro: "In a multicycle implementation, each step in the execution will take 1 clock cycle." (P&H, seção
  4.5 *A Multicycle Implementation*, p. 282). O IR vem do mesmo texto: "The IR needs to hold the instruction
  until the end of execution of that instruction, and thus will require a write control signal." (seção 4.5,
  p. 282.e2; o IR aparece na Figure e4.5.1, p. 282.e1). É exatamente o nosso `ir_wr_en`.

| Estado | Nome | O que acontece | Enables ativos |
|---|---|---|---|
| 0 (`00`) | fetch | PC aponta a instrução; na borda que encerra o estado 0 a ROM síncrona registra `ROM[PC]` | nenhum |
| 1 (`01`) | decode | a saída da ROM está estável; na borda que encerra o estado 1 o IR grava essa saída | `ir_wr_en` |
| 2 (`10`) | execute | o IR já tem a instrução; UC decodifica, banco lê, ULA calcula; na borda que encerra o estado 2 gravam banco e PC | `pc_wr_en`, `banco_wr_en` (se a instrução escreve) |

Como o PC só muda no fim do estado 2, durante toda a execução ele ainda contém o endereço da instrução
corrente (isso será usado nos branches do lab 6). Enables:

```
ir_wr_en    <= '1' when estado="01" else '0';
pc_wr_en    <= '1' when estado="10" else '0';
banco_wr_en <= '1' when estado="10" and (LD ou MOV ou ADD ou SUB) else '0';   (escrito como when-else, uma linha por instrução)
```

A ROM é síncrona e não tem enable: o PDF do *µProcessador 4* avisa "Note que esta ROM é sincrona! Isto
significa que é preciso dar um clock nela para que ela leia os dados" (seção "ROM em VHDL", p. 1). Ela lê a
cada borda, mas só a leitura feita no fim do estado 0 importa, porque o IR só grava no fim do estado 1.

### 5.3 Unidade de controle (`un_controle.vhd`)

Interface:

| Porta | Dir. | Largura | Função |
|---|---|---|---|
| `instr` | in | 16 | saída do IR |
| `estado` | in | 2 | estado atual |
| `pc_atual` | in | 7 | saída do PC |
| `pc_wr_en` | out | 1 | escreve o PC (estado 2) |
| `pc_prox` | out | 7 | próximo PC: `instr(6 downto 0)` no JMP, `pc_atual+1` nos demais |
| `ir_wr_en` | out | 1 | escreve o IR (estado 1) |
| `banco_wr_en` | out | 1 | escreve o banco (estado 2 e LD/MOV/ADD/SUB) |
| `ula_controle` | out | 2 | `00` soma (ADD), `01` subtração (SUB); `00` nos demais |
| `sel_dado_banco` | out | 2 | `00` ULA, `01` constante (LD), `10` `data_r2` (MOV) |
| `cte_estendida` | out | 16 | constante de 9 bits estendida para 16 |
| `reg_r1`, `reg_r2`, `reg_wr` | out | 3 | `instr(11 downto 9)`, `instr(8 downto 6)`, `instr(11 downto 9)` |

Decodificação como no *µProcessador 4*: "Para decodificar instruções, basta separar os bits do opcode em
sinais parciais e fazer comparações simples" (seção "Unidade de Controle com Jump", p. 3). O livro diz o
mesmo papel da UC: "The control unit must be able to take inputs and generate a write signal for each state
element, the selector control for each multiplexor, and the ALU control." (P&H, seção 4.4, p. 269).

Tabela de controle (estado 2):

| Instrução | banco_wr_en | sel_dado_banco | ula_controle | pc_prox |
|---|---|---|---|---|
| NOP | 0 | – | – | PC+1 |
| LD | 1 | 01 (constante) | – | PC+1 |
| MOV | 1 | 10 (`data_r2` = Rs) | – | PC+1 |
| ADD | 1 | 00 (ULA) | 00 | PC+1 |
| SUB | 1 | 00 (ULA) | 01 | PC+1 |
| JMP | 0 | – | – | `instr(6..0)` |
| outros | 0 | – | – | PC+1 |

Como o banco sempre lê Rd em `data_r1` e Rs em `data_r2`, a ULA recebe `A = Rd`, `B = Rs`, e o resultado volta
para Rd (2 operandos). No MOV, o dado escrito é `data_r2` direto, sem passar pela ULA. `sel_ula_b` (mux da
entrada B da ULA) ainda não existe neste lab porque nenhuma instrução do lab 5 opera a ULA com constante; ele
entra no lab 6 com o CMPI.

**Extensão de sinal** (só `when-else` e `&`):

```
cte_estendida <= "0000000" & instr(8 downto 0) when instr(8)='0' else
                 "1111111" & instr(8 downto 0) when instr(8)='1' else
                 "0000000000000000";
```

Base: "The shortcut is to take the most significant bit from the smaller quantity—the sign bit—and replicate
it to fill the new bits of the larger quantity. [...] This shortcut is called sign extension." (P&H, seção 2.4
*Signed and Unsigned Numbers*, p. 85). No hardware do livro isso é o bloco Imm Gen (P&H, seção 4.4,
Figure 4.17, p. 274, tabela "Immediate Output Bit by Bit", em que os bits altos são cópias de `i31`).

**Seleção do próximo PC:** um mux entre "endereço do JMP" e "PC+1", como nos slides: "o PC deve ser escrito
com o valor PC+delta endereços quando [...] caso contrário, devemos escrever PC+4 no PC. Isso nos dá um
simples mux" (`cap2-ciclo-unico.pdf`, seção 6.2, p. 14). Somamos 1 porque cada endereço da ROM guarda uma
instrução inteira.

### 5.4 Banco de registradores (interface alterada)

Mesmo banco do lab 3 (8 x `reg16bits`, `when-else` para o `wr_en` de cada um e mux de leitura), com **8 portas
de saída a mais**, `saida_r0` .. `saida_r7`, ligadas direto nos registradores. Motivo: o PDF pede os "valores
internos de todos os registradores, em ordem" visíveis no gtkwave (*µProcessador 5*, "Testes", p. 2); a forma
mais simples foi levá-los até pinos do top-level (`r0`..`r7`). A parte original da interface não mudou:

```
entity banco is
   port( data_wr                : in unsigned(15 downto 0);
         reg_wr, reg_r1, reg_r2 : in unsigned(2 downto 0);
         clk, wr_en, rst        : in std_logic;
         data_r1, data_r2       : out unsigned(15 downto 0);
         saida_r0, saida_r1, saida_r2, saida_r3 : out unsigned(15 downto 0);
         saida_r4, saida_r5, saida_r6, saida_r7 : out unsigned(15 downto 0));
```

### 5.5 ULA

Interface fixada para todos os labs: `A, B` (16 bits), `carry_in`, `controle` (2 bits), `ULA_Out`, `zero`,
`carry`, `overflow`, `sinal`. Operações: `00` A+B, `01` A−B, `10` A−B−carry_in, `11` A and B. Neste lab só
`00` e `01` são usadas, `carry_in` está ligado em `'0'` e as flags ainda não são guardadas (isso é o lab 6).

### 5.6 Top-level (`processador.vhd`)

Portas: `clk`, `rst` (entradas); `estado` (2), `valor_pc` (7), `instrucao` (16, saída do IR), `saida_ula` (16),
`r0`..`r7` (16 cada). O nome `valor_pc` foi usado porque `pc` já é o nome do componente. No testbench os
sinais se chamam, nesta ordem de declaração: `reset`, `clk`, `estado`, `pc`, `instrucao`, `saida_ula`,
`r0`..`r7` — a ordem pedida pelo PDF.

## 6. Programa-teste (`lab5/programa.asm`)

| End. | Passo | Assembly | Binário | Hexa |
|---|---|---|---|---|
| 0 | A | `LD R3,5` | `0001 011 000000101` | 1605 |
| 1 | B | `LD R4,8` | `0001 100 000001000` | 1808 |
| 2 | (aux.) | `LD R1,1` | `0001 001 000000001` | 1201 |
| 3 | C | `MOV R5,R3` | `0010 101 011 000000` | 2AC0 |
| 4 | C | `ADD R5,R4` | `0011 101 100 000000` | 3B00 |
| 5 | D | `SUB R5,R1` | `0100 101 001 000000` | 4A40 |
| 6 | E | `JMP 20` | `1000 00000 0010100` | 8014 |
| 7 | F | `LD R5,0` | `0001 101 000000000` | 1A00 |
| 8..19 | – | (NOP) | `0000 000000000000` | 0000 |
| 20 | G | `MOV R3,R5` | `0010 011 101 000000` | 2740 |
| 21 | H | `JMP 3` | `1000 00000 0000011` | 8003 |
| 22 | I | `LD R3,0` | `0001 011 000000000` | 1600 |

Observações ligadas ao sorteio:

- **Passo C** (R5 ← R3+R4): com ADD de 2 operandos não existe `ADD R5,R3,R4` (e o *Características*, seção 1,
  proíbe executar essa forma). São duas instruções: `MOV R5,R3` e `ADD R5,R4`. O próprio PDF prevê: "implementar
  o passo C (R5 <= R3+R4) pode exigir várias instruções" (*µProcessador 5*, p. 3).
- **Passo D** (R5 ← R5−1): não existe SUBI ("Subtração apenas entre registradores, nunca com constantes",
  sorteio). Por isso a constante 1 é carregada em R1 **uma vez**, no endereço 2, antes do laço (fora dele,
  para não gastar clocks a cada volta). O passo A continua no endereço 0, que não é NOP.
- `LD R5,0` e `LD R3,0` são a forma de "zerar" com o nosso assembly (não há CLR no sorteio).
- O JMP do passo H volta para o endereço 3, a primeira instrução do passo C.

## 7. Resultados da simulação

Simulação com GHDL 4.1 (`processador_tb`, 30 µs, clock de 100 ns, reset nos 200 ns iniciais) e conferência
automática do VCD por um script Python da equipe (fora do repositório). Tempos abaixo = borda de subida em
que o valor foi gravado.

Primeiras instruções executadas (PC durante o estado 2, IR, efeito):

| Borda (ns) | PC exec. | IR | Efeito observado |
|---|---|---|---|
| 450 | 0 | 1605 | R3 = 5, PC → 1 |
| 750 | 1 | 1808 | R4 = 8, PC → 2 |
| 1050 | 2 | 1201 | R1 = 1, PC → 3 |
| 1350 | 3 | 2AC0 | R5 = 5 |
| 1650 | 4 | 3B00 | R5 = 13 |
| 1950 | 5 | 4A40 | R5 = 12 |
| 2250 | 6 | 8014 | PC → 20 (o endereço 7 nunca é executado) |
| 2550 | 20 | 2740 | R3 = 12 |
| 2850 | 21 | 8003 | PC → 3 (o endereço 22 nunca é executado) |
| 3150.. | 3,4,5,6,20,21,... | | laço |

- A instrução do endereço 0 é executada (PC=0 no primeiro estado 2, 350–450 ns); `0x0000` é NOP.
- Os PCs executados foram sempre 0,1,2 e depois o ciclo 3,4,5,6,20,21; **7 e 22 nunca aparecem**, ou seja,
  nenhuma instrução após um JMP é executada.
- Valores de R5 após o passo D (SUB) em cada volta: **12, 19, 26, 33, 40, 47, 54, 61, 68, 75, 82**
  (bordas 1950, 3750, 5550, 7350, 9150, 10950, 12750, 14550, 16350, 18150, 19950 ns) — a sequência pedida
  pelo PDF (0x0C, 0x13, 0x1A, 0x21, 0x28, ...).
- Como o passo C precisa de duas instruções, R5 passa por dois valores intermediários em cada volta: primeiro
  recebe R3 (que já é igual ao R5 anterior, então não muda a partir da 2ª volta) e depois R3+R4 (13, 20, 27, ...),
  antes do SUB. Isso é consequência direta do sorteio (2 operandos), não erro.
- Cada volta do laço tem 6 instruções x 3 clocks = 18 clocks = 1800 ns (medido: R5=19 em 3750 ns, R5=26 em
  5550 ns). Teste de sanidade pedido no *µProcessador 4* ("Estime o número de clocks necessários", p. 4).
- Estado final (30 µs): R1=1, R3=117, R4=8, R5=117, demais 0.
- As mensagens `NUMERIC_STD."=": metavalue detected` aparecem só em 0 ms, antes do primeiro clock, quando a
  saída da ROM ainda é `U`; depois disso não há mais nenhuma.

## 8. Verificação da lógica sequencial (desenho pedido no PDF)

O PDF pede: "desenhe manualmente [...] as formas de onda dos seguintes sinais [...] para a execução completa
de uma instrução: clock, wr_en do PC, valor do PC, wr_en do acumulador (se houver), valor do acumulador,
wr_en dos registradores e valor do registrador escrito. Em especial, identifique o estado de cada ciclo de
clock e a transição dos valores" (*µProcessador 5*, "Verificação da Lógica Sequencial", p. 4). Não há
acumulador (ISA ortogonal).

Desenho **esperado** (feito antes de olhar a simulação), para `SUB R5,R1` no endereço 5, segunda volta do
laço (R5 vale 20 = 0x14 e deve passar a 19 = 0x13):

```
Estado      |  2  |  0  |  1  |  2  |  0  |
Ck         _|‾‾|__|‾‾|__|‾‾|__|‾‾|__|‾‾|__
                  ^     ^     ^     ^
                  |     |     |     +-- fim do estado 2: grava PC e R5
                  |     |     +-------- fim do estado 1: IR <- ROM (SUB)
                  |     +-------------- fim do estado 0: ROM lê ROM[5]
                  +-------------------- ADD anterior grava PC=5 e R5=20
pc_wr_en    ‾‾‾‾‾‾|_____________|‾‾‾‾‾|_____
            ______ _________________ _______
PC           4    X        5        X  6
            ‾‾‾‾‾‾ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾ ‾‾‾‾‾‾‾
            ______ _____ ___________ _______
instrucao    ADD  X ADD X    SUB    X  SUB
            ‾‾‾‾‾‾ ‾‾‾‾‾ ‾‾‾‾‾‾‾‾‾‾‾ ‾‾‾‾‾‾‾
banco_wr_en ‾‾‾‾‾‾|_____________|‾‾‾‾‾|_____
            ______ _________________ _______
R5           13   X       20        X  19
            ‾‾‾‾‾‾ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾ ‾‾‾‾‾‾‾
```

(`instrucao` é a saída do IR: fica com o ADD durante os estados 0 e 1 e muda para o SUB só na borda que termina
o estado 1.)

**Simulação real** (VCD, sinais `clk`, `estado`, `uut.pc_wr_en_s`, `pc`, `instrucao`, `uut.banco_wr_en_s`,
`uut.bancoreg.wr_en5`, `r5`):

| Tempo (ns) | Evento |
|---|---|
| 3350 | borda, estado 1→2 do ADD; `pc_wr_en`=1, `banco_wr_en`=1 |
| 3450 | borda: PC 4→5, R5 0x0D→0x14 (13→20); estado 2→0; enables→0 |
| 3550 | borda: estado 0→1; saída da ROM passa a 0x4A40 (SUB R5,R1) |
| 3650 | borda: estado 1→2; IR = 0x4A40; `pc_wr_en`=1; `banco_wr_en`=1; `wr_en5`=1; dado na entrada do banco = 0x13 |
| 3750 | borda: PC 5→6; R5 0x14→0x13 (20→19); estado 2→0; enables→0 |

A simulação bate com o desenho: o PC e R5 mudam na mesma borda (fim do estado 2), os enables ficam em 1 só
durante o estado 2, e a instrução no IR troca uma borda antes (fim do estado 1).

## 9. Como rodar

```
cd lab5
./run.sh
```

O `run.sh` faz `ghdl -a` de todos os fontes, `ghdl -e processador_tb`, `ghdl -r processador_tb
--wave=processador_tb.ghw` e abre `gtkwave processador_tb.ghw processador_tb.gtkw`. O `.gtkw` já coloca os
sinais na ordem do PDF: `reset`, `clk`, `estado`, `pc`, `instrucao` (hexa), `saida_ula` e `r0`..`r7` (decimal
com sinal). Para depurar, os sinais internos estão na hierarquia `top.processador_tb.uut` (ex.: `pc_wr_en_s`,
`banco_wr_en_s`, `rom_dado_s`). Os arquivos gerados (`.ghw`, `work-obj93.cf`) estão no `.gitignore`.
