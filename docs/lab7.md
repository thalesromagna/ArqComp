# Lab 7 — Memória de Dados (RAM, LW e SW) + Validação (pendente)

Arquivos em `lab7/`. Base: PDF *µProcessador 7* ("Memória de Dados + Validação", arquivo
`uprocessador 7 v5.1.pdf`), documento *Características do Projeto do µP* e o lab 6 (`docs/lab6.md`), do qual
este lab é uma evolução. Convenção de citação igual à do `docs/lab5.md`.

O circuito segue os itens da unidade de controle sorteados no Email 3 (`docs/00-especificacoes.md`, seção 1):
instrução/ROM de **17 bits**, ROM **síncrona**, **PC sensível à borda de descida** e **sem registrador de
instrução**.

## 1. O que o lab pede

- "Implemente no circuito uma memória RAM e instruções para usá-la. As instruções deverão ser exatamente
  aquelas de leitura e escrita de memória no processador escolhido." (*µProcessador 7*, introdução, p. 1)
- "O endereço a ser lido ou escrito deve obrigatoriamente usar um registrador como ponteiro, para, por
  exemplo, poder fazer loops sobre vetores." (seção "Requisitos", p. 1), com a nota "Pode ser incluída uma
  constante de deslocamento, como no lw e sw do MIPS. Ou não, você é quem sabe" (nota 1, p. 1).
- "Note que a RAM deverá ter barramentos de dados e endereços explícitos. O barramento de controle pode ser
  apenas o clock e o write enable" (p. 1).
- "Um mux dá as caras nos dados a serem escritos no Banco de Registradores. Por fim, não esqueça de verificar
  os momentos de leitura da RAM e escrita no Banco; altere a máquina de estados se for necessário." (p. 1)
- Testes (seção "Testes", p. 1): "Faça várias escritas com dados variados em endereços espaçados, bem
  aleatório."; "Usar o valor do endereço para o dado (“número 3 no endereço 3”) pode dar “falso ok.”";
  "Evite testar com leitura subsequente à escrita"; "Evite usar os mesmos registradores: use todos, um pra
  cada coisa, com valores embaralhados."
- Entregar (seção "Arquivos a Entregar", p. 2): VHDL e testbenches; "Páginas do manual com as instruções de
  memória escolhidas em destaque"; "Especificação atualizada da codificação das instruções"; "Código assembly
  e codificação na ROM para o programa-teste pedido acima".
- Validação com o crivo de Eratóstenes (seção "Validação do µProcessador – Última Entrega", p. 2–3) — **não
  feita agora**, ver seção 8.

## 2. Arquivos

| Arquivo | Conteúdo / mudança |
|---|---|
| `ram.vhd` | **novo**: RAM 128 x 16 do PDF, escrita síncrona, leitura assíncrona |
| `un_controle.vhd` | instruções LW e SW; saída `ram_wr_en`; `sel_dado_banco="11"` para LW; entrada `instr` de 17 bits, opcode de 5 bits (`instr(16 downto 12)`), sem a saída `ir_wr_en` |
| `processador.vhd` | instância da RAM; entrada "11" (dado da RAM) no mux do banco; sem registrador de instrução: a saída `dado` da ROM vai direto para a UC e para a porta `instrucao` (17 bits) |
| `rom.vhd` | dado de 17 bits (`unsigned(16 downto 0)`); programa de teste da RAM |
| `pc.vhd` | registrador do lab 3 com `falling_edge(clk)` (PC na borda de descida) |
| `processador_tb.vhd` | tempo de simulação de 30 µs; `instrucao` de 17 bits |
| `programa.asm` | listagem do programa (binário de 17 bits e hexadecimal de 5 dígitos) |
| `processador_tb.gtkw` | mesma lista de sinais dos labs 5 e 6, com `instrucao[16:0]` |
| `run.sh` | inclui `ram.vhd`; `reg16bits.vhd` continua na lista porque o banco o usa |
| `reg16bits.vhd`, `reg1bit.vhd`, `maq_estados.vhd`, `banco.vhd`, `ula.vhd` | iguais ao lab 6 |

## 3. Instruções de memória escolhidas e codificação

```
MSB b16                       b0 LSB
LW Rd,(Rs)  01011 ddd sss xxxxxx     Rd <- RAM[Rs(6 downto 0)]
SW Rd,(Rs)  01100 ddd sss xxxxxx     RAM[Rs(6 downto 0)] <- Rd
```

