Programa-teste do Lab 7 (uProcessador 7, secao "Testes"): RAM com LW Rd,(Rs) e SW Rd,(Rs)
Endereco da RAM = 7 bits menos significativos do registrador ponteiro Rs
Enderecos 44..127: NOP (0x00000)
Instrucao de 17 bits: opcode de 5 bits (b16..b12) e campos de 12 bits (b11..b0)

End  Passo  Assembly         Binario (17 bits)         Hex     Efeito
---  -----  ---------------  ------------------------  -----   ---------------------------
  0  E1     LD R1,45         00001 001 000101101       0122D   R1 = 45 (ponteiro)
  1  E1     LD R2,-123       00001 010 110000101       01585   R2 = -123 (0xFF85)
  2  E1     SW R2,(R1)       01100 010 001 000000      0C440   RAM[45] <- -123
  3  E2     LD R3,117        00001 011 001110101       01675   R3 = 117 (ponteiro)
  4  E2     LD R4,200        00001 100 011001000       018C8   R4 = 200
  5  E2     SW R4,(R3)       01100 100 011 000000      0C8C0   RAM[117] <- 200
  6  E3     LD R5,6          00001 101 000000110       01A06   R5 = 6 (ponteiro)
  7  E3     LD R6,-1         00001 110 111111111       01DFF   R6 = -1 (0xFFFF)
  8  E3     SW R6,(R5)       01100 110 101 000000      0CD40   RAM[6] <- 0xFFFF
  9  E4     LD R7,90         00001 111 001011010       01E5A   R7 = 90 (ponteiro)
 10  E4     LD R0,77         00001 000 001001101       0104D   R0 = 77
 11  E4     SW R0,(R7)       01100 000 111 000000      0C1C0   RAM[90] <- 77
 12  E5     SUB R6,R4        00100 110 100 000000      04D00   R6 = -1 - 200 = -201 (0xFF37)
 13  E5     ADD R1,R5        00011 001 101 000000      03340   R1 = 45 + 6 = 51 (ponteiro calculado)
 14  E5     SW R6,(R1)       01100 110 001 000000      0CC40   RAM[51] <- -201
 15  E6     LD R0,33         00001 000 000100001       01021   R0 = 33
 16  E6     SW R0,(R5)       01100 000 101 000000      0C140   RAM[6] <- 33 (sobrescreve 0xFFFF)
 17  Z      LD R2,0          00001 010 000000000       01400   apaga registradores de dados
 18  Z      LD R4,0          00001 100 000000000       01800
 19  Z      LD R6,0          00001 110 000000000       01C00
 20  Z      LD R0,0          00001 000 000000000       01000
 21  L1     LW R4,(R7)       01011 100 111 000000      0B9C0   R4 <- RAM[90] = 77
 22  L2     LW R6,(R3)       01011 110 011 000000      0BCC0   R6 <- RAM[117] = 200
 23  L3     LW R2,(R5)       01011 010 101 000000      0B540   R2 <- RAM[6] = 33
 24  L4     LW R0,(R1)       01011 000 001 000000      0B040   R0 <- RAM[51] = -201
 25  L5     LD R1,45         00001 001 000101101       0122D   R1 = 45
 26  L5     LW R7,(R1)       01011 111 001 000000      0BE40   R7 <- RAM[45] = -123
 27  V      LD R1,1          00001 001 000000001       01201   R1 = 1 (incremento)
 28  V      LD R3,100        00001 011 001100100       01664   R3 = 100 (ponteiro do vetor)
 29  V      LD R5,250        00001 101 011111010       01AFA   R5 = 250 (primeiro dado)
 30  V      LD R6,-13        00001 110 111110011       01DF3   R6 = -13 (passo do dado)
 31  V1     SW R5,(R3)       01100 101 011 000000      0CAC0   RAM[R3] <- R5
 32  V1     ADD R5,R6        00011 101 110 000000      03B80   R5 <- R5 - 13
 33  V1     ADD R3,R1        00011 011 001 000000      03640   R3 <- R3 + 1
 34  V1     CMPI R3,104      00111 011 001101000       07668   flags de R3 - 104
 35  V1     BLE -4           01001 00000 1111100       0907C   se R3 <= 104 volta para 31
 36  V      LD R3,100        00001 011 001100100       01664   R3 = 100
 37  V      LD R4,0          00001 100 000000000       01800   R4 = 0 (soma)
 38  V2     LW R2,(R3)       01011 010 011 000000      0B4C0   R2 <- RAM[R3]
 39  V2     ADD R4,R2        00011 100 010 000000      03880   R4 <- R4 + R2
 40  V2     ADD R3,R1        00011 011 001 000000      03640   R3 <- R3 + 1
 41  V2     CMPI R3,104      00111 011 001101000       07668   flags de R3 - 104
 42  V2     BLE -4           01001 00000 1111100       0907C   se R3 <= 104 volta para 38
 43  FIM    JMP 43           01000 00000 0101011       0802B   laco de parada (R4 = 1120)
