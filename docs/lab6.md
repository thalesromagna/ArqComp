# Lab 6 — Condicionais e Desvios (flags, CMPR/CMPI, SUBB, BLE, BVC)

Arquivos em `lab6/`. Base: PDF *µProcessador 6* ("Condicionais e Desvios"), documento *Características do
Projeto do µP* (arquivo `6996-EncargosdeIRRF-082026.pdf`) e o lab 5 (`docs/lab5.md`), do qual este lab é uma
evolução. Convenção de citação igual à do `docs/lab5.md` (livro P&H com página impressa; slides e PDFs com a
página do PDF).

O lab já segue o **Email 3** (unidade de controle, ver `docs/00-especificacoes.md`, seção 1): instrução e
ROM de **17 bits** (opcode de 5 bits), ROM **síncrona**, PC sensível à **borda de descida** e **sem
registrador de instrução**. A seção 4.1 explica o que isso muda no circuito e na temporização.

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
**SUBB**, comparações **CMPR** e **CMPI**, ADD/SUB só entre registradores e com 2 operandos (Emails 1 e 2);
instrução de 17 bits, PC na descida, ROM síncrona, "Incondicional é absoluto e condicional é relativo" e
registrador de instruções "não usar" (Email 3).

## 2. Arquivos

| Arquivo | Conteúdo / mudança em relação ao lab 5 |
|---|---|
| `reg1bit.vhd` | **novo**: flip-flop de 1 bit com reset e enable (modelo `reg8bits` do *µProcessador 3* com 1 bit), borda de **subida** |
| `un_controle.vhd` | novas instruções SUBB, CMPR, CMPI, BLE, BVC; saídas `flags_wr_en` e `sel_ula_b`; entradas das flags. Email 3: `instr` de 17 bits, `opcode <= instr(16 downto 12)` (5 bits), **sem** a saída `ir_wr_en` |
| `processador.vhd` | 4 flip-flops de flag (Z, N, C, V) no top-level; mux na entrada B da ULA; `carry_in` da ULA = flag C. Email 3: **sem registrador de instrução**; a saída `dado` da ROM (17 bits) vai direto na UC e no pino `instrucao` |
| `rom.vhd` | ROM síncrona de 128 x **17 bits** (`unsigned(16 downto 0)`) com o programa do lab 6 + testes extras |
| `pc.vhd` | registrador de 7 bits (mesmo modelo do lab 3) com `falling_edge(clk)`: PC na **descida** (Email 3) |
| `processador_tb.vhd` | tempo de simulação (50 µs); `instrucao` com 17 bits |
| `programa.asm` | listagem do programa (binário de 17 bits, hexa com 5 dígitos) |
| `reg16bits.vhd`, `maq_estados.vhd`, `banco.vhd`, `ula.vhd` | iguais ao lab 5 (`reg16bits` só é usado dentro do banco) |
| `processador_tb.gtkw`, `run.sh` | mesma lista de sinais, com `instrucao[16:0]`; `run.sh` inclui `reg1bit.vhd` |

## 3. Instruções novas e codificação

Codificação completa em `docs/00-especificacoes.md`, seção 4. Instruções deste lab (as do lab 5 continuam):

```
MSB b16                       b0 LSB
SUBB Rd,Rs  00101 ddd sss xxxxxx     Rd <- Rd - Rs - C                  flags Z N C V
CMPR Rd,Rs  00110 ddd sss xxxxxx     Rd - Rs (só flags, não grava)      flags Z N C V
CMPI Rd,cte 00111 ddd ccccccccc      Rd - cte (só flags, não grava)     flags Z N C V
BLE  delta  01001 xxxxx eeeeeee      se Z=1 ou N/=V: PC <- PC + delta
BVC  delta  01010 xxxxx eeeeeee      se V=0:         PC <- PC + delta

eeeeeee = delta de 7 bits em complemento de 2 (-64..+63); ccccccccc = constante de 9 bits em complemento de 2
```

