soul.o:	soul.s
	arm-eabi-as -g soul.s -o soul.o

soul: soul.o
	arm-eabi-ld soul.o -o soul -g --section-start=.iv=0x778005e0 -Ttext=0x77800700 -Tdata=0x77801800 -e 0x778005e0

disk.img: faz_nada soul
	mksd.sh --so soul --user faz_nada

gdb:
	arm-eabi-gdb soul
