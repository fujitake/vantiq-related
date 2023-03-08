# InfluxDB PV拡張手順

## InfluxDBのPVに空きがなくなってしまった際の影響
InfluxDBのPVの空き容量がなくなるとVantiqのSystem adminのGrafanaのグラフ表示がされなかったり、以下のように influxdb や telegraf-prom, telegraf-ds Podでエラーログが出力されたりするようになる。  

- influxdb
```log
[httpd] 172.20.12.164 - admin [06/Mar/2023:01:29:56 +0000] "POST /write?db=kubernetes HTTP/1.1 " 500 132 "-" "Telegraf/1.21.3 Go/1.17.5" 6723466c-bbbe-11ed-bb97-aa792124062e 11219
ts=2023-03-06T01:29:56.701118Z lvl=error msg="[500] - \"engine: error writing WAL entry: write /var/lib/influxdb/wal/kubernetes/autogen/126/_00005.wal: no space left on device\"" log_id=0gHQ4vF0000 service=httpd
ts=2023-03-06T01:30:00.019709Z lvl=info msg="failed to store statistics" log_id=0gHQ4vF0000 service=monitor error="engine: error writing WAL entry: write /var/lib/influxdb/wal/_internal/monitor/125/_00008.wal: no space left on device"
```

- telegraf-prom
```log
2023-03-06T01:30:00Z E! [outputs.influxdb] When writing to [http://influxdb:8086]: 500 Internal Server Error: engine: error writing WAL entry: write /var/lib/influxdb/wal/kubernetes/autogen/126/_00005.wal: no space left on device
2023-03-06T01:30:00Z E! [agent] Error writing to outputs.influxdb: could not write any address
```

- telegraf-ds
```log
2023-03-06T01:29:53Z E! [outputs.influxdb] When writing to [http://influxdb:8086]: 500 Internal Server Error: engine: error writing WAL entry: write /var/lib/influxdb/wal/kubernetes/autogen/126/_00005.wal: no space left on device
2023-03-06T01:29:53Z E! [agent] Error writing to outputs.influxdb: could not write any address
```

influxdb Podにアクセスして以下のように対象のディレクトリの容量を確認できる。  

```bash
$ kubectl exec -it -n shared influxdb-0 -- bash
bash-5.1# du -sh /var/lib/influxdb/
49.0G   /var/lib/influxdb/
bash-5.1# df -hT
Filesystem           Type            Size      Used Available Use% Mounted on
・・・
/dev/nvme1n1         ext4           49.0G     49.0G         0 100% /var/lib/influxdb
・・・
```


## 前提
- EKS/AKS v1.23以降
- CSI Driverが有効化されている

### CSI Driverが有効になっているかの確認方法
- EKS  
以下のDeployment, DaemonSetが動作しているか確認する。  
```bash
$ kubectl get deployment,ds -n kube-system -l app.kubernetes.io/component=csi-driver
NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ebs-csi-controller   2/2     2            2           68d

NAME                                  DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR              AGE
daemonset.apps/ebs-csi-node           11        11        11      11           11          kubernetes.io/os=linux     68d
daemonset.apps/ebs-csi-node-windows   0         0         0       0            0           kubernetes.io/os=windows   68d
$
$ kubectl get po -o wide -n kube-system -l app.kubernetes.io/component=csi-driver
NAME                                READY   STATUS    RESTARTS   AGE     IP              NODE                                          NOMINATED NODE   READINESS GATES
ebs-csi-controller-57f4f9fd-7pxch   6/6     Running   0          6d16h   172.20.11.208   ip-172-20-11-138.us-west-2.compute.internal   <none>           <none>
ebs-csi-controller-57f4f9fd-n8gh4   6/6     Running   0          6d16h   172.20.10.91    ip-172-20-10-73.us-west-2.compute.internal    <none>           <none>
ebs-csi-node-2kl8g                  3/3     Running   0          6d17h   172.20.11.121   ip-172-20-11-55.us-west-2.compute.internal    <none>           <none>
ebs-csi-node-6vm9q                  3/3     Running   0          6d17h   172.20.10.65    ip-172-20-10-160.us-west-2.compute.internal   <none>           <none>
ebs-csi-node-c5gq6                  3/3     Running   0          6d17h   172.20.11.125   ip-172-20-11-138.us-west-2.compute.internal   <none>           <none>
ebs-csi-node-cz9dm                  3/3     Running   0          6d17h   172.20.11.254   ip-172-20-11-190.us-west-2.compute.internal   <none>           <none>
ebs-csi-node-dr5nk                  3/3     Running   0          6d17h   172.20.12.54    ip-172-20-12-120.us-west-2.compute.internal   <none>           <none>
ebs-csi-node-fpp76                  3/3     Running   0          6d17h   172.20.11.200   ip-172-20-11-73.us-west-2.compute.internal    <none>           <none>
ebs-csi-node-jgflc                  3/3     Running   0          6d17h   172.20.10.23    ip-172-20-10-83.us-west-2.compute.internal    <none>           <none>
ebs-csi-node-kxqdx                  3/3     Running   0          6d17h   172.20.10.244   ip-172-20-10-73.us-west-2.compute.internal    <none>           <none>
ebs-csi-node-mq7qv                  3/3     Running   0          6d17h   172.20.12.64    ip-172-20-12-196.us-west-2.compute.internal   <none>           <none>
ebs-csi-node-wvd2t                  3/3     Running   0          6d      172.20.10.159   ip-172-20-10-136.us-west-2.compute.internal   <none>           <none>
ebs-csi-node-xbt74                  3/3     Running   0          6d17h   172.20.12.188   ip-172-20-12-93.us-west-2.compute.internal    <none>           <none>
```

