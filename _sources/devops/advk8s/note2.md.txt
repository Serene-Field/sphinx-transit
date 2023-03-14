# Advanced Kubernetes 2 | Minikube, Etcdclient, and Etcdctl

### 1. Minikube Installation

Prerequisites:

- Docker
- Macbook with ARM chip (M1/M2)

For MacOS with ARM chip,

```bash
$ brew install minikube
```

Then start the cluster with,

```bash
$ minikube start
```

If you have a prebuilt minikube cluster, please delete it by,

```bash
$ minikube delete
```

Then let's create a kubernetes cluster with 4 nodes by,

```bash
$ minikube start --nodes 4
$ kubectl get nodes
NAME           STATUS   ROLES           AGE     VERSION
minikube       Ready    control-plane   2m23s   v1.25.3
minikube-m02   Ready    <none>          108s    v1.25.3
minikube-m03   Ready    <none>          76s     v1.25.3
minikube-m04   Ready    <none>          44s     v1.25.3
```

### 2. Cluster Overview

Now, let's have an overview of the cluster,

```bash
$ kubectl get pods -n kube-system -o wide
NAME                               READY   STATUS    RESTARTS   AGE   IP             NODE           NOMINATED NODE   READINESS GATES
coredns-565d847f94-kgj6n           1/1     Running   0          15m   10.244.0.2     minikube       <none>           <none>
etcd-minikube                      1/1     Running   0          15m   192.168.49.2   minikube       <none>           <none>
kindnet-8qn44                      1/1     Running   0          15m   192.168.49.3   minikube-m02   <none>           <none>
kindnet-bpkgz                      1/1     Running   0          15m   192.168.49.2   minikube       <none>           <none>
kindnet-f26zn                      1/1     Running   0          13m   192.168.49.5   minikube-m04   <none>           <none>
kindnet-vmfcm                      1/1     Running   0          14m   192.168.49.4   minikube-m03   <none>           <none>
kube-apiserver-minikube            1/1     Running   0          15m   192.168.49.2   minikube       <none>           <none>
kube-controller-manager-minikube   1/1     Running   0          15m   192.168.49.2   minikube       <none>           <none>
kube-proxy-4jrnq                   1/1     Running   0          15m   192.168.49.2   minikube       <none>           <none>
kube-proxy-52zp9                   1/1     Running   0          15m   192.168.49.3   minikube-m02   <none>           <none>
kube-proxy-jmbsk                   1/1     Running   0          13m   192.168.49.5   minikube-m04   <none>           <none>
kube-proxy-s6f7n                   1/1     Running   0          14m   192.168.49.4   minikube-m03   <none>           <none>
kube-scheduler-minikube            1/1     Running   0          15m   192.168.49.2   minikube       <none>           <none>
storage-provisioner                1/1     Running   0          15m   192.168.49.2   minikube       <none>           <none>
```

Here we have,

- coredns
- etcd
- apiserver
- controller-manager
- scheduler
- storage-provisioner

deployed only on the master (`control-plane`) node and we have,

- kindnet
- proxy

deployed on each of the node.

### 3. Interact with Etcd

In this section we are going to learn about` etcd`. `etcd` is a distributed key-value store that is used for storing and retrieving configuration data, metadata, and other kinds of data that need to be shared across multiple machines or applications. It was developed by CoreOS, and is now a graduated project of the Cloud Native Computing Foundation (CNCF).

minikube already created an `etcd` named `etcd-minikube` for us but we have no way to inspect it so far. Therefore, we need a client for interaction purpose. Let's follow some steps to setup the etcd client,

- Connect to the master node `minikube`

```bash
$ docker exec -it minikube bash
```

- Download the YAML script for the `etcdclient`,

```bash
$ curl -LO https://gist.githubusercontent.com/Sadamingh/8b63a5741417a5819a185cb20369d1da/raw/db4717373b4e514c52a446c61f478e6c4683a934/etcdclient.yaml
```