As do lab 5 mantêm os opcodes da tabela geral: NOP `00000`, LD `00001`, MOV `00010`, ADD `00011`,
SUB `00100` e JMP `01000` (absoluto). ADD e SUB passam a gravar as flags. Opcodes 01011 a 11111 continuam sem efeito
(PC+1); 01011 e 01100 ficam reservados para LW e SW (lab 7).

**Largura de 17 bits (Email 3).** "O tamanho das instruções é sorteado para a equipe, e é igual à largura de
um dado da ROM." (*µProcessador 5*, "Implementação", p. 2). A codificação de 16 bits usada antes do Email 3
ganhou um `0` à esquerda do opcode: o opcode passou a ter 5 bits (b16..b12) e os campos b11..b0
(`ddd`, `sss`, constante de 9 bits, endereço/delta de 7 bits) continuam nas mesmas posições, então a UC só
mudou a largura de `instr` e do `opcode` (`instr(16 downto 12)`). NOP continua sendo tudo zero (`0x00000`).
A troca de opcodes é permitida: "É permitido mudar os formatos de instrução (os opcodes) em laboratórios
posteriores." (*µProcessador 5*, "Implementação", p. 2).

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

### 4.1 Sem registrador de instrução, ROM síncrona e PC na descida (Email 3)

```
            +-------------+ estado
  clk,rst ->| maq_estados |---------------------------------+
            |  (subida)   |                                 |
            +-------------+                                 v
   +-----------+ pc_s  +-----------+ instrucao (17) +-------------+
   |    PC     |------>|    ROM    |--------------->| un_controle |--> banco_wr_en, flags_wr_en,
   | (descida) |       | síncrona  |   (= pino      | (when-else) |    ula_controle, sel_ula_b, ...
   +-----------+       | (subida)  |   instrucao)   |             |--> pc_wr_en
         ^             +-----------+                |             |
         |                    pc_prox               |             |
         +------------------------------------------|             |
                                                    +-------------+
```

- **Sem registrador de instrução.** O Email 3 sorteou "Registrador de Instruções: ['não usar']" e o lab 5
  só pede o IR "Caso o seu sorteio especifique um Registrador de Instrução" (*µProcessador 5*,
  "Implementação", p. 2). O `processador.vhd` não tem mais a instância `reg_instr` nem o `ir_wr_en`: a saída
  `dado` da ROM (sinal `rom_dado_s`, 17 bits, mesmo nome dos labs 5 e 7) entra direto em `instr` da UC e sai
  no pino `instrucao`, como prevê a lista de sinais do gtkwave: "instrução (saída do Registrador de
  Instrução, ou, se não houver, da ROM)" (*µProcessador 5*, "Testes", p. 2).
- **ROM síncrona.** Modelo do *µProcessador 4* com `process(clk)` e `rising_edge`, só com a largura de 17 bits:
  "Note que esta ROM é sincrona! Isto significa que é preciso dar um clock nela para que ela leia os dados, ou
  seja, só quando houver rampa de subida no clock é que teremos uma resposta à saída." (*µProcessador 4*,
  "ROM em VHDL", p. 1).
- **PC na descida.** "Se algum item sorteado for sensível a rampa de descida, utilize falling_edge(clk) ao
  invés de rising_edge(clk)." (*µProcessador 5*, "Contadores em VHDL", p. 1). O `pc.vhd` é o registrador do
  lab 3 com 7 bits e `if falling_edge(clk) then`. ROM, banco, flip-flops das flags (`reg1bit`) e máquina de
  estados continuam na **subida**.
- `pc_wr_en <= '1' when estado="10" else '0'` (sem mudança). O estado 2 vai de uma subida à seguinte e tem uma
  única descida, no meio; por isso o PC é escrito exatamente uma vez por instrução, meio clock antes do banco e
  das flags.

Linha do tempo de uma instrução (testbench: período de 100 ns, subidas em 50, 150, 250, ... ns, descidas em
100, 200, 300, ... ns, reset nos 200 ns iniciais):