- AKS  
以下のDaemonSetが動作しているか確認する。  
```bash
$ kubectl get ds -n kube-system -o wide csi-azuredisk-node
NAME                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE    CONTAINERS                                       IMAGES                                                                                                                                                                                       SELECTOR
csi-azuredisk-node   11        11        11      11           11          <none>          358d   liveness-probe,node-driver-registrar,azuredisk   mcr.microsoft.com/oss/kubernetes-csi/livenessprobe:v2.6.0,mcr.microsoft.com/oss/kubernetes-csi/csi-node-driver-registrar:v2.5.0,mcr.microsoft.com/oss/kubernetes-csi/azuredisk-csi:v1.26.2   app=csi-azuredisk-node
system@opnode-1:~$
system@opnode-1:~$ kubectl get po -n kube-system -o wide -l app=csi-azuredisk-node
NAME                       READY   STATUS    RESTARTS   AGE     IP            NODE                                 NOMINATED NODE   READINESS GATES
csi-azuredisk-node-4x42q   3/3     Running   0          10m     10.1.48.6     aks-vantiqnp-41304253-vmss000018     <none>           <none>
csi-azuredisk-node-659jp   3/3     Running   0          10m     10.1.48.122   aks-keycloaknp-41304253-vmss000018   <none>           <none>
csi-azuredisk-node-6lw4d   3/3     Running   0          9m53s   10.1.48.93    aks-keycloaknp-41304253-vmss000017   <none>           <none>
csi-azuredisk-node-bzz2g   3/3     Running   0          10m     10.1.48.64    aks-vantiqnp-41304253-vmss00001a     <none>           <none>
csi-azuredisk-node-c86n2   3/3     Running   0          10m     10.1.48.35    aks-vantiqnp-41304253-vmss000019     <none>           <none>
csi-azuredisk-node-gw57z   3/3     Running   0          10m     10.1.48.209   aks-mongodbnp-34842842-vmss00001c    <none>           <none>
csi-azuredisk-node-hf59s   3/3     Running   0          10m     10.1.48.151   aks-keycloaknp-41304253-vmss000019   <none>           <none>
csi-azuredisk-node-jl8ss   3/3     Running   0          10m     10.1.48.238   aks-mongodbnp-34842842-vmss00001d    <none>           <none>
csi-azuredisk-node-r9r6n   3/3     Running   0          10m     10.1.48.180   aks-mongodbnp-34842842-vmss00001b    <none>           <none>
csi-azuredisk-node-vwb95   3/3     Running   0          10m     10.1.49.11    aks-grafananp-12051192-vmss00000f    <none>           <none>
csi-azuredisk-node-zksvg   3/3     Running   0          10m     10.1.49.40    aks-metricsnp-53833300-vmss00000f    <none>           <none>

```

## 拡張実施を行う際の影響
InfluxDBの再起動(削除&再デプロイ)が必要なため、一時的にInfluxDBがダウンします。  
そのため、PVの空きがある状態の場合ダウンしている間のメトリクスは取得できません。  

VantiqやMongoDBなどの主要コンポーネントに影響はありません。  

## 拡張手順

本手順では以下のように50GBのinfluxdbのPVを55GBに変更する。  
```bash
$ kubectl get pv -o wide -n shared
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                             STORAGECLASS   REASON   AGE   VOLUMEMODE
pvc-6b18ccfa-xxxx-xxxx-xxxx-xxxxxxxxxxxx   50Gi       RWO            Retain           Bound      shared/influxdb-data-influxdb-0   vantiq-sc               69d   Filesystem
・・・

$ kubectl get pv -o wide
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                             STORAGECLASS   REASON   AGE   VOLUMEMODE
pvc-6b18ccfa-xxxx-xxxx-xxxx-xxxxxxxxxxxx   50Gi       RWO            Retain           Bound      shared/influxdb-data-influxdb-0   vantiq-sc               69d   Filesystem
・・・
```

