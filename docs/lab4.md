# Lab 4 — Unidade de Controle Rudimentar (ROM, PC, máquina de estados, NOP e JMP)

Arquivos em `lab4/`. Base: PDF *µProcessador 4* ("Unidade de Controle Rudimentar") e, para o modelo de
registrador e de testbench, o PDF *µProcessador 3*. Todas as decisões gerais (largura de 16 bits, PC de
7 bits, codificação de NOP e JMP) vêm de `docs/00-especificacoes.md`.

O PDF resume o objetivo assim: "Vamos fazer um programa armazenado em ROM ser percorrido por um PC e
executar jumps incondicionais" (*µProcessador 4*, p. 1, introdução).

## 1. Sorteio da ROM: escolha PROVISÓRIA

O PDF pede: "Verifique no email com o seu sorteio para o microprocessador a largura dos dados da ROM
especificadas para a sua equipe de laboratório. Verifique também se a ROM é síncrona ou assíncrona"
(*µProcessador 4*, seção "ROM em VHDL", p. 2).

Esse sorteio **ainda não foi recebido** (ver `docs/00-especificacoes.md`, seção 2). Até ele chegar, a
equipe usa a escolha provisória registrada lá:

| Item | Valor provisório | Justificativa |
|---|---|---|
| Largura do dado da ROM | 16 bits | mesma largura dos dados do processador; codificação da seção 4 do `00-especificacoes.md` |
| Número de endereços | 128 (0 a 127) | "é uma ROM de 128 endereços" (*µProcessador 4*, "ROM em VHDL") |
| Síncrona ou assíncrona | síncrona | é o modelo do próprio PDF: "Note que esta ROM é sincrona!" (*µProcessador 4*, "ROM em VHDL", p. 1) |

Se o sorteio indicar outra largura, muda só `unsigned(15 downto 0)` na ROM, o sinal de instrução e os
recortes de `opcode`/endereço na unidade de controle. Se indicar ROM assíncrona, basta trocar a
arquitetura da ROM pelo trecho do PDF ("basta retirar o clock e o process", *µProcessador 4*, p. 1);
nesse caso a análise de tempo da seção 7 muda (a instrução passa a aparecer no mesmo ciclo do PC).

## 2. Ordem de trabalho (igual à do PDF) e arquivos

| Etapa do PDF | Arquivo | Testbench |
|---|---|---|
| "ROM em VHDL" | `rom.vhd` | `rom_tb.vhd` |
| "Máquina de Estados" (flip-flop T) | `maq_estados.vhd` | `maq_estados_tb.vhd` |
| "Contador de Programa" (registrador comum) | `pc.vhd` | `pc_tb.vhd` |
| "Conecte o PC à ROM!" (PC + somador +1, `wr_en=1`) | `pc_rom.vhd` | `pc_rom_tb.vhd` |
| "Unidade de Controle com Jump" (NOP e JMP) | `un_controle.vhd` | `un_controle_tb.vhd` |
| Top-level do lab | `processador.vhd` | `processador_tb.vhd` |
| Script de compilação e simulação | `run.sh` | – |

