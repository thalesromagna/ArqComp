# Lab 4 — Unidade de Controle Rudimentar (ROM, PC, máquina de estados, NOP e JMP)

Arquivos em `lab4/`. Base: PDF *µProcessador 4* ("Unidade de Controle Rudimentar") e, para o modelo de
registrador e de testbench, o PDF *µProcessador 3*. Os itens da unidade de controle (ROM síncrona de
17 bits, PC na borda de descida, JMP absoluto, sem registrador de instrução) foram sorteados no
**Email 3** do professor; a codificação de NOP e JMP com opcode de 5 bits vem de
`docs/00-especificacoes.md`, seção 4.

O PDF resume o objetivo assim: "Vamos fazer um programa armazenado em ROM ser percorrido por um PC e
executar jumps incondicionais" (*µProcessador 4*, p. 1, introdução).

## 1. Sorteio da unidade de controle (Email 3)

O PDF pede: "Verifique no email com o seu sorteio para o microprocessador a largura dos dados da ROM
especificadas para a sua equipe de laboratório. Verifique também se a ROM é síncrona ou assíncrona.
Construa uma ROM de acordo" (*µProcessador 4*, seção "ROM em VHDL", p. 2).

O email com esse sorteio é o Email 3, que o professor mandou justamente para este lab: "Este lab ainda
não vai integrar com ULA/regs. Estou adiantando o email para quem já tiver entregue o lab anterior. Este
email é para quem terminou o lab #3 e já quer ir adiantando o #4" (Email 3, em
`especificações do professor para meu grupo.txt`). O sorteio foi:

```
{'Largura da ROM / tamanho da instrução em bits': [17],
 'Incremento do PC': ['PC sensível a clock de descida'],
 'Leitura da ROM': ['síncrona'],
 'Saltos': 'Incondicional é absoluto e condicional é relativo',
 'Registrador de Instruções': ['não usar']}
```

| Item | Valor | Consequência no lab 4 | Fonte |
|---|---|---|---|
| Largura do dado da ROM | **17 bits** | `dado : out unsigned(16 downto 0)`; cada instrução tem 17 bits: "O tamanho das instruções é sorteado para a equipe, e é igual à largura de um dado da ROM" | Email 3; *µProcessador 5*, "Implementação", p. 2 |
| Leitura da ROM | **síncrona** | modelo do próprio PDF, com `process(clk)` e `rising_edge`: "Note que esta ROM é sincrona! Isto significa que é preciso dar um clock nela para que ela leia os dados" | Email 3; *µProcessador 4*, "ROM em VHDL", p. 1 |
| Incremento do PC | **borda de descida** | `pc.vhd` usa `falling_edge(clk)`: "Se algum item sorteado for sensível a rampa de descida, utilize falling_edge(clk) ao invés de rising_edge(clk)" | Email 3; *µProcessador 5*, "Contadores em VHDL", p. 1 |
| Saltos | JMP absoluto (condicionais relativos) | "instruções JMP devem saltar para um endereço absoluto (ou seja, a constante especificada na instrução vai ser escrita no PC)"; os condicionais só entram no lab 6 | Email 3; *µProcessador 4*, "Observações sobre o sorteio", p. 4 |
| Registrador de instruções | não usar | a saída da ROM vai direto para a unidade de controle. O lab 4 nunca teve esse registrador; ele só aparece no lab 5 e apenas "Caso o seu sorteio especifique um Registrador de Instrução" | Email 3; *µProcessador 5*, "Implementação", p. 2 |
| Número de endereços | 128 (0 a 127) → PC de 7 bits | "é uma ROM de 128 endereços" | *µProcessador 4*, "ROM em VHDL", p. 1 |

Codificação (17 bits, `00-especificacoes.md`, seção 4): opcode nos 5 bits mais significativos
(b16..b12) e campos em b11..b0. No lab 4 só existem duas instruções:

| Assembly | Binário | Hex | Operação |
|---|---|---|---|
| `NOP` | `00000 000000000000` | `0x00000` | só avança o PC |
| `JMP end` | `01000 xxxxx aaaaaaa` | `0x08000` + end (com x = 0) | PC ← end (endereço absoluto de 7 bits em b6..b0) |
| (outros opcodes) | – | – | não fazem nada (PC avança), como NOP |

Na ROM as palavras são escritas com a notação `B"..."` e sublinhados separando os campos (por exemplo
`B"01000_00000_0000101"`): "se você explicitar uma string como binária (colocando B na frente) dá pra
usar sublinhado como separador pra visualizar melhor, sem alterar o valor" (*µProcessador 5*, "Dica
esperta", p. 3).

## 2. Ordem de trabalho (igual à do PDF) e arquivos

