if [ -z "$1" ]
  then
    NAME=simple
  else
   	NAME=$1
fi


make all &&
xfce4-terminal -x bash -c "player /home/mc404/usr/worlds_mc404/$NAME.cfg" &&
sleep 3 &&
xfce4-terminal -x bash -c "armsim_player --rom=/home/mc404/simuladorfromspecg/simulador/dumboot.bin --sd=disk.img -g" &&
sleep 3 &&
arm-eabi-gdb -x ./cmds SOUL.x
