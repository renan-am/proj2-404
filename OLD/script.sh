if [ -z "$1" ]
  then
    NAME=simple
  else
   	NAME=$1
fi

make img && 
xfce4-terminal -x bash -c "player /home/mc404/usr/worlds_mc404/$NAME.cfg" &&
sleep 3 &&
armsim_player --rom=/home/mc404/simuladorfromspecg/simulador/dumboot.bin --sd=disk.img