| Etapa do PDF | Arquivo | Testbench |
|---|---|---|
| "ROM em VHDL" | `rom.vhd` | `rom_tb.vhd` |
| "Máquina de Estados" (flip-flop T) | `maq_estados.vhd` | `maq_estados_tb.vhd` |
| "Contador de Programa" (registrador comum) | `pc.vhd` | `pc_tb.vhd` |
| "Conecte o PC à ROM!" (PC + somador +1, `wr_en=1`) | `pc_rom.vhd` | `pc_rom_tb.vhd` |
| "Unidade de Controle com Jump" (NOP e JMP) | `un_controle.vhd` (sem a máquina de estados: desvio explicado no fim da seção 3.5) | `un_controle_tb.vhd` |
| Top-level do lab | `processador.vhd` | `processador_tb.vhd` |
| Script de compilação e simulação | `run.sh` | – |

Regras de VHDL respeitadas (ver `00-especificacoes.md`, seção 5): `process`/`if` só na ROM síncrona
(cópia do modelo do lab 4), no PC (cópia do registrador do lab 3 com `falling_edge`) e no flip-flop T
(trecho do lab 4); toda a lógica da unidade de controle é `when-else` terminando em `else` zero ("Use
when-else para construir qualquer lógica, que deve ser colocada fora do 'process.'", *µProcessador 4*,
"Unidade de Controle com Jump", p. 3). Não há comentários no código.

Bordas usadas: ROM e máquina de estados na **subida** (`rising_edge`, modelos dos PDFs); PC na
**descida** (`falling_edge`, Email 3).

## 3. Entidades e interfaces

### 3.1 `rom` (`rom.vhd`)

```
port( clk      : in std_logic;
      endereco : in unsigned(6 downto 0);
      dado     : out unsigned(16 downto 0) );
```

Cópia do modelo do PDF, trocando apenas a largura do dado de 12 para 17 bits (`type mem is array (0 to
127) of unsigned(16 downto 0)`) e o conteúdo. A leitura acontece dentro de `process(clk)` com
`rising_edge(clk)`: "só quando houver rampa de subida no clock é que teremos uma resposta à saída"
(*µProcessador 4*, "ROM em VHDL", p. 1). Endereços não listados valem zero (`others => (others=>'0')`),
ou seja, NOP (17 zeros).

### 3.2 `maq_estados` (`maq_estados.vhd`)

```
port( clk,rst: in std_logic;
      estado: out std_logic );
```

Flip-flop T de 1 bit, na borda de **subida** (o sorteio só muda a borda do PC). O PDF manda: "use um
simples flip-flop T, ou seja, aquele que troca de estado a cada clock" e mostra o trecho
`estado <= not estado;` dentro do `elsif rising_edge(clk)`, lembrando "Não esqueça do reset"
(*µProcessador 4*, "Máquina de Estados", p. 2). Como o flip-flop precisa ler o próprio valor
(`not estado`), usamos o sinal interno `estado_s`, seguindo a dica do próprio PDF ("é comum usar os
sufixos _i, _o e _s ... 'dado_s' para o signal interno", mesma seção) e a forma da máquina do
*µProcessador 5*.

| `estado` | nome | o que acontece |
|---|---|---|
| 0 | fetch | `pc_wr_en = 0`; a saída da ROM já é a instrução apontada pelo PC (registrada na subida que encerrou o estado 1 anterior; a primeira, `ROM[0]`, durante o reset); na subida que encerra o estado 0 a ROM relê o mesmo endereço |
| 1 | decode/execute | `pc_wr_en = 1`; a unidade de controle decodifica a instrução e o PC é escrito na **descida do meio do estado** |

Reset assíncrono leva a `estado = 0` (fetch).

### 3.3 `pc` (`pc.vhd`) — registrador na borda de descida

```
port( clk, rst, wr_en : in std_logic;
      data_in  : in unsigned(6 downto 0);
      data_out : out unsigned(6 downto 0) );
```

"O PC é só um registrador comum, igual ao do laboratório #3" (*µProcessador 4*, "Contador de Programa",
p. 3). O código é o registrador `reg8bits` do *µProcessador 3* (o `reg16bits.vhd` do nosso lab 3) com
7 bits (a ROM tem 128 = 2^7 endereços) e com
`falling_edge(clk)` no lugar de `rising_edge(clk)`, por causa do Email 3 ("PC sensível a clock de
descida") e da regra do *µProcessador 5*: "Se algum item sorteado for sensível a rampa de descida,
utilize falling_edge(clk) ao invés de rising_edge(clk)" ("Contadores em VHDL", p. 1). O resto
(reset assíncrono, `wr_en`) fica igual.

Por que a descida funciona bem com os dois estados:

- `pc_wr_en` é igual a `estado`, e o estado só muda nas subidas. Então cada estado contém exatamente uma
  descida, no meio dele. A única descida com `pc_wr_en = 1` é a do meio do estado 1: **uma escrita do PC
  por instrução**, 50 ns depois da subida que inicia o estado 1.
- Na descida, a instrução que a unidade de controle está usando ainda é a da ROM, que só muda na subida
  seguinte. Logo `pc_prox` foi calculado com a instrução certa.
- Na subida que encerra o estado 1, o PC já mudou há meio clock, então a ROM síncrona já lê o endereço
  novo. A instrução seguinte aparece no começo do estado 0 (e não no fim, como seria com o PC na
  subida), e a subida que encerra o estado 0 só relê o mesmo endereço.

O PDF proíbe o contador pronto: "Não use um contador típico VHDL ... Ao invés disso, construa um VHDL que
faz como na figura" (*µProcessador 4*, "Contador de Programa", p. 2; PC como registrador + somador
externo "+1"). Isso é o mesmo arranjo do livro: "the program counter (PC), which as we saw in Chapter 2
is a register that holds the address of the current instruction. Lastly, we will need an adder to
increment the PC to the address of the next instruction" (Patterson & Hennessy, *Computer Organization
and Design RISC-V Edition*, seção 4.3 *Building a Datapath*, p. 261). A Figure 4.6 do livro, "A portion
of the datapath used for fetching instructions and incrementing the program counter" (seção 4.3,
p. 263), é exatamente PC → memória de instruções, com o somador de volta ao PC. Os slides do professor
dizem o mesmo: "O Program Counter (Contador de Programa) é apenas um registrador ... a atualização dele
(um incremento ou jump ou qualquer outra coisa) é realizada por um circuito externo, talvez na UC"
(`cap2-ciclo-unico.pdf`, seção 3.1 "WTF é um PC?", p. 6).

