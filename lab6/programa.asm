Programa-teste do Lab 6 (uProcessador 6, secao "Testes") + testes extras de desvios e flags
Equipe Thales e Sergio - saltos condicionais sorteados: BLE (Z=1 ou N/=V) e BVC (V=0)
Branches: PC <- PC + delta, PC = endereco do proprio branch, delta de 7 bits em complemento de 2
Enderecos 41..127: NOP (0x0000)

End  Passo  Assembly         Binario                  Hex    Efeito
---  -----  ---------------  -----------------------  ----   ---------------------------
  0  A      LD R3,0          0001 011 000000000       1600   R3 <- 0
  1  B      LD R4,0          0001 100 000000000       1800   R4 <- 0
  2  (aux)  LD R1,1          0001 001 000000001       1201   R1 <- 1 (nao ha ADDI)
  3  C      ADD R4,R3        0011 100 011 000000      38C0   R4 <- R4 + R3
  4  D      ADD R3,R1        0011 011 001 000000      3640   R3 <- R3 + 1
  5  E      CMPI R3,29       0111 011 000011101       761D   flags de R3 - 29
  6  E      BLE -3           1001 00000 1111101       907D   se R3 <= 29 (R3 < 30) volta para 3 (C)
  7  F      MOV R5,R4        0010 101 100 000000      2B00   R5 <- R4 (= 435)
  8  T1     LD R6,37         0001 110 000100101       1C25   teste menor de dois: R6 = 37
  9  T1     LD R7,-20        0001 111 111101100       1FEC   R7 = -20 (0xFFEC)
 10  T1     MOV R0,R6        0010 000 110 000000      2180   R0 <- R6 (candidato a menor)
 11  T1     CMPR R6,R7       0110 110 111 000000      6DC0   37-(-20)=57: Z=0 N=0 V=0 C=1
 12  T1     BLE 2            1001 00000 0000010       9002   nao salta (R6 > R7)
 13  T1     MOV R0,R7        0010 000 111 000000      21C0   R0 <- -20 (menor)
 14  T2     LD R6,-90        0001 110 110100110       1DA6   R6 = -90 (0xFFA6)
 15  T2     LD R7,12         0001 111 000001100       1E0C   R7 = 12
 16  T2     MOV R2,R6        0010 010 110 000000      2580   R2 <- R6 (candidato a menor)
 17  T2     CMPR R6,R7       0110 110 111 000000      6DC0   -90-12=-102: Z=0 N=1 V=0 C=0
 18  T2     BLE 2            1001 00000 0000010       9002   salta para 20 (R6 <= R7)
 19  T2     MOV R2,R7        0010 010 111 000000      25C0   pulada
 20  T3     LD R6,-256       0001 110 100000000       1D00   R6 = 0xFF00
 21  T3     ADD R6,R6        0011 110 110 000000      3D80   0xFE00
 22  T3     ADD R6,R6        0011 110 110 000000      3D80   0xFC00
 23  T3     ADD R6,R6        0011 110 110 000000      3D80   0xF800
 24  T3     ADD R6,R6        0011 110 110 000000      3D80   0xF000
 25  T3     ADD R6,R6        0011 110 110 000000      3D80   0xE000
 26  T3     ADD R6,R6        0011 110 110 000000      3D80   0xC000
 27  T3     ADD R6,R6        0011 110 110 000000      3D80   0x8000: C=1 V=0 N=1
 28  T3     BVC 2            1010 00000 0000010       A002   V=0: salta para 30
 29  T3     LD R7,-1         0001 111 111111111       1FFF   pulada
 30  T4     SUB R6,R1        0100 110 001 000000      4C40   0x8000-1=0x7FFF: V=1 C=0 N=0
 31  T4     BVC 2            1010 00000 0000010       A002   V=1: nao salta
 32  T4     LD R7,77         0001 111 001001101       1E4D   executada (prova que nao saltou)
 33  T5     LD R6,200        0001 110 011001000       1CC8   R6 = 200
 34  T5     SUBB R6,R7       0101 110 111 000000      5DC0   C=0: R6 <- 200-77-0 = 123
 35  T5     CMPI R6,124      0111 110 001111100       7C7C   123-124=-1: C=1 N=1 Z=0 V=0
 36  T5     SUBB R6,R7       0101 110 111 000000      5DC0   C=1: R6 <- 123-77-1 = 45
 37  T6     CMPI R6,45       0111 110 000101101       7C2D   Z=1
 38  T6     BLE 2            1001 00000 0000010       9002   Z=1: salta para 40
 39  T6     LD R6,0          0001 110 000000000       1C00   pulada
 40  FIM    JMP 40           1000 00000 0101000       8028   laco de parada
