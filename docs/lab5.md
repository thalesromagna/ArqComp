# Lab 5 — "Calculadora Programável" (ROM + PC + UC + banco + ULA executando um programa)

Arquivos em `lab5/`. Base: PDF *µProcessador 5* ("Calculadora Programável"), mais os modelos de VHDL
dos PDFs *µProcessador 3* (registrador e testbench) e *µProcessador 4* (ROM). As decisões gerais (dados de
16 bits, instrução de 17 bits, PC de 7 bits na borda de descida, ROM síncrona, 3 estados, sem registrador de
instrução, codificação) estão em `docs/00-especificacoes.md`.

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
- Borda de descida: "Se algum item sorteado for sensível a rampa de descida, utilize falling_edge(clk) ao
  invés de rising_edge(clk)." (seção "Contadores em VHDL", p. 1). O Email 3 sorteou `'Incremento do PC':
  ['PC sensível a clock de descida']`.
- "Sugiro fazer uma máquina de 3 estados: fetch, decode e execute" e "Caso o seu sorteio especifique um
  Registrador de Instrução, basta adicionar no circuito um registrador comum que apenas armazena a instrução
  lida da ROM, instrução esta que será executada nos clocks seguintes." (seção "Implementação", p. 2). O
  Email 3 sorteou `'Registrador de Instruções': ['não usar']`, então **não há registrador de instrução**.
- "O tamanho das instruções é sorteado para a equipe, e é igual à largura de um dado da ROM." (seção
  "Implementação", p. 2). O Email 3 sorteou 17 bits, logo a ROM tem dados de 17 bits.
- Pinos no gtkwave, "preferencialmente nesta ordem": reset; clock; estado; PC; "instrução (saída do
  Registrador de Instrução, ou, se não houver, da ROM)"; saída da ULA; "saídas do acumulador e valores
  internos de todos os registradores, em ordem." (seção "Testes", p. 2). Como não há registrador de
  instrução, o pino `instrucao` é a saída da ROM.
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
| `reg16bits.vhd` | registrador de 16 bits (modelo `reg8bits` do *µProcessador 3*); usado nos 8 registradores do banco |
| `pc.vhd` | PC: registrador de 7 bits, mesmo modelo, com `falling_edge(clk)` (borda de descida, Email 3) |
| `maq_estados.vhd` | contador 0,1,2 do *µProcessador 5* |
| `rom.vhd` | ROM síncrona de 128 x 17 bits (modelo do *µProcessador 4*) com o programa |
| `banco.vhd` | banco com 8 registradores de 16 bits (R0..R7) |
| `ula.vhd` | ULA de 16 bits com flags (idêntica à do lab 2, ver `docs/lab2.md`) |
| `un_controle.vhd` | unidade de controle, só combinacional |
| `processador.vhd` | top-level |
| `processador_tb.vhd` | testbench top-level (nome exigido pelo PDF) |
| `programa.asm` | listagem do programa: endereço, assembly, binário (17 bits), hexa (5 dígitos) |
| `processador_tb.gtkw` | lista de sinais do gtkwave, já na ordem pedida |
| `run.sh` | compila, simula e abre o gtkwave |

O diretório é autocontido: todos os `.vhd` necessários estão nele.

## 3. Regras de VHDL respeitadas

- `process`/`if` só em: `reg16bits`, `pc` (registradores, modelo do *µProcessador 3*: "O if-then só deve ser
  usado nesta disciplina para criar um registrador!", seção "Registrador Padrão", p. 2), `rom` (modelo do
  *µProcessador 4*) e `maq_estados` (modelo do *µProcessador 5*) e no testbench.
- O `pc.vhd` é o mesmo registrador do `reg16bits.vhd` (7 bits em vez de 16), trocando apenas
  `rising_edge(clk)` por `falling_edge(clk)`, como manda o *µProcessador 5* ("Se algum item sorteado for
  sensível a rampa de descida, utilize falling_edge(clk) ao invés de rising_edge(clk).", seção "Contadores em
  VHDL", p. 1).
- Todo o resto é `when-else` terminado em `else` zero (*µProcessador 2*: "Numa estrutura when-else sempre
  termine com else '0';", seção "Multiplexação", p. 2), `&`, recortes, `+`, `-`, `and`, `port map`.
- Sem comentários no código. **Desvio consciente:** o `maq_estados.vhd` é o código do PDF linha por linha,
  mas sem os três comentários `-- se agora esta em 2`, `-- o prox vai voltar ao zero`, `-- senao avanca`,
  porque a regra da equipe é não ter comentários nos fontes. Nenhum comando foi alterado.

## 4. Codificação das instruções (formato de 17 bits)

Codificação completa em `docs/00-especificacoes.md`, seção 4. A instrução tem 17 bits (Email 3): opcode de
**5 bits** em b16..b12 e campos em b11..b0. As instruções implementadas **neste lab** são:

```
MSB b16                      b0 LSB
NOP        00000 000000000000          nada
LD  Rd,cte 00001 ddd ccccccccc         Rd <- cte (9 bits, complemento de 2, com extensão de sinal)
MOV Rd,Rs  00010 ddd sss xxxxxx        Rd <- Rs
ADD Rd,Rs  00011 ddd sss xxxxxx        Rd <- Rd + Rs
SUB Rd,Rs  00100 ddd sss xxxxxx        Rd <- Rd - Rs
JMP end    01000 xxxxx aaaaaaa         PC <- end (endereço absoluto de 7 bits)