Diferenças em relação ao livro, todas vindas do enunciado ou do sorteio:
- somamos 1 e não 4, porque cada endereço da nossa ROM guarda uma instrução inteira (os slides explicam
  que se soma 4 no RISC-V porque "cada instrução ocupa 4 endereços", `cap2-ciclo-unico.pdf`, p. 6);
- nosso PC tem `wr_en`. No livro "The program counter is a 32-bit register that is written at the end of
  every clock cycle and thus does not need a write control signal" (legenda da Figure 4.5, p. 262), mas
  lá o processador é ciclo único; aqui cada instrução leva dois clocks e o PC só pode ser escrito em um
  deles, por isso o write enable ("seria complicado fazer as coisas em ciclo único ... especialmente
  por conta da atualização correta do PC", *µProcessador 4*, "Máquina de Estados", p. 2);
- nosso PC é escrito na borda de descida, não no fim do ciclo (Email 3).

### 3.4 `pc_rom` (`pc_rom.vhd`) — PC ligado à ROM, só contando

```
port( clk, rst  : in std_logic;
      pc_saida  : out unsigned(6 downto 0);
      rom_saida : out unsigned(16 downto 0) );
```

Etapas intermediárias do PDF: "Crie outro módulo (uma proto-unidade de controle) que simplesmente
adiciona 1 no valor de saída do PC e conecta o resultado desta soma de volta à entrada do PC. Por
enquanto pode deixar wr_en=1 sempre" e "Conecte o PC à ROM! Basta ligar a saída do PC direto na entrada
de endereços da ROM. Coloque a saída da ROM num pino do top-level" (*µProcessador 4*, "Contador de
Programa", p. 3). O módulo tem o PC com `wr_en=>'1'`, o somador `pc_mais_um <= pc_s + 1` e a ROM. Com o
PC na descida e a ROM na subida, a saída da ROM mostra `ROM[PC]` meio clock (50 ns) depois de cada
mudança do PC.

### 3.5 `un_controle` (`un_controle.vhd`) — combinacional

```
port( instr    : in unsigned(16 downto 0);
      estado   : in std_logic;
      pc_atual : in unsigned(6 downto 0);
      pc_wr_en : out std_logic;
      pc_prox  : out unsigned(6 downto 0) );
```

Lógica (tudo `when-else`):

```
opcode     = instr(16 downto 12)                (5 bits)
jump_en    = 1 quando opcode = 01000, senão 0
pc_mais_um = pc_atual + 1
pc_prox    = instr(6 downto 0) quando jump_en = 1
             pc_mais_um        quando jump_en = 0
             0000000           nos demais casos (else zero obrigatório)
pc_wr_en   = 1 quando estado = 1, senão 0
```

- Decodificação: "basta separar os bits do opcode em sinais parciais e fazer comparações simples"; o
  trecho do professor usa `signal opcode: unsigned(3 downto 0)`, `opcode <= instr(11 downto 8)` e
  `jump_en <= '1' when opcode="1111" else '0';` (*µProcessador 4*, "Unidade de Controle com Jump",
  p. 3). Nosso opcode também está nos MSBs, mas tem 5 bits (`instr(16 downto 12)`, instrução de 17
  bits) e o JMP é `01000` (`00-especificacoes.md`, seção 4).
- JMP absoluto: "usando ou endereço absoluto (a constante dentro da instrução nos dá o endereço destino
  do salto) ou então endereço relativo ... de acordo com o email recebido" (*µProcessador 4*, "Unidade
  de Controle com Jump", p. 3); o Email 3 sorteou "Incondicional é absoluto". Por isso
  `pc_prox = instr(6 downto 0)`. Observação: no RISC-V o `jal` é relativo ao PC — "RISC-V uses
  PC-relative addressing for both conditional branches and unconditional jumps" (P&H, seção 2.10,
  p. 123); o nosso JMP segue o sorteio, não a convenção do RISC-V. Os desvios relativos (BLE, BVC)
  só entram no lab 6.