| Estado | Borda | O que acontece |
|---|---|---|
| 0 (fetch) | subida que encerra o estado | a ROM registra `ROM[PC]`; é o mesmo endereço que ela já leu na subida anterior, então a saída não muda |
| 1 (decode) | – | `instrucao` estável; a UC decodifica, o banco lê, a ULA calcula e `pc_prox` fica pronto |
| 2 (execute) | **descida** do meio do estado | o PC recebe `pc_prox` |
| 2 (execute) | subida que encerra o estado | gravam banco e flags, com os sinais da instrução atual (a saída da ROM só muda nessa mesma borda), e a ROM já lê `ROM[novo PC]` |

A instrução fica estável durante decode e execute sem precisar de IR porque a saída da ROM só muda numa subida
e o endereço dela (o PC) só muda na descida do estado 2. Medido no VCD: `instrucao` só muda nas subidas
450, 750, 1050, ... ns (as que encerram cada estado 2), nunca no fim do estado 0 ou 1; o PC só muda em
descidas (400, 700, 1000, ... ns) e sempre com o estado em 2. Primeira instrução: reset solto em 200 ns,
estado 0→1 em 250 ns, 1→2 em 350 ns, PC 0→1 na descida de 400 ns, R3 gravado e `instrucao` = 0x01800 na
subida de 450 ns. A ROM não tem reset: na subida de 50 ns (ainda em reset, PC=0) ela já lê 0x01600 (`LD R3,0`).

### 4.2 Flags: ULA e flip-flops

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

### 4.3 Mux da entrada B da ULA (CMPI)

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

### 4.4 Desvios na unidade de controle

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
- **Base do endereço relativo = endereço do próprio branch.** O PC recebeu o endereço do BLE/BVC na descida
  do meio do estado 2 da instrução anterior e só volta a mudar na descida do meio do estado 2 do próprio
  branch. Até essa descida, `pc_atual` é o endereço do branch, então o `pc_prox` gravado nela é
  `endereço do branch + delta` (ou `+1` se não salta). Isso segue a nota do PDF: "“branch 5” vai pular cinco
  instruções pra frente de onde ele está" (*µProcessador 6*, nota 1, p. 1) e o livro: "The instruction set
  architecture specifies that the base for the branch address calculation is the address of the branch
  instruction." (P&H, seção 4.3, p. 264). Ex.: `BLE -3` no endereço 6 vai para 3; `BLE 2` no endereço 12 vai
  para 14.
- **Depois da descida** o PC já está no destino e `pc_prox` é recalculado com ele (no `BLE -3` tomado,
  3 + (−3) = 0, medido entre 2200 e 2250 ns), mas esse valor nunca é gravado: `pc_wr_en` cai na subida que
  encerra o estado 2 e a próxima descida já cai no estado 0. Isso vale também para o PC+1 e o JMP.
- **A instrução seguinte a um desvio tomado nem chega a ser lida:** a subida que encerra o estado 2 do branch
  já lê a ROM no endereço de destino. Medido: os códigos dos endereços 19 (0x025C0), 29 (0x01FFF) e 39
  (0x01C00) nunca aparecem em `instrucao`; o do endereço 7 (0x02B00) só aparece em 37050 ns, depois do único
  BLE não tomado. Forma de onda na seção 6.3.
- **Complemento de 2:** o delta tem 7 bits e o PC também, então a soma `pc_atual + delta` em 7 bits (módulo
  128) já dá o resultado certo para delta negativo: como o delta já tem a largura do PC, a "extensão de sinal"
  para 7 bits não acrescenta nenhum bit, e por isso não há circuito de extensão (escolha da equipe). O PDF
  garante que a soma funciona com o delta em complemento de 2: "Se for feita extensão de sinal do operando,
  basta fazer normalmente a soma ao PC: ela vai funcionar, pelas propriedades de complemento de 2"
  (*µProcessador 6*, p. 1) e "Pode continuar usando signals UNSIGNED normalmente no VHDL, vai funcionar, confie"
  (p. 3). O livro chama isso de "PC-relative addressing", "An addressing regime in which the address is the
  sum of the program counter (PC) and a constant in the instruction" (P&H, seção 2.10, p. 122). Diferença
  para o RISC-V: lá o offset é deslocado 1 bit (meia palavra): "The architecture also states that the offset
  field is shifted left 1 bit so that it is a half word offset" (P&H, seção 4.3, p. 264); aqui cada endereço
  é uma instrução, então o delta é em instruções.