- **Ponteiro em registrador, sem deslocamento.** O PDF permite as duas formas (nota 1). Escolhemos a forma
  sem constante porque é a do exemplo do próprio PDF, `lw $r1,($r3)` ("dado lido da RAM carregado no reg 1",
  p. 1), e porque o ponteiro em registrador já basta para os laços sobre vetores pedidos. Com a instrução de
  17 bits sobrariam 6 bits (b5..b0) depois do opcode e dos dois registradores; eles ficam sem uso (`x`). É
  escolha da equipe.
- **Endereço = 7 bits menos significativos de Rs**, porque a RAM tem 128 posições (`endereco : in
  unsigned(6 downto 0)` no modelo do PDF). Os bits 15..7 do ponteiro são ignorados.
- A RAM é de palavras de 16 bits: cada endereço guarda um dado inteiro (não há endereçamento por byte).
- Nenhuma das duas altera as flags ("quando houver branches, MOV, NOP, LW, SW, o valor dos flip-flops fica
  inalterado", *Características*, seção 4.4, p. 6).

### 3.1 Especificação atualizada da codificação (17 bits)

Instrução de 17 bits, igual à largura do dado da ROM ("O tamanho das instruções é sorteado para a equipe, e é
igual à largura de um dado da ROM.", *µProcessador 5*, "Implementação", p. 2; sorteio no Email 3). Opcode de
5 bits em b16..b12 e campos em b11..b0, como em `docs/00-especificacoes.md`, seção 4. Legenda: `ddd` destino
(ou primeiro operando), `sss` fonte (segundo operando), `ccccccccc` constante de 9 bits em complemento de 2,
`aaaaaaa` endereço absoluto, `eeeeeee` delta em complemento de 2, `x` irrelevante.

| Assembly | Binário (b16..b0) | Operação |
|---|---|---|
| `NOP` | `00000 000000000000` | nada |
| `LD Rd,cte` | `00001 ddd ccccccccc` | Rd ← cte (com extensão de sinal) |
| `MOV Rd,Rs` | `00010 ddd sss xxxxxx` | Rd ← Rs |
| `ADD Rd,Rs` | `00011 ddd sss xxxxxx` | Rd ← Rd + Rs |
| `SUB Rd,Rs` | `00100 ddd sss xxxxxx` | Rd ← Rd − Rs |
| `SUBB Rd,Rs` | `00101 ddd sss xxxxxx` | Rd ← Rd − Rs − C |
| `CMPR Rd,Rs` | `00110 ddd sss xxxxxx` | Rd − Rs (só flags) |
| `CMPI Rd,cte` | `00111 ddd ccccccccc` | Rd − cte (só flags) |
| `JMP end` | `01000 xxxxx aaaaaaa` | PC ← end |
| `BLE delta` | `01001 xxxxx eeeeeee` | se Z=1 ou N≠V: PC ← PC + delta |
| `BVC delta` | `01010 xxxxx eeeeeee` | se V=0: PC ← PC + delta |
| `LW Rd,(Rs)` | `01011 ddd sss xxxxxx` | Rd ← RAM[Rs] |
| `SW Rd,(Rs)` | `01100 ddd sss xxxxxx` | RAM[Rs] ← Rd |
| (01101 a 11111) | – | não usados, não fazem nada (PC avança) |

### 3.2 "Páginas do manual com as instruções de memória escolhidas em destaque"

As instruções são as de load/store do RISC-V, o processador estudado na disciplina ("O processador RISC-V que
estudamos é uma das poucas exceções que não utilizam flags", *µProcessador 2*, seção "Flags", p. 6; "Este
processador é apenas didático, uma simplificação da já bastante simples ISA RV32I do RISC-V",
`cap2-ciclo-unico.pdf`, seção 4 "O que Vamos Implementar Aqui?", p. 8, com `lw` e `sw` na lista da seção 4.1
"Instruções Implementadas", na mesma página), com o modo de endereçamento reduzido a "registrador como
ponteiro":

- P&H, **Figure 2.1, p. 70** (a figura fica na seção 2.2 *Operations of the Computer Hardware*), tabela
  "RISC-V assembly language", categoria "Data transfer":
  linha "Load word | `lw x5, 40(x6)` | `x5 = Memory[x6 + 40]` | Word from memory to register" e linha "Store
  word | `sw x5, 40(x6)` | `Memory[x6 + 40] = x5` | Word from register to memory". A mesma tabela mostra a
  sintaxe só com ponteiro na linha "Load reserved | `lr.d x5, (x6)` | `x5 = Memory[x6]`" (é uma instrução
  atômica, citada aqui só como exemplo da notação `(Rs)` que adotamos).
- P&H, seção 2.3, **p. 75**: "The data transfer instruction that copies data from memory to a register is
  traditionally called load. [...] The real RISC-V name for this instruction is lw, standing for load word."
- P&H, seção 2.3, **p. 76**: "The instruction complementary to load is traditionally called store; it copies
  data from a register to memory."
- P&H, seção 2.3, **p. 77**: "Load word and store word are the instructions that copy words between memory
  and registers in the RISC-V architecture."
- `riscv-card.pdf` (RISC-V Reference Card), p. 1, tabela "RV32I Base Integer Instructions": `lw  Load Word
  I 0000011 0x2  rd = M[rs1+imm][0:31]` e `sw  Store Word  S 0100011 0x2  M[rs1+imm][0:31] = rs2[0:31]`.

A nota 1 do *µProcessador 7* (p. 1) fala em "lw e sw do MIPS" só como exemplo de constante de deslocamento. O
livro chama o MIPS de "The instruction set most similar to RISC-V" e lista entre os pontos comuns aos dois "The
only way to access memory is via load and store instructions on both architectures." (P&H, seção 2.16 *Real
Stuff: MIPS Instructions*, p. 152).

Diferenças em relação ao RISC-V (escolha da equipe): sem o `imm` (equivale a `imm = 0`), palavra de 16 bits
em vez de 32, e no SW o registrador do dado vem no campo `ddd` (primeiro operando), para manter a ordem
`SW Rd,(Rs)` igual à do LW. Para imprimir e destacar: página 70 do livro (Figure 2.1, linhas lw/sw) e a
primeira página do `riscv-card.pdf` (linhas lw/sw).

## 4. Circuito

### 4.1 Organização (Email 3): ROM síncrona, sem registrador de instrução, PC na descida

- **ROM síncrona de 17 bits** (`rom.vhd`): o modelo do *µProcessador 4* com `process(clk)` e
  `rising_edge(clk)`, só com o dado alargado para `unsigned(16 downto 0)`. "Note que esta ROM é sincrona!
  Isto significa que é preciso dar um clock nela para que ela leia os dados, ou seja, só quando houver rampa
  de subida no clock é que teremos uma resposta à saída." (*µProcessador 4*, "ROM em VHDL", p. 1).
- **Sem registrador de instrução.** O *µProcessador 5* só pede o registrador "Caso o seu sorteio especifique
  um Registrador de Instrução" ("Implementação", p. 2), e o Email 3 sorteou "não usar". Por isso a saída
  `dado` da ROM vai direto para a entrada `instr` da unidade de controle, e a porta `instrucao` do
  processador mostra essa mesma saída, como prevê a lista de sinais do gtkwave: "instrução (saída do
  Registrador de Instrução, ou, se não houver, da ROM)" (*µProcessador 5*, "Testes", p. 2). A instrução fica
  estável durante decode e execute porque a ROM só muda numa subida e o PC só muda na descida do execute
  (ver 4.5).
