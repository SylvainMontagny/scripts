#!/bin/bash
ssh_unsec="ssh -o StrictHostKeyChecking=no" #alias for ssh command


#sleep 2
create_vm () {
vm_name="CentOS8-3"
vboxmanage import /mnt/public_nas_maurienne/virtualmachines/VirtualBox/CentOS8-3.ova
vboxmanage showvminfo "${vm_name}" | grep NIC 
vboxmanage startvm "${vm_name}" --type headless 
echo -e "\n **Management Network ip address : ${ip} **\n"

get_ip "${vm_name}" 
wait_until_ssh "${ip}" "password" "root" #"Pa\$\$word8c" "tc"
wan_ip=$(sshpass -p 'password' ssh -o 'StrictHostKeyChecking no' root@${ip} ip addr | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep 192.168.14 )
echo -e "\n **\n **\n ** WAN IP Addres is ${wan_ip}. Give this address to your partner \n ** \n **"

}

destroy_vm () {
  vm_name="CentOS8-3"
  vboxmanage controlvm "${vm_name}" poweroff
  vboxmanage unregistervm "${vm_name}" --delete
}

get_ip () {
local i=0
while [[ -z ${ip} ]] && [[ $i -lt 30 ]] 
do 
 sleep 1
 ip=$(get-ip-vm.sh "${1}")
 ((i++))
 printf "Wait until "${1}" boot\n"
done
printf "Management's IP for ${1} is ${ip}\n"
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
 printf "Wait until ssh_server on "${1}" start\n"
 sleep 1
 ((i++))
 sshpass -p "${password}" $ssh_unsec ${user}@${1} "echo 1" 2>/dev/null
 ssh_return=$?
 done
}




main() {
id=$(id -un)
echo "tests"
if [ -z $1 ]; then 
  create_vm
  
elif [ $1 = "destroy_vm" ]; then
  destroy_vm
else
  printf "Erreur dans l'argument"
fi

}



main "${@}"