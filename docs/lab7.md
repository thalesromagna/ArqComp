# Lab 7: Memória de Dados (RAM, LW e SW) + Validação (crivo com INC e HALT)

Equipe: Thales e Sergio. Disciplina: Arquitetura de Computadores (UTFPR, prof. Juliano).

Base deste documento:

- roteiro *µProcessador 7* ("Memória de Dados + Validação", arquivo `uprocessador 7 v5.1.pdf`, 3 páginas);
- documento do sorteio *Características do Projeto do µP* (arquivo `6996-EncargosdeIRRF-082026.pdf`, que vem
  junto com os PDFs dos labs; 12 páginas; aqui chamado de *Características*);
- email do professor de 13/11/2026 com os itens sorteados para a validação;
- código do Thales em `micro_processador/` (codificação em `micro_processador/outros/codificação.txt`).

Convenção de citação: trecho literal entre aspas, seguido de documento, seção e página. Nos PDFs de 3 e 12
páginas a página impressa coincide com a página do PDF. No livro de Patterson & Hennessy (P&H), *Computer
Organization and Design, RISC-V Edition*, a página do PDF é a página impressa + 36 (ex.: p. 70 impressa =
página 106 do PDF). O que não foi possível conferir na fonte está marcado com `[VALIDAR]`.

Itens sorteados da equipe que este lab precisa respeitar: ULA ortogonal com 8 registradores (r0 a r7, todos
comuns), instrução de 17 bits, ROM síncrona, PC sensível à borda de descida, sem registrador de instrução,
JMP absoluto, desvios condicionais relativos BLE e BVC.

## 1. O que o lab pede

### 1.1 RAM e instruções de memória (roteiro, p. 1 e 2)

- "Implemente no circuito uma memória RAM e instruções para usá-la. As instruções deverão ser exatamente
  aquelas de leitura e escrita de memória no processador escolhido." (*µProcessador 7*, introdução, p. 1)
- "O endereço a ser lido ou escrito deve obrigatoriamente usar um registrador como ponteiro, para, por
  exemplo, poder fazer loops sobre vetores." (seção "Requisitos", p. 1), com a nota de rodapé "Pode ser
  incluída uma constante de deslocamento, como no lw e sw do MIPS. Ou não, você é quem sabe" (nota 1, p. 1).
- Exemplo do roteiro, sem constante: `lw $r1,($r3)` com o comentário "dado lido da RAM carregado no reg 1"
  (seção "Requisitos", p. 1).
- "Note que a RAM deverá ter barramentos de dados e endereços explícitos. O barramento de controle pode ser
  apenas o clock e o write enable que já está bom." (p. 1)
- "Um mux dá as caras nos dados a serem escritos no Banco de Registradores. Por fim, não esqueça de verificar
  os momentos de leitura da RAM e escrita no Banco; altere a máquina de estados se for necessário." (p. 1)
- Testes (seção "Testes", p. 1): "Faça várias escritas com dados variados em endereços espaçados, bem
  aleatório."; "Usar o valor do endereço para o dado (“número 3 no endereço 3”) pode dar “falso ok.”";
  "Evite testar com leitura subsequente à escrita: o valor pode estar sobrando ainda em algum barramento ou
  registrador temporário."; "Evite usar os mesmos registradores: use todos, um pra cada coisa, com valores
  embaralhados."; "Fazer uma só escrita e leitura subsequente é coisa de novato não promissor, sabe?"
- RAM: "A RAM completa em VHDL segue:" (seção "Detalhes de Implementação", p. 2) e "Note que, desta forma, a
  escrita é síncrona e a leitura é assíncrona" (p. 2).

### 1.2 Validação (roteiro, p. 2 e 3)

- "Implemente um programa que cospe os números primos em algum pino do top-level." (seção "Validação do
  µProcessador – Última Entrega", p. 2)
- Passos do crivo: "Coloque na memória RAM, com um loop em assembly, os números de interesse:" "no mínimo até
  o 32;" "coloque o número 1 no endereço 1, o 2 no 2, o 3 no 3... (facilita)." (item 1, p. 2); "Elimine da
  lista, com um loop, todos os múltiplos de 2." (item 2, p. 2); "Idem para 3 e 5." (item 3, p. 2); "Seria
  decente seguir o algoritmo completo (“tente” eliminar todos os não primos, como os múltiplos de 7, 11 e
  etc.), então faça isso se der." (item 4, p. 3); "Faça um loop para ler a RAM do endereço 2 ao 32." (item 5,
  p. 3); "Ponha um pino extra para visualizar as coisas ou simplesmente jogue o dado lido da RAM na saída da
  ULA, para que possamos acompanhar o resultado." (item 6, p. 3)
- Dica de conferência: "Faça a listagem de assembly/opcodes no formato mais fácil possível para conferência."
  (seção "Dicas", p. 3)

