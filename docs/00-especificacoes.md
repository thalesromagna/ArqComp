# Especificações do µProcessador da equipe (Thales e Sergio)

Este documento reúne **o que o professor sorteou** para a equipe, **o que ainda não foi sorteado**
e **as decisões de projeto** que valem para todos os laboratórios. Os emails originais estão em
`especificações do professor para meu grupo.txt`. Todos os labs seguem este arquivo.

## 1. Itens sorteados (emails do prof. Juliano)

Email 1 — ULA:

```
{'Saltos condicionais': ['BLE', 'BVC']}
```

Email 2 — Banco de registradores:

```
{'Número de registradores no banco': [8],
 'Acumulador ou não': 'ULA com instruções ortogonais'}

{'ADD ops': 'ADD com dois operandos apenas',
 'Carga de constantes': 'Carrega diretamente com LD sem somar',
 'ADD ctes': 'ADD apenas entre registradores, nunca com constantes',
 'SUB ctes': 'Subtração apenas entre registradores, nunca com constantes',
 'Comparações': 'Comparação tanto com regs quanto ctes (CMPR/CMPI)',
 'Subtração': 'Tanto SUB sem borrow quanto SUBB com borrow estão presentes',
 'SUB ops': 'Subtração com dois operandos apenas'}
```

Email 3 — Unidade de controle:

```
{'Largura da ROM / tamanho da instrução em bits': [17],
 'Incremento do PC': ['PC sensível a clock de descida'],
 'Leitura da ROM': ['síncrona'],
 'Saltos': 'Incondicional é absoluto e condicional é relativo',
 'Registrador de Instruções': ['não usar']}
```

### Consequências de cada item (com a fonte)

| Item sorteado | Consequência | Fonte |
|---|---|---|
| BLE, BVC | Flags obrigatórias: **Z, N, V** (LE: `Z = 1 or N != V`; VC: `V = 0`). | Tabela do apêndice do *µProcessador 2* e Tabela 2 do documento *Características do Projeto do µP* (arquivo `6996-EncargosdeIRRF-082026.pdf`), seção 5.2 |
| SUBB presente | Flag **C** também é necessária: "SUBB R1,R2 irá realizar R1 ← R1 − R2 − Cf". | *Características*, seção 4.3 |
| 8 registradores | Banco R0..R7, endereço de registrador com 3 bits. | Email 2 |
| Ortogonal | Não há acumulador; "deverá ser implementada uma instrução MOV Rn,Rm, que faz Rn ← Rm". | *Características*, seção 2; *µProcessador 3*, "Sorteio para a Equipe" |
| 2 operandos (ADD/SUB) | "o primeiro operando é tanto fonte quanto destino ... SUB R3,R6 que realiza R3 ← R3 − R6". | *Características*, seção 4.1 |
| LD sem somar | "Instrução LD exclusiva de carga (por ex., LD R5,131), caso em que a constante deverá ser conduzida diretamente da instrução para o banco". | *Características*, seção 3 |
| Constantes | "deverão ser sinalizadas e estar em complemento de 2, exigindo portanto extensão de sinal". | *Características*, seções 3 e 4.2 |
| ADD/SUB sem constantes | Não existem ADDI nem SUBI. Para subtrair 1 é preciso carregar 1 num registrador. | Email 2 |
| CMPR / CMPI | "realiza uma comparação subtraindo os dois operandos e alterando as flags ... sem gravar o resultado". | *Características*, seção 4.3 |
| ROM de 17 bits | Cada instrução tem 17 bits; a ROM guarda `unsigned(16 downto 0)`. "O tamanho das instruções é sorteado para a equipe, e é igual à largura de um dado da ROM". | Email 3; *µProcessador 5*, "Implementação" |
| PC na descida do clock | O registrador do PC usa `falling_edge(clk)`: "Se algum item sorteado for sensível a rampa de descida, utilize falling_edge(clk) ao invés de rising_edge(clk)". | Email 3; *µProcessador 5*, "Contadores em VHDL" |
| ROM síncrona | Modelo do PDF com `process(clk)`: "Note que esta ROM é sincrona! Isto significa que é preciso dar um clock nela para que ela leia os dados". | Email 3; *µProcessador 4*, "ROM em VHDL" |
| Saltos | JMP absoluto; BLE e BVC relativos (confirma a convenção que já seguíamos). | Email 3; *Características*, seção 5.1 |
| Sem registrador de instrução | A instrução vem direto da saída da ROM. O lab 5 só pede o registrador "Caso o seu sorteio especifique um Registrador de Instrução", e a lista de sinais do gtkwave prevê "instrução (saída do Registrador de Instrução, ou, se não houver, da ROM)". | Email 3; *µProcessador 5*, "Implementação" e "Testes" |