Regras de VHDL respeitadas (ver `00-especificacoes.md`, seção 5): `process`/`if` só na ROM síncrona
(cópia do modelo do lab 4), no PC (cópia do `reg8bits` do lab 3) e no flip-flop T (trecho do lab 4);
toda a lógica da unidade de controle é `when-else` terminando em `else` zero ("Use when-else para
construir qualquer lógica, que deve ser colocada fora do 'process.'", *µProcessador 4*, "Unidade de
Controle com Jump", p. 3). Não há comentários no código.

## 3. Entidades e interfaces

### 3.1 `rom` (`rom.vhd`)

```
port( clk      : in std_logic;
      endereco : in unsigned(6 downto 0);
      dado     : out unsigned(15 downto 0) );
```

Cópia do modelo do PDF, trocando apenas a largura do dado de 12 para 16 bits e o conteúdo. A leitura
acontece dentro de `process(clk)` com `rising_edge(clk)`: "só quando houver rampa de subida no clock é
que teremos uma resposta à saída" (*µProcessador 4*, "ROM em VHDL", p. 1). Endereços não listados valem
zero (`others => (others=>'0')`), ou seja, NOP.

### 3.2 `maq_estados` (`maq_estados.vhd`)

```
port( clk,rst: in std_logic;
      estado: out std_logic );
```

Flip-flop T de 1 bit. O PDF manda: "use um simples flip-flop T, ou seja, aquele que troca de estado a
cada clock" e mostra o trecho `estado <= not estado;` dentro do `elsif rising_edge(clk)`, lembrando
"Não esqueça do reset" (*µProcessador 4*, "Máquina de Estados", p. 2). Como uma porta `out` não pode ser
lida dentro da arquitetura, usamos o sinal interno `estado_s`, seguindo a dica do próprio PDF ("é comum
usar os sufixos _i, _o e _s ... 'dado_s' para o signal interno", mesma seção) e a forma da máquina do
*µProcessador 5*.

| `estado` | nome | o que acontece |
|---|---|---|
| 0 | fetch | a ROM lê `ROM[PC]` na borda de subida que encerra o estado |
| 1 | decode/execute | a unidade de controle decodifica a instrução e o PC é escrito na borda que encerra o estado |

Reset assíncrono leva a `estado = 0` (fetch).

### 3.3 `pc` (`pc.vhd`)

```
port( clk, rst, wr_en : in std_logic;
      data_in  : in unsigned(6 downto 0);
      data_out : out unsigned(6 downto 0) );
```

"O PC é só um registrador comum, igual ao do laboratório #3" (*µProcessador 4*, "Contador de Programa",
p. 3). O código é o `reg8bits` do *µProcessador 3* com 7 bits (a ROM tem 128 = 2^7 endereços).
O PDF proíbe o contador pronto: "Não use um contador típico VHDL ... Ao invés disso, construa um VHDL que
faz como na figura" (mesma seção, p. 2; PC como registrador + somador externo "+1"). Isso é o mesmo arranjo do livro:
"the program counter (PC), which as we saw in Chapter 2 is a register that holds the address of the
current instruction. Lastly, we will need an adder to increment the PC to the address of the next
instruction" (Patterson & Hennessy, *Computer Organization and Design RISC-V Edition*, seção 4.3
*Building a Datapath*, p. 261). A Figure 4.6 do livro, "A portion of the datapath used for fetching
instructions and incrementing the program counter" (seção 4.3, p. 263), é exatamente PC → memória de
instruções, com o somador de volta ao PC. Os slides do professor dizem o mesmo: "O Program Counter
(Contador de Programa) é apenas um registrador ... a atualização dele (um incremento ou jump ou
qualquer outra coisa) é realizada por um circuito externo, talvez na UC" (`cap2-ciclo-unico.pdf`,
seção 3.1 "WTF é um PC?", p. 6).

Diferenças em relação ao livro, ambas vindas do enunciado:
- somamos 1 e não 4, porque cada endereço da nossa ROM guarda uma instrução inteira (os slides explicam
  que se soma 4 no RISC-V porque "cada instrução ocupa 4 endereços", `cap2-ciclo-unico.pdf`, p. 6);