- Copy the yaml file to manifests, then exit the connection to master node

```bash
$ mv etcdclient.yaml /etc/kubernetes/manifests/
$ exit
```

- Allow a few seconds for creating the pod, then check if the pod `etcdclient-minikube` is running by,

```bash
$ kubectl get pods -n kube-system | grep etcdclient
```

- Note: in case you have to restart the pod, use the following command,

```bash
$ kubectl delete po etcdclient-minikube -n kube-system
```

- Once the pod is up and running, we can access the etcd client through

```bash
$ kubectl exec -n kube-system -it etcdclient-minikube -- sh
/ #
```

### 4. `etcdctl` Usage

Now that we have the etcd client up, we can then access the etcd information through `etcdctl`. 

We can check the `etcd` node by,

```
/ # etcdctl member list --write-out=table
+------------------+---------+----------+---------------------------+---------------------------+
|        ID        | STATUS  |   NAME   |        PEER ADDRS         |       CLIENT ADDRS        |
+------------------+---------+----------+---------------------------+---------------------------+
| aec36adc501070cc | started | minikube | https://192.168.49.2:2380 | https://192.168.49.2:2379 |
+------------------+---------+----------+---------------------------+---------------------------+
```

From the table above we can know that there's only one `etcd` node for the minikube cluster. We can inspect the key-value pairs of this `etcd` by `etcdctl get ...`. For example, we can get the number of etcd keys with prefix `/registry` by,

```
/ # etcdctl get --prefix /registry | wc -l
5980
```

We can also view all the kv pairs of keys with the prefix `/registry` as json type,

```
/ # etcdctl get --prefix /registry --write-out=json
...
```

Because there're `5980` results and it's hard to inspect just one record, we can limit the output number to 1 by,

```
/ #  etcdctl get --limit=1 --prefix /registry --write-out=json
{"header":{"cluster_id":18038207397139142846,"member_id":12593026477526642892,"revision":7941,"raft_term":2},"kvs":[{"key":"L3JlZ2lzdHJ5L2FwaXJlZ2lzdHJhdGlvbi5rOHMuaW8vYXBpc2VydmljZXMvdjEu","create_revision":17,"mod_revision":17,"version":1,"value":"eyJraW5kIjoiQVBJU2VydmljZSIsImFwaVZlcnNpb24iOiJhcGlyZWdpc3RyYXRpb24uazhzLmlvL3YxIiwibWV0YWRhdGEiOnsibmFtZSI6InYxLiIsInVpZCI6ImNiNGFhYWJmLWJkNGQtNDIzMy05OWNmLTA1ZGJhZDU4MTE2OCIsImNyZWF0aW9uVGltZXN0YW1wIjoiMjAyMy0wMy0xM1QyMDo1ODo0MloiLCJsYWJlbHMiOnsia3ViZS1hZ2dyZWdhdG9yLmt1YmVybmV0ZXMuaW8vYXV0b21hbmFnZWQiOiJvbnN0YXJ0In0sIm1hbmFnZWRGaWVsZHMiOlt7Im1hbmFnZXIiOiJrdWJlLWFwaXNlcnZlciIsIm9wZXJhdGlvbiI6IlVwZGF0ZSIsImFwaVZlcnNpb24iOiJhcGlyZWdpc3RyYXRpb24uazhzLmlvL3YxIiwidGltZSI6IjIwMjMtMDMtMTNUMjA6NTg6NDJaIiwiZmllbGRzVHlwZSI6IkZpZWxkc1YxIiwiZmllbGRzVjEiOnsiZjptZXRhZGF0YSI6eyJmOmxhYmVscyI6eyIuIjp7fSwiZjprdWJlLWFnZ3JlZ2F0b3Iua3ViZXJuZXRlcy5pby9hdXRvbWFuYWdlZCI6e319fSwiZjpzcGVjIjp7ImY6Z3JvdXBQcmlvcml0eU1pbmltdW0iOnt9LCJmOnZlcnNpb24iOnt9LCJmOnZlcnNpb25Qcmlvcml0eSI6e319fX1dfSwic3BlYyI6eyJ2ZXJzaW9uIjoidjEiLCJncm91cFByaW9yaXR5TWluaW11bSI6MTgwMDAsInZlcnNpb25Qcmlvcml0eSI6MX0sInN0YXR1cyI6eyJjb25kaXRpb25zIjpbeyJ0eXBlIjoiQXZhaWxhYmxlIiwic3RhdHVzIjoiVHJ1ZSIsImxhc3RUcmFuc2l0aW9uVGltZSI6IjIwMjMtMDMtMTNUMjA6NTg6NDJaIiwicmVhc29uIjoiTG9jYWwiLCJtZXNzYWdlIjoiTG9jYWwgQVBJU2VydmljZXMgYXJlIGFsd2F5cyBhdmFpbGFibGUifV19fQo="}],"more":true,"count":301}
```

