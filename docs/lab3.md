# Lab 3 — Banco de Registradores e ULA

Arquivos em `lab3/`:

| Arquivo | Conteúdo |
|---|---|
| `reg16bits.vhd` | registrador de 16 bits (modelo `reg8bits` do PDF, alargado) |
| `banco.vhd` | banco com 8 registradores R0..R7, instancia `reg16bits` 8 vezes |
| `ula.vhd` | ULA do lab 2 (mesma entidade usada em `lab2/`) |
| `banco_ula.vhd` | top level: banco + ULA + muxes para a ISA ortogonal |
| `reg16bits_tb.vhd`, `banco_tb.vhd`, `banco_ula_tb.vhd` | testbenches |
| `run.sh` | análise, elaboração e simulação com GHDL |

As especificações da equipe estão em `docs/00-especificacoes.md` (8 registradores, ISA ortogonal,
ADD/SUB/SUBB com dois operandos só entre registradores, LD direto, CMPR/CMPI).

Referências usadas:

- *µProcessador 3* (`PDF dos labs/uprocessador 3.pdf`), citado pela seção e página do PDF.
- *Características do Projeto do µP* (arquivo `PDF dos labs/6996-EncargosdeIRRF-082026.pdf`).
- Slides `Materiais teóricos/cap2-ciclo-unico.pdf` (a página citada é a do PDF, que coincide com o número impresso no rodapé).
- Patterson & Hennessy, *Computer Organization and Design RISC-V Edition*, seção 4.3 *Building a Datapath*
  (página impressa do livro).

---

## 1. O que o lab pede

Do *µProcessador 3*:

- Seção "Registrador Padrão" (p. 2): "Faça um registrador de dezesseis bits e construa um testbench adequado".
- Seção "Pinagem do Banco de Registradores" (p. 4–5): "Construa o banco de registradores especificado para a equipe
  e faça um testbench adequado. Cada registrador tem 16 bits." e "É obrigatório usar múltiplas fontes VHDL:
  um arquivo “.vhd” para um registrador e outro arquivo instanciando os registradores (este é o banco)."
- Seção "Ligando os Registradores a uma ULA" (p. 6–7): "Obrigatoriamente criem no mínimo um bloco para a ULA,
  um bloco para o banco e usem ambos integrados no arquivo top level" e "Obrigatoriamente façam um reset
  explícito de todos os registradores/flip-flops no início da simulação".
- Seção "Registrador Padrão" (p. 2): "O if-then só deve ser usado nesta disciplina para criar um registrador!"

---

## 2. Código recebido do colega (Thales) e correções

Na raiz do repositório estavam `reg16bits.vhd`, `banco.vhd` e `banco_tb.vhd` (e `ula.vhd`/`ula_tb.vhd`, do lab 2,
que não foram tocados aqui). Os arquivos da raiz não foram alterados; as versões corrigidas estão em `lab3/`.

| Arquivo | O que havia | O que foi feito em `lab3/` |
|---|---|---|
| `reg16bits.vhd` | Cópia fiel do `reg8bits` do PDF com 16 bits: mesmo `process(clk,rst,wr_en)`, reset assíncrono, `wr_en` como clock enable, `rising_edge(clk)`, `data_out <= registro` fora do processo. Funcionalmente correto. Tinha tabulações e linhas em branco soltas dentro do `if`. | Mantido igual; só a formatação foi limpa (sem tabulações). |
| `banco.vhd` | 8 instâncias de `reg16bits`, decodificador de escrita com `when-else` (um `wr_en_regN` por registrador) e dois muxes de leitura `when-else` terminando em `"0000000000000000"`. Interface igual à exigida. Funcionalmente correto. | Mantido (nomes e ordem das portas iguais); só indentação/tabulações. |
| `banco_tb.vhd` | 1) **Não compilava**: `wait 100 ns;` (falta o `for`). O GHDL acusa `banco_tb.vhd:93:22:error: 'on', 'until', 'for' or ';' expected`. 2) Tinha comentários `--` copiados do PDF (a equipe decidiu não ter comentários no código). 3) Só escrevia R1, R2 e R7; não testava R0, R3..R6, nem leitura de todos os registradores, nem a escrita durante o reset. | Reescrito: reset explícito (`reset_global`), escrita em todos os 8 registradores, leitura dupla de todos, teste de `wr_en='0'`, leitura do mesmo registrador nas duas portas, e escrita/leitura no mesmo ciclo. |
| (não havia) | Não existia testbench do registrador, pedido na seção "Registrador Padrão". | Criado `reg16bits_tb.vhd`. |
| (não havia) | Não existia top level banco + ULA. | Criado `banco_ula.vhd` e `banco_ula_tb.vhd`. |

