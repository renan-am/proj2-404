
@ Este arquivo é segmentado 4 partes (questão de legibilidade)
@   * Seção para declaração de contantes    : Onde as contantes são declaradas
@   * Seção do vetor de interrupções        : Código referente ao vetor de interrupções
@   * Seção de texto                        : Onde as rotinas são escritas
@   * Seção de dados                        : Onde são adicionadas as variáveis (.word, .skip) utilizadas neste arquivo


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@      Seção de Constantes/Defines           @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ Constantes para os Modos de operação do Processador, utilizados para trocar entre modos de operação (5 bits menos significativos)
        .set MODE_USER,                 0x10
        @ Você pode definir as outras....
@    .set MODE_IRQ,                  0xxx
@    .set MODE_SUPERVISOR,           0xxx
@    .set MODE_SYSTEM,               0xxx

@ Constantes referentes aos endereços
    .set USER_ADDRESS,              0x77812000      @ Endereço do código de usuário
    .set STACK_POINTER_IRQ,         0x7E000000      @ Endereço inicial da pilha do modo IRQ
    .set STACK_POINTER_SUPERVISOR,  0x7F000000      @ Endereço inicial da pilha do modo Supervisor
    .set STACK_POINTER_USER,                0x80000000      @ Endereço inicial da pilha do modo Usuário

@ Constantes Referentes ao TZIC
    .set TZIC_BASE,                 0x0FFFC000
    .set TZIC_INTCTRL,              0x00
    .set TZIC_INTSEC1,              0x84
    .set TZIC_ENSET1,               0x104
    .set TZIC_PRIOMASK,             0x0C
    .set TZIC_PRIORITY9,            0x424

@ Constantes Referentes ao GPT
    .set GPT_CR,        0x53FA0000
    .set GPT_PR,        0x53FA0004
    .set GPT_OCR1,      0x53FA0010
    .set GPT_IR,        0x53FA000C
    .set GPT_SR,        0x53FA0008
    @ verificar o valor plausivel para TIME_SZ
    .set TIME_SZ,   0x5

@ Constantes Referentes ao GPIO
    .set DR,    0x53F84000
    .set GDIR,  0x53F84004
    .set PSR,   0x53F84008




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@      Seção do Vetor de Interrupções        @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Este vetor possui entradas das rotinas para o tratamento de cada tipo de interrupção
.align 4
.org 0x0                    @ 0x0 --> salto para rotina de tratamento do RESET
.section .iv,"a"
_start:
interrupt_vector:
    b reset_handler        @ Rotina utilizada para interrupção RESET

.org 0x08                  @ 0x8 --> salto para rotina de tratamento de syscalls (interrupções svc)
    b svc_handler          @ Rotina utilizada para interrupção SVC

.org 0x18                  @ 0x18 --> salto para rotina de tratamento de interrupções do tipo IRQ
    b irq_handler          @ Rotina utilizada para interrupção IRQ (GPT, ...)



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@                     Seção de Texto               @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.org 0x100
.text

@ Rotina de tratamento da interrupção RESET.
@ Esta rotina é unicamente invocada assim que o processador é iniciado (interrupção reset). O processador é iniciado no modo de operação de sistema, com as flags zeradas e as INTERRUPÇÕES DESABILITADAS!
@ Esta rotina é utilizada para configurar todo o sistema, antes de executar o código de usuário (ronda, segue-parede), que esta localizado em USER_ADDRESS.
@ Uma vez que o código de usuário é executado, syscalls são utilizadas para voltar aos modo de operação de sistema.
@
@ Essa rotina deve configurar:
@   1)  Inicializar o contador de tempo (variável contador) e o endereço base do vetor de interrupções no coprocessador p15    -- (OK)
@
@   2)  Inicializar as pilhas dos modos de operação
@          * Alterar o registrador sp, dos modos IRQ e SVC (cada modo tem seus próprios registradores!), com endereços definidos. Assim, sempre que chavearmos de modo, este tera um endereço para sua pilha, separadamente.
@          * Lembre-se que, o registrador CPRS (que pode ser acessado por instruções mrs/msr) contém o modo de operação atual do processador. Para trocar de modo, basta escrever os bits referentes ao novo modo, no CPRS. Apenas o modo de operação USER possui restrições quanto a escrever no CPRS. Para retornar a um modo de operação de sistema, o usuário deve realizar uma syscall (que é tratada pelo svc_handler)
@
@   3)  Configurar os dispositivos:
@          * Configurar o GPT para gerar uma interrupção do tipo IRQ (que será tratada por irq_handler) assim que o contador atingir um valor definido. O GPT é um contador de propósito geral e deve-se configurar a frequencia e o valor que será contado. Cada interrupção gerada deste contador representa uma unidade de tempo do seu sistema (quanto mais alto ou baixo o valor de contagem, seu tempo passará mais rapído ou devagar)
@          * Configurar GPIO: Definir em GDIR quais portas do GPIO são de entrada e saída.
@
@   4)  Configurar o TZIC (Controlador de Interrupções)         -- (OK)
@          * Após configurar as interrupções dos dispositivos, a configuração do TZIC deve ser realizada para permitir que as interrupções dos periféricos cheguem a CPU.
@          * Nesta parte, estamos cadastrando as interrupcões do GPT como habilitadas para o TZIC
@
@   5)  Habilitar interrupções e executar o código do usuário
@           * Uma vez que o sistema foi configurado, devemos executar (saltar para) o código do usuário (segue-parede/ronda), que esta localizado em USER_ADDRESS
@           * Lembre-se também de habilitar as interrupções antes de executar o código usuário. Para habilitar as interrupções escreva nos bits do CPRS (bit de IRQ e FIQ. Feito isso, as interrupções cadastradas no TZIC irão interromper o processador, que irá parar o que estiver fazendo, chavear de modo e executar a rotina de tratamento adequada para cada interrupção.
@           * Uma vez que o código de usuário é executado, a rotina reset_handler não é mais usada (até reinicar). Apenas as rotinas irq_handler (para interrupções do GPT) e svc_handler (para syscalls feitas pelo usuário) são utilizadas.

reset_handler:
@   1) ----------- Inicialização do contador e do IV -------------------------
    @ zera contador de tempo
    mov r0, #0
    ldr r1, =counter
    str r0, [r1]
    @Faz o registrador que aponta para a tabela de interrupções apontar para a tabela interrupt_vector
    ldr r0, =interrupt_vector @ carrega vetor de interrupcoes
    mcr p15, 0, r0, c12, c0, 0 @ no co-processador 15

