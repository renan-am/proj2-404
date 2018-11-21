if [ -z "$1" ]
  then
    NAME=simple
  else
   	NAME=$1
fi

rm -rf disk.img *.x *.o &&

source /home/specg12-1/mc404/simulador/set_path_player.sh &&
make all &&
gnome-terminal -x  bash -c "player /home/specg12-1/mc404/simulador/simulador_player/worlds_mc404/$NAME.cfg" &&
sleep 3 && 
gnome-terminal -x bash -c "armsim_player --rom=/home/specg12-1/mc404/simulador/simulador_player/bin/dumboot.bin --sd=disk.img -g" &&
sleep 3 &&
arm-eabi-gdb -x ./cmds SOUL.x
