# Lab 7 — Memória de Dados (RAM, LW e SW) + Validação (pendente)

Arquivos em `lab7/`. Base: PDF *µProcessador 7* ("Memória de Dados + Validação", arquivo
`uprocessador 7 v5.1.pdf`), documento *Características do Projeto do µP* e o lab 6 (`docs/lab6.md`), do qual
este lab é uma evolução. Convenção de citação igual à do `docs/lab5.md`.

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

| Arquivo | Mudança em relação ao lab 6 |
|---|---|
| `ram.vhd` | **novo**: RAM 128 x 16 do PDF, escrita síncrona, leitura assíncrona |
| `un_controle.vhd` | instruções LW e SW; nova saída `ram_wr_en`; `sel_dado_banco="11"` para LW |
| `processador.vhd` | instância da RAM; entrada "11" (dado da RAM) no mux do banco |
| `rom.vhd` | programa de teste da RAM |
| `processador_tb.vhd` | só o tempo de simulação (30 µs) |
| `programa.asm` | listagem do programa |
| `reg16bits.vhd`, `reg1bit.vhd`, `pc.vhd`, `maq_estados.vhd`, `banco.vhd`, `ula.vhd` | iguais ao lab 6 |
| `processador_tb.gtkw`, `run.sh` | mesma lista de sinais; `run.sh` inclui `ram.vhd` |

## 3. Instruções de memória escolhidas

```
MSB b15                      b0 LSB
LW Rd,(Rs)  1011 ddd sss xxxxxx     Rd <- RAM[Rs(6 downto 0)]
SW Rd,(Rs)  1100 ddd sss xxxxxx     RAM[Rs(6 downto 0)] <- Rd
```