---

## 3. Registrador de 16 bits (`reg16bits.vhd`)

```
entity reg16bits is port( clk, rst, wr_en : in std_logic;
                          data_in  : in  unsigned(15 downto 0);
                          data_out : out unsigned(15 downto 0));
```

É o `reg8bits` da seção "VHDL Sequencial" (p. 1) com 16 bits. Comportamento:

| rst | wr_en | clk | registro |
|---|---|---|---|
| 1 | x | x | 0 (assíncrono) |
| 0 | 1 | borda de subida | `data_in` |
| 0 | 0 | x | mantém |

O `wr_en` é o clock enable: "Para fazer uma sequência de operações em vários registradores, usamos um clock
enable. Quando ele estiver em 0, o clock será ignorado." (*µProcessador 3*, "Registrador Padrão", p. 2).

---

## 4. Banco de registradores (`banco.vhd`)

```
entity banco is port( data_wr                : in  unsigned(15 downto 0);
                      reg_wr, reg_r1, reg_r2 : in  unsigned(2 downto 0);
                      clk, wr_en, rst        : in  std_logic;
                      data_r1, data_r2       : out unsigned(15 downto 0));
```

### Base teórica

- Livro, seção 4.3, p. 262: "A register file is a collection of registers in which any register can be
  read or written by specifying the number of the register in the file." e "Writes, however, are controlled
  by the write control signal, which must be asserted for a write to occur at the clock edge."
- Livro, Figure 4.7 (p. 263): "The register file contains all the registers and has two read ports and one
  write port." Na figura, o bloco *Registers* tem as entradas *Read register 1*, *Read register 2*,
  *Write register*, *Write data* e o sinal *RegWrite*, e as saídas *Read data 1* e *Read data 2*.
  No nosso banco: `reg_r1`, `reg_r2`, `reg_wr`, `data_wr`, `wr_en`, `data_r1`, `data_r2`.
  No livro os números de registrador têm 5 bits (32 registradores); aqui têm 3 bits (8 registradores).
- Mesma legenda: "the read will get the value written in an earlier clock cycle, while the value written
  will be available to a read in a subsequent clock cycle." (observado na simulação, seção 8).
- Slides `cap2-ciclo-unico.pdf`, seção 3.3 "Como Funfa um Banco de Registradores?" (p. 7): "A maneira mais
  fácil de se entender um banco de registradores é pensar nele como se fosse uma memória de dados", "O
  registrador em si é apenas uma coleção de flip-flops D em paralelo" e "habilitamos a escrita setando wr en
  (write enable) para 1; na próxima rampa de subida do clock, a escrita será realizada." A pinagem é a da
  "Figura 5: Bloco do Banco de Registradores" (p. 8), com os mesmos nomes `reg_r1`, `reg_r2`, `reg_wr`,
  `data_wr`, `data_r1`, `data_r2`, `wr_en`.
- *µProcessador 3*, "Pinagem do Banco de Registradores" (p. 4): "Se não houver acumulador, as instruções são
  ortogonais e o banco é similar ao visto em sala" e "o banco sempre está fazendo a leitura de dois
  registradores, portanto temos dois barramentos de entrada dizendo o número dos registradores que desejamos ler."

### Circuito