- nosso PC tem `wr_en`. No livro "The program counter is a 32-bit register that is written at the end of
  every clock cycle and thus does not need a write control signal" (legenda da Figure 4.5, p. 262), mas
  lá o processador é ciclo único; aqui cada instrução leva dois clocks e o PC só pode ser escrito em um
  deles, por isso o write enable ("seria complicado fazer as coisas em ciclo único ... especialmente
  por conta da atualização correta do PC", *µProcessador 4*, "Máquina de Estados", p. 2).

### 3.4 `pc_rom` (`pc_rom.vhd`) — PC ligado à ROM, só contando

```
port( clk, rst  : in std_logic;
      pc_saida  : out unsigned(6 downto 0);
      rom_saida : out unsigned(15 downto 0) );
```

Etapas intermediárias do PDF: "Crie outro módulo (uma proto-unidade de controle) que simplesmente
adiciona 1 no valor de saída do PC e conecta o resultado desta soma de volta à entrada do PC. Por
enquanto pode deixar wr_en=1 sempre" e "Conecte o PC à ROM! Basta ligar a saída do PC direto na entrada
de endereços da ROM. Coloque a saída da ROM num pino do top-level" (*µProcessador 4*, "Contador de
Programa", p. 3). O módulo tem o PC com `wr_en=>'1'`, o somador `pc_mais_um <= pc_s + 1` e a ROM.

### 3.5 `un_controle` (`un_controle.vhd`) — combinacional

```
port( instr    : in unsigned(15 downto 0);
      estado   : in std_logic;
      pc_atual : in unsigned(6 downto 0);
      pc_wr_en : out std_logic;
      pc_prox  : out unsigned(6 downto 0) );
```

Lógica (tudo `when-else`):

```
opcode     = instr(15 downto 12)
jump_en    = 1 quando opcode = 1000, senão 0
pc_mais_um = pc_atual + 1
pc_prox    = instr(6 downto 0) quando jump_en = 1
             pc_mais_um        quando jump_en = 0
             0000000           nos demais casos (else zero obrigatório)
pc_wr_en   = 1 quando estado = 1, senão 0
```

- Decodificação: "basta separar os bits do opcode em sinais parciais e fazer comparações simples"; o
  trecho do professor usa `opcode <= instr(11 downto 8)` e `jump_en <= '1' when opcode="1111" else '0';`
  (*µProcessador 4*, "Unidade de Controle com Jump", p. 3). Nosso opcode também está nos 4 MSBs, mas a
  instrução tem 16 bits e o JMP é `1000` (codificação do `00-especificacoes.md`, seção 4).
- JMP absoluto: "usando ou endereço absoluto (a constante dentro da instrução nos dá o endereço destino
  do salto) ou então endereço relativo ... de acordo com o email recebido" e "instruções JMP devem saltar
  para um endereço absoluto (ou seja, a constante especificada na instrução vai ser escrita no PC)"
  (*µProcessador 4*, "Unidade de Controle com Jump", p. 3, e "Observações sobre o sorteio", p. 4). Por isso
  `pc_prox = instr(6 downto 0)`. Observação: no RISC-V o `jal` é relativo ao PC — "RISC-V uses
  PC-relative addressing for both conditional branches and unconditional jumps" (P&H, seção 2.10,
  p. 123); o nosso JMP segue a convenção do professor, não a do RISC-V. Os desvios relativos (BLE, BVC)
  só entram no lab 6.
- Seleção do próximo PC por um mux: é o mesmo esquema dos slides para o `beq`: "o PC deve ser escrito com
  o valor PC+delta ... caso contrário, devemos escrever PC+4 no PC. Isso nos dá um simples mux"
  (`cap2-ciclo-unico.pdf`, seção 6.2 "Seleção do Próximo Endereço", p. 14). Aqui as entradas do mux são "endereço do JMP" e "PC+1".
- NOP (`0000...`) e qualquer outro opcode caem em `pc_mais_um`: não fazem nada além de avançar o PC,
  conforme `00-especificacoes.md` ("Opcodes não usados não fazem nada"). A exceção de opcode sugerida
  pelo PDF ("Se quiser ser chique ... Mas só se você quiser") não foi implementada.
- `pc_wr_en` só em `estado = 1`: "O circuito deverá fazer a leitura da ROM no estado 0 (fetch) e a
  atualização do PC no estado 1 (decode/execute)" (*µProcessador 4*, "Unidade de Controle com Jump", p. 3).

### 3.6 `processador` (`processador.vhd`) — top-level do lab

```
port( clk, rst  : in std_logic;
      estado    : out std_logic;
      pc_wr_en  : out std_logic;
      pc_saida  : out unsigned(6 downto 0);
      instrucao : out unsigned(15 downto 0) );
```

Ligações (os pinos de saída existem só para ver os sinais no gtkwave):

```
            +-------------+ estado_s
  clk,rst ->| maq_estados |-----------------------------+
            +-------------+                             |
                                                        v
            +------+  pc_s   +-----+ instrucao_s  +-------------+
  clk,rst ->|  pc  |-------->| rom |------------->| un_controle |
            |      |    |    +-----+              |             |
            |      |    +------------------------>| pc_atual    |
            |      |<---------------- pc_prox_s --|             |
            |wr_en |<---------------- pc_wr_en_s -|             |
            +------+                              +-------------+
```

## 4. Programa de teste na ROM

O PDF pede "a codificação das instruções em binário ... de preferência saltando alguns endereços para a
frente e também fazendo um loop" (*µProcessador 4*, "Unidade de Controle com Jump", p. 3).