- **Ponteiro em registrador, sem deslocamento.** O PDF permite as duas formas (nota 1). Escolhemos a forma
  sem constante porque não há bits sobrando no formato de 16 bits para um deslocamento útil junto com dois
  registradores de 3 bits, e porque o exemplo do próprio PDF é assim: `lw $r1,($r3)` ("dado lido da RAM
  carregado no reg 1", p. 1). É escolha da equipe.
- **Endereço = 7 bits menos significativos de Rs**, porque a RAM tem 128 posições (`endereco : in
  unsigned(6 downto 0)` no modelo do PDF). Os bits 15..7 do ponteiro são ignorados.
- A RAM é de palavras de 16 bits: cada endereço guarda um dado inteiro (não há endereçamento por byte).
- Nenhuma das duas altera as flags ("quando houver branches, MOV, NOP, LW, SW, o valor dos flip-flops fica
  inalterado", *Características*, seção 4.4, p. 6).

### 3.1 "Páginas do manual com as instruções de memória escolhidas em destaque"

As instruções são as de load/store do RISC-V (o processador de referência da disciplina), com o modo de
endereçamento reduzido a "registrador como ponteiro":

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

Diferenças em relação ao RISC-V (escolha da equipe): sem o `imm` (equivale a `imm = 0`), palavra de 16 bits
em vez de 32, e no SW o registrador do dado vem no campo `ddd` (primeiro operando), para manter a ordem
`SW Rd,(Rs)` igual à do LW. Para imprimir e destacar: página 70 do livro (Figure 2.1, linhas lw/sw) e a
primeira página do `riscv-card.pdf` (linhas lw/sw).

## 4. Circuito

### 4.1 RAM (`ram.vhd`)

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

### 4.2 Mux de dados do banco

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

### 4.3 Controle (estado 2)

| Instrução | banco_wr_en | ram_wr_en | flags_wr_en | sel_dado_banco | pc_prox |
|---|---|---|---|---|---|
| LW | 1 | 0 | 0 | 11 (RAM) | PC+1 |
| SW | 0 | 1 | 0 | – | PC+1 |
| demais | como no lab 6 | 0 | como no lab 6 | como no lab 6 | como no lab 6 |

```
ram_wr_en <= '1' when estado="10" and eh_sw='1' else
             '0';
```

Base: "a memória de dados RAM: ela deve ser habilitada para escrita no write enable ou wr en [...] Da mesma
forma, apenas a instrução lw vai fazer a leitura da RAM" (`cap2-ciclo-unico.pdf`, seção 5.3, p. 11). Nossa RAM
não tem read enable (o modelo do PDF só tem `wr_en`), então ela está sempre "lendo" o endereço `data_r2`; o
dado só é usado quando `sel_dado_banco="11"` e `banco_wr_en=1`, isto é, no LW.

### 4.4 Momentos de leitura e escrita (a máquina de estados não mudou)

O PDF pede: "não esqueça de verificar os momentos de leitura da RAM e escrita no Banco; altere a máquina de
estados se for necessário" (p. 1). Verificação:

- Durante todo o estado 2 o IR está estável (gravado no fim do estado 1), então `reg_r1`/`reg_r2` e as saídas
  do banco estão estáveis; a leitura assíncrona da RAM segue o endereço imediatamente.
- **LW:** no estado 2 `ram_dado_s = RAM[Rs]` já está na entrada do banco; o banco grava na borda que termina o
  estado 2 (a mesma de todas as escritas).
- **SW:** a RAM grava `Rd` em `RAM[Rs]` na borda que termina o estado 2 (`ram_wr_en` só é 1 no estado 2).

Não há conflito: cada instrução faz no máximo uma escrita e todas acontecem na mesma borda, como no multiciclo
do livro ("At the end of a clock cycle, all data that is used in subsequent clock cycles must be stored in a
state element", P&H, seção 4.5, p. 282.e1). Portanto **mantivemos os 3 estados** (o lab 5 diz que "a RAM pode
ficar mais clara com 4 estados", nota 3, p. 2, mas não foi necessário).

## 5. Programa de teste (`lab7/programa.asm`)

| End. | Assembly | Hexa | Efeito esperado |
|---|---|---|---|
| 0 | `LD R1,45` | 122D | R1 = 45 (ponteiro) |
| 1 | `LD R2,-123` | 1585 | R2 = −123 (0xFF85) |
| 2 | `SW R2,(R1)` | C440 | RAM[45] ← −123 |
| 3 | `LD R3,117` | 1675 | R3 = 117 (ponteiro) |
| 4 | `LD R4,200` | 18C8 | R4 = 200 |
| 5 | `SW R4,(R3)` | C8C0 | RAM[117] ← 200 |
| 6 | `LD R5,6` | 1A06 | R5 = 6 (ponteiro) |
| 7 | `LD R6,-1` | 1DFF | R6 = −1 (0xFFFF) |
| 8 | `SW R6,(R5)` | CD40 | RAM[6] ← 0xFFFF |
| 9 | `LD R7,90` | 1E5A | R7 = 90 (ponteiro) |
| 10 | `LD R0,77` | 104D | R0 = 77 |
| 11 | `SW R0,(R7)` | C1C0 | RAM[90] ← 77 |
| 12 | `SUB R6,R4` | 4D00 | R6 = −1 − 200 = −201 (dado calculado) |
| 13 | `ADD R1,R5` | 3340 | R1 = 45 + 6 = 51 (ponteiro calculado) |
| 14 | `SW R6,(R1)` | CC40 | RAM[51] ← −201 |
| 15 | `LD R0,33` | 1021 | R0 = 33 |
| 16 | `SW R0,(R5)` | C140 | RAM[6] ← 33 (sobrescreve 0xFFFF) |
| 17–20 | `LD R2,0`; `LD R4,0`; `LD R6,0`; `LD R0,0` | 1400, 1800, 1C00, 1000 | apaga os registradores que tinham os dados |
| 21 | `LW R4,(R7)` | B9C0 | R4 ← RAM[90] = 77 |
| 22 | `LW R6,(R3)` | BCC0 | R6 ← RAM[117] = 200 |
| 23 | `LW R2,(R5)` | B540 | R2 ← RAM[6] = 33 |
| 24 | `LW R0,(R1)` | B040 | R0 ← RAM[51] = −201 |
| 25 | `LD R1,45` | 122D | R1 = 45 |
| 26 | `LW R7,(R1)` | BE40 | R7 ← RAM[45] = −123 |
| 27–30 | `LD R1,1`; `LD R3,100`; `LD R5,250`; `LD R6,-13` | 1201, 1664, 1AFA, 1DF3 | incremento, ponteiro do vetor, 1º dado, passo |
| 31 | `SW R5,(R3)` | CAC0 | laço 1: RAM[R3] ← R5 |
| 32 | `ADD R5,R6` | 3B80 | R5 ← R5 − 13 |
| 33 | `ADD R3,R1` | 3640 | R3 ← R3 + 1 |
| 34 | `CMPI R3,104` | 7668 | |
| 35 | `BLE -4` | 907C | volta para 31 enquanto R3 ≤ 104 |
| 36–37 | `LD R3,100`; `LD R4,0` | 1664, 1800 | ponteiro e soma |
| 38 | `LW R2,(R3)` | B4C0 | laço 2: R2 ← RAM[R3] |
| 39 | `ADD R4,R2` | 3880 | R4 ← R4 + R2 |
| 40 | `ADD R3,R1` | 3640 | R3 ← R3 + 1 |
| 41 | `CMPI R3,104` | 7668 | |
| 42 | `BLE -4` | 907C | volta para 38 enquanto R3 ≤ 104 |
| 43 | `JMP 43` | 802B | fim (R4 = 250+237+224+211+198 = 1120) |

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
= borda de subida em que o registrador foi gravado.

Leituras da primeira parte (valores com sinal):

| Borda (ns) | PC | Instrução | Valor lido | Esperado |
|---|---|---|---|---|
| 6750 | 21 | `LW R4,(R7)` (R7 = 90) | R4 = 77 | 77 |
| 7050 | 22 | `LW R6,(R3)` (R3 = 117) | R6 = 200 | 200 |
| 7350 | 23 | `LW R2,(R5)` (R5 = 6) | R2 = 33 | 33 (sobrescrito) |
| 7650 | 24 | `LW R0,(R1)` (R1 = 51) | R0 = −201 | −201 |
| 8250 | 26 | `LW R7,(R1)` (R1 = 45) | R7 = −123 | −123 |

Antes das leituras (6450 ns) os registradores eram R0=0, R1=51, R2=0, R3=117, R4=0, R5=6, R6=0, R7=90, ou seja,
os valores vieram mesmo da RAM.

Laço 1 (escrita do vetor): R5 passou por 250, 237, 224, 211, 198 nos SW dos endereços 100..104; BLE tomado 4
vezes e não tomado na 5ª (R3 = 105), bordas 9750 a 16950 ns. Laço 2 (leitura): R2 recebeu 250 (17850 ns), 237
(19350), 224 (20850), 211 (22350), 198 (23850); R4 acumulou 250, 487, 711, 922, **1120** (24150 ns).

Estado final (a partir de 25350 ns, laço `JMP 43`): R0 = −201, R1 = 1, R2 = 198, R3 = 105, **R4 = 1120**,
R5 = 185, R6 = −13, R7 = −123. Todos os endereços de 0 a 43 foram executados na ordem esperada; os LD/LW/SW
não alteraram as flags (ex.: ZNCV = 0000 do início até o primeiro SUB em 4050 ns).

## 7. Como rodar

```
cd lab7
./run.sh
```

Mesma lista de sinais dos labs 5 e 6 (`processador_tb.gtkw`). Para depurar a RAM, adicione no gtkwave os sinais
internos `top.processador_tb.uut.ram_wr_en_s`, `endereco_ram_s`, `ram_dado_s` e `dado_banco_s`.

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
registrador, laços com CMPI/BLE e JMP.
