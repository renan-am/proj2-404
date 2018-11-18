assembly: motors.s
	arm-eabi-as motors.s -o motors.o
linker: assembly
	arm-eabi-ld motors.o -o motors  -Ttext=0x77802000
img: linker
	mksd.sh --so /home/mc404/simuladorfromspecg/simulador/simulador_player/bin/knrl --user motors
