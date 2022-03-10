#!/bin/bash

ssh_unsec="ssh -o StrictHostKeyChecking=no" #alias for ssh command
vm_name=$1

#sleep 2
create_vm () {
#vm_name="CentOS8-3"
#vm_name=$1
vboxmanage import /mnt/public_nas_maurienne/virtualmachines/VirtualBox/CentOS8-3.ova
vboxmanage modifyvm "CentOS8-3" --name "${vm_name}"
vboxmanage showvminfo "${vm_name}" | grep NIC 
vboxmanage startvm "${vm_name}" --type headless 
#echo -e "\n"
get_ip "${vm_name}" 
wait_until_ssh "${ip}" "password" "root" #"Pa\$\$word8c" "tc"
wan_ip=$(sshpass -p 'password' ssh -o 'StrictHostKeyChecking no' root@${ip} ip addr | grep -E "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep 192.168.14 )
echo -e "\nWAN IP Addres is \n ${wan_ip} \n"

}



get_ip () {
local i=0
while [[ -z ${ip} ]] && [[ $i -lt 30 ]] 
do 
 sleep 1
 ip=$(get-ip-vm.sh "${1}")
 ((i++))
 printf "Wait until "${1}" boot...\n"
done
printf "\n     Management's IP Address of ${1} is ${ip}\n"
}

#$1 -> ipaddress
#$2 -> password
#$3 -> user
wait_until_ssh () {

if [[ -z $2 ]]; then
  password="password"
else
  password=$2
fi

if [[ -z $3 ]]; then
  user="root"
else
  user=$3
fi

local i=0
local ssh_return=1
ssh-keygen -R ${1} 
 while [[ $ssh_return != 0 ]] && [[ $i -lt 30 ]]
 do 
 printf "Wait until ssh_server on "${1}" starts\n"
 sleep 1
 ((i++))
 sshpass -p "${password}" $ssh_unsec ${user}@${1} "echo 1" 2>/dev/null
 ssh_return=$?
 done
}



main() {
id=$(id -un)

clear
if [ -z $1 ] || [ $1 = "help" ]
then
	echo "INFO : First argument must be the VM Name"
    exit
else
	echo "Creation of the Virtual Machine nammed $1"
    create_vm "$1" 
fi
}

main "${@}"