- Seleção do PC por mux, como nos slides: "o PC deve ser escrito com o valor PC+delta endereços quando ambos
  é igual==1 e instr beq==1; caso contrário, devemos escrever PC+4 no PC. Isso nos dá um simples mux"
  (`cap2-ciclo-unico.pdf`, seção 6.2, p. 14), e "No caso de incluirmos outras instruções de saltos, podemos
  gerar mais sinais pela ULA e combiná-los, dentro ou fora da ULA" (p. 15). No livro, "An AND gate is used to
  combine the branch control signal and the Zero output from the ALU; the AND gate output controls the
  selection of the next PC." (P&H, Figure 4.21, p. 277). No nosso caso a "AND" é entre `eh_ble`/`eh_bvc` e a
  condição das flags guardadas.

### 4.5 Tabela de controle (estado 2)

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

| End. | Passo | Assembly | Binário (17 bits) | Hexa | Comentário |
|---|---|---|---|---|---|
| 0 | A | `LD R3,0` | `00001 011 000000000` | 01600 | |
| 1 | B | `LD R4,0` | `00001 100 000000000` | 01800 | |
| 2 | (aux.) | `LD R1,1` | `00001 001 000000001` | 01201 | não há ADDI: a constante 1 fica em R1 |
| 3 | C | `ADD R4,R3` | `00011 100 011 000000` | 038C0 | R4 ← R4 + R3 |
| 4 | D | `ADD R3,R1` | `00011 011 001 000000` | 03640 | R3 ← R3 + 1 |
| 5 | E | `CMPI R3,29` | `00111 011 000011101` | 0761D | flags de R3 − 29 |
| 6 | E | `BLE -3` | `01001 00000 1111101` | 0907D | delta −3 = `1111101`: volta para 3 se R3 ≤ 29 |
| 7 | F | `MOV R5,R4` | `00010 101 100 000000` | 02B00 | |

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

Deltas: `BLE 2`/`BVC 2` = `0000010`, `BLE -3` = `1111101`, todos em complemento de 2. A codificação de
todos os endereços (binário de 17 bits e hexa de 5 dígitos) está em `lab6/programa.asm`, conferida
automaticamente contra o `rom.vhd`.

## 6. Resultados da simulação

GHDL 4.1, `processador_tb` com 50 µs, gravando VCD numa pasta de trabalho fora do repositório; o VCD foi
conferido por script Python da equipe (também fora do repositório). Em cada linha: **PC (descida)** = descida
do meio do estado 2 em que o PC mudou; **grava (subida)** = subida que encerra o estado 2, em que banco e flags
gravaram (sempre 50 ns depois). Flags na ordem Z N C V, depois da instrução.

### 6.1 Programa obrigatório

| PC (descida, ns) | Grava (subida, ns) | PC | Instrução | Depois | ZNCV |
|---|---|---|---|---|---|
| 400 | 450 | 0 | LD R3,0 | R3=0, PC → 1 | 0000 |
| 700 | 750 | 1 | LD R4,0 | R4=0, PC → 2 | 0000 |
| 1000 | 1050 | 2 | LD R1,1 | R1=1, PC → 3 | 0000 |
| 1300 | 1350 | 3 | ADD R4,R3 | R4=0 | 1000 |
| 1600 | 1650 | 4 | ADD R3,R1 | R3=1 | 0000 |
| 1900 | 1950 | 5 | CMPI R3,29 | ULA = −28 | 0110 |
| 2200 | 2250 | 6 | BLE -3 | PC → 3 (tomado, N≠V) | 0110 |
| ... | | | | | |
| 35500 | 35550 | 5 | CMPI R3,29 (R3=29) | ULA = 0 | 1000 |
| 35800 | 35850 | 6 | BLE -3 | PC → 3 (tomado, Z=1) | 1000 |
| 36100 | 36150 | 3 | ADD R4,R3 | R4 = 435 | 0000 |
| 36400 | 36450 | 4 | ADD R3,R1 | **R3 = 30** | 0000 |
| 36700 | 36750 | 5 | CMPI R3,29 | ULA = 1 | 0000 |
| 37000 | 37050 | 6 | BLE -3 | PC → 7 (não tomado) | 0000 |
| 37300 | 37350 | 7 | MOV R5,R4 | **R5 = 435** | 0000 |

