# CKAD 1 | Core Concepts

### Basic Creation commands

- create pod

```
kubectl run podName --image=imageName --env=KEY=VALUE --labels=key=value --port=PortNum
```

- delete pod

```
kubectl delete po podName
```

- create deployment

```
kubectl create deployment depName --image=imageName -r replicaCount --port=PortNum
```

- configMap

```
kubectl create cm cmName --from-literal=key=value
```

- service

```
kubectl create svc clusterip svcName --tcp=sourceIP:targetIP
```

- secret

```
kubectl create secret generic secretName --from-literal=key=value
```

- apply file

```
kubectl apply -f fileName
```

- bind secret and configmap

```
kubectl set env --from=secret/secretName --from=configmap/cmName objectType/objectName
```

- update resource limits

```
kubectl set resources objectType objectName --limits=cpu=cpuQuotaUpperBound,memory=memQuotaUpperBound --requests=cpu=cpuQuotaLowerBound,memory=memQuotaLowerBound
```

- label pod

```
kubectl label pods podName key=value --overwrite
```

- update replicas

```
kubectl scale --replicas=repValue deployment/deploymentName
```

- execute on pod

```
kubectl exec podName -c containerName -- command
```

- unschedule node

```
kubectl cordon nodeName
```

- node for maintaince

```
kubectl drain nodeName
```

- bring node back

```
kubectl uncordon nodeName
```

- taint node

```
kubectl taint node nodeName key=value:NoSchedule-
```

- edit with YAML

```
kubectl edit objectType/objectName -o yaml 
```

- force replace YAML to update (don't need to specify the object)

```
kubectl replace -f fileName --force
```

- get pod logs

```
kubectl logs podName -n namespace
```

### Commands and Arguments

- Update pod container commands

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: podName
spec:
    containers:
    - name: containerName
      image: containerImage
      command:
      - commands
      - to
      - be
      - executed
      args:
      - command
      - arguments
```

Can also be written as,

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: podName
spec:
    containers:
    - name: containerName
      image: containerImage
      command: ["commands", "to", "be", "executed"]
      args: ["command", "arguments"]
```

- `ENTRYPOINT` commands in the Dockerfile will be override by pod defination
- We can only specify the argument to use the commands in Dockerfile by default

### Environment Variables

```yaml
apiVersion: v1
kind: Pod
metadata:
    name: podName
spec:
    containers:
    - name: containerName
      image: containerImage
      env:
      - name: ENVVARNAME
        value: envVarValue
```

### Configmap

- Create configmap by,

```bash
$ kubectl create cm configMapName --from-literal=key=val
```

- Bind pod with one key in configMap 

```yaml
apiVersion: v1
kind: Pod
metadata: 
  name: podName
spec:
  containers:
    - name: containerName
      image: containerImage
      env:
        - name: KEY
          valueFrom:
            configMapKeyRef:
              name: cmName
              key: KEY
```

- Bind pod with all Keys in configMap

```yaml
apiVersion: v1
kind: Pod
metadata: 
  name: podName
spec:
  containers:
    - name: containerName
      image: containerImage
      envFrom:
        - configMapRef:
            name: cmName
```

### Secrets

- Create a serect: must use `generic`

```bash
$ kubectl create secret generic secretName --from-literal=KEY=value
```

- Bind pod with secret

```yaml
apiVersion: v1
kind: Pod
metadata: 
  name: podName
spec:
  containers:
    - name: containerName
      image: containerImage
      envFrom:
        - secretRef:
            name: secretName
```

### Pod Execution

- One command

```bash
$ kubectl exec -it podName -- command
```

- Get shell

```bash
$ kubectl exec -it podName -- sh
```

### Security Context

- Specify user for all containers in a pod

```yaml
apiVersion: v1
kind: Pod
metadata: 
  name: podName
spec:
  securityContext:
    runAsUser: userID
  containers:
    - name: containerName
      image: containerImage
```

- Specify user for one container

```yaml
apiVersion: v1
kind: Pod
metadata: 
  name: podName
spec:
  containers:
    - name: containerName
      image: containerImage
      securityContext:
        runAsUser: userID
```

- Grant container privileges of `CAP_SYS_TIME`

```yaml
apiVersion: v1
kind: Pod
metadata: 
  name: podName
spec:
  containers:
    - name: containerName
      image: containerImage
      securityContext:
        capabilities:
          add: ["SYS_TIME"]
```

### Resources

- Set memory limitations

```yaml
apiVersion: v1
kind: Pod
metadata: 
  name: podName
spec:
  containers:
    - name: containerName
      image: containerImage
      resources:
        limits:
          memory: 10Mi
        requests:
          memory: 5Mi
```

### Node Affinity

- Show labels

```
$ kubectl get node --show-labels
```

- Set a label

```
$ kubectl set node nodeName key=value
```



