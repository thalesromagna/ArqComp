# LOG

Fatos informados e marcos. Datas no formato AAAA-MM-DD.

- 2026-11-13: email do prof. Juliano com o sorteio da validação: "Contador com INC", "Tabela do crivo começa no endereço 48 da RAM" e "Instrução Halt ao final" (implementar dois dos três, à escolha). Pediu também um programa assembly que teste todas as instruções sorteadas no semestre.
- 2026-11-19: Vinícius (veterano) emprestou uma Sipeed Tang Nano 20K e enviou o projeto Gowin dele (`fpga_teste.zip`). Recomendações dele: alterar só os VHDL e os nomes de pinos no `pinout.cst`; gravar sempre na SRAM da placa, nunca na flash; usar dois displays de 7 segmentos e resistores de 330 ohms.
- 2026-11-20: decisão da equipe (Sergio): implementar os três itens da validação (INC, tabela no endereço 48 e HALT), além de tudo o que o roteiro do Lab 7 pede.
- 2026-11-20: Sergio pediu para tirar o item "Tabela do crivo começa no endereço 48"; ficam INC e HALT, e a tabela do crivo começa no endereço 0 (RAM[n] = n).
