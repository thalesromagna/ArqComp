; teste_ram.asm - teste da RAM (lab 7)
; fase 1: todas as escritas (enderecos espalhados, dado nunca igual ao endereco)
; fase 2: leituras em outra ordem, com outros ponteiros e outros destinos
; fase 3: soma de um vetor com ponteiro incrementado por INC
; r7 so recebe valores lidos ou resultados: 200, 177, 45, 77, 9, -123, -50, 120, 85

        ld r0, 50
        add r0, r0          ; r0 = 100 (endereco > 63)
        ld r1, 40
        ld r5, 37
        add r1, r5          ; r1 = 77
        sw r1, (r0)         ; RAM[100] = 77
        ld r2, 5            ; r2 = 5
        ld r3, -23          ; r3 = -23
        sw r3, (r2)         ; RAM[5] = -23 (sera sobrescrito)
        ld r4, 37           ; r4 = 37
        ld r5, 50
        add r5, r5
        add r5, r5          ; r5 = 200
        sw r5, (r4)         ; RAM[37] = 200
        ld r6, 45
        add r6, r6          ; r6 = 90
        sub r1, r5          ; r1 = 77 - 200 = -123
        sw r1, (r6)         ; RAM[90] = -123
        ld r2, 63
        add r2, r2
        inc r2              ; r2 = 127
        add r3, r5          ; r3 = -23 + 200 = 177
        sw r3, (r2)         ; RAM[127] = 177
        ld r4, 32
        add r4, r4          ; r4 = 64
        ld r0, 9            ; r0 = 9
        sw r0, (r4)         ; RAM[64] = 9
        ld r6, 5            ; r6 = 5
        ld r5, 45           ; r5 = 45
        sw r5, (r6)         ; RAM[5] = 45 (sobrescreve -23)
        ld r3, 33           ; r3 = 33 (difere de 37 so no bit 2 do endereco)
        ld r4, -50          ; r4 = -50
        sw r4, (r3)         ; RAM[33] = -50
        ld r0, 32
        add r0, r0
        ld r2, 37
        add r0, r2          ; r0 = 101 (difere de 37 so no bit 6 do endereco)
        ld r1, 60
        add r1, r1          ; r1 = 120
        sw r1, (r0)         ; RAM[101] = 120

        ld r1, 63
        ld r2, 8
        add r1, r2          ; r1 = 71 (inicio do vetor)
        ld r3, 12
        sw r3, (r1)         ; RAM[71] = 12
        inc r1              ; r1 = 72
        ld r4, -7
        sw r4, (r1)         ; RAM[72] = -7
        inc r1              ; r1 = 73
        ld r0, 30
        sw r0, (r1)         ; RAM[73] = 30
        inc r1              ; r1 = 74
        ld r6, 50
        sw r6, (r1)         ; RAM[74] = 50

        ld r6, 37           ; ponteiro r6 = 37
        lw r0, (r6)         ; r0 = RAM[37] = 200
        mov r7, r0          ; r7 = 200
        ld r1, 63
        add r1, r1
        inc r1              ; r1 = 127
        lw r4, (r1)         ; r4 = RAM[127] = 177
        mov r7, r4          ; r7 = 177
        ld r3, 5            ; ponteiro r3 = 5
        lw r7, (r3)         ; r7 = RAM[5] = 45 (sobrescrita conferida; -23 seria erro)
        ld r2, 50
        add r2, r2          ; r2 = 100
        lw r5, (r2)         ; r5 = RAM[100] = 77
        mov r7, r5          ; r7 = 77
        ld r5, 32
        add r5, r5          ; r5 = 64
        lw r6, (r5)         ; r6 = RAM[64] = 9
        mov r7, r6          ; r7 = 9
        ld r0, 45
        add r0, r0          ; r0 = 90
        lw r7, (r0)         ; r7 = RAM[90] = -123
        ld r4, 33           ; ponteiro r4 = 33
        lw r1, (r4)         ; r1 = RAM[33] = -50 (bit 2 do endereco travado daria 200 aqui ou -50 em RAM[37])
        mov r7, r1          ; r7 = -50
        ld r6, 32
        add r6, r6
        ld r5, 37
        add r6, r5          ; ponteiro r6 = 101
        lw r2, (r6)         ; r2 = RAM[101] = 120 (bit 6 do endereco travado daria 200 aqui ou 120 em RAM[37])
        mov r7, r2          ; r7 = 120

        ld r0, 0            ; soma = 0
        ld r1, 63
        ld r2, 8
        add r1, r2          ; ponteiro r1 = 71
        ld r2, 3
        add r2, r1          ; ultimo endereco r2 = 74
soma:
        lw r3, (r1)         ; r3 = RAM[ponteiro]
        add r0, r3          ; soma = soma + r3
        inc r1              ; ponteiro++
        cmpr r1, r2         ; ponteiro - 74
        ble soma            ; repete enquanto ponteiro <= 74
        mov r7, r0          ; r7 = 12 - 7 + 30 + 50 = 85
        halt
