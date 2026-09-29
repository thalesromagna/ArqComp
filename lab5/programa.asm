Programa-teste do Lab 5 (uProcessador 5, secao "Testes")
Equipe Thales e Sergio - ISA ortogonal, 8 registradores, ADD/SUB com 2 operandos

End  Passo  Assembly          Binario (opcode campos)   Hex    Efeito
---  -----  ----------------  ------------------------  ----   ---------------------------
 0   A      LD   R3,5         0001 011 000000101        1605   R3 <- 5
 1   B      LD   R4,8         0001 100 000001000        1808   R4 <- 8
 2   (aux)  LD   R1,1         0001 001 000000001        1201   R1 <- 1 (para o passo D; nao ha SUBI)
 3   C      MOV  R5,R3        0010 101 011 000000       2AC0   R5 <- R3
 4   C      ADD  R5,R4        0011 101 100 000000       3B00   R5 <- R5 + R4   (R5 = R3 + R4)
 5   D      SUB  R5,R1        0100 101 001 000000       4A40   R5 <- R5 - 1
 6   E      JMP  20           1000 00000 0010100        8014   PC <- 20
 7   F      LD   R5,0         0001 101 000000000        1A00   R5 <- 0 (nunca executada)
 8..19      NOP               0000 000000000000         0000   (enderecos vazios da ROM)
20   G      MOV  R3,R5        0010 011 101 000000       2740   R3 <- R5
21   H      JMP  3            1000 00000 0000011        8003   PC <- 3 (passo C)
22   I      LD   R3,0         0001 011 000000000        1600   R3 <- 0 (nunca executada)