### 1.3 Itens sorteados para a validação (email de 13/11/2026)

Texto do email: "Seguem as características sorteadas para a VALIDAÇÃO do processador da sua equipe. Vocês
deverão implementar dois dos três itens sorteados abaixo, à sua escolha." Itens: "Contador com INC", "Tabela
do crivo começa no endereço 48 da RAM" e "Instrução Halt ao final". E ainda: "ADICIONALMENTE, vou querer um
outro programa assembly que testa todas as instruções sorteadas para a equipe durante o semestre -- pode ser
apenas uma lista de instruções para verificarmos a execução correta."

**A equipe implementou dois itens: "Contador com INC" e "Instrução Halt ao final".** O item da tabela no
endereço 48 não foi implementado: a tabela do crivo começa no endereço 0, com o número n no endereço n, como o
próprio roteiro sugere ("coloque o número 1 no endereço 1, o 2 no 2, o 3 no 3... (facilita).", item 1, p. 2).
As definições dos dois itens estão no documento do sorteio:

- "Contador com INC: no loop, incrementa-se a variável de controle (um registrador) com uma instrução INC Rn e
  o final do loop deve ser verificado com este registrador Rn;" (*Características*, seção 6.2 "Final do
  Loop", p. 9)
- "Instrução Halt ao final: todo programa deverá terminar com uma instrução HALT; quando ela for executada, o
  microprocessador deverá paralisar a execução e indicar isso levantando para 1 o sinal em um pino de saída
  chamado ‘halted’, no top level;" (*Características*, seção 6.3 "Complicação", p. 10)

Regra geral que continua valendo: "O processador não deverá executar opcodes fora do que foi explicitamente
pedido (a não ser que os alunos peçam autorização ao professor)." (*Características*, seção 1
"Obrigatório", p. 2), e logo em seguida "Isto significa que não pode existir um código binário que faça uma
instrução “extra” executar." (mesma seção, p. 2). Por isso o opcode livre `1110` age como NOP (ver seção 4).
`[VALIDAR]` confirmar com o professor que o opcode `1110` sem uso agir como NOP não conta como "instrução
extra".

## 2. Arquivos alterados e novos

Todos relativos a `micro_processador/`.

| Arquivo | Situação | Conteúdo / mudança |
|---|---|---|
| `ram.vhd` | novo | RAM 128 x 16 exatamente como o modelo do roteiro (entity `ram`: `clk`, `endereco unsigned(6 downto 0)`, `wr_en`, `dado_in`, `dado_out`); escrita síncrona na subida, leitura assíncrona. Único componente novo do processador (os outros VHDL novos são o `ram_tb.vhd` e as ROMs alternativas `programas/rom_*.vhd`) |
| `ram_tb.vhd` | novo | testbench da RAM: grava e lê 13 endereços (0, 127, as potências de 2 de 1 a 64, 126, 63, 95 e 45) com dados diferentes do endereço; confere leitura assíncrona (sem borda de clock durante a leitura), que `wr_en`='0' não grava, que a escrita só ocorre na borda de subida e a sobrescrita sem afetar os outros endereços |
| `uc/uc.vhd` | alterado | decodifica LW (`1010`), SW (`1011`), INC (`1100`) e HALT (`1101`); novas saídas `ram_wr_en` e `halt`; `pc_wr_en` = estado e não halt |
| `uc/uc_tb.vhd` | alterado | novos casos com asserts para LW, SW, INC (com lixo nos bits baixos: a constante tem que sair 1), HALT e o opcode `1110` (NOP), conferindo `ram_wr_en`, `halt`, `sel_data_wr`, escrita no banco e nas flags e que nenhuma instrução nova gera desvio |
| `banco_ula/banco_ula.vhd` | alterado | nova entrada `ram_data` (entrada `"11"` do mux `data_wr`) e nova saída `data_r7` |
| `banco_ula/banco_ula_tb.vhd` | alterado | asserts para gravação vinda de `ram_data` com `sel_data_wr`="11" (caso do LW), para `wr_en`='0' não gravar e para `data_r7` (muda só quando r7 é escrito) |
| `banco_ula/banco/banco.vhd` | alterado | nova saída `data_r7` <= reg7 |
| `banco_ula/banco/banco_tb.vhd` | alterado | só ligação da nova porta `data_r7` no componente (sem casos novos) |
| `processador.vhd` | alterado | instância da RAM (`endereco` = `data_r2(6 downto 0)`, `dado_in` = `data_r1`, `wr_en` = `ram_wr_en`, `dado_out` → `ram_data`); novas portas `r7_out` e `halted` |
| `processador_tb.vhd` | alterado | clock de 100 ns; reset nos 2 primeiros períodos; imprime `R7 <valor>` a cada mudança de `r7_out`, `HALTED` quando `halted`='1' (e encerra) ou `TIMEOUT` se não houver HALT até 2 ms |
| `run.sh` | novo | compila e simula com ghdl; compara a sequência de r7 com o `.esperado` (ver seção 8) |
| `processador_tb.gtkw` | novo | lista de sinais salva para o gtkwave |
| `rom.vhd` | alterado | conteúdo trocado pelo programa do crivo (validação); entity `rom` igual |
| `programas/` | novo | `crivo`, `teste_ram` e `instrucoes`: `.asm` (fonte), `.lst` (listagem para conferência), `.esperado` (sequência de r7); `rom_teste_ram.vhd` e `rom_instrucoes.vhd` com a mesma entity `rom` |
| `programas/montador.py` | novo | montador e simulador de ISA (conjunto de instruções) em Python: gera `.lst`, ROM VHDL e `.esperado` a partir do `.asm` e executa um `.asm` ou ROM `.vhd` até o HALT, com relatório de cobertura opcional (ver seção 8) |
| `programas/desmontador.py` | novo | desmonta uma ROM `.vhd` e compara palavra a palavra com o `.asm` (ida e volta) |
| `programas/test_montador.py` | novo | testes unitários (`unittest`) do montador e do simulador |
| `outros/codificação.txt` | alterado | codificação com LW, SW, INC, HALT e a lista de quem altera flags |

