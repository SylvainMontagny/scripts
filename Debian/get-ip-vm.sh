#!/bin/bash
#Script to get the mangagement IP of all vm of the current user
#The VM must be connected to vbox-tap0
if [ -z ${1} ]; then
   vms=()
   while read vm
      do 
      #echo ${vms[@]}
      vms+=("$vm")
      done < <(vboxmanage list runningvms | grep -o '^".*"')

   #echo ${vms[@]}
   for vm in "${vms[@]}"; do
    vm=$(echo $vm | sed 's/\"//g')
    #echo $vm
    mac=$(vboxmanage showvminfo "${vm}" | grep "Interface 'vbox-tap0'" | sed 's/ //g' | cut -b 10-21 | sed s'/.\{2\}/&:/g;s/:$//')
    if [ ! -z $mac ]
      then  
 	ip=$(sshpass -p 'Pa$$word8c' ssh -o 'StrictHostKeyChecking no' tc@172.29.253.2 "cat /var/db/dhcpd.leases | grep -i -B 10 ${mac} | grep lease | tail -1 | cut -d ' ' -f 2")
    ip2=$(sshpass -p 'password' ssh -o 'StrictHostKeyChecking no' root@$ip "ip a | grep -i enp0s8 | tail -1 | cut -d ' ' -f 6")
        else 
	ip="Pas d'IP"
     fi
     echo -e "${vm} \t| ${mac} \t| ${ip} \t | ${ip2}"
    done
else
    mac=$(vboxmanage showvminfo "${1}" 2>/dev/null | grep "Interface 'vbox-tap0'" | sed 's/ //g' | cut -b 10-21 | sed s'/.\{2\}/&:/g;s/:$//')
    if [ ! -z $mac ]
      then
        ip=$(sshpass -p 'Pa$$word8c' ssh -o 'StrictHostKeyChecking no' tc@172.29.253.2 "cat /var/db/dhcpd.leases | grep -i -B 10 ${mac} | grep lease | tail -1 | cut -d ' ' -f 2")
     fi
     echo ${ip}
fi