| End. | Assembly | Binário (16 bits) | Comentário |
|---:|---|---|---|
| 0 | `NOP` | `0000000000000000` | primeira instrução após o reset |
| 1 | `JMP 5` | `1000000000000101` | salto para frente |
| 2 | `NOP` | `0000000000000000` | pulado |
| 3 | `NOP` | `0000000000000000` | pulado |
| 4 | `NOP` | `0000000000000000` | pulado |
| 5 | `NOP` | `0000000000000000` | início do loop |
| 6 | `NOP` | `0000000000000000` | |
| 7 | `JMP 10` | `1000000000001010` | outro salto para frente, pula 8 e 9 |
| 8 | `NOP` | `0000000000000000` | pulado |
| 9 | `NOP` | `0000000000000000` | pulado |
| 10 | (opcode 1111) | `1111000000000011` | opcode não usado: deve agir como NOP |
| 11 | `JMP 5` | `1000000000000101` | volta ao endereço 5: loop infinito |
| 12–127 | – | `0000000000000000` | `others` (NOP), nunca alcançados |

Sequência esperada de endereços executados: 0, 1, 5, 6, 7, 10, 11, 5, 6, 7, 10, 11, 5, ...

## 5. Estimativa do número de clocks (teste de sanidade)

O PDF pede: "Estime o número de clocks necessários para seu programa. Por exemplo, se uma instrução leva
dois clocks para ser executada, então ele deverá executar dez instruções em vinte clocks"
(*µProcessador 4*, p. 4).

- Toda instrução leva 2 clocks (fetch + decode/execute). Período do clock: 100 ns.
- O reset do testbench dura 2 clocks (0 a 200 ns); a primeira borda útil é em 250 ns.
- Antes do loop: 2 instruções (endereços 0 e 1) = 4 clocks → o PC recebe 5 na 4.ª borda útil, em
  250 + 3·100 = **550 ns**.
- Uma volta do loop: 5 instruções (5, 6, 7, 10, 11) = 10 clocks = **1000 ns** → o PC volta a 5 em
  1550 ns, 2550 ns, 3550 ns.
- Em 4 µs de simulação há 38 clocks úteis → 19 instruções completas (2 + 3 voltas de 5 + 2), ou seja,
  19 escritas do PC, entre 350 ns e 3950 ns.

Conferido na simulação: o PC recebeu 5 em 550, 1550, 2550 e 3550 ns, e houve 19 escritas do PC
(350, 550, ..., 3950 ns, uma a cada 200 ns). Bate com a estimativa.

## 6. Formas de onda esperadas: três instruções seguidas, a segunda um JMP

O PDF encoraja: "desenhe no caderno, sem olhar no gtkwave, as formas de onda esperadas para a execução de
três instruções seguidas, sendo a segunda um jump. Coloque clock, os write enables e os dados de saída
de PC e ROM. Compare com o gtkwave -- se estiver diferente, encontre a explicação" (*µProcessador 4*, p. 4).

As três instruções são as dos endereços 0 (`NOP`), 1 (`JMP 5`) e 5 (`NOP`). O raciocínio, feito antes
de simular:

1. No estado 0 o PC já está estável; a ROM é síncrona, então só na borda que **encerra** o estado 0 ela
   registra `ROM[PC]`. Durante o estado 0 a saída da ROM ainda mostra a instrução anterior (ou `ROM[0]`,
   lida durante o reset), mas isso não importa porque `pc_wr_en = 0`.
2. No estado 1 a saída da ROM é a instrução do PC atual; a unidade de controle, combinacional, calcula
   `pc_prox` a partir dela; `pc_wr_en = 1`.
3. Na borda que encerra o estado 1 o PC recebe `pc_prox`. Nessa mesma borda a ROM lê de novo o endereço
   antigo (o PC ainda não mudou no instante da borda), então a saída da ROM **não muda** nessa borda.
   A instrução nova só aparece uma borda depois, no fim do estado 0 seguinte.

Portanto a ROM síncrona funciona bem com dois estados: a instrução certa está disponível durante todo o
estado 1, que é quando o PC é atualizado.

Desenho esperado (bordas de subida marcadas com `^`, 100 ns por clock, reset até 200 ns):

