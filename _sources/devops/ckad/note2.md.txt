# CKAD 2 | Multicontainer Pods

### Logging

- Check pod logs

```
kubectl logs podName
```

- Check container logs in a pod

```
kubectl logs podName containerName
```

### Monitoring 

- Check node resource

```
kubectl top nodes
```

- Check pod resource

```
kubectl top pods
```

### [Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#:~:text=The%20kubelet%20uses%20readiness%20probes,removed%20from%20Service%20load%20balancers.)

- Readiness Probe 

By leveraging readiness probes, Kubernetes can ensure that only healthy and fully operational containers receive traffic from services or other pods, preventing requests from being sent to containers that are still starting up or experiencing issues. Here's a http readiness probe example,

```
spec -> containers ->

- readinessProbe:
    httpGet:
      path: /path
      port: portNum
    periodSeconds: periodValue
    initialDelaySeconds: delayValue
```

- Liveness Probe 

The liveness probe focuses on the ongoing health of a container, automatically restarting it if needed. Here's a http liveness probe example,

```
spec -> containers ->

- livenessProbe:
    httpGet:
      path: /path
      port: portNum
    periodSeconds: periodValue
    initialDelaySeconds: delayValue
```

### [initContainers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)

Init containers are specialized containers that run before app containers in a Pod.

- Configuration

```
spec -> initContainers -> 

- name: initContainerName
  image: initContainerImage
# The rest is similar to a normal container
```

