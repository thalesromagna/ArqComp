; crivo.asm - Crivo de Eratostenes (validacao do lab 7)
; tabela na RAM a partir do endereco 0: RAM[n] = n, n = 1..32 (endereco = numero)
; registradores: r1 = contador (INC) e ponteiro, r3 = ponteiro da leitura (INC),
; r4 = multiplo m, r5 = valor lido, r6 = zero, r7 = saida (so primos)

        ld r1, 1            ; n = 1
preenche:
        sw r1, (r1)         ; RAM[n] = n
        inc r1              ; n++
        cmpi r1, 32         ; n - 32
        ble preenche        ; repete enquanto n <= 32

        ld r1, 2            ; p = 2
        ld r6, 0            ; r6 = 0 (valor para riscar)
proximo_p:
        lw r5, (r1)         ; r5 = RAM[p]
        cmpi r5, 0
        ble avanca_p        ; ja riscado (Z=1): nao e primo, pula
        mov r4, r1
        add r4, r1          ; m = 2p
        jmp testa_m
risca:
        sw r6, (r4)         ; RAM[m] = 0
        add r4, r1          ; m = m + p
testa_m:
        cmpi r4, 32         ; m - 32
        ble risca           ; risca enquanto m <= 32
avanca_p:
        inc r1              ; p++
        cmpi r1, 32         ; p - 32
        ble proximo_p       ; tenta todos os p ate 32

        ld r3, 2            ; ponteiro = 2
le:
        lw r5, (r3)         ; r5 = RAM[ponteiro]
        cmpi r5, 0
        ble nao_primo       ; zero (Z=1): riscado
        mov r7, r5          ; r7 = primo
nao_primo:
        inc r3              ; ponteiro++
        cmpi r3, 32         ; ponteiro - 32
        ble le              ; repete enquanto ponteiro <= 32
        halt