1. kubectl edit pvcコマンドでPVのサイズを編集  
以下のように`spec.resources.request.storage`を変更する。  
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
spec:
  ・・・
  resources:
    requests:
      storage: 55Gi
```

変更後、以下のようにpvc, pvのCAPACITYが変更されていることを確認する。
```bash
$ kubectl get pvc -o wide -n shared
NAME                       STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE   VOLUMEMODE
influxdb-data-influxdb-0   Bound    pvc-6b18ccfa-xxxx-xxxx-xxxx-xxxxxxxxxxxx   55Gi       RWO            vantiq-sc      69d   Filesystem
・・・

$ kubectl get pv -o wide
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                             STORAGECLASS   REASON   AGE   VOLUMEMODE
pvc-6b18ccfa-xxxx-xxxx-xxxx-xxxxxxxxxxxx   55Gi       RWO            Retain           Bound      shared/influxdb-data-influxdb-0   vantiq-sc               69d   Filesystem
・・・
```


2. InfluxDB StatefulSetを削除  
```bash
$ kubectl delete sts -n shared influxdb
```


3. InfluxDBを再起動  
以下のように`deploy.yaml`の`influxdb.persistence.size`を変更する。 
```yaml
influxdb:
  persistence:
    size: 55Gi
```

```bash
$ ./gradlew -Pcluster=<YOUR-CLUSTER> deployShared
```


4. 対象のディレクトリの空き容量が増えたことをPod内から確認
```bash
$ kubectl exec -it -n shared influxdb-0 -- bash
bash-5.1# du -sh /var/lib/influxdb/
49.0G   /var/lib/influxdb/
bash-5.1# df -hT
Filesystem           Type            Size      Used Available Use% Mounted on
・・・
/dev/nvme1n1         ext4           54.0G     49.0G      4.9G  91% /var/lib/influxdb
・・・

```

またVantiq System adminのGrafanaのグラフが表示されるようになったこと、influxdb, telegraf-prom, telegraf-dsのPodのログでエラーが発生しなくなったことを確認する。  


※変更ができなかった場合のログ確認  
pvcやpvの詳細をkubectl describeコマンドなどで確認する。  
また、以下のようにCSI Driverのlogも確認する。DaemonSetはInfluxDBがスケジュールされているNode上に存在するPodのlogを確認する。    
(以下はEKSでresizeが成功した場合のログ)
```bash
# EKSはコントローラーもあるのでそちらのlogも確認
$ kubectl logs -n kube-system ebs-csi-controller-57f4f9fd-7pxch -c csi-resizer
・・・
I0306 02:29:43.547894       1 event.go:285] Event(v1.ObjectReference{Kind:"PersistentVolumeClaim", Namespace:"shared", Name:"influxdb-data-influxdb-0", UID:"6b18ccfa-xxxx-xxxx-xxxx-xxxxxxxxxxxx", APIVersion:"v1", ResourceVersion:"18244763", FieldPath:""}): type: 'Normal' reason: 'Resizing' External resizer is resizing volume pvc-6b18ccfa-xxxx-xxxx-xxxx-xxxxxxxxxxxx
I0306 02:29:43.663421       1 event.go:285] Event(v1.ObjectReference{Kind:"PersistentVolumeClaim", Namespace:"shared", Name:"influxdb-data-influxdb-0", UID:"6b18ccfa-xxxx-xxxx-xxxx-xxxxxxxxxxxx", APIVersion:"v1", ResourceVersion:"18244763", FieldPath:""}): type: 'Normal' reason: 'FileSystemResizeRequired' Require file system resize of volume on node
$
$
$ kubectl logs -n kube-system ebs-csi-node-wvd2t
Defaulted container "ebs-plugin" out of: ebs-plugin, node-driver-registrar, liveness-probe
・・・
I0306 02:29:46.599234       1 resizefs_linux.go:71] Device /dev/nvme1n1 resized successfully

```

# 参考
- [kubernetes-sigs/aws-ebs-csi-driver: CSI driver for Amazon EBS https://aws.amazon.com/ebs/](https://github.com/kubernetes-sigs/aws-ebs-csi-driver)
- [aws-ebs-csi-driver/examples/kubernetes/resizing](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/tree/8803fbf2d46de300891ac65b8b449783fd79ce02/examples/kubernetes/resizing)
- [azuredisk-csi-driver/README.md at c1411783e26096ded05e391f5a5d1571ed9d6cd3 · kubernetes-sigs/azuredisk-csi-driver](https://github.com/kubernetes-sigs/azuredisk-csi-driver/blob/c1411783e26096ded05e391f5a5d1571ed9d6cd3/deploy/example/resize/README.md)