Interface final do top-level:

```vhdl
entity processador is
    port( clk       : in  std_logic;
          rst       : in  std_logic;
          estado    : out std_logic;
          pc        : out unsigned(6 downto 0);
          instrucao : out unsigned(16 downto 0);
          ula_out   : out unsigned(15 downto 0);
          r7_out    : out unsigned(15 downto 0);
          halted    : out std_logic
    );
end entity;
```

Ordem de compilação (a mesma da síntese): `reg1bit.vhd`, `banco_ula/banco/reg16bits.vhd`,
`banco_ula/banco/banco.vhd`, `banco_ula/ula/ula.vhd`, `banco_ula/banco_ula.vhd`, `proto_uc/pc.vhd`,
`proto_uc/somador.vhd`, `proto_uc/proto_uc.vhd`, `sm.vhd`, `ram.vhd`, `rom.vhd`, `uc/uc.vhd`, `processador.vhd`.

## 3. Instruções de memória escolhidas

```
            b16..b13 b12..b10 b9..b7 b6..b0
LW Rd,(Rs)    1010     ddd     sss   xxxxxxx     Rd <- RAM[Rs(6..0)]
SW Rd,(Rs)    1011     ddd     sss   xxxxxxx     RAM[Rs(6..0)] <- Rd
```

