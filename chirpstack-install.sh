#!/bin/bash
CHIRPSTACK_DIR="$HOME/chirpstack"

if [ -z $1 ]
then
	PORT_PKTFWD="1700"
    echo "Port Number for UDP Packet forward will be 1700"
    sleep 3
    
elif [ $1 = "help" ]
then
	echo "INFO : First argument (default 1700) is optionnal : port number for UDP Packet Forwarder "
    exit
else 
    PORT_PKTFWD=$1
    echo "Port Number for UDP Packet forward will be $PORT_PKTFWD"
    sleep 3
fi




cd "$HOME"
cp –r Script/chirpstack-docker chirpstack 
cd chirpstack
sed -i -e "s/1700/$PORT_PKTFWD/g" docker-compose-env.yml
sed -i -e "s/1700/$PORT_PKTFWD/g" docker-compose.yml
sudo docker-compose up -d

