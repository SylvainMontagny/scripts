#!/bin/bash

clear
if [ -z $1 ] || [ $1 = "help" ] 
then
	echo "INFO : First argument must be the VM Name"
    echo "List VM"
    vboxmanage list vms
    echo "List running VM"
    vboxmanage list runningvms
    exit 
else
    echo "List VM"
    vboxmanage list vms
    echo "List running VM"
    vboxmanage list runningvms
	echo "Delete Virtual Machine named $1"
    vboxmanage controlvm "${1}" poweroff
    vboxmanage unregistervm "${1}" --delete  
    echo "List VM"
    vboxmanage list vms
    echo "List running VM"
    vboxmanage list runningvms
fi
