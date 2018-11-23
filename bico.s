
@ A camada de software BiCo (Biblioteca de Controle)
@ implementa as APIs de controle em linguagem de montagem ARM.
@
@ Basicamente, a camada BiCo é responsável por realizar a ponte
@ entre o código do usuário da lógica de controle e as chamadas
@ de sistema, ou syscalls.


@ ----------- Text -------------
.text
.align 4


@ A diretiva .globl tem a função de permitir que as funções
@ definidas nesse arquivo sejam vistas e utilizadas nos outros
@ arquivos.

.globl set_motor_speed
.globl read_sonar
.globl get_time
.globl set_time



@ Função set_motor_speed
@ - parâmetros -
@   r1 -> define a velocidade que será utilizada
@   r0 -> define o motor que receberá a nova velocidade
@ - retorno -
@   nenhum
@
@ Com esses parâmetros recebidos, (20) é passado para
@ o registrador r7, indicando o tipo da syscall que deve
@ ser feita, e então é feita a chamada de sistema.

set_motor_speed:
    push {r7, lr}

    ldrb r1, [r0, #1]
    ldrb r0, [r0]

    mov r7, #20
    svc 0x0

    pop {r7, pc}


@ Função read_sonar
@ - parâmetros -
@   r0 -> define o sonar que deve ser lido
@ - retorno -
@   r0 -> valor respectivo ao sonar lido
@
@ Com o parâmetro recebido, (21) é passado para
@ o registrador r7, indicando o tipo da syscall que deve
@ ser feita, e então é feita a chamada de sistema.

read_sonar:
	push {r7, lr}

  mov r7, #21

  svc 0x0

	pop {r7, pc}


@ Função get_time
@ - parâmetros -
@   nenhum
@ - retorno -
@   r0 -> tempo do sistema
@
@ (17) é passado para o registrador r7, indicando o
@ tipo da syscall que deve ser feita, e então é feita
@ a chamada de sistema.

get_time:
  push {r7, lr}
	mov r7, #17
	svc 0x0
  pop {r7, pc}


@ Função set_time
@ - parâmetros -
@   r0 -> tempo do sistema
@ - retorno -
@   nenhum
@
@ Com o parâmetro recebido, (18) é passado para
@ o registrador r7, indicando o tipo da syscall que deve
@ ser feita, e então é feita a chamada de sistema.

set_time:
	push {r7, lr}
	mov r7, #18
  svc 0x0
  pop {r7, pc}