Regras gerais que também valem:

- "O processador não deverá executar opcodes fora do que foi explicitamente pedido" (*Características*, seção 1).
  Opcodes não usados não fazem nada (comportam-se como NOP e o PC avança).
- NOP é o código todo em zero, `0x00000` em 17 bits (*Características*, seção 7; *µProcessador 5*, "Avaliação").
- JMP usa endereço **absoluto**; branches Bxx usam endereço **relativo**, com delta em complemento de 2
  (*Características*, seção 5.1; *µProcessador 4* e *µProcessador 6*, "Observações sobre o sorteio").
- As flags ficam em flip-flops individuais, fora da ULA, atualizados apenas em instruções de ULA
  (*Características*, seção 4.4, "Armazenamento das flags"; *µProcessador 6*, "Os Flip-flops das Flags").

## 2. Itens que ainda NÃO foram sorteados / recebidos

| Item | Onde é pedido | Situação |
|---|---|---|
| Final do loop da validação | *Características*, seção 6.2 | **Pendente.** Não implementado. |
| Complicação da validação | *Características*, seção 6.3 | **Pendente.** Não implementado. |
| Programa de validação (crivo de Eratóstenes) | *µProcessador 7*, "Validação" | **Pendente** até o sorteio dos itens acima. |
| Extra FPGA (primos nos displays da DE10-Lite) | `FPGA.pdf` | **Pendente.** Depende da validação e dos arquivos do professor (RAMDisp.vhd, projeto Quartus). |

Largura da instrução (17 bits), ROM síncrona, PC na descida e ausência de registrador de instrução
já foram sorteados (Email 3).

## 3. Organização do processador

- Dados de 16 bits (*µProcessador 2*, "Tarefa para Entregar: ULA", p. 7: "duas entradas de dados de 16 bits";
  *µProcessador 3*, "Pinagem do Banco de Registradores", p. 5: "Cada registrador tem 16 bits").
- ROM de 128 endereços (modelo do *µProcessador 4*) → PC de 7 bits.
- RAM de 128 endereços × 16 bits (modelo do *µProcessador 7*), escrita síncrona e leitura assíncrona.
- Máquina de 3 estados: fetch, decode, execute (sugestão do *µProcessador 5*, "Implementação"),
  com o contador do *µProcessador 5* copiado como está (borda de subida). No lab 4, que só pede 2 estados,
  é o flip-flop T do *µProcessador 4*.
- Sem registrador de instrução (Email 3): a instrução é a própria saída `dado` da ROM síncrona.
- Bordas usadas:
  - ROM, banco, flags, RAM e máquina de estados: **subida** (`rising_edge`);
  - PC: **descida** (`falling_edge`, Email 3), com `wr_en` ligado só no estado de execução.
- Linha do tempo de uma instrução (labs 5 a 7; no lab 4 é igual, com o estado 1 fazendo o papel do execute):
  - estado 0 (fetch): a saída da ROM já é a instrução apontada pelo PC, que a ROM síncrona registrou na
    subida que encerrou o execute anterior (a primeira, `ROM[0]`, já é lida nas subidas durante o reset,
    que zera o PC). Na subida que encerra o estado 0 a ROM lê de novo o mesmo endereço, e a saída não muda;
  - estado 1 (decode): a unidade de controle decodifica a mesma instrução;
  - estado 2 (execute): na **descida** do meio do estado, o PC recebe o próximo endereço; na **subida**
    que encerra o estado, gravam banco, flags e RAM (com os sinais da instrução atual, pois a saída da ROM
    só muda nessa mesma borda) e a ROM já registra `ROM[novo PC]`, que é a instrução do próximo fetch.
- A instrução fica estável durante fetch, decode e execute porque a ROM só muda numa subida e o PC só muda
  na descida do execute: a única subida que lê um endereço novo é a que encerra o execute.
  O próximo PC é calculado com o PC da própria instrução, então um branch faz
  `PC ← PC + delta`, onde PC é o endereço do próprio branch
  ("branch 5 vai pular cinco instruções pra frente de onde ele está", *µProcessador 6*, nota 1).

