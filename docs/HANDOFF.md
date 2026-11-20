# HANDOFF — retomada da próxima sessão

Lab 7 (RAM + validação + programa de todas as instruções) implementado e verificado em simulação
na branch local `lab7-validacao`, a partir da `origin/main` do Thales. Nada commitado.

## Prompt de retomada

Leia primeiro, nesta ordem: docs/HANDOFF.md, docs/LOG.md, docs/lab7.md, docs/fpga-tang-nano-20k.md
Fronteira: só este repositório; não commitar nem dar push sem pedido explícito do Sergio; não gravar na flash da placa.
Próximo passo: o Sergio decide se commita a branch `lab7-validacao` e como integrar com o Thales; depois sintetiza no Gowin e testa na placa (pronto = primos 2..31 nos displays).

## Pendências que dependem de decisão
- Commit/push da branch e integração com o Thales (combinar com ele para não duplicar trabalho).
- [VALIDAR] com o professor: opcode 1110 sem uso agir como NOP não conta como "instrução extra".
- [VALIDAR] com o professor: "processador escolhido" = RISC-V (base das páginas do manual de LW/SW).

## Pendências que dependem da placa
- Gowin EDA Education (Windows) ainda não instalado; síntese no Gowin nunca rodou (só `ghdl --synth`).
- Montagem física (displays anodo comum, 14 resistores 330 ohms) e gravação na SRAM não testadas.

## Fatos para não re-descobrir
- `ghdl` não está instalado no sistema: nas sessões de IA usou-se um ghdl 4.1 extraído do .deb no
  scratchpad. Para o Sergio rodar: `sudo apt install ghdl gtkwave` e depois `sh micro_processador/run.sh [teste_ram|instrucoes]`.
- `ghdl --std=93` estrito não liga componentes a entidades; usar o padrão (93c).
- `src/processador/` da FPGA é versionado; atualizar com `sh fpga/sincronizar.sh` sempre que mudar o processador.
- Os `.esperado` são gerados pelo simulador Python (`programas/montador.py`), não à mão.
