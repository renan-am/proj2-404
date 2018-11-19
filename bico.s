@ ----------- Data -------------


@ ----------- Text -------------
.text
.align 4
.globl set_motor_speed
.globl read_sonar
.globl get_time
.globl set_time


set_motor_speed:
    push {r7, lr}

  
    ldrb r1, [r0, #1] 
    ldrb r0, [r0]

    mov r7, #20
    svc 0x0 

    pop {r7, pc}



read_sonar:
	push {r7, lr}
  
  mov r7, #21
	
  svc 0x0
  
	pop {r7, pc}


get_time:
  push {r7, lr}
	mov r7, #17
	svc 0x0
  pop {r7, pc}
  

set_time:
	push {r7, lr}
	mov r7, #18
  svc 0x0
  pop {r7, pc}