```
              reg_wr  wr_en
                 |      |
          +------v------v------+      wr_en_reg0 ... wr_en_reg7
          | decodificador      |------------------------------+
          | wr_en_regN = 1 se  |                              |
          | wr_en=1 e reg_wr=N |                              |
          +--------------------+                              |
                                                              v
 data_wr ---------+-----------+--- ... ---+           +--------------+
                  |           |           |           |              |
               +--v--+     +--v--+     +--v--+        |              |
               | R0  |     | R1  | ... | R7  |  clk, rst em todos    |
               +--+--+     +--+--+     +--+--+        |              |
                  | reg0      | reg1      | reg7                     |
                  +-----+-----+----...----+                          |
                        |                                            |
              +---------+---------+                                  |
              |                   |                                  |
         +----v----+         +----v----+                             |
 reg_r1->| mux 8:1 |  reg_r2>| mux 8:1 |                             |
         +----+----+         +----+----+
              |                   |
           data_r1             data_r2
```

- Os 8 registradores recebem o mesmo `data_wr`, `clk` e `rst`; só um recebe `wr_en='1'` (decodificador de
  `reg_wr` feito com `when-else`).
- A leitura é combinacional: dois muxes 8:1 (`when-else`) escolhem `reg0..reg7` pelos números `reg_r1` e `reg_r2`.
- Todos os registradores, inclusive R0, são de uso geral (ver pergunta da seção 7).

---

## 5. ULA (`ula.vhd`)

É a mesma entidade do lab 2 (arquivo idêntico ao de `lab2/`, ver `docs/lab2.md`):

```
entity ula is port( A, B : in unsigned(15 downto 0); carry_in : in std_logic;
                    controle : in unsigned(1 downto 0);
                    ULA_Out : out unsigned(15 downto 0);
                    zero, carry, overflow, sinal : out std_logic);
```

| controle | operação | carry | overflow |
|---|---|---|---|
| 00 | A + B | bit 16 da soma em 17 bits | A(15)=B(15) e res(15)≠A(15) |
| 01 | A − B | bit 16 da subtração (empresta-um) | A(15)≠B(15) e res(15)≠A(15) |
| 10 | A − B − carry_in | bit 16 da subtração | A(15)≠B(15) e res(15)≠A(15) |
| 11 | A and B | 0 | 0 |

`zero` = 1 quando o resultado é 0; `sinal` = bit 15 do resultado. Não há flip-flops de flags aqui: isso é do
lab 6 (*µProcessador 6*, "Os Flip-flops das Flags"). Por isso `carry_in` ainda vem do testbench.
"Não é necessário testar as outras operações da ULA: supomos que vocês fizeram isso direito na prática
anterior." (*µProcessador 3*, p. 7).

---

## 6. Banco + ULA para a ISA ortogonal (`banco_ula.vhd`)

### O que o PDF diz

- *µProcessador 3*, "Ligando os Registradores a uma ULA" (p. 6): "Se não houver acumulador (ISA ortogonal),
  fica muito parecido com o meu PDF". O "PDF" é o `cap2-ciclo-unico.pdf`: `data_r1` vai para uma entrada da ULA
  e `data_r2` (ou uma constante) para a outra.
- Mesma seção (p. 6): "se houver LD de constante, ela deve entrar no banco via um MUX; instruções MOV de cópia de
  registrador também exigem MUX".
- Seção "Sorteio para a Equipe -- Operações da ULA" (p. 5): com "Carrega diretamente com LD sem somar" a
  "constante deverá ser conduzida diretamente do exterior do circuito (neste lab, vem do testbench), para o
  banco de registradores"; e, se houver comparação com constante ("CMPI (compara com constante)"),
  "a constante externa deverá poder ser selecionada como uma das entradas da ULA."
- Livro, seção 4.3, p. 267 (exemplo que gera a Figure 4.10): "one multiplexor is placed at the ALU input and
  another at the data input to the register file."
- Slides `cap2-ciclo-unico.pdf`, p. 7: "um mux seletor é necessário para fazer essa escolha, diferenciando add
  de addi"; p. 17: "Precisamos então de um mux para escolher entre esta constante e o valor do registrador" e
  "Este mux irá selecionar qual dos dados será repassado ao banco de registradores para ser escrito".

### Muxes necessários para as instruções sorteadas

