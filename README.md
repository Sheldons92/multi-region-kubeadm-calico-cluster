# multi-region-kubeadm-calico-cluster

This repository is used for creating 3 Kubernetes Clusters using Kubeadm (Ubuntu 22.04) in 3 seperate regions and installing Calico on top using different Pod IP Cidrs, for the purpose of connecting them together in the future and running a CockroachDB Cluster on top.

Each region corresponds to a cluster and the scripts in each folder, use the below configuration to ensure there's no overlapping on the networks:

## Pod IP CIDR
- Region 1: 192.168.0.0/18
- Region 2: 192.168.64.0/18
- Region 3: 192.168.128.0/18
## Service IP CIDR
- Region 1: 172.20.0.0/16
- Region 2: 172.21.0.0/16
- Region 3: 172.22.0.0/16

# Prerequisites

* Prior to running the scripts, you should provision at least 2 Virtual Machines (I use EC2) running Ubuntu 22.04 in 3 different regions, 1 for a master node and 1 for a worker node.

# Instructions Region 1

1. Run the master set up script on the node allocated as your master

```
curl https://raw.githubusercontent.com/Sheldons92/multi-region-kubeadm-calico-cluster/manifest-approach/Region_1/master.sh | bash
```

2. Run the worker set up script on the node allocated as your master

```
curl https://raw.githubusercontent.com/Sheldons92/multi-region-kubeadm-calico-cluster/manifest-approach/Region_1/worker.sh | bash
```

3. Using the output from the master node script, run the kubeadm join command using sudo this will look something like the below

```
sudo kubeadm join 10.10.13.8:6443 --token XXXXXXXXXX \
	--discovery-token-ca-cert-hash sha256:XXXXXXXXXXX
```

4. Once the cluster has successfully provisioned, verify it is working from the master node (Note: you should see CoreDNS is in a pending state this is because no overlay network is present)

```
kubectl get pods -A -o wide
```

5. Install the Calico manifest

```
kubectl apply -f https://raw.githubusercontent.com/Sheldons92/multi-region-kubeadm-calico-cluster/manifest-approach/Region_1/calico.yaml 
```

# Instructions Region 2

1. Run the master set up script on the node allocated as your master

```
curl https://raw.githubusercontent.com/Sheldons92/multi-region-kubeadm-calico-cluster/manifest-approach/Region_2/master.sh | bash
```

2. Run the worker set up script on the node allocated as your master

```
curl https://raw.githubusercontent.com/Sheldons92/multi-region-kubeadm-calico-cluster/manifest-approach/Region_2/worker.sh | bash
```

3. Using the output from the master node script, run the kubeadm join command using sudo this will look something like the below

```
sudo kubeadm join 10.10.13.8:6443 --token XXXXXXXXXX \
	--discovery-token-ca-cert-hash sha256:XXXXXXXXXXX
```

4. Once the cluster has successfully provisioned, verify it is working from the master node (Note: you should see CoreDNS is in a pending state this is because no overlay network is present)

```
kubectl get pods -A -o wide
```

5. Install the Calico manifest

```
kubectl apply -f https://raw.githubusercontent.com/Sheldons92/multi-region-kubeadm-calico-cluster/manifest-approach/Region_2/calico.yaml 
```

# Instructions Region 3

1. Run the master set up script on the node allocated as your master

```
curl https://raw.githubusercontent.com/Sheldons92/multi-region-kubeadm-calico-cluster/manifest-approach/Region_3/master.sh | bash
```

2. Run the worker set up script on the node allocated as your master

```
curl https://raw.githubusercontent.com/Sheldons92/multi-region-kubeadm-calico-cluster/manifest-approach/Region_3/worker.sh | bash
```

3. Using the output from the master node script, run the kubeadm join command using sudo this will look something like the below

```
sudo kubeadm join 10.10.13.8:6443 --token XXXXXXXXXX \
	--discovery-token-ca-cert-hash sha256:XXXXXXXXXXX
```

4. Once the cluster has successfully provisioned, verify it is working from the master node (Note: you should see CoreDNS is in a pending state this is because no overlay network is present)

```
kubectl get pods -A -o wide
```

5. Install the Calico manifest

```
kubectl apply -f https://raw.githubusercontent.com/Sheldons92/multi-region-kubeadm-calico-cluster/manifest-approach/Region_3/calico.yaml 
```