#!/bin/bash

# Prompt for root password
echo "Please enter a root password for the container:"
read -s rootpw

# Create the container
vmid=114
hostname=awx
ostemplate=debian-11-standard_11.6-1_amd64.tar.zst
rootfs=10
swap=1024
cpus=2
memory=4096
net0="name=eth0,bridge=vmbr0,ip=192.168.2.27/24,gw=192.168.2.1"
sshport=2222

pct create $vmid $ostemplate -rootfs $rootfs -swap $swap -hostname $hostname -cpus $cpus -memory $memory -net0 $net0 -ssh-public-keys /root/.ssh/id_rsa.pub -onboot 1 -startup order=1
pct set $vmid -root-password "$rootpw" -ssh-port $sshport
pct start $vmid

# Wait for the container to start up
sleep 10

# Install Ansible Core and AWX
pct exec $vmid -- sh -c 'echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list && apt-get update && apt-get -y install ansible'
pct exec $vmid -- sh -c 'apt-get -y install curl gnupg2 software-properties-common && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian buster stable" && apt-get update && apt-get -y install docker-ce docker-ce-cli containerd.io'
pct exec $vmid -- sh -c 'curl -s https://api.github.com/repos/ansible/awx/archive/refs/tags/17.0.0.tar.gz | tar -xvz && cd awx-17.0.0/installer/ && ansible-playbook -i inventory install.yml'

# Print login information
echo "AWX should now be installed and accessible at https://192.168.2.100 with your root password."
echo "SSH access is available on port $sshport with username 'root' and your root password." 
