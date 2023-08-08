# deploy.yamlのカスタマイズ構成
この記事ではPrivate Cloud要件に応じてカスタマイズが必要な場合の構成例を説明する。
[k8sdeploy](https://github.com/Vantiq/k8sdeploy)（要権限）により、既定の構成が定義されているが、`deploy.yaml`で既定の設定をオーバーライドする。


## オプションのコンポーネントの利用設定

##### mongodb backup
backupを有効化する。Backupの詳細は[k8sdeploy_tools](https://github.com/Vantiq/k8sdeploy_tools)（要権限）を参照。

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
userdbを構成する。Vantiqで扱う永続データのうち、システム関連を`mongodb`, ユーザー所有を`userdb`に保存する。  
ISVモデルでマルチテナントに展開する場合、`userdb`を構成する。

```yaml
vantiq:
...
  userdb:
    enabled: true
```
Backupを有効化する場合
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

以下は、さらに`userdb`のバックアップと意図したNodeにスケジュールされるよう`affinity`を追加した例。
```yaml
vantiq:
  userdb:
    enabled: true
    backup:
      enabled: true
      provider: azure
      schedule: "@daily"
      bucket: userdbbackup

    affinity: |
      nodeAffinity:
        {{- if eq .Values.workloadPreference "hard" }}
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: vantiq.com/workload-preference
              operator: In
              values:
              - userdb
        {{- else }}
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 50
          preference:
            matchExpressions:
            - key: vantiq.com/workload-preference
              operator: In
              values:
              - userdb
        {{- end }}
      podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
                - key: app
                  operator: In
                  values:
                    - userdb
                    - vantiq
                    - vision-analytics
                    - metrics-collector
                    - influxdb-influxdb
                    - influxdb
            topologyKey: kubernetes.io/hostname
```


#### metrics-collector
`vantiq`サーバーからのメトリクス収集機能を`metrics-collector`として切り離し、本体の性能を向上させる。

```yaml
vantiq:
...
  metricsCollector:
    enabled: true
```

## 各コンポーネントのサーバーのリソース制限
リソース要求と上限を制限することで、小さいNodeにスケジュールされるようにする.
`cpu`と`memory`は稼働確認済みの参考値であり、推奨値や下限値ではない。適宜調整が必要。

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

## Affinityの設定
追加でaffinityを設定することで、特定のラベルがついたNodeにPodを誘導する。

#### influxdb

ラベル名`vantiq.com/workload-preference`の値が`influx`となっているNodeにスケジュールする。


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

ラベル名`vantiq.com/workload-preference`の値が`database`となっているNodeであり、かつ、`mongodb`,`vantiq`, `influxdb`などのラベルの他のpodと排他的になるよう、スケジュールする。

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

## コンポーネントのバージョン指定
`vantiq_system_release`としてパッケージされている標準の構成のうち、特定のコンポーネントについて異なるバージョンを指定したい場合に使用する

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
