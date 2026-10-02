Programa-teste do Lab 5 (uProcessador 5, secao "Testes")
Equipe Thales e Sergio - ISA ortogonal, 8 registradores, ADD/SUB com 2 operandos
Enderecos 23..127: NOP (0x00000)
Instrucao de 17 bits: opcode de 5 bits (b16..b12) e campos de 12 bits (b11..b0)

End  Passo  Assembly          Binario (17 bits)          Hex     Efeito
---  -----  ----------------  -------------------------  -----   ---------------------------
 0   A      LD   R3,5         00001 011 000000101        01605   R3 <- 5
 1   B      LD   R4,8         00001 100 000001000        01808   R4 <- 8
 2   (aux)  LD   R1,1         00001 001 000000001        01201   R1 <- 1 (para o passo D; nao ha SUBI)
 3   C      MOV  R5,R3        00010 101 011 000000       02AC0   R5 <- R3
 4   C      ADD  R5,R4        00011 101 100 000000       03B00   R5 <- R5 + R4   (R5 = R3 + R4)
 5   D      SUB  R5,R1        00100 101 001 000000       04A40   R5 <- R5 - 1
 6   E      JMP  20           01000 00000 0010100        08014   PC <- 20
 7   F      LD   R5,0         00001 101 000000000        01A00   R5 <- 0 (nunca executada)
 8..19      NOP               00000 000000000000         00000   (enderecos vazios da ROM)
20   G      MOV  R3,R5        00010 011 101 000000       02740   R3 <- R5
21   H      JMP  3            01000 00000 0000011        08003   PC <- 3 (passo C)
22   I      LD   R3,0         00001 011 000000000        01600   R3 <- 0 (nunca executada)