Base teórica do caminho de dados: Patterson & Hennessy, *Computer Organization and Design RISC-V Edition*,
seções 4.3 (*Building a Datapath*) e 4.4 (*A Simple Implementation Scheme*), e os slides `cap2-ciclo-unico.pdf`.
Cada lab em `docs/` cita os trechos usados.

## 4. Codificação das instruções (17 bits)

```
MSB b16                         b0 LSB
     | opcode (5) | campos (12)     |
```

O opcode ocupa os 5 bits mais significativos (b16..b12); os campos ocupam b11..b0. Com 5 bits sobram
19 opcodes livres para as instruções que o sorteio da validação ainda pode exigir (*Características*, seção 6).

Legenda: `ddd` registrador destino (ou primeiro operando), `sss` registrador fonte (segundo operando),
`ccccccccc` constante de 9 bits em complemento de 2, `aaaaaaa` endereço absoluto de 7 bits,
`eeeeeee` delta de 7 bits em complemento de 2, `x` irrelevante.

| Assembly | Binário | Operação | Flags |
|---|---|---|---|
| `NOP` | `00000 000000000000` | nada | – |
| `LD Rd,cte` | `00001 ddd ccccccccc` | Rd ← cte (com extensão de sinal) | – |
| `MOV Rd,Rs` | `00010 ddd sss xxxxxx` | Rd ← Rs | – |
| `ADD Rd,Rs` | `00011 ddd sss xxxxxx` | Rd ← Rd + Rs | Z N C V |
| `SUB Rd,Rs` | `00100 ddd sss xxxxxx` | Rd ← Rd − Rs | Z N C V |
| `SUBB Rd,Rs` | `00101 ddd sss xxxxxx` | Rd ← Rd − Rs − C | Z N C V |
| `CMPR Rd,Rs` | `00110 ddd sss xxxxxx` | Rd − Rs (só flags) | Z N C V |
| `CMPI Rd,cte` | `00111 ddd ccccccccc` | Rd − cte (só flags) | Z N C V |
| `JMP end` | `01000 xxxxx aaaaaaa` | PC ← end | – |
| `BLE delta` | `01001 xxxxx eeeeeee` | se Z=1 ou N≠V: PC ← PC + delta | – |
| `BVC delta` | `01010 xxxxx eeeeeee` | se V=0: PC ← PC + delta | – |
| `LW Rd,(Rs)` | `01011 ddd sss xxxxxx` | Rd ← RAM[Rs] | – |
| `SW Rd,(Rs)` | `01100 ddd sss xxxxxx` | RAM[Rs] ← Rd | – |
| (01101 a 11111) | – | não usados, não fazem nada (PC avança) | – |

As instruções entram aos poucos: Lab 4 tem NOP e JMP; Lab 5 acrescenta LD, MOV, ADD, SUB;
Lab 6 acrescenta SUBB, CMPR, CMPI, BLE, BVC e os flip-flops das flags; Lab 7 acrescenta LW e SW.

Carry na subtração: vale 1 quando há "empresta-um" (Rd < Rs, sem sinal), como no exemplo do
*Características*, seção 4.4: "se R3 estiver com um valor menor do que 51 ... a flag de carry vai ser ativada".

## 5. Regras de VHDL seguidas (exigência do professor)

- Só construções que aparecem nos PDFs dos labs: `when-else`, `and/or/not`, `&`, recorte de bits, `+`, `-`,
  comparações, `component`/`port map`, `type ... is array` e `to_integer` (ROM/RAM).
- `process` e `if` **apenas** para registradores/flip-flops (o PC com `falling_edge`), ROM síncrona, RAM e a máquina de estados,
  exatamente como nos modelos dos PDFs (*µProcessador 3*, "Registrador Padrão", p. 2: "O if-then só deve ser usado nesta disciplina para criar um registrador!").
- Todo `when-else` termina com `else` para zero (*µProcessador 2*, seção "Multiplexação", p. 2: "Numa estrutura when-else sempre termine com else '0';").
- Extensão de sinal feita com `when-else` e concatenação, sem funções de biblioteca extras.
- Sem comentários no código; as explicações ficam em `docs/`.
