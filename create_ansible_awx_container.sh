#!/bin/bash

# Define variables for container creation
CONTAINER_NAME="ansible-awx"
VM_ID=114
VM_TYPE="lxc"
OS_TEMPLATE="local:vztmpl/debian-11-standard_11.6-1_amd64.tar.zst"
ROOTFS_SIZE="10G"
CPU_CORES=2
MEMORY=4096
SWAP=1024
SSH_PUBLIC_KEY="/root/.ssh/id_rsa.pub"
SSH_PORT=22
IP_ADDRESS="192.168.2.27"
GATEWAY="192.168.2.1"
DNS_SERVER="192.168.2.11"

# Create the Proxmox LXC container
pct create $VM_ID $OS_TEMPLATE --hostname $CONTAINER_NAME --memory $MEMORY --swap $SWAP --cpu $CPU_CORES --net0 name=eth0,bridge=vmbr0,ip=$IP_ADDRESS/24,gw=$GATEWAY --ssh-public-keys $SSH_PUBLIC_KEY --onboot 1 --ostype Debian --searchdomain $DNS_SERVER

# Set root password for container
echo "password123" | pct set $VM_ID --root-password

# Start the container
pct start $VM_ID



# Warten, bis der Container gestartet ist
sleep 10

# Ansible Core installieren
pct exec $VMID -- bash -c "apt-get update && apt-get install -y ansible"

# AWX installieren
pct exec $VMID -- bash -c "apt-get install -y gnupg2 curl && curl -s https://packagecloud.io/install/repositories/ansible/awx/script.deb.sh | bash && apt-get install -y ansible-awx"

# AWX-Konfiguration
pct exec $VMID -- bash -c "cd /var/lib/awx/installer && ansible-playbook -i inventory install.yml"

# AWX starten
pct exec $VMID -- bash -c "systemctl start docker-compose@awx"

# AWX bei Systemstart starten
pct exec $VMID -- bash -c "systemctl enable docker-compose@awx"
