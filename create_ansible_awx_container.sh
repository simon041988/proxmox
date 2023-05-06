#!/bin/bash

# Define variables
VMID=114
OSTEMPLATE=local:vztmpl/debian-11-standard_11.6-1_amd64.tar.zst
DISKSIZE=10G
SWAPSIZE=1024
CPUS=2
MEMORY=4096
IPADDRESS=192.168.2.27
GATEWAY=192.168.2.1
DNS=192.168.2.11

# Create LXC container
pct create $VMID $OSTEMPLATE -rootfs $DISKSIZE -swap $SWAPSIZE -cpus $CPUS -memory $MEMORY -net0 name=eth0,ip=$IPADDRESS/24,gw=$GATEWAY -nameserver $DNS

# Set hostname
pct set $VMID -hostname ansible

# Set root password interactively
pct set $VMID -rootfs password

# Set SSH port
pct set $VMID -ssh-port 2222

# Start container
pct start $VMID

# Wait for container to start
sleep 10

# Install sshpass to be able to execute ssh commands with password authentication
pct exec $VMID -- apt update
pct exec $VMID -- apt install -y sshpass


# Install Ansible Core and AWX
pct exec $vmid -- sh -c 'echo "deb http://deb.debian.org/debian buster-backports main" >> /etc/apt/sources.list && apt-get update && apt-get -y install ansible'
pct exec $vmid -- sh -c 'apt-get -y install curl gnupg2 software-properties-common && curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian buster stable" && apt-get update && apt-get -y install docker-ce docker-ce-cli containerd.io'
pct exec $vmid -- sh -c 'curl -s https://api.github.com/repos/ansible/awx/archive/refs/tags/17.0.0.tar.gz | tar -xvz && cd awx-17.0.0/installer/ && ansible-playbook -i inventory install.yml'

# Print login information
echo "AWX should now be installed and accessible at https://192.168.2.100 with your root password."
echo "SSH access is available on port $sshport with username 'root' and your root password." 
