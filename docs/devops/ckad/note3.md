# CKAD 3 | Pod Design

### Labels and Selectors

- select pod by labels

```
kubectl get pods --selector key=value --show-labels
```

- select all object by labels

```
kubectl get all --selector key=value --show-labels
```

- select pods by multiple labels

```
kubectl get pods --selector key1=value1,key2=value2
```

### Rolling Updates & Rollbacks

- image update

```
kubectl edit objectType objectName
# then change the image
```

- edit strategy to recreate

    - **Recreate**: All old pods are terminated before any new pods are added. Note that there can be a downtime expected because all the containers are brought down at one time.

```
spec -> strategy:

type: Recreate
```


- edit strategy to rolling update

    - **RollingUpdate**: New pods are added gradually, and old pods are terminated gradually
    - **maxSurge**: The number of pods that can be created above the desired amount of pods during an update
    - **maxUnavailable**: The number of pods that can be unavailable during the update process

```
spec -> strategy:

rollingUpdate:
  maxSurge: 25%
  maxUnavailable: 25%
type: RollingUpdate
```

### Jobs

- Create a job definition

```
kubectl create job jobName --image=kodekloud/throw-dice --dry-run=client -o yaml > jobName.yaml
```

- Edit a job definition
    - **backoffLimit**: how many times it can fail before it reaches one success. Setting a large number will ensure the job does not quit before it succeeds.
    - **completions**: how many times of success do we need to reach the success.
    - **parallelism**: how many jobs of completion can run in parallel.

```
apiVersion: batch/v1
kind: Job
metadata:
  name: jobName
spec:
  completions: compNum
  parallelism: paraNum
  backoffLimit: limitNum
  template:
    spec:
      containers:
      - name: containerName
        image: imageName
```

### CronJob

- Cronjob definition
    - **schedule**: the time of execution in the cronjob format. Reference: https://crontab.guru/

```
apiVersion: batch/v1
kind: CronJob
metadata:
  name: jobName
spec:
  schedule: cornjobSchedule
  jobTemplate:
    spec:
      completions: compNum
      parallelism: paraNum
      backoffLimit: limitNum
      template:
        spec:
          containers:
          - name: containerName
            image: imageName
```
