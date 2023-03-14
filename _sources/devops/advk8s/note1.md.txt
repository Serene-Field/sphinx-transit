# Advanced Kubernetes 1 | CNCF Basics and Kubeadm

### 1. CNCF Basics

#### (1) CNCF Trail Map

![](https://raw.githubusercontent.com/cncf/trailmap/master/CNCF_TrailMap_latest.png)

#### (2) Topics Overview

- `kubeadm`: installing kubernetes on-prem
- `K8s Operators`: file, block, and object storage
- `cert-manager`: managing ssl
- `Dex`: managing LDAP
- `Istio`: service mesh, load balancing
- `Calico`: networking
- `Vault`: secret store
- `Openshift`: PaaS

### 2. Environment Configuration

I'm on a M2 Macbook with Parallel as VM. So I use Parallel to start a Ubuntu 22.04 VM. When the VM is up, install the network tools and use `ifconfig` to find the IP address

```bash
$ sudo apt install net-tools
$ ifconfig
```

Then ssh through the terminal from the macbook outside the VM.

Also, install `git` with,

```bash
$ sudo apt-get update
$ sudo apt install git
```

### 3. Build 1-Node Environment with Kubeadm 

First, git clone from the libraray,

```bash
$ cd /home/parallels/
$ git clone https://github.com/Sadamingh/on-prem-or-cloud-agnostic-kubernetes.git
```

Then go to the directory by,

```bash
$ sudo su -
$ cd /home/parallels/on-prem-or-cloud-agnostic-kubernetes
```
Install `docker`, `kubelet`, `kubeadm`, `kubectl` with `scripts/install-node.sh`,

```bash
$ source scripts/install-node.sh
```

The let's bring up kubelet service by,

```bash
$ swapoff -a
$ sudo systemctl restart kubelet.service
```

After installation, configure `kubeadm` through,

```bash
$ source scripts/config-kubeadm.sh 
```

Note that the configuration step is supposed to be run only on the master node. For the other working nodes, we only have to run `install-node.sh`.

Also note that `podSubnet` value in `config-kubeadm.sh` is originally set to be `10.211.0.0/16`. Please make sure this value aligns to the IP address.

Finally, let's create a new user. First we have to go with the root permission. And execute the `create-user.sh` script.

```bash
$ source scripts/create-user.sh
```

Then for the newly created user `ubuntu`, we can reset the password by `passwd`,

```bash
$ passwd ubuntu
```

### 4. Test

We can test the cluster through the following commands and the following results are expected. 

```bash
$ kubectl get nodes
NAME                         STATUS   ROLES           AGE     VERSION
ubuntu-linux-22-04-desktop   Ready    control-plane   3h28m   v1.26.2

$ kubectl get pods -A
NAMESPACE     NAME                                                 READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-57b57c56f-4kb6g              1/1     Running   0          3h28m
kube-system   canal-vpb26                                          2/2     Running   0          3h28m
kube-system   coredns-787d4945fb-6kvh2                             1/1     Running   0          3h28m
kube-system   coredns-787d4945fb-t9cqf                             1/1     Running   0          3h28m
kube-system   etcd-ubuntu-linux-22-04-desktop                      1/1     Running   0          3h28m
kube-system   kube-apiserver-ubuntu-linux-22-04-desktop            1/1     Running   0          3h28m
kube-system   kube-controller-manager-ubuntu-linux-22-04-desktop   1/1     Running   0          3h28m
kube-system   kube-proxy-dcw8p                                     1/1     Running   0          3h28m
kube-system   kube-scheduler-ubuntu-linux-22-04-desktop            1/1     Running   0          3h28m
```

### 5. Debug

After rebooting the VM, the connection to kubernetes will be lost. Logs like

```
$ kubectl get nodes
E0313 10:34:40.260814 2711656 mencache.g:238] couldn't get current server API g roup list: Get "http://localhost: 8080/api?timeout=32s": dial tcp 127.0.0.1:8080:connect: connection refused
```

In this case, rerun `install-node.sh` by,

```bash
$ source scripts/install-node.sh
$ swapoff -a
$ sudo systemctl restart kubelet.service
```