- O BLE do endereço 6 foi executado 30 vezes: **29 tomado** (para trás, PC → 3) e 1 não tomado (PC → 7).
- Ao fim do obrigatório: **R3 = 30, R4 = 435, R5 = 435**.
- Veja que as flags não mudam no BLE nem no LD (ex.: 2250 ns mantém 0110 do CMPI), como exigido.
- Sanidade de clocks: o passo F é a 124ª instrução executada (3 + 30 x 4 + 1); a n-ésima instrução muda o PC
  na descida 100 + 300·n ns e grava na subida 150 + 300·n ns, logo 37300 e 37350 ns, exatamente o medido.

### 6.2 Testes extras (valores medidos)

| PC (descida, ns) | Grava (subida, ns) | PC | Instrução | Resultado | ZNCV | PC seguinte |
|---|---|---|---|---|---|---|
| 38500 | 38550 | 11 | CMPR R6,R7 (37, −20) | 57 | 0010 | 12 |
| 38800 | 38850 | 12 | BLE 2 | não tomado | 0010 | 13 |
| 39100 | 39150 | 13 | MOV R0,R7 | **R0 = −20** | 0010 | 14 |
| 40300 | 40350 | 17 | CMPR R6,R7 (−90, 12) | −102 | 0100 | 18 |
| 40600 | 40650 | 18 | BLE 2 | tomado | 0100 | **20** |
| 43000 | 43050 | 27 | ADD R6,R6 | R6 = −32768 (0x8000) | 0110 | 28 |
| 43300 | 43350 | 28 | BVC 2 | tomado (V=0) | 0110 | **30** |
| 43600 | 43650 | 30 | SUB R6,R1 | R6 = 32767 (0x7FFF) | 0001 | 31 |
| 43900 | 43950 | 31 | BVC 2 | não tomado (V=1) | 0001 | 32 |
| 44200 | 44250 | 32 | LD R7,77 | R7 = 77 | 0001 | 33 |
| 44800 | 44850 | 34 | SUBB R6,R7 (C=0) | **R6 = 123** | 0000 | 35 |
| 45100 | 45150 | 35 | CMPI R6,124 | −1 | 0110 | 36 |
| 45400 | 45450 | 36 | SUBB R6,R7 (C=1) | **R6 = 45** | 0000 | 37 |
| 45700 | 45750 | 37 | CMPI R6,45 | 0 | 1000 | 38 |
| 46000 | 46050 | 38 | BLE 2 | tomado (Z=1) | 1000 | **40** |
| 46300.. | 46350.. | 40 | JMP 40 | laço (PC regravado com 40) | 1000 | 40 |

- Endereços **nunca executados**: 19, 29 e 39 — exatamente as instruções logo após os desvios tomados. Todos
  os outros de 0 a 40 foram executados (166 instruções em 50 µs, nenhuma fora de 0..40).
- Estado final (50 µs): R0 = −20, R1 = 1, R2 = −90, R3 = 30, **R4 = 435, R5 = 435**, R6 = 45, R7 = 77.
- O "menor de dois" ficou em R0 (−20, entre 37 e −20) e em R2 (−90, entre −90 e 12).
- As mensagens `NUMERIC_STD."=": metavalue detected` aparecem só em 0 ms, antes da primeira subida, quando a
  saída da ROM ainda é `U`; depois disso não há mais nenhuma.

### 6.3 Temporização de um desvio tomado (forma de onda)

Primeiro `BLE -3` (endereço 6, R3 = 1, flags do `CMPI R3,29` = 0110, ou seja N≠V) seguido do `ADD R4,R3` do
endereço 3. Valores medidos no VCD (`pc_wr_en_s`, `pc_prox_s`, `flags_wr_en_s`, `flag_*_s` e `banco_wr_en_s`
são sinais internos de `uut`; `instrucao` em hexa de 17 bits):