- Seleção do próximo PC por um mux: é o mesmo esquema dos slides para o `beq`: "o PC deve ser escrito com
  o valor PC+delta ... caso contrário, devemos escrever PC+4 no PC. Isso nos dá um simples mux"
  (`cap2-ciclo-unico.pdf`, seção 6.2 "Seleção do Próximo Endereço", p. 14). Aqui as entradas do mux são
  "endereço do JMP" e "PC+1".
- NOP (17 zeros) e qualquer outro opcode caem em `pc_mais_um`: não fazem nada além de avançar o PC,
  conforme `00-especificacoes.md` ("Opcodes não usados não fazem nada"). Como o opcode tem 5 bits, um
  código como `11000` (que teria os mesmos 4 bits baixos do JMP) também é tratado como não usado. A
  exceção de opcode sugerida pelo PDF ("Se quiser ser chique ... Mas só se você quiser", p. 4) não foi
  implementada.
- `pc_wr_en` só em `estado = 1`: "O circuito deverá fazer a leitura da ROM no estado 0 (fetch) e a
  atualização do PC no estado 1 (decode/execute)" (*µProcessador 4*, "Unidade de Controle com Jump", p. 3).

**Desvio consciente do roteiro: a máquina de estados fica fora da `un_controle`.** O PDF manda: "Inclua
a máquina de estados de 1 bit no módulo da unidade de controle" (*µProcessador 4*, "Unidade de Controle
com Jump", p. 3). Aqui o flip-flop T continua na sua própria entidade, `maq_estados`, o mesmo `.vhd` que o
PDF manda testar sozinho numa etapa anterior ("Faça mais um testbench simples só para este '.vhd'" e
"Teste separadamente esse flip-flop T pois essa é uma atitude saudável", *µProcessador 4*, "Máquina de
Estados", p. 2). Ele é instanciado no top-level `processador`, ao lado da `un_controle`, que recebe
`estado` como entrada (diagrama da seção 3.6). O bloco "unidade de controle" do enunciado corresponde,
portanto, ao par `maq_estados` + `un_controle`. O comportamento pedido na frase seguinte do PDF
("O circuito deverá fazer a leitura da ROM no estado 0 (fetch) e a atualização do PC no estado 1
(decode/execute)", p. 3) é o mesmo, pois `pc_wr_en = estado`. Com essa divisão, o `un_controle.vhd` não
tem nenhum `process`: toda a lógica dele fica fora de `process`, em `when-else` (mais o recorte do opcode
e o somador `pc_atual + 1`), como o PDF pede para a lógica ("Use when-else para construir qualquer
lógica, que deve ser colocada fora do 'process.'", p. 3), e o único `process` desse par é o do flip-flop
T. É a mesma divisão dos slides do professor, que, sobre o processador ciclo único completo (Figura 11,
"Microprocessador ciclo único completo"), lembram que "a unidade de controle é apenas combinacional, não
possuindo nenhum estado ou flip-flop" (`cap2-ciclo-unico.pdf`, seção 7.1, p. 16). O nosso processador
não é ciclo único, e o estado de que ele precisa fica no `maq_estados`. É também a estrutura dos labs
5 a 7, em que a máquina de estados é a entidade `maq_estados` do modelo do *µProcessador 5* ("Contadores
em VHDL", p. 1), instanciada no top-level ao lado da `un_controle`.

### 3.6 `processador` (`processador.vhd`) — top-level do lab

```
port( clk, rst  : in std_logic;
      estado    : out std_logic;
      pc_wr_en  : out std_logic;
      pc_saida  : out unsigned(6 downto 0);
      instrucao : out unsigned(16 downto 0) );
```

Ligações (os pinos de saída existem só para ver os sinais no gtkwave). Não há registrador de instrução
(Email 3): `instrucao_s` é a própria saída da ROM.

```
            +-------------+ estado_s  (subida)
  clk,rst ->| maq_estados |-----------------------------+
            +-------------+                             |
                                                        v
            +------+  pc_s   +-----+ instrucao_s  +-------------+
  clk,rst ->|  pc  |-------->| rom |------------->| un_controle |
            |(desc)|    |    |(sub)|              |             |
            |      |    |    +-----+              |             |
            |      |    +------------------------>| pc_atual    |
            |      |<---------------- pc_prox_s --|             |
            |wr_en |<---------------- pc_wr_en_s -|             |
            +------+                              +-------------+
```

## 4. Programa de teste na ROM

O PDF pede "a codificação das instruções em binário ... de preferência saltando alguns endereços para a
frente e também fazendo um loop" (*µProcessador 4*, "Unidade de Controle com Jump", p. 3). É o mesmo
programa de antes, recodificado em 17 bits.

| End. | Assembly | Binário (17 bits) | Hex | Comentário |
|---:|---|---|---|---|
| 0 | `NOP` | `00000_000000000000` | `0x00000` | primeira instrução após o reset |
| 1 | `JMP 5` | `01000_00000_0000101` | `0x08005` | salto para frente |
| 2 | `NOP` | `00000_000000000000` | `0x00000` | pulado |
| 3 | `NOP` | `00000_000000000000` | `0x00000` | pulado |
| 4 | `NOP` | `00000_000000000000` | `0x00000` | pulado |
| 5 | `NOP` | `00000_000000000000` | `0x00000` | início do loop |
| 6 | `NOP` | `00000_000000000000` | `0x00000` | |
| 7 | `JMP 10` | `01000_00000_0001010` | `0x0800A` | outro salto para frente, pula 8 e 9 |
| 8 | `NOP` | `00000_000000000000` | `0x00000` | pulado |
| 9 | `NOP` | `00000_000000000000` | `0x00000` | pulado |
| 10 | (opcode 01111) | `01111_00000_0000011` | `0x0F003` | opcode não usado: deve agir como NOP |
| 11 | `JMP 5` | `01000_00000_0000101` | `0x08005` | volta ao endereço 5: loop infinito |
| 12–127 | – | `00000_000000000000` | `0x00000` | `others` (NOP), nunca alcançados |

Sequência esperada de endereços executados: 0, 1, 5, 6, 7, 10, 11, 5, 6, 7, 10, 11, 5, ...

## 5. Estimativa do número de clocks (teste de sanidade)

O PDF pede: "Estime o número de clocks necessários para seu programa. Por exemplo, se uma instrução leva
dois clocks para ser executada, então ele deverá executar dez instruções em vinte clocks"
(*µProcessador 4*, "Unidade de Controle com Jump", p. 4).

- Clock do testbench: período 100 ns, subidas em 50, 150, 250, ... ns e descidas em 100, 200, 300, ... ns.
- Toda instrução leva 2 clocks (fetch + decode/execute) = 200 ns. O PC é escrito uma vez por instrução,
  na descida do meio do estado 1.
- O reset dura de 0 a 200 ns. A primeira instrução (end. 0) tem o fetch em 150–250 ns e o
  decode/execute em 250–350 ns; a primeira escrita do PC é na descida de **300 ns**.
- Antes do loop: 2 instruções (endereços 0 e 1) = 4 clocks → o PC recebe 5 na descida do meio do
  segundo estado 1, em 300 + 200 = **500 ns**.
- Uma volta do loop: 5 instruções (5, 6, 7, 10, 11) = 10 clocks = **1000 ns** → o PC volta a 5 em
  1500, 2500 e 3500 ns.
- Nos 4 µs do `sim_time_proc` as escritas do PC acontecem nas descidas de 300, 500, ..., 3900 ns, uma a
  cada 200 ns: (3900 − 300)/200 + 1 = **19 escritas**, ou seja, 19 instruções (2 + 3 voltas de 5 + 2: as
  duas últimas são os endereços 5 e 6), em 38 clocks (150 a 3950 ns). O período extra que o clock ainda
  dá até 4,1 µs (seção 9) não tem escrita do PC.

Conferido no VCD de `processador_tb`: o PC mudou em 300, 500, 700, ..., 3900 ns (19 mudanças, todas
em descidas, uma a cada 200 ns) e valeu 5 a partir de 500, 1500, 2500 e 3500 ns. Bate com a estimativa.

## 6. Formas de onda esperadas: três instruções seguidas, a segunda um JMP

O PDF encoraja: "desenhe no caderno, sem olhar no gtkwave, as formas de onda esperadas para a execução de
três instruções seguidas, sendo a segunda um jump. Coloque clock, os write enables e os dados de saída
de PC e ROM. Compare com o gtkwave -- se estiver diferente, encontre a explicação" (*µProcessador 4*,
"Unidade de Controle com Jump", p. 4).

As três instruções são as dos endereços 0 (`NOP`), 1 (`JMP 5`) e 5 (`NOP`). O raciocínio, feito antes
de simular:

1. A máquina de estados e a ROM mudam só nas **subidas**; o PC muda só nas **descidas** e só com
   `pc_wr_en = 1`, isto é, na descida do meio do estado 1.
2. Estado 1 (decode/execute): a saída da ROM é a instrução do PC atual; a unidade de controle,
   combinacional, calcula `pc_prox`; na descida do meio do estado o PC recebe `pc_prox`.
3. Na subida que encerra o estado 1 o PC já mudou há 50 ns, então a ROM registra `ROM[novo PC]`:
   a instrução seguinte aparece **no começo** do estado 0.
4. Na subida que encerra o estado 0 a ROM lê de novo o mesmo endereço, então a saída **não muda**.
   A instrução fica estável durante os estados 0 e 1 inteiros.
5. Depois da descida, ainda no estado 1, `pc_prox` é recalculado com o PC novo e a instrução antiga (e
   pode mudar), mas a próxima descida já cai no estado 0, com `pc_wr_en = 0`: não há segunda escrita.

Desenho esperado (1 caractere = 10 ns; `^` subida, `v` descida; reset até 200 ns):

```
tempo (ns)    150  200  250  300  350  400  450  500  550  600  650  700  750  800
borda         ^    v    ^    v    ^    v    ^    v    ^    v    ^    v    ^    v
clk           |‾‾‾‾|____|‾‾‾‾|____|‾‾‾‾|____|‾‾‾‾|____|‾‾‾‾|____|‾‾‾‾|____|‾‾‾‾
rst           ‾‾‾‾‾|___________________________________________________________
estado        0         |1        |0        |1        |0        |1        |0
pc_wr_en      __________|‾‾‾‾‾‾‾‾‾|_________|‾‾‾‾‾‾‾‾‾|_________|‾‾‾‾‾‾‾‾‾|____
PC            0              |1                  |5                  |6
ROM (dado)    NOP (ROM[0])        |JMP 5 (ROM[1])     |NOP (ROM[5])       |NOP (ROM[6])
instrução     |<---- 0: NOP ----->|<--- 1: JMP 5 ---->|<---- 2: NOP ----->|
                    (end. 0)            (end. 1)            (end. 5)
```

Leitura: o PC muda nas descidas de 300, 500 e 700 ns (meio de cada estado 1) e a saída da ROM muda nas
subidas de 350, 550 e 750 ns (fim de cada estado 1), sempre meio clock depois do PC. Cada instrução
ocupa 2 clocks, de uma subida que inicia o estado 0 até a próxima; o fetch da instrução 0 é o
intervalo 150–250 ns (último clock do reset, já com `estado = 0` e PC = 0). Em 750 ns a ROM lê
`ROM[6]`, que também é NOP, então no gtkwave não aparece transição nessa borda.

## 7. Resultado da simulação (comparação com o desenho)

Valores lidos do VCD de `processador_tb` (instantes logo após cada borda; `pc_prox` é o sinal interno
`pc_prox_s`):

| Tempo | Borda | estado | pc_wr_en | PC | Saída da ROM | pc_prox | Comentário |
|---:|:-:|:-:|:-:|---:|---|---:|---|
| 50 ns | subida | 0 | 0 | 0 | `00000_000000000000` | 1 | reset; a ROM já registra ROM[0] |
| 200 ns | descida | 0 | 0 | 0 | `00000_000000000000` | 1 | reset solto nesta borda; `pc_wr_en = 0`, PC não muda |
| 250 ns | subida | 1 | 1 | 0 | `00000_000000000000` | 1 | decode/execute do NOP (end. 0) |
| 300 ns | descida | 1 | 1 | **1** | `00000_000000000000` | 2 | PC escrito na descida |
| 350 ns | subida | 0 | 0 | 1 | `01000_00000_0000101` | 5 | ROM já leu ROM[1] = JMP 5 |
| 400 ns | descida | 0 | 0 | 1 | `01000_00000_0000101` | 5 | `pc_wr_en = 0`: PC não muda |
| 450 ns | subida | 1 | 1 | 1 | `01000_00000_0000101` | 5 | ROM releu ROM[1] (sem mudança) |
| 500 ns | descida | 1 | 1 | **5** | `01000_00000_0000101` | 5 | salto feito |
| 550 ns | subida | 0 | 0 | 5 | `00000_000000000000` | 6 | NOP do end. 5 |
| 700 ns | descida | 1 | 1 | **6** | `00000_000000000000` | 7 | |
| 900 ns | descida | 1 | 1 | **7** | `00000_000000000000` | 8 | |
| 950 ns | subida | 0 | 0 | 7 | `01000_00000_0001010` | 10 | JMP 10 |
| 1100 ns | descida | 1 | 1 | **10** | `01000_00000_0001010` | 10 | 8 e 9 pulados |
| 1150 ns | subida | 0 | 0 | 10 | `01111_00000_0000011` | 11 | opcode 01111 (não usado) |
| 1300 ns | descida | 1 | 1 | **11** | `01111_00000_0000011` | 12 | agiu como NOP (PC+1) |
| 1350 ns | subida | 0 | 0 | 11 | `01000_00000_0000101` | 5 | JMP 5 |
| 1500 ns | descida | 1 | 1 | **5** | `01000_00000_0000101` | 5 | fecha o loop |
| 2500, 3500 ns | descida | 1 | 1 | **5** | `01000_00000_0000101` | 5 | o loop se repete a cada 1000 ns |

Tempos medidos: o PC muda em 300, 500, 700, 900, 1100, 1300, 1500 ns, ... (só descidas, no meio do
estado 1); a saída da ROM muda em 350, 550, 950, 1150, 1350, 1550 ns, ... (só subidas, no fim do
estado 1), 50 ns depois do PC. Isso coincide com o desenho da seção 6 em todos os instantes. Os
endereços 2, 3, 4, 8, 9 nunca aparecem no PC.

O que aparece no gtkwave e não estava no desenho: `pc_prox` pode mudar até duas vezes por instrução. Ele
é recalculado na descida em que o PC é escrito (com o PC novo e a instrução antiga, que continua na saída
da ROM) e na subida seguinte, quando chega a instrução nova. Por exemplo, vira 2 em 300 ns, porque o PC
já é 1 e a instrução ainda é o NOP do end. 0, e vira 5 em 350 ns, quando chega o JMP. Quando o valor
recalculado é igual ao anterior, não há transição: em 500 ns (o PC vira 5 e a instrução ainda é o
JMP 5), em 750 ns (`ROM[6]` também é NOP, então a saída da ROM nem muda) e em 1100 ns (o PC vira 10 e a
instrução ainda é o JMP 10). Medido no VCD: `pc_prox` muda em 300, 350, 550, 700, 900, 950, 1150, 1300,
1350, 1550 ns, ... Isso não afeta o PC: a descida seguinte (400 ns, no exemplo) cai no estado 0, com
`pc_wr_en = 0`, e na descida do estado 1 seguinte (500 ns) `pc_prox` já foi calculado com a instrução
nova.

A liberação do reset em 200 ns coincide com uma descida, mas nesse instante `estado = 0` e
`pc_wr_en = 0`, então o PC não é escrito; a primeira escrita é em 300 ns.

Na simulação aparece duas vezes o aviso `NUMERIC_STD."=": metavalue detected` em 0 ns: uma no
`un_controle_tb` e uma no `processador_tb`. É a comparação `opcode="01000"` antes de `instr` ter valor
(no `processador_tb`, a saída da ROM é `U` até a primeira subida, em 50 ns). Não ocorre depois disso.

## 8. Testes dos blocos isolados

Todos os testbenches seguem o modelo do *µProcessador 3* (constante `period_time` de 100 ns,
`reset_global`, `sim_time_proc`, `clk_proc`, processo de estímulos terminando com `wait;`). O
`un_controle_tb` não tem clock (bloco combinacional), como os testbenches do *µProcessador 1*.
Valores conferidos nos VCDs.

### `rom_tb` (sem reset, pois a ROM não tem)

| Tempo | endereco | dado após a borda |
|---:|---:|---|
| 50 ns | 0 | `00000_000000000000` |
| 150 ns | 1 | `01000_00000_0000101` |
| 250 ns | 7 | `01000_00000_0001010` |
| 350 ns | 10 | `01111_00000_0000011` |
| 450 ns | 11 | `01000_00000_0000101` |
| 550 ns | 127 | `00000_000000000000` (others) |
| 600–640 ns | 1 → 7 → 11 entre bordas | `dado` **não muda** (continua zero) |
| 650 ns | 11 | `01000_00000_0000101` |

O último caso prova que a ROM é síncrona: mudar o endereço entre bordas não altera a saída; só a borda
de 650 ns lê o endereço presente naquele instante.

### `maq_estados_tb`

Reset em 0–200 ns e de novo em 700–800 ns. Observado: `estado` = 0 durante o reset; alterna
1, 0, 1, 0, 1 nas subidas de 250 a 650 ns; em 700 ns o reset assíncrono zera o estado imediatamente
(sem esperar borda); após soltar o reset volta a alternar a partir da subida de 850 ns. O flip-flop T
continua na borda de subida.

### `pc_tb` — o PC grava na descida

Depois dos valores iniciais (0 ns), nenhum estímulo (`rst`, `wr_en`, `data_in`) muda numa borda. Quase
todas as mudanças acontecem 20 ns depois de uma descida (220, 320, 420, 620, 720, 820, 920 e 1020 ns),
isto é, 30 ns **antes** de uma subida. Assim, se o PC gravasse na subida, a saída mudaria em 250, 350,
... ns; ela muda em 300, 400, ... ns. A única exceção é a volta de `wr_en` a 0 em 680 ns, 30 ns depois da
subida de 650 ns e 20 ns antes da descida de 700 ns; com isso a janela 620–680 ns, com `wr_en = 1`, só
contém a subida de 650 ns. O reset também é solto fora das bordas (220 ns), porque aqui `wr_en = 1` e a
liberação do reset exatamente numa descida faria o PC já gravar nessa borda.

| Intervalo | rst | wr_en | data_in | Bordas no intervalo | data_out medido |
|---|:-:|:-:|---:|---|---|
| 0–220 ns | 1 | 1 | 5 | descidas 100 e 200 | 0 (reset vence) |
| 220–320 ns | 0 | 1 | 1 | subida 250, descida 300 | 1 **em 300 ns** (nada em 250) |
| 320–420 ns | 0 | 1 | 2 | subida 350, descida 400 | 2 **em 400 ns** |
| 420–620 ns | 0 | 0 | 127 | descidas 500 e 600 | 2 (mantém) |
| 620–680 ns | 0 | 1 | 85 | **só a subida 650** | 2 (mantém: a subida não grava) |
| 680–720 ns | 0 | 0 | 85 | descida 700 | 2 (mantém: `wr_en = 0`) |
| 720–820 ns | 0 | 1 | 85 | subida 750, descida 800 | 85 **em 800 ns** |
| 820–920 ns | 1 | 1 | 12 | descida 900 | 0 **em 820 ns** (reset assíncrono, fora de borda) |
| 920–1020 ns | 0 | 1 | 12 | subida 950, descida 1000 | 12 **em 1000 ns** |
| 1020 ns em diante | 0 | 1 | 3 | subida 1050, descida 1100 | 3 **em 1100 ns** |

Instantes medidos de mudança de `data_out`: 300, 400, 800, 820 (reset), 1000 e 1100 ns. Fora o reset,
todos são descidas; nenhuma mudança ocorre numa subida, nem mesmo na janela 620–680 ns, em que
`wr_en = 1` e `data_in = 85` estavam prontos na subida de 650 ns.

### `pc_rom_tb`

Reset de 0 a 220 ns (solto fora de borda, pelo mesmo motivo do `pc_tb`). O PC conta 1, 2, 3, ... nas
descidas a partir de 300 ns, uma unidade por clock (em 2000 ns vale 18). A saída da ROM mostra o
conteúdo em ordem, meio clock (50 ns) atrasada: em 350 ns (PC = 1) aparece `ROM[1]` =
`01000_00000_0000101`; em 450 ns (PC = 2) `ROM[2]` = NOP; em 950 ns (PC = 7) `ROM[7]` =
`01000_00000_0001010`; em 1250 ns (PC = 10) `ROM[10]` = `01111_00000_0000011`; em 1350 ns (PC = 11)
`ROM[11]`; em 1450 ns `ROM[12]` = NOP. Os JMPs são ignorados, como pede o PDF nessa etapa.

### `un_controle_tb`

| Intervalo | instr | estado | pc_atual | pc_wr_en | pc_prox |
|---|---|:-:|---:|:-:|---:|
| 0–50 ns | `00000_000000000000` (NOP) | 0 | 0 | 0 | 1 |
| 50–100 ns | `00000_000000000000` (NOP) | 1 | 0 | 1 | 1 |
| 100–150 ns | `01000_00000_0000101` (JMP 5) | 1 | 1 | 1 | 5 |
| 150–200 ns | `01000_00000_0000101` (JMP 5) | 0 | 1 | 0 | 5 |
| 200–250 ns | `01111_00000_0000011` (não usado) | 1 | 10 | 1 | 11 |
| 250–300 ns | `00000_000000000000` (NOP) | 1 | 127 | 1 | 0 (volta a 0 em 7 bits) |
| 300–350 ns | `01000_11111_1111111` (JMP 127, bits x em 1) | 1 | 3 | 1 | 127 |
| 350 ns em diante | `11000_00000_0000101` (não usado) | 1 | 20 | 1 | 21 |

O último caso confere que o 5.º bit do opcode é decodificado: `11000` tem os mesmos 4 bits baixos do
JMP, mas `jump_en = 0` e o PC só avança.

## 9. Como rodar

Dentro de `lab4/`:

```
./run.sh
gtkwave processador_tb.ghw
```

O `run.sh` analisa todos os fontes com `ghdl -a`, elabora e roda cada testbench gerando um `.ghw`
("rode a entidade do testbench final com, digamos, ghdl -r e_4_entradas_tb --wave=result.ghw",
*µProcessador 3*, apêndice). Os arquivos gerados (`.ghw`, `work-obj93.cf`, executáveis) não devem ser
versionados.

Duração das simulações: o `sim_time_proc` leva `finished` a '1' em 2 µs nos blocos com clock e em 4 µs
no `processador_tb`. Nesse mesmo instante o `clk_proc` ainda lê `finished = '0'`, porque um signal "só
vai ser atualizado ao final do ciclo de simulação" (*µProcessador 5*, "Contadores em VHDL", nota 2,
p. 1), e por isso completa mais um período: descida em 2000 ns e subida em 2050 ns (4000 e 4050 ns no
`processador_tb`). As ondas vão, então, até 2,1 µs e 4,1 µs. No `processador_tb` a descida extra de
4000 ns cai no estado 0 e não escreve o PC, então continuam sendo 19 instruções (seção 5). O
`un_controle_tb`, sem clock, dura 400 ns.

Entrega: "me interessam apenas os arquivos fontes VHDL. Entregue-os dentro de um arquivo .zip"
(*µProcessador 4*, "Unidade de Controle com Jump", p. 4).
