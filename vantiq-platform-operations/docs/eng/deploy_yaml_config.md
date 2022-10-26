# Customized configuration of deploy.yaml
This article describes an example configuration that requires customization according to Private Cloud requirements. The default configuration is defined by [k8sdeploy](https://github.com/Vantiq/k8sdeploy) (permission required), but the default settings are overridden in `deploy.yaml`.  


## Configuration for use of optional components  

##### mongodb backup
Enable backup. For the details of Backup, refer to [k8sdeploy_tools](https://github.com/Vantiq/k8sdeploy_tools) (permission required).  

```yaml
vantiq:
...
  mongodb:
    backup:
      enabled: true
      provider: azure
      schedule: "@daily"
      bucket: mongodbbackup
```

#### userdb
Configure userdb. Of the persistent data handled by Vantiq, system-related data is stored in `mongodb` and user-owned data is stored in `userdb`.  

```yaml
vantiq:
...
  userdb:
    enabled: true
```
For enabling Backup   
```yaml
vantiq:
...
  userdb:
    enabled: true
    backup:
      enabled: true
      provider: azure
      schedule: "@daily"
      bucket: userdbbackup
```



#### metrics-collector
Decouple the metrics collection function from the `vantiq` server as a `metrics-collector` to improve the performance of the main unit.   

```yaml
vantiq:
...
  metricsCollector:
    enabled: true
```

## Server resource limitations for each component  
Limit resource requests and upper limits so that they are scheduled to smaller Nodes. The `cpu` and `memory` are reference values that have been confirmed in operation and are not recommended values or lower limits.
Adjustments will be required as appropriate.  

#### vantiq server

```yaml
vantiq:
...
  resources:
    limits:
      cpu: 2
      memory: 3Gi

    requests:
      cpu: 1
      memory: 2Gi
```

#### mongodb
```yaml
vantiq:
...
  mongodb:
  ...
    resources:
      limits:
        cpu: 2
        memory: 4Gi
      requests:
        cpu: 0.5
        memory: 2Gi
    persistentVolume:
      size: 50Gi
```

#### influxdb
```yaml
influxdb:

  persistence:
    size: 50Gi

  resources:
    limits:
      cpu: 2
      memory: 3Gi

    requests:
      cpu: 0.5
      memory: 1Gi
```

#### metrics-collector
```yaml
vantiq:
...
  metricsCollector:
  ...
    resources:
      limits:
        cpu: 1
        memory: 3Gi

      requests:
        cpu: 0.5
        memory: 2Gi
```

## Configurations for Affinity  
Guide pods to a specific labeled Node by setting up affinity additionally.  

#### influxdb

Schedule to a Node whose label name `vantiq.com/workload-preference` with value `influx`.  


```yaml
influxdb:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 50
        preference:
          matchExpressions:
          - key: vantiq.com/workload-preference
            operator: In
            values:
            - influxdb
  ```

#### mongodb

Schedule a Node whose label name `vantiq.com/workload-preference` with a value of `database` and which is exclusive to other pods with labels as `mongodb`, `vantiq`, `influxdb`, etc.  

```yaml
vantiq:
...
  mongodb:
  ...
    affinity: |
      nodeAffinity:
        {{- if eq .Values.workloadPreference "hard" }}
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: vantiq.com/workload-preference
              operator: In
              values:
              - database
        {{- else }}
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 50
          preference:
            matchExpressions:
            - key: vantiq.com/workload-preference
              operator: In
              values:
              - database
        {{- end }}
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
                - key: app
                  operator: In
                  values:
                    - mongodb
                    - vantiq
                    - vision-analytics
                    - metrics-collector
                    - influxdb-influxdb
                    - influxdb
            topologyKey: kubernetes.io/hostname
```

## Version specification of components  
Use to specify a different version for a particular component other than the standard configuration packaged as `vantiq_system_release`.  

#### keycloak

```yaml
keycloak:
  image:
    tag: 15.0.1-1
```

#### telegraf-prom
```yaml
telegraf-prom:
  image:
    tag: 1.15.2-alpine
```