```
Instrução   | CMPI  |     BLE -3 (end. 6)   |   ADD R4,R3 (end. 3)  | ADD R3|
Estado      |   2   |   0   |   1   |   2   |   0   |   1   |   2   |   0   |
Ck          |‾‾‾|___|‾‾‾|___|‾‾‾|___|‾‾‾|___|‾‾‾|___|‾‾‾|___|‾‾‾|___|‾‾‾|___|
t (ns)      1850    1950    2050    2150    2250    2350    2450    2550    2650
pc_wr_en    ‾‾‾‾‾‾‾‾|_______________|‾‾‾‾‾‾‾|_______________|‾‾‾‾‾‾‾|________
            ____ ___ ___________________ ___ ___________________ ____________
pc_prox      6  X 7 X         3         X 0 X         4         X     5
            ‾‾‾‾ ‾‾‾ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾ ‾‾‾ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾ ‾‾‾‾‾‾‾‾‾‾‾‾
            ____ _______________________ _______________________ ____________
PC           5  X           6           X           3           X     4
            ‾‾‾‾ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾ ‾‾‾‾‾‾‾‾‾‾‾‾
            ________ _______________________ _______________________ ________
instrucao    0761D  X         0907D         X         038C0         X 03640
            ‾‾‾‾‾‾‾‾ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾ ‾‾‾‾‾‾‾‾
flags_wr_en ‾‾‾‾‾‾‾‾|_______________________________________|‾‾‾‾‾‾‾|________
            ________ _______________________________________________ ________
ZNCV          0000  X                     0110                      X  0000
            ‾‾‾‾‾‾‾‾ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾ ‾‾‾‾‾‾‾‾
banco_wr_en ________________________________________________|‾‾‾‾‾‾‾|________
            ________________________________________________________ ________
R4                                     0                            X   1
            ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾ ‾‾‾‾‾‾‾‾
```

| Tempo (ns) | Borda | Evento |
|---|---|---|
| 1900 | descida, estado 2 do CMPI | PC 5 → 6 (`pc_prox` = 5+1) |
| 1950 | subida, fim do CMPI | flags 0000 → 0110; a ROM lê ROM[6]: `instrucao` = 0x0907D (BLE −3); `pc_prox` = 6 + (−3) = 3 |
| 2050, 2150 | subidas, fim dos estados 0 e 1 | a ROM relê ROM[6]; nada muda; em 2150 `pc_wr_en` = 1 |
| 2200 | **descida, estado 2 do BLE** | PC 6 → 3; `pc_prox` passa a 3 + (−3) = 0, que não é gravado |
| 2250 | subida, fim do BLE | `pc_wr_en` = 0; flags inalteradas; a ROM lê ROM[3]: `instrucao` = 0x038C0 (ADD R4,R3). O endereço 7 não é lido |
| 2500 | descida, estado 2 do ADD | PC 3 → 4 |
| 2550 | subida, fim do ADD | R4 0 → 1; flags 0110 → 0000; `instrucao` = 0x03640 |

O desenho mostra o que muda com o Email 3: o PC troca na **descida** do meio do estado 2, meio clock antes de
banco e flags, e a instrução (saída da ROM) só muda na subida que encerra o estado 2.

## 7. Como rodar

```
cd lab6
./run.sh
```

O `processador_tb.gtkw` tem a lista de sinais do lab 5, na ordem do *µProcessador 5*: `reset`, `clk`,
`estado`, `pc`, `instrucao[16:0]` (hexa; é a saída da ROM, pois não há IR), `saida_ula` e `r0`..`r7`. Para ver
as flags, adicione no gtkwave `top.processador_tb.uut.flag_z_s`, `flag_n_s`, `flag_c_s`, `flag_v_s` e
`flags_wr_en_s`; para a temporização dos desvios, `pc_wr_en_s` e `pc_prox_s` (sinais internos do top-level;
não são pinos, para manter os pinos iguais aos do lab 5 como o PDF pede).