ddd = registrador destino/primeiro operando, sss = registrador fonte, ccccccccc = constante,
aaaaaaa = endereço absoluto, x = irrelevante (gravado como 0)
```

Todos os outros opcodes (00101 a 00111 e 01001 a 11111) **não fazem nada** neste lab: não escrevem no banco e
o PC avança 1, como um NOP. Isso segue "O processador não deverá executar opcodes fora do que foi
explicitamente pedido" (*Características do Projeto do µP*, seção 1, p. 2). O código `0x00000` (17 zeros) é
NOP (opcode 00000), como pede a avaliação do *µProcessador 5* (p. 4).

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
  instrução vai ser escrita no PC)" (seção 5.1, p. 7). O Email 3 sorteou `'Saltos': 'Incondicional é
  absoluto e condicional é relativo'`.

## 5. Circuito

### 5.1 Diagrama de blocos

```
            +-----------+  estado
  clk,rst ->|maq_estados|---------------------------------------+
            +-----------+                                       |
                                                                v
   +-----------+ pc_s     +----------+ instrucao         +-------------+
   |    PC     |----+---->|   ROM    |------------------>| un_controle |--> pc_wr_en, pc_prox
   | (descida) |    |     | sinc.    | (saída dado da    | (when-else) |--> banco_wr_en
   +-----------+    |     | 128 x 17 |  ROM, 17 bits)    |             |--> ula_controle
        ^           |     +----------+                   |             |--> sel_dado_banco
        |           +---------- pc_atual --------------->|             |--> cte_estendida
        |  pc_prox                                       |             |--> reg_r1/reg_r2/reg_wr
        +------------------------------------------------|             |
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

### 5.2 Multiciclo de 3 estados, sem registrador de instrução

O nosso processador não é ciclo único: cada instrução leva 3 clocks. Base:

- Slides: "Uma maneira simples de dividir a execução de uma instrução é quebrá-la em alguns estados
  padronizados. Um esquema simples e típico pode ser: Fetch (busca): lê a instrução da memória (e incrementa
  o PC); Decode: decodifica a instrução, identificando-a e gerando os sinais de controle necessários;
  Execute: realiza a operação em si e grava os resultados de acordo." e "O estado inicial no reset é fetch,
  e a cada clock temos uma transição, ciclicamente. Isso pode ser facilmente implementado como um simples
  contador." (`cap2-ciclo-unico.pdf`, seção 8.2, Figura 12, p. 19).
- Livro: "In a multicycle implementation, each step in the execution will take 1 clock cycle." (P&H, seção
  4.5 *A Multicycle Implementation*, p. 282).

**Diferença em relação ao slide:** no slide o fetch "incrementa o PC"; aqui o PC só é gravado no execute, na
descida do meio do estado 2 (linha do tempo abaixo). O próximo PC depende da instrução decodificada (o
endereço do JMP) e é calculado com o PC da própria instrução (`pc_atual`, que os desvios relativos do lab 6
vão usar). Além disso, sem registrador de instrução a ROM lê `ROM[PC]` em toda subida: se o PC mudasse no
meio do fetch, a subida que encerra o estado 0 já traria a instrução seguinte. O próprio slide admite
dividir as operações de outro jeito: "Podemos, é claro, fazer um processador com mais estados, ou com menos,
dividindo as operações de forma diferente." (idem, p. 19). O *µProcessador 4* também mandava "fazer a
leitura da ROM no estado 0 (fetch) e a atualização do PC no estado 1 (decode/execute)" (seção "Unidade de
Controle com Jump", p. 3), mas na máquina de **2 estados** daquele lab; com os nossos 3 estados, o
decode/execute virou os estados 1 e 2, e o PC é gravado no estado 2.

**Sem registrador de instrução (Email 3).** O *µProcessador 5* só pede o IR "Caso o seu sorteio especifique
um Registrador de Instrução" (seção "Implementação", p. 2) e já prevê a ausência dele na lista de sinais:
"instrução (saída do Registrador de Instrução, ou, se não houver, da ROM)" (seção "Testes", p. 2). Por isso a
saída `dado` da ROM vai direto para a entrada `instr` da `un_controle`, e é ela que aparece no pino
`instrucao`.

No livro o IR existe porque "any data produced by one of these three functional units (the memory, the
register file, or the ALU) must be saved into a temporary register for use on a later cycle" e "The IR needs
to hold the instruction until the end of execution of that instruction" (P&H, seção 4.5, p. 282.e2), num
projeto em que "A single memory unit is used for both instructions and data" (idem, p. 282.e1). No nosso
caso a ROM só guarda instruções e, por ser síncrona, a sua saída já é um valor registrado: "Note que esta ROM
é sincrona! Isto significa que é preciso dar um clock nela para que ela leia os dados" (*µProcessador 4*,
seção "ROM em VHDL", p. 1). A saída `dado` só muda numa borda de subida, e o endereço (PC) só muda uma vez por
instrução, na descida do meio do estado 2. Então a instrução fica estável desde a subida que encerra o
estado 2 da instrução anterior até a subida que encerra o seu próprio estado 2, que é exatamente o intervalo
em que a `un_controle` precisa dela.

**Linha do tempo de uma instrução** (bordas de subida em 50, 150, 250... ns e de descida em 100, 200, 300...
ns no testbench):

| Estado | Nome | O que acontece | Enables ativos |
|---|---|---|---|
| 0 (`00`) | fetch | o PC aponta a instrução; na subida que encerra o estado 0 a ROM síncrona registra `ROM[PC]` | nenhum |
| 1 (`01`) | decode | a saída da ROM é a instrução; a `un_controle` decodifica, o banco lê, a ULA calcula | nenhum |
| 2 (`10`) | execute | na **descida** do meio do estado o PC recebe `pc_prox`; na **subida** que encerra o estado gravam o banco (com os sinais da instrução atual, pois a saída da ROM só muda nessa mesma borda) e a ROM já lê a próxima instrução | `pc_wr_en`, `banco_wr_en` (se a instrução escreve) |

A ROM não tem enable e lê em toda subida. Como o PC já mudou na descida do estado 2, a leitura da subida que
encerra o estado 2 já traz a próxima instrução, e a leitura do fim do estado 0 relê o mesmo endereço (o
valor não muda). Os três estados continuam, porque o contador do *µProcessador 5* deve ser reproduzido "ipsis
literis" e os estados separam as bordas: PC na descida do estado 2, banco na subida que o encerra.

O próximo PC é calculado com o PC da própria instrução (`pc_atual`), pois até a descida do estado 2 o PC ainda
contém o endereço da instrução corrente (isso será usado nos branches do lab 6). Depois da descida o
`pc_prox` passa a valer PC+1 do novo PC, mas isso não é gravado: a próxima descida já cai no estado 0, com
`pc_wr_en` em 0. Enables:

```
pc_wr_en    <= '1' when estado="10" else '0';
banco_wr_en <= '1' when estado="10" and (LD ou MOV ou ADD ou SUB) else '0';   (escrito como when-else, uma linha por instrução)
```

### 5.3 Unidade de controle (`un_controle.vhd`)

Interface:

| Porta | Dir. | Largura | Função |
|---|---|---|---|
| `instr` | in | 17 | saída `dado` da ROM (não há registrador de instrução) |
| `estado` | in | 2 | estado atual |
| `pc_atual` | in | 7 | saída do PC |
| `pc_wr_en` | out | 1 | escreve o PC (estado 2, na descida) |
| `pc_prox` | out | 7 | próximo PC: `instr(6 downto 0)` no JMP, `pc_atual+1` nos demais |
| `banco_wr_en` | out | 1 | escreve o banco (estado 2 e LD/MOV/ADD/SUB) |
| `ula_controle` | out | 2 | `00` soma (ADD), `01` subtração (SUB); `00` nos demais |
| `sel_dado_banco` | out | 2 | `00` ULA, `01` constante (LD), `10` `data_r2` (MOV) |
| `cte_estendida` | out | 16 | constante de 9 bits estendida para 16 |
| `reg_r1`, `reg_r2`, `reg_wr` | out | 3 | `instr(11 downto 9)`, `instr(8 downto 6)`, `instr(11 downto 9)` |

O opcode é `instr(16 downto 12)` (5 bits), comparado com `"00001"` (LD), `"00010"` (MOV), `"00011"` (ADD),
`"00100"` (SUB) e `"01000"` (JMP). Os campos (b11..b0) são os mesmos de antes.

Decodificação como no *µProcessador 4*: "Para decodificar instruções, basta separar os bits do opcode em
sinais parciais e fazer comparações simples" (seção "Unidade de Controle com Jump", p. 3). O livro diz o
mesmo papel da UC: "The control unit must be able to take inputs and generate a write signal for each state
element, the selector control for each multiplexor, and the ALU control." (P&H, final da seção 4.3 *Building
a Datapath*, p. 269).

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
Figure 4.18, p. 274, tabela "Immediate Output Bit by Bit", em que os bits altos são cópias de `i31`).

**Seleção do próximo PC:** um mux entre "endereço do JMP" e "PC+1", como nos slides: "o PC deve ser escrito
com o valor PC+delta endereços quando [...] caso contrário, devemos escrever PC+4 no PC. Isso nos dá um
simples mux" (`cap2-ciclo-unico.pdf`, seção 6.2, p. 14). Somamos 1, e não 4, porque o enunciado manda: "A
“contagem” vai ser dada por um circuito externo somador com 1." (*µProcessador 4*, "Contador de Programa",
p. 2); e porque cada endereço da nossa ROM guarda uma instrução inteira de 17 bits (o tamanho das instruções
"é igual à largura de um dado da ROM", *µProcessador 5*, "Implementação", p. 2). No RISC-V se soma 4 porque
"cada instrução ocupa 4 endereços" (`cap2-ciclo-unico.pdf`, seção 3.1, p. 6), já que "Cada endereço de
memória tem um byte, cada instrução tem 4 bytes = 32 bits" (idem, nota de rodapé 1).

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

Portas: `clk`, `rst` (entradas); `estado` (2), `valor_pc` (7), `instrucao` (17, saída da ROM), `saida_ula`
(16), `r0`..`r7` (16 cada). O nome `valor_pc` foi usado porque `pc` já é o nome do componente. Instâncias:
`maq_estados`, `pc`, `rom`, `un_controle`, `banco` e `ula`; o sinal `rom_dado_s` liga a ROM à unidade de
controle e ao pino `instrucao`. No testbench os sinais se chamam, nesta ordem de declaração: `reset`, `clk`,
`estado`, `pc`, `instrucao`, `saida_ula`, `r0`..`r7` — a ordem pedida pelo PDF.

## 6. Programa-teste (`lab5/programa.asm`)

| End. | Passo | Assembly | Binário (17 bits) | Hexa |
|---|---|---|---|---|
| 0 | A | `LD R3,5` | `00001 011 000000101` | 01605 |
| 1 | B | `LD R4,8` | `00001 100 000001000` | 01808 |
| 2 | (aux.) | `LD R1,1` | `00001 001 000000001` | 01201 |
| 3 | C | `MOV R5,R3` | `00010 101 011 000000` | 02AC0 |
| 4 | C | `ADD R5,R4` | `00011 101 100 000000` | 03B00 |
| 5 | D | `SUB R5,R1` | `00100 101 001 000000` | 04A40 |
| 6 | E | `JMP 20` | `01000 00000 0010100` | 08014 |
| 7 | F | `LD R5,0` | `00001 101 000000000` | 01A00 |
| 8..19 | – | (NOP) | `00000 000000000000` | 00000 |
| 20 | G | `MOV R3,R5` | `00010 011 101 000000` | 02740 |
| 21 | H | `JMP 3` | `01000 00000 0000011` | 08003 |
| 22 | I | `LD R3,0` | `00001 011 000000000` | 01600 |

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

Simulação com GHDL 4.1 (`processador_tb`, 30 µs, clock de 100 ns com subidas em 50, 150, 250... ns e descidas
em 100, 200, 300... ns, reset nos 200 ns iniciais) e conferência automática do VCD por um script Python da
equipe (fora do repositório).

Primeiras instruções executadas. "Descida" = borda em que o PC mudou (meio do estado 2); "Subida" = borda em
que o banco gravou (fim do estado 2); "instrução" = saída da ROM durante o estado 2:

| Descida (ns): PC | Subida (ns) | PC exec. | instrução | Efeito no banco |
|---|---|---|---|---|
| 400: 0 → 1 | 450 | 0 | 01605 | R3 = 5 |
| 700: 1 → 2 | 750 | 1 | 01808 | R4 = 8 |
| 1000: 2 → 3 | 1050 | 2 | 01201 | R1 = 1 |
| 1300: 3 → 4 | 1350 | 3 | 02AC0 | R5 = 5 |
| 1600: 4 → 5 | 1650 | 4 | 03B00 | R5 = 13 |
| 1900: 5 → 6 | 1950 | 5 | 04A40 | R5 = 12 |
| 2200: 6 → 20 | 2250 | 6 | 08014 | nenhum (o endereço 7 nunca é executado) |
| 2500: 20 → 21 | 2550 | 20 | 02740 | R3 = 12 |
| 2800: 21 → 3 | 2850 | 21 | 08003 | nenhum (o endereço 22 nunca é executado) |
| 3100.. | 3150.. | 3,4,5,6,20,21,... | | laço |

- A instrução do endereço 0 é executada (PC=0 no primeiro estado 2, 350–450 ns; R3 = 5 em 450 ns).
- Os PCs executados foram sempre 0,1,2 e depois o ciclo 3,4,5,6,20,21; o PC **nunca vale 7 nem 22** e a
  saída da ROM nunca mostra `01A00` nem `01600`, ou seja, nenhuma instrução após um JMP é executada.
- No VCD inteiro o PC só muda em bordas de descida, e `instrucao` e os registradores só mudam em bordas de
  subida.
- `0x00000` é NOP: num teste à parte (cópia da ROM fora do repositório, com `JMP 8` no lugar de `JMP 20` para
  passar pelos endereços 8..19), cada `00000` e também um opcode não usado (`1FBFF`, opcode 11111) deixaram
  `banco_wr_en` em 0, nenhum registrador mudou e o PC avançou 1.
- Valores de R5 após o passo D (SUB) em cada volta: **12, 19, 26, 33, 40, 47, 54, 61, 68, 75, 82, 89, 96,
  103, 110, 117** (subidas de 1950, 3750, 5550, 7350, 9150, 10950, 12750, 14550, 16350, 18150, 19950,
  21750, 23550, 25350, 27150, 28950 ns; 16 voltas em 30 µs) — a sequência pedida pelo PDF (0x0C, 0x13, 0x1A,
  0x21, 0x28, ...).
- Como o passo C precisa de duas instruções, R5 passa por dois valores intermediários em cada volta: primeiro
  recebe R3 (que já é igual ao R5 anterior, então não muda a partir da 2ª volta) e depois R3+R4 (13, 20, 27, ...),
  antes do SUB. Isso é consequência direta do sorteio (2 operandos), não erro.
- Cada volta do laço tem 6 instruções x 3 clocks = 18 clocks = 1800 ns (medido: R5=19 em 3750 ns, R5=26 em
  5550 ns). Teste de sanidade pedido no *µProcessador 4* ("Estime o número de clocks necessários", p. 4).
- Estado final (30 µs): R1=1, R3=117, R4=8, R5=117, demais 0.
- Durante o reset o PC vale 0 e a ROM (que não tem reset) já lê `ROM[0]` nas subidas de 50 e 150 ns, por isso
  `instrucao` mostra `01605` desde 50 ns; nada é gravado, porque o estado fica em 0 até o reset cair (200 ns).
- As mensagens `NUMERIC_STD."=": metavalue detected` aparecem só em 0 ms, antes da primeira subida do clock,
  quando a saída da ROM ainda é `U`; depois disso não há mais nenhuma.

## 8. Verificação da lógica sequencial (desenho pedido no PDF)

O PDF pede: "desenhe manualmente [...] as formas de onda dos seguintes sinais [...] para a execução completa
de uma instrução: clock, wr_en do PC, valor do PC, wr_en do acumulador (se houver), valor do acumulador,
wr_en dos registradores e valor do registrador escrito. Em especial, identifique o estado de cada ciclo de
clock e a transição dos valores" (*µProcessador 5*, "Verificação da Lógica Sequencial", p. 4). Não há
acumulador (ISA ortogonal).

Desenho **esperado**, montado a partir da linha do tempo da seção 5.2, para `SUB R5,R1` no endereço 5,
segunda volta do laço (R5 vale 20 = 0x14 e deve passar a 19 = 0x13). Cada estado dura um período: começa
numa subida, tem a descida no meio e termina na subida seguinte. O PC (borda de descida) muda no meio do
estado 2; o banco (borda de subida) grava na subida que encerra o estado 2.

```
tempo (ns)    3350        3450        3550        3650        3750
estado        |   2 ADD   |     0     |     1     |   2 SUB   |     0     |
clk          _|‾‾‾‾‾|_____|‾‾‾‾‾|_____|‾‾‾‾‾|_____|‾‾‾‾‾|_____|‾‾‾‾‾|______
borda               a     b           c           d     e     f
pc_wr_en     _|‾‾‾‾‾‾‾‾‾‾‾|_______________________|‾‾‾‾‾‾‾‾‾‾‾|____________
             _______ ___________________________________ __________________