| Instrução | Precisa de | Mux |
|---|---|---|
| ADD, SUB, SUBB, CMPR | A = Rd, B = Rs | `sel_ula_b = '0'` (B = `data_r2`) |
| CMPI Rd,cte | B = constante | `sel_ula_b = '1'` (B = `constante`) — **mux na entrada B da ULA** |
| ADD, SUB, SUBB | gravar resultado da ULA | `sel_dado = "00"` |
| LD Rd,cte | gravar a constante sem passar pela ULA | `sel_dado = "01"` — **mux na entrada de dados do banco** |
| MOV Rd,Rs | gravar `data_r2` | `sel_dado = "10"` |

Como ADD/SUB/SUBB têm dois operandos ("o primeiro operando é tanto fonte como destino ... SUB R5,R1 faz
R5←R5-R1 (ortogonal)", *µProcessador 3*, p. 5), usamos sempre `reg_wr = reg_r1 = Rd` e `reg_r2 = Rs`.
No MOV a fonte vai em `reg_r2` para ficar na mesma posição do segundo operando de ADD/SUB; essa escolha
(caminho direto `data_r2 → data_wr` em vez de passar pela ULA) é da equipe e evita alterar a ULA.
A ULA nunca recebe constante em ADD/SUB (sorteio: "ADD apenas entre registradores, nunca com constantes").

### Circuito (ASCII)

```
                                     constante (16 bits, do testbench)
                                         |
            +----------------------------+-----------------------------+
            |                            |                             |
            |      reg_r1 reg_r2 reg_wr  |                             |
            |        |      |      |     |                             |
            |     +--v------v------v--+  |    sel_ula_b                |
            |     |                   |  |       |                     |
            |     |      banco        |  |   +---v---+                 |
            |     |    R0 .. R7       |  +-->| 1     |                 |
            |     |                   |      |  mux  |--- B ---+       |
            |     |           data_r2 |--+-->| 0     |         |       |
            |     |                   |  |   +-------+      +--v---+   |
            |     |           data_r1 |--|------------ A -->| ULA  |<--- controle, carry_in
            |     |                   |  |                  +--+---+   |
            |     | data_wr           |  |                     |       |
            |     +---^---------------+  |          ula_out <--+--> zero, carry,
            |         |   ^ clk rst wr_en|                     |    overflow, sinal
            |     +---+---+              |                     |
            |     |  mux  |<---- 10 -----+                     |
            +---->| 01    |                                    |
                  |  00   |<-----------------------------------+
                  +---^---+
                      |
                   sel_dado
```

### Interface do top level

```
entity banco_ula is port( clk, rst, wr_en        : in std_logic;
                          reg_wr, reg_r1, reg_r2 : in unsigned(2 downto 0);
                          controle               : in unsigned(1 downto 0);
                          sel_ula_b              : in std_logic;
                          sel_dado               : in unsigned(1 downto 0);
                          constante              : in unsigned(15 downto 0);
                          carry_in               : in std_logic;
                          ula_out                : out unsigned(15 downto 0);
                          zero, carry, overflow, sinal : out std_logic);
```

A constante chega ao top já com 16 bits; a extensão de sinal da constante de 9 bits da instrução
(*Características*, seção 3: "deverão ser sinalizadas e estar em complemento de 2, exigindo portanto extensão
de sinal") será feita no lab 5, quando a constante vier da instrução.

### Sinais de controle por instrução (o que a UC do lab 5/6 vai gerar)

| Instrução | wr_en | reg_wr | reg_r1 | reg_r2 | controle | sel_ula_b | sel_dado |
|---|---|---|---|---|---|---|---|
| LD Rd,cte | 1 | Rd | x | x | x | x | 01 |
| MOV Rd,Rs | 1 | Rd | x | Rs | x | x | 10 |
| ADD Rd,Rs | 1 | Rd | Rd | Rs | 00 | 0 | 00 |
| SUB Rd,Rs | 1 | Rd | Rd | Rs | 01 | 0 | 00 |
| SUBB Rd,Rs | 1 | Rd | Rd | Rs | 10 | 0 | 00 |
| CMPR Rd,Rs | 0 | x | Rd | Rs | 01 | 0 | x |
| CMPI Rd,cte | 0 | x | Rd | x | 01 | 1 | x |

CMPR/CMPI não gravam o resultado: "realiza uma comparação subtraindo os dois operandos e alterando as flags
... sem gravar o resultado" (*Características*, seção 4.3), por isso `wr_en = 0`.

---

## 7. Respostas às perguntas do PDF (*µProcessador 3*, p. 6)

**"Existe um registrador com constante zero? Isso significa que a carga de uma constante é feita com a soma da
constante com zero?"**
Não. O sorteio foi "Carrega diretamente com LD sem somar". O documento *Características* (seção 3) só exige
R0 fixo em zero na outra opção: "Constantes gravadas por soma com registrador zero e instrução ADDI com três
operandos (por ex., ADDI R6,R0,131), caso em que o registrador R0 deve ser fixo com o valor zero". No nosso
caso R0 é um registrador comum (na simulação, `LD R0,2` e `MOV R0,R1` gravam R0 normalmente). A carga não
passa pela ULA: a constante vai direto para `data_wr` pelo mux `sel_dado = "01"`.

**"É vital poder copiar o dado guardado no acumulador para um registrador do banco e vice-versa. Precisamos de
MUXes para isso? Se sim, onde?"**
Não há acumulador (ISA ortogonal). A cópia equivalente é `MOV Rn,Rm` (*µProcessador 3*, "Sorteio para a Equipe
-- Acumulador ou Não", p. 5: "deverá ser implementada no futuro uma instrução MOV Rn,Rm"), e ela exige um mux
na entrada de dados do banco (entrada `"10"` do mux `sel_dado`, que liga `data_r2` a `data_wr`).

**"Como carregar uma constante para um registrador do banco? Qual a instrução ou instruções assembly? É preciso
mudar algo no circuito?"**
Com uma única instrução `LD Rd,cte` (ex.: `LD R3,5`). No circuito é preciso: (1) a entrada `constante` vinda de
fora (neste lab, do testbench; no lab 5, do campo da instrução com extensão de sinal); (2) o mux na entrada de
dados do banco (`sel_dado = "01"`). Para o CMPI também é preciso o mux na entrada B da ULA (`sel_ula_b = '1'`).

---

## 8. Testes e resultados observados

Todos os testbenches seguem o modelo da seção "Testbench com Clock" (p. 2–3): `reset_global` com reset por 2
períodos, `sim_time_proc`, `clk_proc`, `period_time = 100 ns`, e terminam com `wait;`. As entradas mudam em
t = 200, 300, 400 ns ...; as bordas de subida do clock são em 50, 150, 250, 350 ns ... Os valores abaixo foram
lidos do VCD gerado pelo GHDL 4.1 (hexadecimal).

### `reg16bits_tb`

| t (ns) | rst | wr_en | data_in | data_out após a borda |
|---|---|---|---|---|
| 0–200 | 1 | 1 | FFFF | 0000 (reset domina) |
| 200 | 0 | 1 | 1234 | 1234 |
| 300 | 0 | 0 | FFFF | 1234 (não escreve) |
| 400 | 0 | 1 | ABCD | ABCD |
| 500 | 0 | 1 | 00FF | 00FF |
| 600 | 0 | 0 | 5555 | 00FF |

### `banco_tb`

- Durante o reset tenta-se gravar 7777 em R3: R3 continua 0000.
- t = 200..900 ns: grava R0..R7 com 0101, 1111, 2222, 3333, 4444, 5555, 6666, FFFF (um por ciclo), lendo o
  registrador recém-escrito em `data_r1` e o anterior em `data_r2`. Ex.: em 590 ns `data_r1 = 3333` (R3) e
  `data_r2 = 2222` (R2).
- t = 1000 ns: `wr_en = 0`, `reg_wr = 5`, `data_wr = AAAA`: R5 continua 5555.
- Leituras duplas: (R0,R7) = (0101, FFFF); (R1,R6) = (1111, 6666); (R2,R5) = (2222, 5555); (R3,R4) = (3333, 4444);
  (R4,R4) = (4444, 4444).
- t = 1600 ns: grava 0ABC em R2 lendo R2 nas duas portas: antes da borda (1640 ns) aparece 2222, depois
  (1690 ns) 0ABC — exatamente o comportamento da legenda da Figure 4.7 citada na seção 4.

### `banco_ula_tb` (sequência de "instruções")

"ULA antes da borda" é a saída combinacional no meio do ciclo (t+40 ns), "registrador" é o valor após a borda.

| t (ns) | instrução simulada | ULA antes da borda | Z C V N | registrador após a borda |
|---|---|---|---|---|
| 0–200 | reset + tentativa de `LD R1,9` | – | – | todos 0000 |
| 200 | LD R3,5 | – | – | R3 = 0005 |
| 300 | LD R4,8 | – | – | R4 = 0008 |
| 400 | MOV R5,R3 | – | – | R5 = 0005 |
| 500 | ADD R5,R4 | 000D | 0 0 0 0 | R5 = 000D (13) |
| 600 | SUB R5,R3 | 0008 | 0 0 0 0 | R5 = 0008 |
| 700 | CMPI R5,8 | 0000 | 1 0 0 0 | R5 = 0008 (não grava) |
| 800 | CMPI R5,20 | FFF4 (−12) | 0 1 0 1 | R5 = 0008 |
| 900 | CMPR R5,R4 | 0000 | 1 0 0 0 | R5 = 0008 |
| 1000 | SUBB R5,R3 (carry_in = 1) | 0002 | 0 0 0 0 | R5 = 0002 (8 − 5 − 1) |
| 1100 | LD R6,32767 | – | – | R6 = 7FFF |
| 1200 | LD R7,1 | – | – | R7 = 0001 |
| 1300 | ADD R6,R7 | 8000 | 0 0 1 1 | R6 = 8000 (overflow) |
| 1400 | LD R1,−3 | – | – | R1 = FFFD |
| 1500 | `wr_en = 0`, tenta gravar 1234 em R5 | – | – | R5 = 0002 (não grava) |
| 1600 | LD R0,2 | – | – | R0 = 0002 |
| 1700 | LD R2,6 | – | – | R2 = 0006 |
| 1800 | MOV R0,R1 | – | – | R0 = FFFD |
| 1900 | leitura R0,R2 com AND | 0004 (FFFD and 0006) | 0 0 0 0 | – |
| 2000 | leitura R3,R4 (soma) | 000D (5 + 8) | – | – |
| 2100 | leitura R5,R6 (soma) | 8002 (2 + 8000) | – | – |
| 2200 | leitura R7,R1 (soma) | FFFE (1 + (−3)) | – | – |

Estado final: R0 = FFFD, R1 = FFFD, R2 = 0006, R3 = 0005, R4 = 0008, R5 = 0002, R6 = 8000, R7 = 0001.
Todos os 8 registradores foram escritos e lidos.

Forma de onda do trecho ADD / SUB / CMPI / CMPI (cada coluna = 50 ns, valor do meio do intervalo; bordas de subida em 550, 650, 750, 850 ns):

```
t (ns)     500  550  600  650  700  750  800  850  900
clk        0    1    0    1    0    1    0    1
                ^borda    ^borda    ^borda    ^borda
wr_en      1    1    1    1    0    0    0    0
controle   00   00   01   01   01   01   01   01
sel_ula_b  0    0    0    0    1    1    1    1
constante  -    -    -    -    0008 0008 0014 0014
R5         0005 000D 000D 0008 0008 0008 0008 0008
ula_out    000D 0015 0008 0003 0000 0000 FFF4 FFF4
zero       0    0    0    0    1    1    0    0
carry      0    0    0    0    0    0    1    1
```

Nas colunas 550 e 650 ns a ULA já mostra a conta com o novo valor de R5 (000D+0008 = 0015, 0008−0005 = 0003),
pois a leitura do banco é combinacional; isso não importa porque a escrita só ocorre na borda seguinte e,
na sequência, o testbench já troca a instrução.

---

## 9. Como rodar

```
cd lab3
sh run.sh
gtkwave banco_ula_tb.ghw
```

O `run.sh` analisa os sete arquivos com `ghdl -a`, elabora e roda os três testbenches gerando
`reg16bits_tb.ghw`, `banco_tb.ghw` e `banco_ula_tb.ghw` (não versionar os `.ghw` nem o `work-obj93.cf`).
