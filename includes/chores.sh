#!/bin/bash

helmEnable(){
echo -e "${BWhite}Enabling Helm${Color_Off}"
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml && echo -e "${IGreen}Helm Enabled${Color_Off}"|| echo -e "${IRed}Helm Enable FAILED${Color_Off}"
}
export -f helmEnable

aptEnable(){
echo -e "${BWhite}Enabling Apt-Commands${Color_Off}"
chmod +x /usr/bin/apt* && echo -e "${IGreen}APT enabled${Color_Off}"|| echo -e "${IRed}APT Enable FAILED${Color_Off}"
}
export -f aptEnable

kubeapiEnable(){
local -r comment='iX Custom Rule to drop connection requests to k8s cluster from external sources'
echo -e "${BWhite}Enabling Apt-Commands${Color_Off}"
if iptables -t filter -L INPUT 2> /dev/null | grep -q "${comment}" ; then
  iptables -D INPUT -p tcp -m tcp --dport 6443 -m comment --comment "${comment}" -j DROP && echo -e "${IGreen}Kubernetes API enabled${Color_Off}"|| echo -e "${IRed}Kubernetes API Enable FAILED${Color_Off}"
else
  echo -e "${IGreen}Kubernetes API already enabled${Color_Off}"
fi
}
export -f kubeapiEnable

# Prune unused docker images to prevent dataset/snapshot bloat related slowdowns on SCALE
prune(){
echo -e "${BWhite}Docker Prune${Color_Off}"
echo "Pruning Docker Images..."
docker image prune -af | grep "^Total" && echo -e "${IGreen}Docker Prune Successfull${Color_Off}" || echo "Docker Prune ${IRed}FAILED${Color_Off}"

# TODO Switch to middleware prune on next release
# midclt call container.prune '{"remove_unused_images": true, "remove_stopped_containers": true}' &> /dev/null && echo "Docker Prune completed"|| echo "Docker Prune ${IRed}FAILED${Color_Off}"
}
export -f prune

#
sync(){
echo -e "${BWhite}Starting Catalog Sync...${Color_Off}"
cli -c 'app catalog sync_all' &> /dev/null && echo -e "${IGreen}Catalog sync complete${Color_Off}" || echo -e "${IRed}Catalog Sync Failed${Color_Off}"
}
export -f sync