- **Ponteiro em registrador, sem constante de deslocamento.** O roteiro aceita as duas formas ("Ou não, você
  é quem sabe", nota 1, p. 1). Escolhemos a forma sem constante porque é a do exemplo do próprio roteiro
  (`lw $r1,($r3)`, p. 1), porque o ponteiro em registrador já resolve os laços sobre vetores e porque o
  endereço vai direto do banco para a RAM, sem passar pela ULA (menos lógica e menos sinais de controle). É
  escolha da equipe; os bits b6..b0 ficam sem uso (`x`).
- **Campos fixos.** O ponteiro é sempre o campo `sss` (lido na porta `data_r2` do banco) e o dado/destino é
  sempre o campo `ddd` (porta `data_r1` no SW; registrador de escrita no LW). Como a UC do Thales já liga
  `reg_r1` = `reg_wr` = b12..b10 e `reg_r2` = b9..b7, nenhum campo novo foi necessário. No SW o registrador do
  dado vem no primeiro operando para manter a ordem `SW Rd,(Rs)` igual à do LW.
- **Endereço = 7 bits menos significativos do ponteiro**, porque a RAM do roteiro tem 128 posições (`endereco
  : in unsigned(6 downto 0)`, p. 2). Os bits 15..7 do ponteiro são ignorados. Cada endereço guarda uma palavra
  de 16 bits (não há endereçamento por byte).
- **Não alteram flags**, como manda o sorteio: "quando houver ADD, SUB,CMP ou similares, o valor indicado pela
  ULA será guardado, mas quando houver branches, MOV, NOP, LW, SW, o valor dos flip-flops fica inalterado."
  (*Características*, seção 4.4 "Flags", p. 6).

### 3.1 Páginas do manual (`docs/manual_lw_sw.pdf`)

As instruções são as de load/store do RISC-V, a ISA do livro da disciplina (P&H, RISC-V Edition), reduzidas
ao modo "registrador como ponteiro". `[VALIDAR]` com o professor se o "processador escolhido" do roteiro é
mesmo o RISC-V do livro: o sorteio diz que os desvios condicionais seguem "o padrão das instruções dos
processadores ARM, que trabalham com flags, ao invés do padrão do RISC-V" (*Características*, seção 5.2, p. 7)
e que "Tanto os opcodes quanto a estrutura interna dos campos de bits são livres para escolha de vocês."
(seção 1, p. 2).

A nota 1 do roteiro fala em "lw e sw do MIPS" (p. 1), e o manual destacado é o do RISC-V. Isso não muda nada:
`lw` e `sw` têm o mesmo significado nas duas ISAs (carregar uma palavra da memória no endereço base +
deslocamento para um registrador e gravar um registrador nesse endereço), com a mesma sintaxe `lw rd,
desl(rs)`. Por isso as páginas abaixo valem para as duas leituras do roteiro.

O arquivo `docs/manual_lw_sw.pdf` tem 5 páginas, com os trechos de LW/SW destacados em amarelo (anotações de
realce feitas com PyMuPDF):

| Pág. do arquivo | Origem | Página impressa | Página do PDF de origem | Trecho destacado |
|---|---|---|---|---|
| 1 | P&H, seção 2.2, Figure 2.1 | 70 | 106 | linhas "Load word" e "Store word" da tabela "RISC-V assembly language" |
| 2 | P&H, seção 2.3 | 75 | 111 | definição de load / `lw` |
| 3 | P&H, seção 2.3 | 76 | 112 | definição de store / `sw` |
| 4 | P&H, seção 2.3 | 77 | 113 | "Load word and store word are..." |
| 5 | RISC-V Reference Card | 1 | 1 | linhas `lw` e `sw` da tabela "RV32I Base Integer Instructions" |

Citações:

- P&H, Figure 2.1, p. 70 (PDF 106), legenda "RISC-V assembly language revealed in this chapter.", categoria
  "Data transfer": linha "Load word | `lw x5, 40(x6)` | `x5 = Memory[x6 + 40]` | Word from memory to register"
  e linha "Store word | `sw x5, 40(x6)` | `Memory[x6 + 40] = x5` | Word from register to memory". A tabela da
  figura é desenho vetorial sem camada de texto: as duas linhas foram conferidas na página renderizada
  (`pdftoppm`), não por busca de texto; só a legenda foi conferida no texto extraído.
- P&H, seção 2.3 "Operands of the Computer Hardware", p. 75 (PDF 111): "The data transfer instruction that
  copies data from memory to a register is traditionally called load." e "The real RISC-V name for this
  instruction is lw, standing for load word."
- P&H, seção 2.3, p. 76 (PDF 112): "The instruction complementary to load is traditionally called store; it
  copies data from a register to memory." e "The actual RISC-V name is sw, standing for store word."
- P&H, seção 2.3, p. 77 (PDF 113): "Load word and store word are the instructions that copy words between
  memory and registers in the RISC-V architecture."
- RISC-V Reference Card (`riscv-card.pdf`), p. 1, "RV32I Base Integer Instructions": `lw  Load Word  I
  0000011  0x2  rd = M[rs1+imm][0:31]` e `sw  Store Word  S  0100011  0x2  M[rs1+imm][0:31] = rs2[0:31]`.

Diferenças em relação ao RISC-V (escolha da equipe): sem o `imm` (equivale a `imm = 0`), palavra de 16 bits
em vez de 32, endereço de 7 bits, e no SW o dado vem do campo `ddd`.

Gerado com um script PyMuPDF (`fitz`) a partir de `Materiais teóricos/` do branch `origin/agora-de-athenas`
(livro P&H e `riscv-card.pdf`): páginas extraídas e realces adicionados por busca de texto (p. 75–77 e
cartão) ou por retângulo (Figure 2.1).

## 4. Codificação atualizada (17 bits)

Formato do Thales: opcode de 4 bits em b16..b13, `ddd` em b12..b10, `sss` em b9..b7 e campo de 7 bits em
b6..b0 (constante em complemento de 2, delta do salto relativo ou endereço absoluto). Texto equivalente em
`micro_processador/outros/codificação.txt`.

| Opcode | Assembly | Binário (b16..b0) | Operação | Flags |
|---|---|---|---|---|
| 0000 | `NOP` | `0000 xxx xxx xxxxxxx` | nada | – |
| 0001 | `LD Rd,c` | `0001 ddd xxx ccccccc` | Rd ← sext(c) | – |
| 0010 | `MOV Rd,Rs` | `0010 ddd sss xxxxxxx` | Rd ← Rs | – |
| 0011 | `ADD Rd,Rs` | `0011 ddd sss xxxxxxx` | Rd ← Rd + Rs | ZNCV |
| 0100 | `SUB Rd,Rs` | `0100 ddd sss xxxxxxx` | Rd ← Rd − Rs | ZNCV |
| 0101 | `BLE delta` | `0101 xxx xxx rrrrrrr` | se Z=1 ou N≠V: PC ← PC + delta | – |
| 0110 | `BVC delta` | `0110 xxx xxx rrrrrrr` | se V=0: PC ← PC + delta | – |
| 0111 | `CMPR Rd,Rs` | `0111 ddd sss xxxxxxx` | Rd − Rs, só flags | ZNCV |
| 1000 | `CMPI Rd,c` | `1000 ddd xxx ccccccc` | Rd − sext(c), só flags | ZNCV |
| 1001 | `SUBB Rd,Rs` | `1001 ddd sss xxxxxxx` | Rd ← Rd − Rs − C | ZNCV |
| **1010** | **`LW Rd,(Rs)`** | `1010 ddd sss xxxxxxx` | Rd ← RAM[Rs(6..0)] | – |
| **1011** | **`SW Rd,(Rs)`** | `1011 ddd sss xxxxxxx` | RAM[Rs(6..0)] ← Rd | – |
| **1100** | **`INC Rd`** | `1100 ddd xxx xxxxxxx` | Rd ← Rd + 1 | – |
| **1101** | **`HALT`** | `1101 xxx xxx xxxxxxx` | PC congela, `halted`='1' até o reset | – |
| 1110 | (não usado) | `1110 xxx xxx xxxxxxx` | age como NOP (PC avança, nada é gravado) | – |
| 1111 | `JMP end` | `1111 xxx xxx eeeeeee` | PC ← end | – |

Legenda: `ddd` registrador destino (ou primeiro operando; no SW, o dado), `sss` registrador fonte (ou segundo
operando; no LW/SW, o ponteiro), `ccccccc` constante de 7 bits em complemento de 2 (−64 a 63, com extensão de
sinal para 16 bits), `rrrrrrr` delta em complemento de 2, `eeeeeee` endereço absoluto, `x` irrelevante.
"Delta" do salto relativo: destino = endereço da própria instrução de salto + delta (soma módulo 128).

Alteram as flags: ADD, SUB, SUBB, CMPR e CMPI. Não alteram: NOP, LD, MOV, BLE, BVC, LW, SW, INC, HALT, JMP e
o opcode 1110.

## 5. Como cada item da validação foi implementado

### 5.1 Contador com INC

Instrução nova `INC Rd` (opcode `1100`), Rd ← Rd + 1. Reaproveita a ULA e o caminho da constante, sem
hardware novo de soma. Na UC, quando o opcode é INC:

- a constante enviada ao banco/ULA é forçada para 1 (em vez de sext(b6..b0));
- `sel_ula_b`='1' (entrada B da ULA = constante) e `ULA_ctrl`="00" (A + B); a entrada A já é `data_r1` = Rd;
- `sel_data_wr`="00" (grava a saída da ULA) e `wr_en_banco`='1' só no estado 1;
- `wr_en_flags`='0': **INC não altera flags** (escolha da equipe). O fim do laço é testado logo depois com
  `CMPI` sobre o mesmo registrador, então INC não precisa gerar flags, e assim ele nunca apaga o resultado de
  uma comparação. O sorteio admite essa exceção: "Claro, em processadores reais há exceções, documentadas nos
  manuais. Por exemplo, incremento e decremento normalmente não atualizam as flags." (*Características*,
  seção 4.4 "Flags", nota de rodapé 1, p. 6).

