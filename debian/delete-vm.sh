#!/bin/bash
#Script to poweroff all vm of the current user
#The VM must be connected to vbox-tap0
 vms=()
   while read vm
      do
      #echo ${vms[@]}
      vms+=("$vm")
   done < <(vboxmanage list vms | grep -o '^".*"')


  for vm in "${vms[@]}"; do
    vm=$(echo $vm | sed 's/\"//g')
    printf "Deleting %s... \n" "${vm}"
    vboxmanage controlvm "${vm}" poweroff
    vboxmanage unregistervm --delete "${vm}" 
  done

