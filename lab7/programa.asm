Programa-teste do Lab 7 (uProcessador 7, secao "Testes"): RAM com LW Rd,(Rs) e SW Rd,(Rs)
Endereco da RAM = 7 bits menos significativos do registrador ponteiro Rs
Enderecos 44..127: NOP (0x0000)

End  Passo  Assembly         Binario                  Hex    Efeito
---  -----  ---------------  -----------------------  ----   ---------------------------
  0  E1     LD R1,45         0001 001 000101101       122D   R1 = 45 (ponteiro)
  1  E1     LD R2,-123       0001 010 110000101       1585   R2 = -123 (0xFF85)
  2  E1     SW R2,(R1)       1100 010 001 000000      C440   RAM[45] <- -123
  3  E2     LD R3,117        0001 011 001110101       1675   R3 = 117 (ponteiro)
  4  E2     LD R4,200        0001 100 011001000       18C8   R4 = 200
  5  E2     SW R4,(R3)       1100 100 011 000000      C8C0   RAM[117] <- 200
  6  E3     LD R5,6          0001 101 000000110       1A06   R5 = 6 (ponteiro)
  7  E3     LD R6,-1         0001 110 111111111       1DFF   R6 = -1 (0xFFFF)
  8  E3     SW R6,(R5)       1100 110 101 000000      CD40   RAM[6] <- 0xFFFF
  9  E4     LD R7,90         0001 111 001011010       1E5A   R7 = 90 (ponteiro)
 10  E4     LD R0,77         0001 000 001001101       104D   R0 = 77
 11  E4     SW R0,(R7)       1100 000 111 000000      C1C0   RAM[90] <- 77
 12  E5     SUB R6,R4        0100 110 100 000000      4D00   R6 = -1 - 200 = -201 (0xFF37)
 13  E5     ADD R1,R5        0011 001 101 000000      3340   R1 = 45 + 6 = 51 (ponteiro calculado)
 14  E5     SW R6,(R1)       1100 110 001 000000      CC40   RAM[51] <- -201
 15  E6     LD R0,33         0001 000 000100001       1021   R0 = 33
 16  E6     SW R0,(R5)       1100 000 101 000000      C140   RAM[6] <- 33 (sobrescreve 0xFFFF)
 17  Z      LD R2,0          0001 010 000000000       1400   apaga registradores de dados
 18  Z      LD R4,0          0001 100 000000000       1800
 19  Z      LD R6,0          0001 110 000000000       1C00
 20  Z      LD R0,0          0001 000 000000000       1000
 21  L1     LW R4,(R7)       1011 100 111 000000      B9C0   R4 <- RAM[90] = 77
 22  L2     LW R6,(R3)       1011 110 011 000000      BCC0   R6 <- RAM[117] = 200
 23  L3     LW R2,(R5)       1011 010 101 000000      B540   R2 <- RAM[6] = 33
 24  L4     LW R0,(R1)       1011 000 001 000000      B040   R0 <- RAM[51] = -201
 25  L5     LD R1,45         0001 001 000101101       122D   R1 = 45
 26  L5     LW R7,(R1)       1011 111 001 000000      BE40   R7 <- RAM[45] = -123
 27  V      LD R1,1          0001 001 000000001       1201   R1 = 1 (incremento)
 28  V      LD R3,100        0001 011 001100100       1664   R3 = 100 (ponteiro do vetor)
 29  V      LD R5,250        0001 101 011111010       1AFA   R5 = 250 (primeiro dado)
 30  V      LD R6,-13        0001 110 111110011       1DF3   R6 = -13 (passo do dado)
 31  V1     SW R5,(R3)       1100 101 011 000000      CAC0   RAM[R3] <- R5
 32  V1     ADD R5,R6        0011 101 110 000000      3B80   R5 <- R5 - 13
 33  V1     ADD R3,R1        0011 011 001 000000      3640   R3 <- R3 + 1
 34  V1     CMPI R3,104      0111 011 001101000       7668   flags de R3 - 104
 35  V1     BLE -4           1001 00000 1111100       907C   se R3 <= 104 volta para 31
 36  V      LD R3,100        0001 011 001100100       1664   R3 = 100
 37  V      LD R4,0          0001 100 000000000       1800   R4 = 0 (soma)
 38  V2     LW R2,(R3)       1011 010 011 000000      B4C0   R2 <- RAM[R3]
 39  V2     ADD R4,R2        0011 100 010 000000      3880   R4 <- R4 + R2
 40  V2     ADD R3,R1        0011 011 001 000000      3640   R3 <- R3 + 1
 41  V2     CMPI R3,104      0111 011 001101000       7668   flags de R3 - 104
 42  V2     BLE -4           1001 00000 1111100       907C   se R3 <= 104 volta para 38
 43  FIM    JMP 43           1000 00000 0101011       802B   laco de parada (R4 = 1120)