```
tempo (ns)   200  250  300  350  400  450  500  550  600  650  700  750
                   ^         ^         ^         ^         ^         ^
clk          ___|‾‾‾‾|____|‾‾‾‾|____|‾‾‾‾|____|‾‾‾‾|____|‾‾‾‾|____|‾‾‾‾|__
rst          ‾‾‾|_________________________________________________________

estado        0  |    1    |    0    |    1    |    0    |    1    |  0
pc_wr_en      0  |‾‾‾‾1‾‾‾‾|    0    |‾‾‾‾1‾‾‾‾|    0    |‾‾‾‾1‾‾‾‾|  0

PC            0            |    1              |    5              |  6
ROM (dado)   NOP (ROM[0])            |  JMP 5 (ROM[1])   |  NOP (ROM[5])
pc_prox       -  |    1    |    -    |    5    |    -    |    6    |
                  \_ NOP __/          \_ JMP __/          \_ NOP __/
                  instr. 0 (end. 0)   instr. 1 (end. 1)   instr. 2 (end. 5)
```

Leitura: cada instrução ocupa os 2 clocks "fetch (estado 0) + decode/execute (estado 1)"; o fetch da
instrução 0 é o intervalo 150–250 ns (último clock do reset, já com `estado = 0` e PC = 0).

## 7. Resultado da simulação (comparação com o desenho)

Valores lidos do VCD de `processador_tb` (instantes logo após cada borda de subida):

| Tempo | estado | pc_wr_en | PC | Saída da ROM | Comentário |
|---:|:-:|:-:|---:|---|---|
| 50 ns | 0 | 0 | 0 | `0000000000000000` | reset; a ROM já registra ROM[0] |
| 150 ns | 0 | 0 | 0 | `0000000000000000` | reset |
| 250 ns | 1 | 1 | 0 | `0000000000000000` | decode/execute do NOP (end. 0); pc_prox = 1 |
| 350 ns | 0 | 0 | **1** | `0000000000000000` | PC escrito; ROM leu de novo o end. 0 |
| 450 ns | 1 | 1 | 1 | `1000000000000101` | JMP 5 disponível; pc_prox = 5 |
| 550 ns | 0 | 0 | **5** | `1000000000000101` | salto feito; ROM ainda mostra o JMP |
| 650 ns | 1 | 1 | 5 | `0000000000000000` | NOP do end. 5 |
| 750 ns | 0 | 0 | **6** | `0000000000000000` | |
| 850 ns | 1 | 1 | 6 | `0000000000000000` | |
| 950 ns | 0 | 0 | **7** | `0000000000000000` | |
| 1050 ns | 1 | 1 | 7 | `1000000000001010` | JMP 10 |
| 1150 ns | 0 | 0 | **10** | `1000000000001010` | 8 e 9 pulados |
| 1250 ns | 1 | 1 | 10 | `1111000000000011` | opcode 1111 |
| 1350 ns | 0 | 0 | **11** | `1111000000000011` | opcode 1111 agiu como NOP (PC+1) |
| 1450 ns | 1 | 1 | 11 | `1000000000000101` | JMP 5 |
| 1550 ns | 0 | 0 | **5** | `1000000000000101` | fecha o loop |
| 2550 ns, 3550 ns | 0 | 0 | **5** | `1000000000000101` | o loop se repete a cada 1000 ns |

A simulação coincidiu com o desenho da seção 6 em todos os instantes: o PC muda nas bordas de 350, 550
e 750 ns (fim de cada estado 1) e a saída da ROM muda nas bordas de 450 e 650 ns (fim de cada estado
0), sempre um clock depois do PC. Os endereços 2, 3, 4, 8, 9 nunca aparecem no PC. A única "surpresa"
aparente no gtkwave é a saída da ROM ficar com a instrução antiga durante o estado 0; é o comportamento
esperado da ROM síncrona e não afeta nada, pois nesse estado `pc_wr_en = 0`.

Na análise aparece duas vezes o aviso `NUMERIC_STD."=": metavalue detected` em 0 ns: é a comparação
`opcode="1000"` antes da primeira borda, quando a saída da ROM ainda é `U`. Não ocorre depois disso.

## 8. Testes dos blocos isolados