@   2) ----------- Inicialização das pilhas modos de operação  ---------------
    @ Você pode inicializar as pilhas aqui (ou, pelo menos, antes de executar o código do usuário)

    ldr sp, =STACK_POINTER_SUPERVISOR
    @ Trocar para IRQ (IRQ/FIQ enabled) e inicilizar o SP_IRQ (r13)
    msr CPSR_c, #0b00010010
    ldr sp, =STACK_POINTER_IRQ
    @volta pro modo Supervisor com IRQ/FIQ enabled
    msr CPSR_c, #0b00010011



@    3) ----------- Configuração dos periféricos (GPT/GPIO) -------------------
    @ Você pode configurar os periféricos aqui....

    ldr r0, =GPT_CR
    mov r1, #0x00000041
    str r1, [r0]

    ldr r0, =GPT_PR
    mov r1, #0
    str r1, [r0]

    ldr r0, =GPT_OCR1
    mov r1, #TIME_SZ
    str r1, [r0]

    ldr r0, =GPT_IR
    mov r1, #1
    str r1, [r0]


    @ jogas os bits da tabela 2 no GDIR
    @ 0 = entrada
    @ 1 = saida
    ldr r0, =GDIR
    ldr r1, =0b11111111111111000000000000111110
    str r1, [r0]

    @ldr r2, =0b01111100011000000011111111111111
    @ldr r3, =0b00000011111111111100000000000000
    @and r2, r2, r3
    @mov r2, r2, lsr #14