- **PC na borda de descida** (`pc.vhd`): é o registrador do lab 3 com `falling_edge(clk)` no lugar de
  `rising_edge(clk)`, seguindo "Se algum item sorteado for sensível a rampa de descida, utilize
  falling_edge(clk) ao invés de rising_edge(clk)." (*µProcessador 5*, "Contadores em VHDL", p. 1). O
  `pc_wr_en` continua ligado só no estado 2 (execute). O livro admite as duas bordas na metodologia de
  clock: "An edge-triggered clocking methodology means that any values stored in a sequential logic element
  are updated only on a clock edge, which is a quick transition from low to high or vice versa" (P&H, seção
  4.2, p. 259); no resto do capítulo ele supõe tudo na subida ("All state elements in this chapter,
  including memory, are assumed positive edge-triggered", legenda da Figure 4.3, p. 259). Aqui só o PC
  foge disso, por causa do sorteio; ROM, banco, flags, RAM e máquina de estados continuam na subida.

### 4.2 RAM (`ram.vhd`)

Cópia do modelo do PDF ("A RAM completa em VHDL segue", seção "Detalhes de Implementação", p. 2):
`process(clk,wr_en)` com `if rising_edge(clk) then if wr_en='1' then conteudo_ram(to_integer(endereco)) <=
dado_in;` e `dado_out <= conteudo_ram(to_integer(endereco));` fora do processo. "Note que, desta forma, a
escrita é síncrona e a leitura é assíncrona" (p. 2). A única diferença para o PDF é a retirada das duas linhas
de comentário `------` (regra da equipe: nenhum comentário no código).

Ligações no top-level:

```
endereco_ram_s <= dado_r2_s(6 downto 0);          (Rs = ponteiro, lido na porta 2 do banco)
memoria_ram: ram port map(clk=>clk, endereco=>endereco_ram_s, wr_en=>ram_wr_en_s,
                          dado_in=>dado_r1_s, dado_out=>ram_dado_s);   (dado a escrever = Rd, porta 1)
```

Como o banco sempre lê `reg_r1 = ddd` e `reg_r2 = sss`, nenhum campo novo foi preciso: no SW, `data_r1` é o
dado (Rd) e `data_r2` é o ponteiro (Rs); no LW, `data_r2` é o ponteiro e `reg_wr = ddd` é o destino.

Base: os slides mostram a ligação equivalente: "O dado escrito por uma instrução sw deve vir de um registrador lido
do banco [...] Portanto, este dado estará disponível na saída inferior do banco de registradores [...] e irá
até os pinos de dados a escrever na RAM." e "Já o dado lido por uma instrução lw vai ser colocado na saída da
RAM que está ligada na entrada de um mux [...] Este mux irá selecionar qual dos dados será repassado ao banco
de registradores para ser escrito" (`cap2-ciclo-unico.pdf`, seção 7.3 "RAM", p. 17). No RISC-V o endereço é
calculado pela ULA (ponteiro + constante, p. 17); como não temos constante, o ponteiro vai direto do banco
para a RAM e a ULA não participa. Diferença em relação aos slides (escolha da equipe): lá o dado do sw sai da
porta inferior do banco (`data r2`, campo rs2); aqui o dado do SW sai de `data_r1` (campo `ddd`) e o ponteiro
de `data_r2` (campo `sss`), para o SW usar os mesmos campos que o LW.

### 4.3 Mux de dados do banco

```
dado_banco_s <= ula_out_s       when sel_dado_banco_s="00" else
                cte_estendida_s when sel_dado_banco_s="01" else
                dado_r2_s       when sel_dado_banco_s="10" else
                ram_dado_s      when sel_dado_banco_s="11" else
                "0000000000000000";
```

É o MemtoReg do livro: "MemtoReg should be set to cause the data from memory to be sent to the register file."
(P&H, seção 4.3, *Check Yourself*, p. 268, alternativa I.a, que é a correta segundo as respostas do livro:
"§4.3, page 268: I. a.", seção 4.19, p. 385) e "two 1-bit signals that are used to control multiplexors (ALUSrc
and MemtoReg)" (Figure 4.21, p. 277). Nos slides: o seletor "deve escolher a entrada 0, vinda da RAM, apenas
quando a instrução for lw" (`cap2-ciclo-unico.pdf`, p. 18). O nosso mux tem 4 entradas porque também passam por
ele a constante do LD e o registrador do MOV.

