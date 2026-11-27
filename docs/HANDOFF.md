# HANDOFF — retomada da próxima sessão

Lab 7 completo e no GitHub (branch `lab7-validacao`, último push `f4a38f7`), com as variantes de 2 displays
e de 4 dígitos e o guia para o Thales (`docs/tang_nano_20k_do_zero.pdf`). Placa testada na SRAM em 2026-11-23:
dezenas OK (apagado, 1, 2, 3); display das unidades (5161AS) apagado, provável comum fora do GND.

## Prompt de retomada

Leia primeiro, nesta ordem: docs/HANDOFF.md, docs/LOG.md, docs/fpga-tang-nano-20k.md (seções 3, 6 e 9), docs/lab7.md
Fronteira: só este repositório; commit/push só com pedido do Sergio; gravar a placa só na SRAM (`openFPGALoader -m`, nunca `-f`).
Próximo passo: resolver o display das unidades (comum no GND, trilho dividido, teste do segmento c) e regravar (pronto = 2 a 31 aparecendo e parando no 31).

## Não commitado
- Só `docs/LOG.md` e este HANDOFF.

## Como rodar
- Gerar e gravar: `sh fpga/tang_nano_20k/fluxo_aberto.sh gravar` (2 displays) ou `... 4dig gravar`.
- A cada reconexão USB: `"/mnt/c/Program Files/usbipd-win/usbipd.exe" attach --wsl --busid <BUSID>` (era 1-6, depois 1-1; confira com `usbipd list`)
  (bind e regra udev `/etc/udev/rules.d/99-tangnano20k.rules` já feitos).
- Testbenches: `PATH=$HOME/.local/opt/oss-cad-suite/bin:$PATH sh fpga/tang_nano_20k/tb/run_tb.sh real`
  (o ghdl do oss-cad-suite precisa de `zlib1g-dev`, ainda não instalado nesta máquina; ou `sudo apt install ghdl`).

## Material (fatos do Sergio, ver LOG)
- Displays: 5161BS (anodo, dezenas), 5161AS (catodo, unidades), 5641AS (4 dígitos, catodo).
- Muitos resistores de 330 ohms; protoboard conseguida em 2026-11-23.

## Pendências
- [VALIDAR] pinagem das pernas (5161 e 5641AS) com o teste do guia antes de ligar tudo.
- [VALIDAR] Gowin IDE aceita o componente `BUFG` (só o fluxo aberto foi testado).
- [VALIDAR] com o professor: opcode 1110 como NOP não conta como instrução extra; "processador escolhido" = RISC-V.
- Integrar com o Thales (merge ou PR de `lab7-validacao` para `main`).