@    4) ----------- Configuração do TZIC  -------------------------------------
    @ Liga o controlador de interrupcoes
    @ R1 <= TZIC_BASE
    ldr r1, =TZIC_BASE

    @ Configura interrupcao 39 do GPT como nao segura
    mov r0, #(1 << 7)
    str r0, [r1, #TZIC_INTSEC1]

    @ Habilita interrupcao 39 (GPT)
    @ reg1 bit 7 (gpt)
    mov r0, #(1 << 7)
    str r0, [r1, #TZIC_ENSET1]

    @ Configure interrupt39 priority as 1
    @ reg9, byte 3
    ldr r0, [r1, #TZIC_PRIORITY9]
    bic r0, r0, #0xFF000000
    mov r2, #1
    orr r0, r0, r2, lsl #24
    str r0, [r1, #TZIC_PRIORITY9]

    @ Configure PRIOMASK as 0
    eor r0, r0, r0
    str r0, [r1, #TZIC_PRIOMASK]

    @ Habilita o controlador de interrupcoes
    mov r0, #1
    str r0, [r1, #TZIC_INTCTRL]

    @instrucao msr - habilita interrupcoes
    msr  CPSR_c, #0x13       @ SUPERVISOR mode, IRQ/FIQ enabled


@    5) ----------- Execução de código de usuário -----------------------------
    @ Você pode fazer isso aqui....

    msr CPSR_c, #0b00010000
    ldr r0, =USER_ADDRESS
    ldr sp, =STACK_POINTER_USER
    mov pc, r0



@   Rotina para o tratamento de chamadas de sistemas, feitas pelo usuário
@   As funções na camada BiCo fazem syscalls que são tratadas por essa rotina
@   Esta rotina deve, determinar qual syscall foi realizada e realizar alguma ação (escrever nos motores, ler contador de tempo, ....)
svc_handler:
    push {r4-r12, lr}

  @ checar r7, dependendo do r7, le/escrever o que for necessário

  @ read_sonar (21)
    read_sonar:
        cmp r7, #21
        bne set_motor_speed

				@ checa intervalo do input
        mov r1, r0
        mov r0, #-1
        cmp r1, #15
        bgt fim_svc
        cmp r1, #0
        blt fim_svc
        mov r0, r1


        ldr r1, =DR
        ldr r2, [r1]
        mov r0, r0, lsl #2
        ldr r3, =0b11111111111111111111111111000000
        and r2, r3
        orr r2, r0
        str r2, [r1]

        @trigger = 1
        ldr r2, [r1]
        mov r0, #1
        mov r0, r0, lsl #1
        orr r2, r0
        str r2, [r1]

        @espera pelo menos 10ms
        mov r3, #0
        loop_wait1:
            add r3, r3, #1
            cmp r3, #100
            ble loop_wait1


        @trigger = 0
        ldr r0, =0b11111111111111111111111111111101
        and r2, r0
        str r2, [r1]


        @espera flag = 1
        mov r3, #0
        ldr r1, =DR
        ldr r4, =0b00000000000000000000000000000001
        loop_check_flag:
            ldr r2, [r1]
            and r2, r4
            cmp r2, #1
            beq fim_check_flag

            add r3, r3, #1
            cmp r3, #0x100
            ble loop_check_flag
        erro_read_sonar:
            mov r0, #-1
            b fim_svc
        fim_check_flag:

        ldr r2, [r1]
        ldr r3, =0b00000000000000111111111111000000
        and r2, r2, r3
        mov r2, r2, lsr #6
        mov r0, r2

        b fim_svc

  @ set_motor_speed (20)
    set_motor_speed:

        cmp r7, #20
				bne get_time

        check_motor_id:
        	cmp r0, #0
        	blt erro_motor_id
					cmp r0, #1
          bgt erro_motor_id
          b check_motor_speed

        erro_motor_id:
        	mov r0, #-1
        	b fim_svc

        check_motor_speed:
					cmp r1, #0
          blt erro_motor_speed
          cmp r1, #63
          bgt erro_motor_speed
          b fim_check_motor

        erro_motor_speed:
        	mov r0, #-2
        	b fim_svc

        fim_check_motor:


          motor0:
          	cmp r0, #0 @motor da direita
            bne motor1

            @ zera em DR os campos dos motores
            ldr r2, =DR
            ldr r3, [r2]
            ldr r4, =0b11111110000000111111111111111111
            and r3, r4
            str r3, [r2]

            ldr r2, =DR
            ldr r3, [r2]
            mov r1, r1, lsl #1
            add r1, r1, #1 @adiciona 1 (motor_write) no ultimo bit que é 0 (por causa do lsl)
            mov r1, r1, lsl #18
            orr r3, r1
            str r3, [r2]

            @ troca o bit write_motor0 de 1 para 0
            ldr r1, =0b11111111111110111111111111111111
            and r3, r1
            str r3, [r2]

            b fim_svc

          motor1:
						cmp r0, #1 @motor da esquerda
            bne fim_svc

             @ zera em DR os campos dos motores
            ldr r2, =DR
            ldr r3, [r2]
            ldr r4, =0b00000001111111111111111111111111
            and r3, r4
            str r3, [r2]

            ldr r2, =DR
            ldr r3, [r2]
            mov r1, r1, lsl #1
            add r1, r1, #1 @adiciona 1 (motor_write) no ultimo bit que é 0 (por causa do lsl)
            mov r1, r1, lsl #25
            orr r3, r1
            str r3, [r2]

            @ troca o bit write_motor1 de 1 para 0
            ldr r1, =0b11111101111111111111111111111111
            and r3, r1
            str r3, [r2]

        b fim_svc

  @ get_time (17)
    get_time:
        cmp r7, #17
        bne set_time

        @ldr r2, =temp
        @ldr r3, [r2]
        @add r3, r3, #1
        @str r3, [r2]

        ldr r1, =counter
        ldr r0, [r1]

        b fim_svc

  @ set_time (18)
    set_time:
        cmp r7, #18
        bne no_svc

        ldr r1, =counter
        str r0, [r1]

        b fim_svc
    no_svc:
    fim_svc:

    pop {r4-r12, lr}
    movs pc, lr


@   Rotina para o tratamento de interrupções IRQ
@   Sempre que uma interrupção do tipo IRQ acontece, esta rotina é executada. O GPT, quando configurado, gera uma interrupção do tipo IRQ. Neste caso, o contador de tempo pode ser incrementado (este incremento corresponde a 1 unidade de tempo do seu sistema)
irq_handler:
    push {r0-r12}

    ldr r0, =GPT_SR
    mov r1, #0x1
    str r1, [r0]

    ldr r0, =counter
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]

    sub lr, lr, #4

    pop {r0-r12}

    movs pc, lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@      Seção de Dados                        @@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Nesta seção ficam todas as váriaveis utilizadas para execução do código deste arquivo (.word / .skip)
.data
counter: .word 0x00000000
temp: .word 0x0