PC            4     X 5                                 X 6
             ‾‾‾‾‾‾‾ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
             _____________ ___________________________________ ____________
instrucao     ADD         X SUB R5,R1 (04A40)                 X JMP 20
             ‾‾‾‾‾‾‾‾‾‾‾‾‾ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾ ‾‾‾‾‾‾‾‾‾‾‾‾
banco_wr_en  _|‾‾‾‾‾‾‾‾‾‾‾|_______________________|‾‾‾‾‾‾‾‾‾‾‾|____________
             _____________ ___________________________________ ____________
R5            12 (0x0C)   X 20 (0x14)                         X 19 (0x13)
             ‾‾‾‾‾‾‾‾‾‾‾‾‾ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾ ‾‾‾‾‾‾‾‾‾‾‾‾
```

- a (descida, meio do estado 2 do ADD): PC 4 → 5.
- b (subida que encerra o estado 2 do ADD): R5 recebe 20; a ROM lê `ROM[5]` e `instrucao` passa a SUB.
- c (subida que encerra o estado 0): a ROM relê `ROM[5]`; a instrução não muda.
- d (subida que encerra o estado 1): começa o estado 2 do SUB; `pc_wr_en` e `banco_wr_en` vão a 1.
- e (descida, meio do estado 2 do SUB): PC 5 → 6.
- f (subida que encerra o estado 2 do SUB): R5 recebe 19; a ROM lê `ROM[6]` e `instrucao` passa a JMP 20;
  os enables voltam a 0.

(`instrucao` é a saída da ROM: não há registrador de instrução, então ela troca na mesma subida em que o banco
grava, e a gravação usa os sinais da instrução que estava lá antes da borda.)

**Simulação real** (VCD, sinais `clk`, `estado`, `uut.pc_wr_en_s`, `pc`, `instrucao`, `uut.banco_wr_en_s`,
`uut.bancoreg.wr_en5`, `uut.dado_banco_s`, `r5`):

| Tempo (ns) | Borda | Evento |
|---|---|---|
| 3350 | subida | estado 1→2 (ADD, PC=4); `pc_wr_en`=1, `banco_wr_en`=1, `wr_en5`=1 |
| 3400 | descida (a) | PC 4→5 |
| 3450 | subida (b) | R5 0x0C→0x14 (12→20); `instrucao` 03B00→04A40 (SUB R5,R1); estado 2→0; enables→0; `saida_ula` e dado na entrada do banco = 0x13 |
| 3550 | subida (c) | estado 0→1; nenhum evento em `instrucao` (a ROM releu o mesmo endereço) |
| 3650 | subida (d) | estado 1→2; `pc_wr_en`=1, `banco_wr_en`=1, `wr_en5`=1 |
| 3700 | descida (e) | PC 5→6 (`pc_prox` passa a 7, mas não é gravado: na descida de 3800 `pc_wr_en` já é 0) |
| 3750 | subida (f) | R5 0x14→0x13 (20→19); `instrucao` 04A40→08014 (JMP 20); estado 2→0; enables→0 |

A simulação bate com o desenho: o PC muda na descida do meio do estado 2 (3400 e 3700 ns), R5 muda na subida
que encerra o estado 2 (3450 e 3750 ns), 50 ns depois do PC, os enables ficam em 1 só durante o estado 2, e a
instrução na saída da ROM troca na mesma subida em que o banco grava.

## 9. Como rodar

```
cd lab5
./run.sh
```

O `run.sh` faz `ghdl -a` de todos os fontes, `ghdl -e processador_tb`, `ghdl -r processador_tb
--wave=processador_tb.ghw` e abre `gtkwave processador_tb.ghw processador_tb.gtkw`. O `.gtkw` já coloca os
sinais na ordem do PDF: `reset`, `clk`, `estado`, `pc`, `instrucao` (17 bits, hexa, saída da ROM),
`saida_ula` e `r0`..`r7` (decimal com sinal). Para depurar, os sinais internos estão na hierarquia
`top.processador_tb.uut` (ex.: `pc_wr_en_s`, `banco_wr_en_s`, `rom_dado_s`). Os arquivos gerados (`.ghw`,
`work-obj93.cf`) estão no `.gitignore`.
