# ArqComp — µProcessador em VHDL

Arquitetura de Computadores — UTFPR / DAELN — prof. Juliano. Equipe: Thales e Sergio.

Processador com dados de 16 bits e instruções de 17 bits, 8 registradores, ISA ortogonal com 2 operandos,
saltos condicionais BLE e BVC, ROM síncrona, PC na borda de descida e sem registrador de instrução,
feito em sete laboratórios. As características sorteadas e a codificação das instruções estão em
[`docs/00-especificacoes.md`](docs/00-especificacoes.md).

## Estrutura

| Diretório | Conteúdo | Documentação |
|---|---|---|
| `lab1/` | Tutorial VHDL: porta AND, decoder 2x4, detector de paridade | [`docs/lab1.md`](docs/lab1.md) |
| `lab2/` | Mux 8x1, soma_e_subtrai e **ULA** com flags Z, N, C, V | [`docs/lab2.md`](docs/lab2.md) |
| `lab3/` | Registrador de 16 bits, **banco de 8 registradores** e ligação com a ULA | [`docs/lab3.md`](docs/lab3.md) |
| `lab4/` | ROM, PC, máquina de estados e **unidade de controle** com JMP | [`docs/lab4.md`](docs/lab4.md) |
| `lab5/` | **Calculadora programável**: LD, MOV, ADD, SUB, JMP | [`docs/lab5.md`](docs/lab5.md) |
| `lab6/` | **Condicionais**: SUBB, CMPR, CMPI, BLE, BVC e flip-flops das flags | [`docs/lab6.md`](docs/lab6.md) |
| `lab7/` | **Memória de dados**: RAM com LW/SW por ponteiro | [`docs/lab7.md`](docs/lab7.md) |
| `PDF dos labs/` | Roteiros dos labs 1 a 7, instruções da FPGA e o documento *Características do Projeto do µP* (arquivo `6996-EncargosdeIRRF-082026.pdf`) | |
| `Materiais teóricos/` | Livro Patterson & Hennessy (RISC-V Edition), slides e listas de assembly | |

Cada diretório de lab é autocontido: todos os `.vhd` usados estão dentro dele.

## Como simular

Requer `ghdl` e `gtkwave`. Dentro do diretório do lab:

```sh
sh run.sh
```

## Pendências

- Validação (crivo de Eratóstenes): aguardando o sorteio dos itens de final de loop e complicação.
- Extra da FPGA (primos nos displays da DE10-Lite): depende da validação e dos arquivos do professor
  (RAMDisp.vhd, projeto Quartus).

Detalhes em [`docs/00-especificacoes.md`](docs/00-especificacoes.md), seção 2.