Todos os testbenches seguem o modelo do *µProcessador 3* (constante `period_time` de 100 ns,
`reset_global`, `sim_time_proc`, `clk_proc`, processo de estímulos terminando com `wait;`). O
`un_controle_tb` não tem clock (bloco combinacional), como os testbenches do *µProcessador 1*.

### `rom_tb` (sem reset, pois a ROM não tem)

| Tempo | endereco | dado após a borda |
|---:|---:|---|
| 50 ns | 0 | `0000000000000000` |
| 150 ns | 1 | `1000000000000101` |
| 250 ns | 7 | `1000000000001010` |
| 350 ns | 10 | `1111000000000011` |
| 450 ns | 11 | `1000000000000101` |
| 550 ns | 127 | `0000000000000000` (others) |
| 600–640 ns | 1 → 7 → 11 entre bordas | `dado` **não muda** (continua `0000000000000000`) |
| 650 ns | 11 | `1000000000000101` |

O último caso prova que a ROM é síncrona: mudar o endereço entre bordas não altera a saída; só a borda
de 650 ns lê o endereço presente naquele instante.

### `maq_estados_tb`

Reset em 0–200 ns e de novo em 700–800 ns. Observado: `estado` = 0 durante o reset; alterna
1, 0, 1, 0, 1 nas bordas de 250 a 650 ns; em 700 ns o reset assíncrono zera o estado imediatamente
(sem esperar borda); após soltar o reset volta a alternar a partir da borda de 850 ns.

### `pc_tb`

| Intervalo | rst | wr_en | data_in | data_out observado |
|---|:-:|:-:|---:|---:|
| 0–200 ns | 1 | 1 | 5 | 0 (reset vence) |
| borda 250 ns | 0 | 1 | 1 | 1 |
| borda 350 ns | 0 | 1 | 2 | 2 |
| bordas 450, 550 ns | 0 | 0 | 127 | 2 (mantém) |
| borda 650 ns | 0 | 1 | 85 | 85 |
| borda 750 ns | 0 | 1 | 12 | 12 |
| 800–900 ns | 1 | 1 | 12 | 0 (reset assíncrono em 800 ns) |
| borda 950 ns | 0 | 1 | 3 | 3 |

### `pc_rom_tb`

PC conta 1, 2, 3, ... a partir da borda de 250 ns, uma unidade por clock; a saída da ROM mostra o
conteúdo em ordem, um clock atrasado (ROM síncrona): em 350 ns PC = 2 e ROM = `ROM[1]` =
`1000000000000101`; em 950 ns PC = 8 e ROM = `ROM[7]` = `1000000000001010`; em 1250 ns ROM = `ROM[10]`
= `1111000000000011`; em 1350 ns ROM = `ROM[11]`. Os JMPs são ignorados, como pede o PDF nessa etapa.
Com 7 bits, depois de 127 o PC volta a 0.

### `un_controle_tb`

| instr | estado | pc_atual | pc_wr_en | pc_prox |
|---|:-:|---:|:-:|---:|
| `0000000000000000` (NOP) | 0 | 0 | 0 | 1 |
| `0000000000000000` (NOP) | 1 | 0 | 1 | 1 |
| `1000000000000101` (JMP 5) | 1 | 1 | 1 | 5 |
| `1000000000000101` (JMP 5) | 0 | 1 | 0 | 5 |
| `1111000000000011` (não usado) | 1 | 10 | 1 | 11 |
| `0000000000000000` (NOP) | 1 | 127 | 1 | 0 (volta a 0 em 7 bits) |
| `1000111111111111` (JMP 127, bits x em 1) | 1 | 3 | 1 | 127 |

## 9. Como rodar

Dentro de `lab4/`:

```
./run.sh
gtkwave processador_tb.ghw
```

O `run.sh` analisa todos os fontes com `ghdl -a`, elabora e roda cada testbench gerando um `.ghw`
("rode a entidade do testbench final com, digamos, ghdl -r e_4_entradas_tb --wave=result.ghw",
*µProcessador 3*, apêndice). Os arquivos gerados (`.ghw`, `work-obj93.cf`, executáveis) não devem ser
versionados. Tempo total das simulações: 2 µs nos blocos e 4 µs no `processador_tb` (19 instruções).

Entrega: "me interessam apenas os arquivos fontes VHDL. Entregue-os dentro de um arquivo .zip"
(*µProcessador 4*, p. 4).
