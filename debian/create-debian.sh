#!/bin/bash

vm_name=$1
nbr_vm=$2

create_vm () {
vboxmanage import /mnt/public_nas_maurienne/virtualmachines/VirtualBox/sylvain/debian-lora.ova 
vboxmanage modifyvm "debian-lora" --name "$1"
vboxmanage startvm "$1" --type headless 
}


main() {
clear
if [ -z $1 ] || [ -z $2 ] || [ $1 = "help" ]
then
	echo "INFO : First argument must be the VM Name"
    echo "INFO : Second argument must be the number of VM to create"
    exit
else
    while ((nbr_vm !=0))
    do
        echo "Creation of the Virtual Machine nammed $1$nbr_vm"
        nbr_vm=$(($nbr_vm - 1))
        create_vm "$1$nbr_vm" 
    done
fi
}

main "${@}"
