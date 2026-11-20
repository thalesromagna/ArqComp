; instrucoes.asm - verificacao de todas as instrucoes (lab 7)
; checkpoints em r7: 25, -40, -15, 45, 13, 7, 8, 2, 3, 1024, 1025, -9
; caminho que nao deveria executar escreve a armadilha -1 em r7

        nop                     ; nada muda
        ld r1, 25               ; r1 = 25 (LD positiva)
        mov r7, r1              ; r7 = 25 (MOV)
        ld r2, -40              ; r2 = -40 (LD negativa)
        mov r7, r2              ; r7 = -40
        add r1, r2              ; r1 = 25 + (-40) = -15
        mov r7, r1              ; r7 = -15 (ADD)
        ld r3, 30               ; r3 = 30
        sub r3, r1              ; r3 = 30 - (-15) = 45
        mov r7, r3              ; r7 = 45 (SUB)
        ld r4, 3                ; r4 = 3
        ld r5, 8                ; r5 = 8
        sub r4, r5              ; r4 = 3 - 8 = -5, C=1 (3 < 8 sem sinal)
        ld r6, 20               ; r6 = 20 (LD nao altera flags)
        ld r0, 6                ; r0 = 6
        subb r6, r0             ; r6 = 20 - 6 - 1 = 13 (SUBB com C=1), gera C=0
        mov r7, r6              ; r7 = 13
        subb r6, r0             ; r6 = 13 - 6 - 0 = 7 (SUBB com C=0)
        mov r7, r6              ; r7 = 7
        .word 0x1DC81           ; opcode 1110 nao usado (bits de "r7, r1, 1"): deve agir como NOP
        cmpi r6, 7              ; 7 - 7 = 0: Z=1 (CMPI)
        inc r6                  ; r6 = 8, flags continuam Z=1 (INC nao altera flags)
        ble ok_z                ; tomado por Z=1
        ld r7, -1               ; armadilha
ok_z:
        mov r7, r6              ; r7 = 8 (INC)
        cmpr r2, r1             ; -40 - (-15) = -25: Z=0, N=1, V=0 (CMPR)
        ble ok_nv               ; tomado por N!=V
        ld r7, -1               ; armadilha
ok_nv:
        ld r7, 2                ; r7 = 2
        cmpi r1, -20            ; -15 - (-20) = 5: Z=0, N=0, V=0
        ble armadilha_ble       ; nao tomado
        ld r7, 3                ; r7 = 3
        jmp depois_ble          ; JMP absoluto pula a armadilha
armadilha_ble:
        ld r7, -1               ; armadilha
depois_ble:
        ld r5, -63              ; r5 = -63
dobra:
        add r5, r5              ; r5 = 2 * r5: -126 ... -32256, na 10a vez 1024 com V=1
        bvc dobra               ; tomado 9 vezes (V=0), nao tomado na 10a (V=1)
        mov r7, r5              ; r7 = 1024
        inc r5                  ; r5 = 1025, flags continuam Z=0 N=0 V=1
        bvc armadilha_inc       ; nao tomado (V=1)
        ble ok_v                ; tomado por N!=V (N=0, V=1)
armadilha_inc:
        ld r7, -1               ; armadilha
ok_v:
        mov r7, r5              ; r7 = 1025
        ld r4, 60
        add r4, r4              ; r4 = 120 (endereco)
        ld r0, -9               ; r0 = -9
        sw r0, (r4)             ; RAM[120] = -9 (SW)
        ld r0, 0                ; r0 = 0 (o valor so pode vir da RAM)
        lw r7, (r4)             ; r7 = -9 (LW)
        halt                    ; para aqui
        ld r7, -1               ; armadilha: so executa se o HALT falhar