And the value can be shown by `--print-value-only` option with `simple` as the write out layout,

```
/ #  etcdctl get --limit=1 --prefix --print-value-only /registry --write-out=simple
{"kind":"APIService","apiVersion":"apiregistration.k8s.io/v1","metadata":{"name":"v1.","uid":"cb4aaabf-bd4d-4233-99cf-05dbad581168","creationTimestamp":"2023-03-13T20:58:42Z","labels":{"kube-aggregator.kubernetes.io/automanaged":"onstart"},"managedFields":[{"manager":"kube-apiserver","operation":"Update","apiVersion":"apiregistration.k8s.io/v1","time":"2023-03-13T20:58:42Z","fieldsType":"FieldsV1","fieldsV1":{"f:metadata":{"f:labels":{".":{},"f:kube-aggregator.kubernetes.io/automanaged":{}}},"f:spec":{"f:groupPriorityMinimum":{},"f:version":{},"f:versionPriority":{}}}}]},"spec":{"version":"v1","groupPriorityMinimum":18000,"versionPriority":1},"status":{"conditions":[{"type":"Available","status":"True","lastTransitionTime":"2023-03-13T20:58:42Z","reason":"Local","message":"Local APIServices are always available"}]}}
```

### 5. `etcd` Pair Example

From the discussions, we can know that we have an API server pod in minikube as,

```bash
$ kubectl get pods -A | grep api 
kube-system   kube-apiserver-minikube            1/1     Running   0          151m
```

From the `etcd` node, it's value is under the key of `/registry/pods/kube-system/kube-apiserver-minikube`. The key value pair of pod `kube-apiserver-minikube` can be queried by,

```
/ #  etcdctl get --prefix /registry/pods/kube-system/kube-apiserver-minikube | more
```

And the output should be,

```
/registry/pods/kube-system/kube-apiserver-minikube
k8s
        
v1Pod?7
?
kube-apiserver-minikube
                       kube-system"*$7c4837d4-a568-47f4-aef1-7b0b82b278772????Z
       componentkube-apiserverZ
control-planebT
?kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint192.168.49.2:8443b=
kubernetes.io/config.hash bd8b8fe30652798a5ae3fc51e66ef681b?
ubernetes.io/config.mirror bd8b8fe30652798a5ae3fc51e66ef681b;
kubernetes.io/config.seen2023-03-13T20:58:44.823612464Zb#
ubernetes.io/config.sourcefilej<
Nodminikube"$19687d12-0294-4c67-9b92-da99bb928665*v10??
kubeletUpdatev????FieldsV1:?
?{"f:metadata":{"f:annotations":{".":{},"f:kubeadm.kubernetes.io/kube-apiserver.advertise-a
--More-- 

```

Here the first line is the key `/registry/pods/kube-system/kube-apiserver-minikube` of the api server pod. The rest lines are the values of this this key.