### 4.4 Controle (estado 2)

| Instrução | banco_wr_en | ram_wr_en | flags_wr_en | sel_dado_banco | pc_prox |
|---|---|---|---|---|---|
| LW | 1 | 0 | 0 | 11 (RAM) | PC+1 |
| SW | 0 | 1 | 0 | – | PC+1 |
| demais | como no lab 6 | 0 | como no lab 6 | como no lab 6 | como no lab 6 |

```
opcode <= instr(16 downto 12);
eh_lw   <= '1' when opcode="01011" else '0';
eh_sw   <= '1' when opcode="01100" else '0';
ram_wr_en <= '1' when estado="10" and eh_sw='1' else
             '0';
```

Base: "a memória de dados RAM: ela deve ser habilitada para escrita no write enable ou wr en [...] Da mesma
forma, apenas a instrução lw vai fazer a leitura da RAM" (`cap2-ciclo-unico.pdf`, seção 5.3, p. 11). Nossa RAM
não tem read enable (o modelo do PDF só tem `wr_en`), então ela está sempre "lendo" o endereço `data_r2`; o
dado só é usado quando `sel_dado_banco="11"` e `banco_wr_en=1`, isto é, no LW.

### 4.5 Momentos de leitura e escrita (a máquina de estados não mudou)

