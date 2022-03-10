#!/bin/bash
TTS_DIR="$HOME/tts"
 
clear
#If no argument and TTS_DIR exists
if [ -z $1 ] && [ -d "$TTS_DIR" ] 
then 
	cd $TTS_DIR 
	sudo docker-compose down 
	sudo rm -rf $TTS_DIR 
	exit 
fi

#If no argument and TTS_DIR doesn't exist
if [ -z $1 ] && [ ! -d "$TTS_DIR" ] 
then 
	echo "Nothing to do, the tts is down already" 
	exit 
fi

#If argument is "help"
if [ $1 = "help" ] 
then 
	echo "INFO : No arguments required, the script will down tts and erase the folder" 
exit
fi