No crivo, as variáveis de controle dos laços de passo 1 são incrementadas com `INC Rn` e o fim de cada um
desses laços é testado com o mesmo Rn (padrão `inc r1` / `cmpi r1,32` / `ble laco`), como pede a definição do
item ("o final do loop deve ser verificado com este registrador Rn"). O laço interno que risca múltiplos anda
de p em p e por isso usa ADD. Ver `micro_processador/programas/crivo.asm`.

### 5.2 Instrução HALT ao final

Instrução nova `HALT` (opcode `1101`). A UC gera `halt`='1' sempre que a instrução na saída da ROM é HALT e:

- `pc_wr_en` = estado and not halt: o PC deixa de ser escrito e fica parado no endereço do HALT, então a ROM
  continua entregando a mesma instrução e o processador fica preso nela;
- HALT não grava banco, RAM nem flags;
- `halt` sai no pino `halted` do top-level, como exige o item ("levantando para 1 o sinal em um pino de saída
  chamado ‘halted’, no top level", *Características*, seção 6.3, p. 10). O sorteio também diz que esses sinais
  "são pinos de saída que devem estar presentes no top level do projeto caso sejam usados." (seção 6.3,
  p. 10).

Só o reset tira o processador desse estado. Os três programas (`crivo`, `teste_ram`, `instrucoes`) terminam
com HALT, e o testbench encerra a simulação quando vê `halted`='1'.

## 6. Temporização de LW e SW (máquina de 2 estados, sem mudança)

O roteiro pede: "não esqueça de verificar os momentos de leitura da RAM e escrita no Banco; altere a máquina
de estados se for necessário." (p. 1). A máquina de estados do Thales (`sm.vhd`) alterna 0/1 a cada subida do
clock; cada instrução dura 2 clocks. Linha do tempo de uma instrução:

| Momento | O que acontece |
|---|---|
| subida que leva o estado 1 → 0 | a ROM (síncrona) entrega a instrução do PC atual |
| estado 0 (um clock) | a UC decodifica; o banco lê `ddd`/`sss` (leitura assíncrona); a RAM lê o endereço `data_r2(6..0)` (leitura assíncrona) |
| estado 1, **descida do meio** | o PC (sensível à descida) recebe o próximo endereço, com `pc_wr_en` = estado and not halt |
| **subida que fecha o estado 1** | banco, flags e RAM gravam; na mesma borda a ROM passa a entregar a próxima instrução |

- **LW:** desde que a instrução aparece na saída da ROM, o endereço da RAM é `Rs(6..0)` e `dado_out` já vale
  `RAM[Rs]`, porque a leitura é assíncrona ("a leitura reflete instantaneamente na saída de dados qualquer
  alteração na entrada de endereços", nota 3, p. 2). O mux `data_wr` seleciona a entrada `"11"` e o banco
  grava em Rd na subida que fecha o estado 1.
- **SW:** `ram_wr_en`='1' só com estado='1' e opcode SW. A RAM grava `Rd` em `RAM[Rs(6..0)]` na subida que
  fecha o estado 1 ("A escrita sempre ocorre numa rampa de subida do clock", nota 3, p. 2).
- **Por que a troca do PC no meio do estado 1 não atrapalha:** endereço e dado da RAM vêm do banco, e os
  números dos registradores vêm da saída da ROM, que só muda numa subida. Entre a descida (PC novo) e a subida
  da gravação a ROM ainda segura a instrução atual, então `ram_wr_en`, endereço e dado ficam estáveis até a
  borda. Na borda, RAM, banco e flags amostram os valores da instrução atual e só depois a saída da ROM troca.

Como toda escrita (banco, flags, RAM) acontece numa única borda e cada instrução faz no máximo uma escrita em
banco ou RAM, **não foi preciso mudar a máquina de estados**: continuam 2 estados.

Para conferir no gtkwave: `clk`, `estado`, `pc`, `instrucao`, o write enable da RAM (o `ram_wr_en` da UC, que
na lista de sinais aparece como `uut.ram1.wr_en`), o endereço e o dado de entrada da RAM (`uut.ram1.endereco`,
`uut.ram1.dado_in`) no momento da subida de gravação (dica do roteiro: "veja as ondas dos enables de escrita e
o dado na entrada no momento da rampa de gravação.", p. 3). O sinal interno `conteudo_ram` da RAM **não está**
no `processador_tb.gtkw`; para ver o conteúdo da memória, adicione-o à mão no gtkwave (painel SST, em
`processador_tb` > `uut` > `ram1`).

## 7. Programas

Todos em `micro_processador/programas/`: `<nome>.asm` (fonte), `<nome>.lst` (endereço, binário agrupado por
campo, hexadecimal de 5 dígitos e assembly, o formato "mais fácil possível para conferência" pedido nas dicas)
e `<nome>.esperado` (sequência esperada de valores de r7, um inteiro com sinal por linha). Endereços,
contagem de instruções e codificação de cada linha: **ver os `.lst`**.

Os `.lst`, as ROMs e os `.esperado` são gerados pelo `programas/montador.py`, e os `.esperado` saem do
simulador de ISA em Python do próprio montador. Portanto o `OK` do `run.sh` prova que o VHDL se comporta igual
a esse modelo, não que o modelo está certo. A conferência independente está nos valores esperados escritos à
mão nos comentários de cada `.asm` (ex.: cabeçalho do `teste_ram.asm`) e, no crivo, na sequência de primos até
31, que é conhecida.

Convenção comum: r7 é o registrador de saída. Os programas só escrevem em r7 o que deve aparecer na saída
(`r7_out`), cada valor diferente do anterior e o primeiro diferente de 0, porque o testbench detecta mudança
de r7. Todos terminam com HALT.

### 7.1 `teste_ram` (programa-teste da RAM, entrega do lab 7)

ROM em `programas/rom_teste_ram.vhd`; fonte `programas/teste_ram.asm`. Testa LW e SW seguindo as regras da
seção "Testes" do roteiro (p. 1):

- várias escritas com dados variados em endereços espaçados ("bem aleatório"): 13 SW, primeiro todas as
  escritas e só depois as leituras; endereços 100 = 77, 5 = −23 (depois sobrescrito com 45), 37 = 200,
  90 = −123, 127 = 177, 64 = 9, 33 = −50, 101 = 120 e o vetor 71..74 = 12, −7, 30, 50. Endereços acima de 63
  são montados com ADD, porque a constante do `LD` vai só até 63;
- dado diferente do endereço em todas as escritas (evita o "falso ok");
- leituras longe das escritas correspondentes, não logo em seguida, e em outra ordem;
- registradores diferentes para escrever, apontar e ler (nas 8 leituras isoladas o ponteiro de leitura é
  outro registrador, recarregado, diferente do usado na escrita), usando os 8 registradores;
- sobrescrita: o endereço 5 recebe −23 e depois 45; a leitura tem que dar 45;
- bit de endereço travado: 33 e 101 são o 37 com o bit 2 e com o bit 6 do endereço trocados, cada um com
  dado próprio, e os dois são lidos de volta. Com o bit 2 ou o bit 6 do endereço travado em 0 a simulação dá
  `FALHA` (testado);
- laço com ponteiro incrementado por INC soma o vetor 71..74 com LW (12 − 7 + 30 + 50 = 85);
- os valores lidos são copiados para r7 e conferidos contra `teste_ram.esperado`. Sequência de r7: 200, 177,
  45, 77, 9, −123, −50, 120, 85.

São 97 palavras na ROM e 112 instruções executadas até o HALT (saída de `montador.py simular`). Pela cobertura
do simulador o programa executa 13 SW e 12 LW (8 leituras isoladas e 4 no laço), além de LD, MOV, ADD, SUB,
INC, CMPR, BLE (tomado 3 vezes e não tomado 1) e HALT. Endereços e codificação: ver `teste_ram.asm` /
`teste_ram.lst`.

### 7.2 `crivo` (validação final, ROM padrão `rom.vhd`)

Fonte `programas/crivo.asm`. Requisitos atendidos:

1. Tabela a partir do endereço 0: RAM[n] = n para n = 1..32, preenchida em laço (roteiro, item 1). O próprio
   contador do laço serve de ponteiro e de dado (`sw r1, (r1)`).
2. Elimina múltiplos de 2, 3 e 5 e segue o algoritmo completo: tenta todos os p; para cada p ainda não
   riscado, zera RAM[m] para m = 2p, 3p, ... ≤ 32 (roteiro, itens 2 a 4).
3. Laço que lê RAM[2] a RAM[32]; para cada valor diferente de 0 faz `MOV r7,valor` (roteiro, item 5).
   O "pino extra" do item 6 é `r7_out` no top-level; `ula_out` continua exposto.
4. Contador com INC nos laços de passo 1 (seção 5.1).
5. Termina com HALT (seção 5.2).

Sequência esperada em r7 (`crivo.esperado`): 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31.

### 7.3 `instrucoes` (programa adicional pedido no email)

ROM em `programas/rom_instrucoes.vhd`; fonte `programas/instrucoes.asm`. Atende ao "ADICIONALMENTE" do email:
uma lista que exercita todas as instruções sorteadas para a equipe no semestre: NOP, LD, MOV, ADD, SUB, SUBB,
CMPR, CMPI, BLE, BVC, JMP, LW, SW, INC e HALT. Os resultados intermediários são copiados para r7 e conferidos
contra `instrucoes.esperado`. Ordem e valores: ver `instrucoes.asm` / `instrucoes.lst`.

Conferido com `python3 programas/montador.py simular programas/instrucoes.asm --cobertura`: 51 palavras, 64
instruções executadas até o HALT, e as 15 instruções executam pelo menos uma vez (o opcode `1110` também
aparece uma vez, para mostrar que age como NOP). BLE é testado tomado (endereços 22, 26 e 40) e não tomado
(endereço 30); BVC é testado tomado (endereço 36, 9 vezes) e não tomado (endereços 36 e 39). Sequência de r7
(`instrucoes.esperado`): 25, −40, −15, 45, 13, 7, 8, 2, 3, 1024, 1025, −9.

## 8. Como simular

Pré-requisitos (Ubuntu/WSL):

```
sudo apt install ghdl gtkwave
```

Na pasta `micro_processador/`:

```
sh run.sh               # crivo (rom.vhd), compara com programas/crivo.esperado
sh run.sh teste_ram     # usa programas/rom_teste_ram.vhd
sh run.sh instrucoes    # usa programas/rom_instrucoes.vhd
```

O script compila os arquivos na ordem da seção 2 mais o testbench, roda a simulação gerando
`processador_tb.ghw`, imprime a sequência de valores de r7 e, se existir `programas/<programa>.esperado`,
compara e imprime `OK` ou `FALHA` (código de saída diferente de 0 na falha). A simulação termina sozinha no
HALT; sem HALT até 2 ms o testbench acusa `TIMEOUT`.

Formas de onda:

```
gtkwave processador_tb.ghw processador_tb.gtkw
```

O `conteudo_ram` não vem no `.gtkw` (ver o fim da seção 6); o write enable da RAM aparece como `ram1.wr_en`.

Testbenches dos componentes (ghdl no padrão 93c, que é o padrão dele), também na pasta `micro_processador/`:

```
W=$(mktemp -d)
for f in reg1bit.vhd ram.vhd ram_tb.vhd uc/uc.vhd uc/uc_tb.vhd \
         banco_ula/banco/reg16bits.vhd banco_ula/banco/banco.vhd banco_ula/banco/banco_tb.vhd \
         banco_ula/ula/ula.vhd banco_ula/ula/ula_tb.vhd banco_ula/banco_ula.vhd banco_ula/banco_ula_tb.vhd; do
    ghdl -a --workdir=$W $f
done
for t in ram_tb uc_tb banco_ula_tb banco_tb ula_tb; do
    ghdl -e --workdir=$W $t && ghdl -r --workdir=$W $t --stop-time=50us
done
```

O ram_tb, o uc_tb e o banco_ula_tb terminam com a nota `<nome>: fim dos testes`; erro de assert aparece
como `(assertion error)`. Os avisos `metavalue detected` em 0 ms vêm dos sinais ainda não inicializados no
instante zero e não indicam falha.

Montador, simulador de ISA e desmontador (Python 3, sem dependências externas), também a partir de
`micro_processador/`:

```
python3 programas/montador.py todos
python3 programas/montador.py montar programas/teste_ram.asm [--rom ARQUIVO.vhd]
python3 programas/montador.py simular programas/crivo.asm [--cobertura] [--r7]
python3 programas/desmontador.py rom.vhd programas/crivo.asm
python3 programas/test_montador.py
```

- `todos`: regera os três programas: `rom.vhd` (crivo), `programas/rom_teste_ram.vhd` e
  `programas/rom_instrucoes.vhd`, mais os `.lst` e os `.esperado`.
- `montar <asm>`: gera o `.lst`, a ROM (por padrão `rom_<nome>.vhd` ao lado do `.asm`; `--rom` escolhe outro
  arquivo) e o `.esperado` de um programa.
- `simular <asm ou vhd>`: executa o programa (fonte `.asm` ou ROM `.vhd`) até o HALT e imprime a sequência de
  r7, os registradores, as flags e as posições escritas da RAM; `--cobertura` acrescenta quantas vezes cada
  opcode executou e, para cada desvio condicional, quantas vezes foi tomado e não tomado; `--r7` imprime só a
  sequência de r7.
- `desmontador.py <rom.vhd> <asm>`: desmonta a ROM e compara com o `.asm` (ida e volta); a saída esperada é
  `0 divergencia(s)`.
- `test_montador.py`: testes unitários do montador e do simulador (18 testes, devem terminar em `OK`).

## 9. Checklist de entrega ("Arquivos a Entregar", roteiro p. 2)

| Item do roteiro | Onde está |
|---|---|
| "Arquivos VHDL do projeto e seus testbenches" | `micro_processador/*.vhd` e subpastas (lista da seção 2); testbenches: `ram_tb.vhd` (novo), `uc/uc_tb.vhd` e `banco_ula/banco_ula_tb.vhd` (com casos de LW, SW, INC, HALT e `1110`), os demais `*_tb.vhd` dos componentes e `processador_tb.vhd` rodando os três programas pelo `run.sh` (seção 8); `processador_tb.gtkw` |
| "Páginas do manual com as instruções de memória escolhidas em destaque" | `docs/manual_lw_sw.pdf` (seção 3.1) |
| "Especificação atualizada da codificação das instruções" | `micro_processador/outros/codificação.txt` e seção 4 deste documento |
| "Código assembly e codificação na ROM para o programa-teste pedido acima" | `programas/teste_ram.asm`, `teste_ram.lst`, `rom_teste_ram.vhd` |
| Validação (crivo) | `rom.vhd`, `programas/crivo.asm`, `crivo.lst`, `crivo.esperado` |
| Programa com todas as instruções (email) | `programas/instrucoes.asm`, `instrucoes.lst`, `rom_instrucoes.vhd`, `instrucoes.esperado` |

O roteiro pede "um arquivo compactado" (p. 2) e "Entregue tudo seguindo o padrão estabelecido nestes últimos
labs." (p. 3).

## 10. Extra: FPGA

Além da simulação, a equipe preparou a execução do processador na placa Sipeed Tang Nano 20K (FPGA Gowin),
usando a mesma interface do top-level da seção 2. O topo `fpga/tang_nano_20k/src/top_primos.vhd` roda o crivo
da `rom.vhd`: o clock de 27 MHz (pino 4) é dividido para 2 kHz e cada valor novo de `r7_out` aparece em
decimal em dois displays de 7 segmentos (dezena nos pinos 15 a 20 e 25, unidade nos pinos 26 a 31 e 53),
parado por cerca de 1,5 s; `halted` vai ao pino 77 (LED opcional) e o botão S1 (pino 88) é o reset
(`fpga/tang_nano_20k/src/pinout.cst`). Passo a passo, ligações e limitações estão em
`docs/fpga-tang-nano-20k.md`; os pontos que dependem da placa física estão marcados com `[VALIDAR]` lá.
