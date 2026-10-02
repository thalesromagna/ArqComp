Programa-teste do Lab 6 (uProcessador 6, secao "Testes") + testes extras de desvios e flags
Equipe Thales e Sergio - saltos condicionais sorteados: BLE (Z=1 ou N/=V) e BVC (V=0)
Branches: PC <- PC + delta, PC = endereco do proprio branch, delta de 7 bits em complemento de 2
Enderecos 41..127: NOP (0x00000)
Instrucao de 17 bits: opcode de 5 bits (b16..b12) e campos de 12 bits (b11..b0)

End  Passo  Assembly         Binario (17 bits)        Hex    Efeito
---  -----  ---------------  -----------------------  -----  ---------------------------
  0  A      LD R3,0          00001 011 000000000      01600  R3 <- 0
  1  B      LD R4,0          00001 100 000000000      01800  R4 <- 0
  2  (aux)  LD R1,1          00001 001 000000001      01201  R1 <- 1 (nao ha ADDI)
  3  C      ADD R4,R3        00011 100 011 000000     038C0  R4 <- R4 + R3
  4  D      ADD R3,R1        00011 011 001 000000     03640  R3 <- R3 + 1
  5  E      CMPI R3,29       00111 011 000011101      0761D  flags de R3 - 29
  6  E      BLE -3           01001 00000 1111101      0907D  se R3 <= 29 (R3 < 30) volta para 3 (C)
  7  F      MOV R5,R4        00010 101 100 000000     02B00  R5 <- R4 (= 435)
  8  T1     LD R6,37         00001 110 000100101      01C25  teste menor de dois: R6 = 37
  9  T1     LD R7,-20        00001 111 111101100      01FEC  R7 = -20 (0xFFEC)
 10  T1     MOV R0,R6        00010 000 110 000000     02180  R0 <- R6 (candidato a menor)
 11  T1     CMPR R6,R7       00110 110 111 000000     06DC0  37-(-20)=57: Z=0 N=0 V=0 C=1
 12  T1     BLE 2            01001 00000 0000010      09002  nao salta (R6 > R7)
 13  T1     MOV R0,R7        00010 000 111 000000     021C0  R0 <- -20 (menor)
 14  T2     LD R6,-90        00001 110 110100110      01DA6  R6 = -90 (0xFFA6)
 15  T2     LD R7,12         00001 111 000001100      01E0C  R7 = 12
 16  T2     MOV R2,R6        00010 010 110 000000     02580  R2 <- R6 (candidato a menor)
 17  T2     CMPR R6,R7       00110 110 111 000000     06DC0  -90-12=-102: Z=0 N=1 V=0 C=0
 18  T2     BLE 2            01001 00000 0000010      09002  salta para 20 (R6 <= R7)
 19  T2     MOV R2,R7        00010 010 111 000000     025C0  pulada
 20  T3     LD R6,-256       00001 110 100000000      01D00  R6 = 0xFF00
 21  T3     ADD R6,R6        00011 110 110 000000     03D80  0xFE00
 22  T3     ADD R6,R6        00011 110 110 000000     03D80  0xFC00
 23  T3     ADD R6,R6        00011 110 110 000000     03D80  0xF800
 24  T3     ADD R6,R6        00011 110 110 000000     03D80  0xF000
 25  T3     ADD R6,R6        00011 110 110 000000     03D80  0xE000
 26  T3     ADD R6,R6        00011 110 110 000000     03D80  0xC000
 27  T3     ADD R6,R6        00011 110 110 000000     03D80  0x8000: C=1 V=0 N=1
 28  T3     BVC 2            01010 00000 0000010      0A002  V=0: salta para 30
 29  T3     LD R7,-1         00001 111 111111111      01FFF  pulada
 30  T4     SUB R6,R1        00100 110 001 000000     04C40  0x8000-1=0x7FFF: V=1 C=0 N=0
 31  T4     BVC 2            01010 00000 0000010      0A002  V=1: nao salta
 32  T4     LD R7,77         00001 111 001001101      01E4D  executada (prova que nao saltou)
 33  T5     LD R6,200        00001 110 011001000      01CC8  R6 = 200
 34  T5     SUBB R6,R7       00101 110 111 000000     05DC0  C=0: R6 <- 200-77-0 = 123
 35  T5     CMPI R6,124      00111 110 001111100      07C7C  123-124=-1: C=1 N=1 Z=0 V=0
 36  T5     SUBB R6,R7       00101 110 111 000000     05DC0  C=1: R6 <- 123-77-1 = 45
 37  T6     CMPI R6,45       00111 110 000101101      07C2D  Z=1
 38  T6     BLE 2            01001 00000 0000010      09002  Z=1: salta para 40
 39  T6     LD R6,0          00001 110 000000000      01C00  pulada
 40  FIM    JMP 40           01000 00000 0101000      08028  laco de parada
