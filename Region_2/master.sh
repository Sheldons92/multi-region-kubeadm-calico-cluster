# #!/bin/bash
K8SVERSION=1.26.1-00

sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

#install pre-reqs
sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

#Install containerd run time

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt update
sudo apt install -y containerd.io

#Configure containerd to run at startup

containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

#Restart and enable containerd

sudo systemctl restart containerd
sudo systemctl enable containerd

#Add repo for Kubernetes

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository -y "deb http://apt.kubernetes.io/ kubernetes-xenial main"

#Install kubernetes components (Latest for now)
sudo apt update
sudo apt install -y \
          kubeadm=${K8SVERSION} \
          kubelet=${K8SVERSION} \
          kubectl=${K8SVERSION} 

sudo apt-mark hold \
          kubeadm=${K8SVERSION} \
          kubelet=${K8SVERSION} \
          kubectl=${K8SVERSION} 

#Configure master node

kubeadm version
sudo kubeadm config images pull
sudo kubeadm init \
    --pod-network-cidr=192.168.64.0/18 \
    --apiserver-cert-extra-sans=127.0.0.1 \
    --service-cidr=172.21.0.0/16

#Configure kubeconfig

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl taint nodes --all node-role.kubernetes.io/control-plane-