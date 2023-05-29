# CKAD 4 | Services & Networking

### Types of Services

- ClusterIP: It exposes the Service on an internal IP address that is only reachable from within the cluster. The service will be mapping from source IP to target IP.
- NodePort: It exposes the Service on a static port on each selected node in the cluster and these ports can be accessible by the external clients directly.
- LoadBalancer
- ExternalName

### ClusterIP

- Create ClusterIP Definition

```
kubectl create svc clusterip svcName --tcp=sourceIP:targetIP -o yaml --dry-run=client > svcName.yaml
```

### NodePort

- Create NodePort Definition

```
kubectl create svc nodeport svcName --tcp=sourceIP:targetIP --node-port=nodePortNum -o yaml --dry-run=client > svcName.yaml
```

### Network Policies

- Get network policies

```
kubectl get netpol
```

- Network Policy Definition

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: netpolName
spec:
  podSelector:
    matchLabels:
      key1: value1
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
      - podSelector:
          matchLabels:
            key2: value2
      ports:
        - protocol: TCP
          port: portNum1
  egress:
    - to:
      - podSelector:
          matchLabels:
            key3: value3
      ports:
        - protocol: TCP
          port: portNum2
```

### Ingress

- Get ingress

```
kubectl get ingress -A
```

- Edit ingress definition

```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingressName
spec:
  rules:
  - http:
      paths:
      - backend:
          service:
            name: svcName
            port:
              number: svcPortNum
        path: URLPath
        pathType: Prefix
```

