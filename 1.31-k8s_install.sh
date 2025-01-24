#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Trap errors and report the failing command
trap 'echo "Error occurred at line $LINENO while executing: $BASH_COMMAND"; exit 1' ERR

echo "                  Applying sysctl parameters"
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

echo "                  Applying sysctl parameters without reboot"
sudo sysctl --system

echo "                  Verifying net.ipv4.ip_forward"
sysctl net.ipv4.ip_forward 

echo "Turning off swap"
sleep 2
sudo swapoff -a

echo "============================== Installing containerd =============================="
sleep 2

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y containerd.io
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

echo "================================= Configuring containerd =============================="
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

echo "========================================== Installing kubeadm, kubelet, and kubectl =========================================="
sleep 2
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx Enabling kubelet xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
sudo systemctl enable --now kubelet

echo "x=x=x=x=x=x=x=x=x=x=x=x=x=x=   Script executed successfully! x=x=x=x=x=x=x=x=x=x=x=x=x=x= "
