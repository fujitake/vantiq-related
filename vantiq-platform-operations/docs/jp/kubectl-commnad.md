# はじめに

本記事では Vantiq Private Cloudの構築/保守作業において、最低限抑えておきたいkubectlコマンドの使い方について記載する。

# 目次
- [はじめに](#はじめに)
- [目次](#目次)
- [Kubernetesリソースの確認](#kubernetesリソースの確認)
  - [リソースの一覧からステータス確認](#リソースの一覧からステータス確認)
  - [各リソースの詳細表示](#各リソースの詳細表示)
  - [レプリカ数をスケールさせる](#レプリカ数をスケールさせる)
  - [Pod(コンテナ)のログを確認](#podコンテナのログを確認)
    - [Podのlogにタイムスタンプを表示する](#podのlogにタイムスタンプを表示する)
    - [Podのログがエスケープシーケンスで見にくい](#podのログがエスケープシーケンスで見にくい)
  - [よくある流れ](#よくある流れ)

# Kubernetesリソースの確認<a id="kubectl_resource_check"></a>
構築時や保守時の基本的な確認としてkubectl コマンドを利用したリソースの確認がある  
主に以下のような確認ができる    

- リソースの一覧からステータス確認
- 各リソースの詳細を確認
- 各Pod(コンテナ)のログを確認

## リソースの一覧からステータス確認
kubectl コマンドでKubernetesの各リソースの確認は以下のように行う
```bash
# <resource>: 表示したいリソースの種類でよく使うものは以下
# pod / deployment / statefulset / job / cronjob / service / pv / pvc / secret / configmap 
kubectl get <resource>

# -n <Namespace名>: Namespaceを指定
# -A: すべてのNamespaceのリソースを表示 
# -o wide: 詳細出力
# shared Namespace のPodを表示
kubectl get pod -n shared

# すべてのNamespaceのPodを表示
kubectl get pod -A

# すべてのNamespaceのPodの詳細も表示
kubectl get pod -A -o wide
```

※Namespace指定の-n / -A オプションはkubectl コマンド共通のオプション


## 各リソースの詳細表示
kubectl describeコマンドで各リソースの詳細を表示することができる

```bash
# <resource>: 表示したいリソースの種類
# <name>: 表示したいリソースの名前(kubectl get から確認可能)
kubectl describe <resource> <name>

# shared Namespaceのkeycloak-0 Podの詳細を表示
kubectl describe pod keycloak-0 -n shared

# shared Namespaceのkeycloakdb Secretの詳細を表示
kubectl describe secret keycloakdb -n shared
```

## レプリカ数をスケールさせる

```bash
# <resource>: スケールさせたいリソースの種類でよく使うものは以下
# deployment / statefulset  
kubectl scale <resource> <resource name> replicas <replica数>

# Vantiq StatefulSetのレプリカ数を0にする 
kubectl scale statefulset vantiq -n your-namespace --replicas 0

# telegraf-prom Deploymentのレプリカ数を0にする
kubectl scale deployment telegraf-prom -n shared --replicas 0
```

## Pod(コンテナ)のログを確認
```bash
# <pod-name>: 表示したいPodの名前(kubectl get から確認可能)
# -c: コンテナ名を指定(Pod内に複数コンテナが有る場合)
kubectl logs <pod-name> -c <コンテナ名>

# mongodb-0 の mongodbコンテナのログを確認
kubectl logs -n your-namespace mongodb-0 -c mongo
```

### Podのlogにタイムスタンプを表示する  
keycloakなどは以下のように`--timestamps`オプションで日付を表示する  
```bash
kubectl logs -n shared keycloak-0 --timestamps
```

### Podのログがエスケープシーケンスで見にくい
keycloakのlogが以下のように`ESC[...m`といった文字列が表示され見にくい
```log
ESC[0mESC[33m06:08:45,145 WARN  [org.wildfly.extension.elytron] ...
```

これは色文字のエスケープシーケンスのため、以下のようにlessの`-R`オプションでエスケープシーケンスを認識させて表示すると見やすくなる  
(上記の例は黄色文字のエスケープシーケンス)
```bash
kubectl logs -n shared keycloak-0 --timestamps | less -R
```

## よくある流れ
上記で紹介したコマンドを利用し、Podが正常起動していないときにどのように確認していくのか一例を紹介する  

まずPod一覧から正常起動していないPodを確認
```bash
$ kubectl get pod -n your-namespace -o wide
NAME                         READY   STATUS               RESTARTS   AGE    IP            NODE                     NOMINATED NODE   READINESS GATES
・・・
mongodb-0                    2/2     Running              0          40h    10.1.48.220   aks-mongodbnp-vmssxxxx   <none>           <none>
mongodb-1                    2/2     Running              0          40h    10.1.48.155   aks-mongodbnp-vmssxxxx   <none>           <none>
mongodb-2                    2/2     Running              0          40h    10.1.48.191   aks-mongodbnp-vmssxxxx   <none>           <none>
vantiq-0                     0/1     CrashLoopBackOff     0          36h    10.1.48.20    aks-vantiqnp-vmssxxxx    <none>           <none>
```

上記の場合`vantiq-0` Podの`STATUS`が異常(CrashLoopBackOff)なことが確認できたので、kubectl describeコマンドで詳細を確認する  
PodのSTATUSに関しては[Podのライフサイクル | Kubernetes](https://kubernetes.io/ja/docs/concepts/workloads/pods/pod-lifecycle/#pod-phase)を参照
```bash
$ kubectl describe pod -n your-namespace vantiq-0
Name:         vantiq-0
・・・
Containers:
  vantiq:
    State:          CrashLoopBack
    Ready:          False
・・・
Events:                      
  FirstSeen	LastSeen	Count	From					                  SubobjectPath		        Type		  Reason		Message
  ---------	--------	-----	----					                  -------------		        --------	------		-------
  <Events>
```

`Containers`フィールドからコンテナのステータス、`Events`フィールドからエラーメッセージなどを確認  
(複数コンテナが起動しているPodではエラーが発生しているコンテナをContainersフィールドのStateから特定する)  
Eventsから原因が特定できない場合などはkubectl logs コマンドでコンテナログを確認  

Pod起動前に初期化処理などを行うinitコンテナで処理が失敗する場合もあり、その場合はkubectl get コマンドで以下のように表示されたりする  
initコンテナに関するSTATUSについては[Initコンテナのデバッグ | Kubernetes](https://kubernetes.io/ja/docs/tasks/debug/debug-application/debug-init-containers/#understanding-pod-status)を参照
```bash
$ kubectl get pod -n your-namespace -o wide
NAME                         READY   STATUS               RESTARTS   AGE    IP            NODE                     NOMINATED NODE   READINESS GATES
・・・
mongodb-0                    2/2     Running              0          40h    10.1.48.220   aks-mongodbnp-vmssxxxx   <none>           <none>
mongodb-1                    2/2     Running              0          40h    10.1.48.155   aks-mongodbnp-vmssxxxx   <none>           <none>
mongodb-2                    2/2     Running              0          40h    10.1.48.191   aks-mongodbnp-vmssxxxx   <none>           <none>
vantiq-0                     1/3     Init:Error           0          36h    10.1.48.20    aks-vantiqnp-vmssxxxx    <none>           <none>
```

この場合も同様にkubectl describe コマンドでPodの詳細を確認
```bash
$ kubectl describe pod -n your-namespace vantiq-0
Name:         vantiq-0
・・・
Init Containers:
  keycloak-init:
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
    Ready:          True
  mongo-available:
    ・・・
    State:          Waiting
      Reason:       CrashLoopBackOff
    State:          Terminated
      Reason:       Error
    Ready:          False
    ・・・
  load-model:
    ・・・
    State:          Waiting
      Reason:       PodInitializing
    Ready:          False
・・・
Events:                      
  FirstSeen	LastSeen	Count	From					                  SubobjectPath		        Type		  Reason		Message
  ---------	--------	-----	----					                  -------------		        --------	------		-------
  <Events>
```

initコンテナで起動に失敗している場合は、`Init Containers`フィールドを確認する  
上記の場合は`mongo-available` initコンテナでエラーが発生しているため、`Events`フィールドや以下のようにkubectl logsコマンドでエラー内容を確認し対応する  

```bash
# initコンテナの場合も-cオプションで対象のコンテナ名を指定すれば良い
kubectl logs -n your-namespace vantiq-0 -c mongo-available
```