O PDF pede: "não esqueça de verificar os momentos de leitura da RAM e escrita no Banco; altere a máquina de
estados se for necessário" (p. 1), e nas dicas da validação: "Verifique, em especial, os momentos de gravação
de dados: veja as ondas dos enables de escrita e o dado na entrada no momento da rampa de gravação." (p. 3).
Linha do tempo de uma instrução (clock de 100 ns, subidas em 50, 150, 250... ns e descidas em 100, 200,
300... ns):

| Momento | O que acontece |
|---|---|
| subida que encerra o execute anterior (início do estado 0) | a ROM registra `ROM[PC]`, com o PC já atualizado na descida anterior: a instrução aparece na saída da ROM |
| subida que encerra o estado 0 | a ROM registra de novo `ROM[PC]` (mesmo valor) |
| estados 1 e 2 | a UC decodifica a saída da ROM; banco e RAM leem (assíncrono) os registradores e o endereço da instrução |
| **descida do meio do estado 2** | o PC recebe `pc_prox` (próximo endereço ou destino do salto) |
| **subida que encerra o estado 2** | banco, flags e RAM gravam; a ROM lê a próxima instrução |

- **LW:** desde o início da instrução, `endereco_ram_s = Rs(6 downto 0)` e `ram_dado_s = RAM[Rs]` (leitura
  assíncrona: "a leitura reflete instantaneamente na saída de dados qualquer alteração na entrada de
  endereços", nota 3, p. 2); o banco grava esse valor na subida que encerra o estado 2.
- **SW:** a RAM grava `Rd` em `RAM[Rs]` na subida que encerra o estado 2 ("A escrita sempre ocorre numa rampa
  de subida do clock", nota 3, p. 2), com `ram_wr_en` em 1 só no estado 2.

**Por que o SW grava o valor certo mesmo com o PC já trocado.** O PC muda na descida do meio do estado 2, meio
ciclo antes da subida em que a RAM grava. Isso não atrapalha porque nem o endereço nem o dado da RAM dependem
do PC: eles vêm do banco (`data_r2` = Rs e `data_r1` = Rd), e os números dos registradores vêm da saída da
ROM, que só muda numa subida. Entre a descida e a subida a ROM ainda segura a instrução SW (o novo PC só será
lido pela ROM na própria subida da gravação), então `ram_wr_en`, `endereco_ram_s` e `dado_r1_s` ficam
estáveis até a borda, como pede o livro: "Any inputs to a state element must reach a stable value (that is,
have reached a value from which they will not change until after the clock edge) before the active clock edge
causes the state to be updated." (P&H, legenda da Figure 4.3, p. 259). Na borda, a RAM, o banco e as flags
amostram os valores da instrução atual e só depois a saída da ROM troca para a próxima instrução.

Forma de onda medida do `SW R2,(R1)` (endereço 2). `^` = subida, `v` = descida; `RAM[45]` é
`conteudo_ram(45)`, observado numa cópia de depuração da RAM com um sinal de monitoramento (fora do
repositório):

```
t (ns)        650  700   750   800   850   900   950  1000  1050  1100  1150
              ^     v     ^     v     ^     v     ^     v     ^     v     ^
clk           |‾‾‾‾‾|_____|‾‾‾‾‾|_____|‾‾‾‾‾|_____|‾‾‾‾‾|_____|‾‾‾‾‾|_____|
estado              2     | 0 (fetch) |1 (decode) | 2 (exec)  |     0
pc_wr_en       ‾‾‾‾‾1‾‾‾‾‾|           0           |‾‾‾‾‾1‾‾‾‾‾|     0
PC               1  |                 2                 |        3
instrucao         01585   |        0C440 = SW R2,(R1)         |   01675
ram_wr_en                       0                 |‾‾‾‾‾1‾‾‾‾‾|     0
endereco_ram        0     |                   45 (= R1)
dado_in             0     |            -123 (= R2)            |     0
RAM[45]                               U                       |   -123
```

O PC passa de 2 para 3 em 1000 ns (descida), mas a instrução continua `0x0C440` até 1050 ns; a RAM grava −123
em 45 na subida de 1050 ns, a mesma em que a ROM passa a mostrar `0x01675` (`LD R3,117`). Depois dessa subida o
`endereco_ram` continua 45: no `LD R3,117` os bits b8..b6 da constante (`001`) ainda selecionam R1 na porta 2 do
banco, e com `ram_wr_en = 0` a RAM não grava nada.

Efeito colateral inofensivo: depois da descida, `pc_prox` é recalculado com o PC novo (no `BLE -4` do endereço
35, por exemplo, `pc_prox` vale 31 até 10900 ns e 27 de 10900 a 10950 ns). Esse valor nunca é gravado, porque
a próxima descida (11000 ns) já cai no estado 0, com `pc_wr_en = 0`.

Não há conflito: cada instrução faz no máximo uma escrita em banco/RAM e todas acontecem na mesma borda, como no
multiciclo do livro ("At the end of a clock cycle, all data that is used in subsequent clock cycles must be
stored in a state element", P&H, seção 4.5, p. 282.e1). Portanto **mantivemos os 3 estados** (o lab 5 diz que
"a RAM pode ficar mais clara com 4 estados", nota 3, p. 2, mas não foi necessário).

## 5. Programa de teste (`lab7/programa.asm`)

| End. | Assembly | Hexa (17 bits) | Efeito esperado |
|---|---|---|---|
| 0 | `LD R1,45` | 0122D | R1 = 45 (ponteiro) |
| 1 | `LD R2,-123` | 01585 | R2 = −123 (0xFF85) |
| 2 | `SW R2,(R1)` | 0C440 | RAM[45] ← −123 |
| 3 | `LD R3,117` | 01675 | R3 = 117 (ponteiro) |
| 4 | `LD R4,200` | 018C8 | R4 = 200 |
| 5 | `SW R4,(R3)` | 0C8C0 | RAM[117] ← 200 |
| 6 | `LD R5,6` | 01A06 | R5 = 6 (ponteiro) |
| 7 | `LD R6,-1` | 01DFF | R6 = −1 (0xFFFF) |
| 8 | `SW R6,(R5)` | 0CD40 | RAM[6] ← 0xFFFF |
| 9 | `LD R7,90` | 01E5A | R7 = 90 (ponteiro) |
| 10 | `LD R0,77` | 0104D | R0 = 77 |
| 11 | `SW R0,(R7)` | 0C1C0 | RAM[90] ← 77 |
| 12 | `SUB R6,R4` | 04D00 | R6 = −1 − 200 = −201 (dado calculado) |
| 13 | `ADD R1,R5` | 03340 | R1 = 45 + 6 = 51 (ponteiro calculado) |
| 14 | `SW R6,(R1)` | 0CC40 | RAM[51] ← −201 |
| 15 | `LD R0,33` | 01021 | R0 = 33 |
| 16 | `SW R0,(R5)` | 0C140 | RAM[6] ← 33 (sobrescreve 0xFFFF) |
| 17–20 | `LD R2,0`; `LD R4,0`; `LD R6,0`; `LD R0,0` | 01400, 01800, 01C00, 01000 | apaga os registradores que tinham os dados |
| 21 | `LW R4,(R7)` | 0B9C0 | R4 ← RAM[90] = 77 |
| 22 | `LW R6,(R3)` | 0BCC0 | R6 ← RAM[117] = 200 |
| 23 | `LW R2,(R5)` | 0B540 | R2 ← RAM[6] = 33 |
| 24 | `LW R0,(R1)` | 0B040 | R0 ← RAM[51] = −201 |
| 25 | `LD R1,45` | 0122D | R1 = 45 |
| 26 | `LW R7,(R1)` | 0BE40 | R7 ← RAM[45] = −123 |
| 27–30 | `LD R1,1`; `LD R3,100`; `LD R5,250`; `LD R6,-13` | 01201, 01664, 01AFA, 01DF3 | incremento, ponteiro do vetor, 1º dado, passo |
| 31 | `SW R5,(R3)` | 0CAC0 | laço 1: RAM[R3] ← R5 |
| 32 | `ADD R5,R6` | 03B80 | R5 ← R5 − 13 |
| 33 | `ADD R3,R1` | 03640 | R3 ← R3 + 1 |
| 34 | `CMPI R3,104` | 07668 | |
| 35 | `BLE -4` | 0907C | volta para 31 enquanto R3 ≤ 104 |
| 36–37 | `LD R3,100`; `LD R4,0` | 01664, 01800 | ponteiro e soma |
| 38 | `LW R2,(R3)` | 0B4C0 | laço 2: R2 ← RAM[R3] |
| 39 | `ADD R4,R2` | 03880 | R4 ← R4 + R2 |
| 40 | `ADD R3,R1` | 03640 | R3 ← R3 + 1 |
| 41 | `CMPI R3,104` | 07668 | |
| 42 | `BLE -4` | 0907C | volta para 38 enquanto R3 ≤ 104 |
| 43 | `JMP 43` | 0802B | fim (R4 = 250+237+224+211+198 = 1120) |

A listagem com o binário de 17 bits separado por campos está em `lab7/programa.asm`. Como o bit b16 de todos
os opcodes usados é 0, o hexadecimal de 5 dígitos sempre começa com 0.

Como o programa atende aos pedidos do PDF:

- Endereços espaçados e "aleatórios": 45, 117, 6, 90, 51 e o vetor 100..104.
- Nenhum dado é igual ao endereço (−123 em 45, 200 em 117, 33 em 6, 77 em 90, −201 em 51, 250..198 em 100..104).
- Nenhuma leitura logo após a escrita correspondente: todas as escritas da primeira parte acontecem antes, os
  registradores dos dados são zerados (end. 17–20), e as leituras são feitas em outra ordem e em
  **registradores diferentes** dos usados na escrita (ex.: 77 foi escrito de R0 e lido em R4; 200 foi escrito de
  R4 e lido em R6).
- Os 8 registradores são usados (R0..R7), como ponteiro, dado ou ambos.
- Há sobrescrita (RAM[6]: 0xFFFF e depois 33; o LW lê 33), dado calculado pela ULA (−201) e ponteiro calculado
  pela ULA (51).
- Laços sobre um vetor com ponteiro incrementado (a motivação do "registrador como ponteiro"), um escrevendo e
  outro lendo, usando CMPI + BLE do lab 6.

Observação: a RAM do PDF não tem reset nem valor inicial, então na simulação as posições nunca escritas valem
`U`. O programa só faz LW de posições já escritas.

## 6. Resultados da simulação

GHDL 4.1, `processador_tb` com 30 µs; VCD conferido por script Python da equipe (fora do repositório). Tempos
de gravação = borda de subida em que o registrador ou a RAM foi gravado; tempos do PC = borda de descida.

Tempos gerais medidos:

- Reset até 200 ns. A saída da ROM mostra `ROM[0] = 0x0122D` desde a primeira subida (50 ns).
- Instrução do endereço `a` (sem desvios antes): aparece na saída da ROM em 150 + 300·a ns (a ≥ 1), estado 2
  a partir de 350 + 300·a, **PC muda na descida de 400 + 300·a** e banco/flags/RAM gravam na subida de
  450 + 300·a. Ex.: endereço 0: PC 0→1 em 400 ns, R1 = 45 em 450 ns.
- Todas as 83 mudanças de valor do PC aconteceram em bordas de descida, sempre no estado 2; a saída da ROM só
  mudou em bordas de subida.

Escritas na RAM (todas com `ram_wr_en = 1` só no estado 2; endereço e dado conferidos contra Rs e Rd lidos do
banco antes da borda, sem nenhuma mudança deles durante o estado 2):

| PC | Instrução | PC muda (descida, ns) | RAM grava (subida, ns) | Gravação |
|---|---|---|---|---|
| 2 | `SW R2,(R1)` | 1000 (2→3) | 1050 | RAM[45] ← −123 |
| 5 | `SW R4,(R3)` | 1900 (5→6) | 1950 | RAM[117] ← 200 |
| 8 | `SW R6,(R5)` | 2800 (8→9) | 2850 | RAM[6] ← −1 (0xFFFF) |
| 11 | `SW R0,(R7)` | 3700 (11→12) | 3750 | RAM[90] ← 77 |
| 14 | `SW R6,(R1)` | 4600 (14→15) | 4650 | RAM[51] ← −201 |
| 16 | `SW R0,(R5)` | 5200 (16→17) | 5250 | RAM[6] ← 33 (antes −1) |
| 31 | `SW R5,(R3)` (laço 1) | 9700, 11200, 12700, 14200, 15700 | 9750, 11250, 12750, 14250, 15750 | RAM[100..104] ← 250, 237, 224, 211, 198 |

Na cópia de depuração, `conteudo_ram` de cada um desses endereços mudou exatamente na subida indicada, para o
valor da tabela.

Leituras da primeira parte (valores com sinal):

| PC muda (descida, ns) | Banco grava (subida, ns) | PC | Instrução | Valor lido | Esperado |
|---|---|---|---|---|---|
| 6700 | 6750 | 21 | `LW R4,(R7)` (R7 = 90) | R4 = 77 | 77 |
| 7000 | 7050 | 22 | `LW R6,(R3)` (R3 = 117) | R6 = 200 | 200 |
| 7300 | 7350 | 23 | `LW R2,(R5)` (R5 = 6) | R2 = 33 | 33 (sobrescrito) |
| 7600 | 7650 | 24 | `LW R0,(R1)` (R1 = 51) | R0 = −201 | −201 |
| 8200 | 8250 | 26 | `LW R7,(R1)` (R1 = 45) | R7 = −123 | −123 |

Antes das leituras (6450 ns) os registradores eram R0=0, R1=51, R2=0, R3=117, R4=0, R5=6, R6=0, R7=90, ou seja,
os valores vieram mesmo da RAM. No `LW R4,(R7)`, por exemplo, `endereco_ram_s = 90` e `ram_dado_s = 77` desde
6450 ns (quando a instrução aparece na saída da ROM) até a gravação em 6750 ns.

Laço 1 (escrita do vetor): R5 passou por 250, 237, 224, 211, 198 nos SW dos endereços 100..104 (subidas 9750 a
15750 ns); o BLE foi tomado 4 vezes (PC 35→31 nas descidas de 10900, 12400, 13900 e 15400 ns) e não tomado na
5ª, com R3 = 105 (PC 35→36 em 16900 ns). Laço 2 (leitura): R2 recebeu 250 (17850 ns), 237 (19350), 224 (20850),
211 (22350), 198 (23850); R4 acumulou 250, 487, 711, 922, **1120** (24150 ns); BLE tomado em 19000, 20500,
22000 e 23500 ns (PC 42→38) e não tomado em 25000 ns (PC 42→43).

Estado final: a última gravação de registrador é R3 = 105 em 24450 ns; o PC vale 43 desde 25000 ns e o
`JMP 43` (`0x0802B`) está na saída da ROM desde 25050 ns. Valores: R0 = −201, R1 = 1, R2 = 198, R3 = 105,
**R4 = 1120**, R5 = 185, R6 = −13, R7 = −123. Todos os endereços de 0 a 43 foram executados na ordem
esperada; os LD/LW/SW não alteraram as flags (ex.: ZNCV = 0000 do início até o primeiro SUB em 4050 ns).

## 7. Como rodar

```
cd lab7
./run.sh
```

Mesma lista de sinais dos labs 5 e 6 (`processador_tb.gtkw`), com `instrucao[16:0]` (saída da ROM). Para
depurar a RAM, adicione no gtkwave os sinais internos `top.processador_tb.uut.ram_wr_en_s`, `endereco_ram_s`,
`ram_dado_s`, `dado_banco_s` e `pc_wr_en_s`.

## 8. Pendências (NÃO implementadas neste momento)

O sorteio dos itens da validação ainda não chegou (`docs/00-especificacoes.md`, seção 2). Ficam pendentes:

1. **Programa de validação — crivo de Eratóstenes** (*µProcessador 7*, seção "Validação do µProcessador –
   Última Entrega", p. 2–3): colocar na RAM os números até no mínimo 32 ("coloque o número 1 no endereço 1, o 2
   no 2, o 3 no 3"), eliminar os múltiplos de 2, 3 e 5 (e, "se der", os demais), ler a RAM do endereço 2 ao 32 e
   mostrar os primos num pino ou na saída da ULA.
2. **Final do loop** (*Características*, seção 6.2, p. 9–10): item sorteado entre SHIFT RIGHT, AND, OR, SHIFT
   LEFT com carry, DEC, INC, JB, JNB, CTZ, CLZ, DJNZ e CJNE. Pode exigir uma instrução nova na ULA/UC.
3. **Complicação** (*Características*, seção 6.3, p. 10–11): item sorteado (exceção de opcode inválido, HALT,
   primos < 1024, exceções de endereço de ROM/RAM, tabela começando em `cte`, etc.).

"A equipe deve escolher um destes dois para implementar, obrigatoriamente, podendo ignorar o outro"
(*Características*, seção 6, p. 8). O lab 7 atual já tem o que o crivo precisa de base: RAM com ponteiro em
registrador, laços com CMPI/BLE e JMP. Com o opcode de 5 bits sobram 19 opcodes livres (01101 a 11111) para a
instrução que o "final do loop" exigir.
