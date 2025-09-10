# はじめに
本記事ではVantiq保守作業において、[k8sdeploy_tools](https://github.com/Vantiq/k8sdeploy_tools) _(要権限)_ でカバーされていない補足の説明について記載する。
kubectl コマンドの簡易的な使い方については[kubectlコマンドの使い方](./kubectl-commnad.md)を参照。

Vantiqプラットフォームに関する保守項目一覧は以下の通り。

\# | 項目名                            | 説明                                                                                                                            | 適切なタイミング                                                | 準備期間の目安 | 更新時のサービス停止 | 作業者
---|-----------------------------------|---------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------|----------------|----------------------|-------------------
1  | [Vantiq ライセンス更新](#renew_license_files)              | Vantiq クラスタが参照するライセンスファイル。**ライセンスが有効でない場合、Vantiq サービスが停止される。**                        | PO 発行後、ライセンス期限前                             | 1 week         | 必要なし             | Vantiq サポート
2  | [SSL 証明書更新](#renew_ssl_certificate)                     | Vantiq クラスタで使用する SSL 証明書。<br />**有効期限が切れると、Vantiq IDE にログインや、HTTPS REST でサービス接続ができなくなる。**     | 証明書の有効期限前                                     | 2 weeks        | 必要なし             | Vantiq サポート
3  | [Vantiq マイナーバージョンアップ](#vantiq_minor_version_upgrade)    | Vantiq の機能追加を伴うバージョンアップを行う。                                                                                  | 概ね 4ヶ月に一度（年3回）                                            | 1 week         | 必要                 | Vantiq サポート
4  | [Vantiq パッチバージョンアップ](#vantiq-patch-version-upgrade)      | Vantiq の現行バージョンの不具合修正を行うバージョンアップを行う。                                                                | 随時。運用上支障がある不具合修正のリリース時。                  | 2 days         | 必要なし             | Vantiq サポート
5  | [Vantiq Sharedコンポーネントバージョンアップ](#vantiq-patch-version-upgrade)      | Vantiq のKeycloakやGrafanaなどのバージョンアップを行う。                                                                | Vantiqマイナーバージョンアップと同タイミング、もしくはSharedコンポーネントで運用上支障がある不具合修正のリリース時。                  | 2 days         | バージョンアップ内容による             | Vantiq サポート
6 | [service principal アカウントの更新](https://learn.microsoft.com/ja-jp/azure/aks/update-credentials) | （AzureでInternal Load Balancerを構成する場合のみ）<br />Vantiq を Private 構成にするため、AKS に権限を持つ Service Principal を使用している。<br />**有効期限切れ後サービスが停止する可能性ある。** | Service Principal の有効期限前。                                 | 1 week         | 必要                 | Vantiq サポート


# 目次

[保守作業](#the_maintenance_operations)  
- [はじめに](#はじめに)
- [目次](#目次)
- [保守作業](#保守作業)
  - [k8sdeploy toolsによる保守作業時のPodの再起動について](#k8sdeploy-toolsによる保守作業時のpodの再起動について)
    - [deployコマンド実行前の現状とのマニフェストの差分確認方法](#deployコマンド実行前の現状とのマニフェストの差分確認方法)
  - [Vantiqバージョンアップ作業](#vantiqバージョンアップ作業)
    - [Vantiq Minor Version Upgrade](#vantiq-minor-version-upgrade)
    - [Vantiq Minor Version Upgrade - Rollback](#vantiq-minor-version-upgrade---rollback)
    - [Vantiq Patch Version Upgrade](#vantiq-patch-version-upgrade)
    - [Vantiq Patch Version Upgrade - Rollback](#vantiq-patch-version-upgrade---rollback)
    - [Vantiq Shared Component Version Upgrade](#vantiq-shared-component-version-upgrade)
    - [Vantiq Shared Componen Version Upgrade - Rollback](#vantiq-shared-componen-version-upgrade---rollback)
  - [Kubernetesバージョンアップ作業](#kubernetesバージョンアップ作業)
    - [Kubernetes Minor Version Upgrade](#kubernetes-minor-version-upgrade)
  - [更新作業](#更新作業)
    - [SSL 証明書を更新する](#ssl-証明書を更新する)
    - [SSL 証明書を更新する - Rollback](#ssl-証明書を更新する---rollback)
    - [License ファイルを更新する](#license-ファイルを更新する)
    - [License ファイルを更新する - Rollback](#license-ファイルを更新する---rollback)
    - [InfluxDBのPVを拡張する](#influxdbのpvを拡張する)
    - [EmailServerを変更する](#EmailServerを変更する)

# 保守作業<a id="the_maintenance_operations"></a>

## k8sdeploy toolsによる保守作業時のPodの再起動について
本ドキュメントに記載している各保守項目に関しては再起動やローリングアップデートが行われるコンポーネントは記載しているが、system versionだけ更新したりdeploy.yamlだけ修正したりしていたがdeployコマンドを実行していなかった場合などに再起動する予定のなかったPodが再起動するということが発生する可能性がある。  

前回の保守作業で何を実施したか分からなくなった場合には以下を参照し、どういった変更が反映されるか事前確認を行い、必要に応じてメンテンナンスタイムを確保し実施すること。


各deployコマンド( `./gradlew -Pcluster=<クラスタ名> deployXXX` )実行の対象は以下のコンポーネント。  
deployVantiqのコンポーネントはVantiqへアクセスする際のホスト名部分のNamespaceに、それ以外のコンポーネントはshared Namespaceにデプロイされる。  

- deployShared
  - Deployment
    - grafana
    - grafanadb-mysql
    - telegraf-prom
  - StatefulSet
    - keycloak
    - influxdb
  - DaemonSet
    - telegraf-ds
  
- deployVantiq
  - StatefulSet
    - vantiq
    - mongodb
    - metrics-collector

- deployNginx
  - ingress-nginx-controller

保守作業時のdeploy.yamlなどの変更内容やsystem versionのアップデート先によってはdeployコマンド実行時に上記のコンポーネントにより管理されているPodが再起動する可能性がある。  
sysem versionの変更内容などはk8sdeploy tools のリリース内容([Releases · Vantiq/k8sdeploy](https://github.com/Vantiq/k8sdeploy/releases))やリポジトリの各Tagの内容などを確認すること。  

**※注意**  
想定外のPodの再起動を防ぐために、system versionを変更した際には一度deployShared/Nginx/Vantiqを実行することを推奨。  
system versionのみ変更すると、例えば以下のようなケースが発生しうる。  
```
 7月のメンテナンスでsystem version の変更を実施(deployコマンドは未実行)  
 9月にSSL証明書を更新。通常はdeployVantiqを実行した際にPodは再起動しないがバージョンアップ先のsystem versionにPodの再起動が必要な変更が含まれていたためPodが再起動してしまった。
```


### deployコマンド実行前の現状とのマニフェストの差分確認方法
deployコマンド実行時のマニフェストの差分確認を行う場合は以下のような手順で確認を行える。  

```bash
# 現在のHelmのリリースに反映されているマニフェストを取得
helm get manifest -n <YOUR-NAMESPACE> <RELEASE-NAME> > current_xxx_release.yaml

# 反映しようとしている各リリースの内容をdry-runオプションを指定することで確認可能
./gradlew -Pcluster=<クラスタ名> -Pdry-run deployXXX > deoloyXXX-dry-run.log
```

上記で各Helmチャートのマニフェストが出力される。出力内容が長いためファイルへ出力している。  
deployコマンドの出力では"MANIFEST"で検索するとそれぞれのリリースのマニフェストを検索し、該当部分のマニフェストとhelmコマンドで取得したマニフェストを比較し変更箇所を確認する。  

helmのリリースは以下のコマンドで確認可能。
```bash
helm ls -A
```


## Vantiqバージョンアップ作業<a id="vantiq_version_upgrade_operations"></a>

### Vantiq Minor Version Upgrade<a id="vantiq_minor_version_upgrade"></a>

**Vantiq Podの再起動が必要**

> **補足説明**  
> * 1.36→1.37バージョンアップでは追加の手順が必要です。  
> [LLM機能を利用しない場合](https://github.com/Vantiq/k8sdeploy_tools/blob/master/docs/R1dot37AltNonAI.md)  
> [LLM機能を利用する場合](https://github.com/Vantiq/k8sdeploy_tools/blob/master/docs/R1dot37Upgrade.md)  
> * [1.38→1.39バージョンアップでは追加の手順が必要です。](https://github.com/Vantiq/k8sdeploy_tools/blob/master/docs/R1dot39Upgrade.md)
> * [1.39→1.40バージョンアップでは追加の手順が必要です。](https://github.com/Vantiq/k8sdeploy_tools/blob/master/docs/R1dot40Upgrade.md)
> * [1.41→1.42バージョンアップでは追加の手順が必要です。](https://github.com/Vantiq/k8sdeploy_tools/blob/master/docs/R1dot42Upgrade.md)

Vantiq の Minor Version がインクレメントされるアップグレード（e.g. `1.30.10` -> `1.31.0`)  
Enhancement のための DB Schema 拡張を伴うため、ダウンタイムが必要になる。
1. 顧客の DTC にアップグレードに伴うサービス停止をアナウンスする (顧客 DTC はサービス停止による影響回避を社内で調整する)。
1. 最新の k8sdeploy_tools に更新する。k8sdeploy_tools のルートで `git pull` を実行する。
1. `deploy.yaml` の変更を行う (`vantiq.image.tag`)。※  
  ※1.38→1.39バージョンアップの場合は、以下の設定変更も実施する。  
    - `keycloak.username`の追加。設定値は`admin`。
    - `keycloak.persistence.dbHost`を`keycloak.database.hostname`に変更。
1. `cluster.properties` の `vantiq_system_release` を vantiq バージョンをサポートするものに変更する。バージョンアップに伴いその他のパラメーターが変更が必要な場合もある。
1. `cluster.properties` に変更があった場合、設定の更新を反映する。  
`./gradlew -Pcluster=<クラスタ名> setupCluster`  
`./gradlew -Pcluster=<クラスタ名> deployShared`  
`./gradlew -Pcluster=<クラスタ名> deployNginx`  
1. Vantiq pod のサービスを停止する (`metrics-collector` と `vision-analytics` は構成している場合のみ)。ここからダウンタイムが開始される。
    ```sh
    kubectl scale sts -n <namespace name> vantiq --replicas=0
    kubectl scale sts -n <namespace name> metrics-collector --replicas=0
    kubectl scale sts -n <namespace name> vision-analytics --replicas=0
    ```
1. mongodb のバックアップをする。`job name` は任意。
    ```sh
    kubectl create job -n <namespace name> <job name> --from=CronJob/mongobackup
    # jobの監視
    kubectl logs -n <namespace name> <mongobackup job pod name>
    ```
1. `deploy.yaml` の変更を適用する。 `./gradlew -Pcluster=<クラスタ名> deployVantiq`   
    **Caution:** `deployVantiq` を行うと vantiq pod のスケールが規定の数 (=3) に戻るが、バージョンアップ適用中は **必ず 1つのみ** にする必要があるため、直後にスケールを再変更する。その間、`metrics-collector`、`vision-analytics` は **必ず 0である** こと。
    ```sh
    ./gradlew -Pcluster=<クラスタ名> deployVantiq
    kubectl scale sts -n <namespace name> vantiq --replicas=1
    kubectl scale sts -n <namespace name> metrics-collector --replicas=0
    kubectl scale sts -n <namespace name> vision-analytics --replicas=0
    ```
1. スキーマ変更が正常に終了したか確認する。`kubectl logs -n <namespace name> vantiq-0 -c load-model -f`
1. `vantiq-0` pod が起動完了し、Vantiq IDE にログインできることを確認する。ここでダウンタイムが終了する。
1. スケールを元に戻す。
    ```sh
    kubectl scale sts -n <namespace name> vantiq --replicas=3
    kubectl scale sts -n <namespace name> metrics-collector --replicas=1
    kubectl scale sts -n <namespace name> vision-analytics --replicas=2
    ```
1. アップグレード作業完了を報告する。Vantiq IDE にログイン -> ナビゲーション バーの [ユーザー] アイコン -> [About] をクリックし、Platform のバージョンをコピーする。  
    例：
    ```
    Platform
    Version 7.6h
    サーバー https://internal.vantiqjp.com/ui/ide/index.html#!/modelo
    Namespace 'system' で 'masanori' としてログインしました （システム管理者） （Namespace 管理者）
    Login expires at Fri Sep 03 23:15:36 2021 (local time)

    UI Build Version : 1.31.8
    UI Build Commit : 937e25e9a8d63907124fb8366c146f926050f84c
    UI Build Date : Sun Jun 06 22:22:36 UTC 2021

    Server Build Version : 1.31.8
    Server Build Commit : eaf73629834f8e3210d62740c573898de6702fce
    Server Build Date : Sun Jun 06 22:24:11 UTC 2021

    Server License Issued To : Vantiq JP
    Server License Expiration Date: Thu Feb 24 2028 10:44:12 GMT+0900 (Japan Standard Time)
    Server License ID: a1585c60-7578-11eb-8d98-acde48001122

    ブラウザー : Chrome 92.0.4515.159
    Useragent : Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36
    ロケール: ja-*-*

    ```
### Vantiq Minor Version Upgrade - Rollback<a id="vantiq_minor_version_upgrade_rollback"></a>
Vantiqの各コンポーネントはkubernetes上で稼働しているため、基本的には切り戻しのために古いバージョンのイメージを再デプロイすることになる。MongoDBのデータについてはバックアップ済みデータを用いてアップグレード作業開始前の状態にする。
1. Vantiq pod のサービスを停止する (`metrics-collector` と `vision-analytics` は構成している場合のみ)。
    ```sh
    kubectl scale sts -n <namespace name> vantiq --replicas=0
    kubectl scale sts -n <namespace name> metrics-collector --replicas=0
    kubectl scale sts -n <namespace name> vision-analytics --replicas=0
    ```
1. アップグレード作業中に作成したMongodbバックアップ（step 7)を用いて作業前の状態に戻す。手順については[Vantiq MongoDB の回復をしたい](./vantiq-install-maintenance-troubleshooting.md#recovery_of_vantiq_mongoDB)を参照する。
1. `deploy.yaml` の`vantiq.image.tag`をアップグレード前のバージョンに戻す。
1. `deploy.yaml` の変更を適用する。 `./gradlew -Pcluster=<クラスタ名> deployVantiq`   



### Vantiq Patch Version Upgrade<a id="vantiq_patch_version_upgrade"></a>

**Vantiq Podの再起動が必要**

Patch Version がインクレメントされるアップグレード（e.g. `1.30.10` -> `1.30.11`)  
DB Schema 拡張を伴わないため、Vantiq Pod のみの更新となる。
1. 最新の k8sdeploy_tools に更新する。k8sdeploy_tools のルートで`git pull` を実行する。
1. `deploy.yaml` の変更を行う（`vantiq.image.tag`）。
1. `cluster.properties` の `vantiq_system_release` を vantiq バージョンをサポートするものに変更する。バージョンアップに伴いその他のパラメーターが変更が必要な場合もある。
1. `cluster.properties` に変更があった場合、設定の更新を反映する。`./gradlew -Pcluster=<クラスタ名> setupCluster`
1. `deploy.yaml` の変更を適用する。 `./gradlew -Pcluster=<クラスタ名> deployVantiq`
1. `vantiq` の rolling update が完了し、Vantiq IDE にログインできることを確認する。
1. アップグレード作業完了を報告する。Vantiq IDE にログイン -> ナビゲーション バーの [ユーザー]アイコン -> [About] をクリックし、Platform のバージョンをコピーする。  
    例：
    ```
    Platform
    Version 7.6h
    サーバー https://internal.vantiqjp.com/ui/ide/index.html#!/modelo
    Namespace 'system' で 'masanori' としてログインしました （システム管理者） （Namespace 管理者）
    Login expires at Fri Sep 03 23:15:36 2021 (local time)

    UI Build Version : 1.31.8
    UI Build Commit : 937e25e9a8d63907124fb8366c146f926050f84c
    UI Build Date : Sun Jun 06 22:22:36 UTC 2021

    Server Build Version : 1.31.8
    Server Build Commit : eaf73629834f8e3210d62740c573898de6702fce
    Server Build Date : Sun Jun 06 22:24:11 UTC 2021

    Server License Issued To : Vantiq JP
    Server License Expiration Date: Thu Feb 24 2028 10:44:12 GMT+0900 (Japan Standard Time)
    Server License ID: a1585c60-7578-11eb-8d98-acde48001122

    ブラウザー : Chrome 92.0.4515.159
    Useragent : Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36
    ロケール: ja-*-*

    ```
### Vantiq Patch Version Upgrade - Rollback<a id="vantiq_patch_version_upgrade_rollback"></a>
Vantiqの各コンポーネントはkubernetes上で稼働しているため、基本的には切り戻しのために古いバージョンのイメージを再デプロイすることになる。
1. `deploy.yaml` の`vantiq.image.tag`をアップグレード前のバージョンに戻す。
1. `deploy.yaml` の変更を適用する。 `./gradlew -Pcluster=<クラスタ名> deployVantiq`   


### Vantiq Shared Component Version Upgrade<a id="vantiq-shared-version-upgrade">

**shared Namespace内の Podの再起動が必要な場合がある**  

Vantiq の Sharedコンポーネント(k8sのshared Namespaceにデプロイされている)のアップグレード。  
アップグレードの内容によっては瞬断などが発生するため、k8sdeploy tools の リリース内容([Releases · Vantiq/k8sdeploy](https://github.com/Vantiq/k8sdeploy/releases))を確認すること。  

1. 最新の k8sdeploy_tools に更新する。k8sdeploy_tools のルートで `git pull` を実行する。
2. `cluster.properties` の `vantiq_system_release` を 目的のバージョンに置き換える。
3. `./gradlew -Pcluster=<CLUSTER-NAME> setupCluster` コマンドを実行する。
4. `./gradlew -Pcluster=<CLUSTER-NAME> deployShared` コマンドを実行する。  
5. `./gradlew -Pcluster=<CLUSTER-NAME> deployNginx` コマンドを実行する。  

### Vantiq Shared Componen Version Upgrade - Rollback<a id="vantiq-shared-version-upgrade---rollback">
切り戻しのためにsystem versionを変更前のバージョンに戻し再度deployコマンドまで実行する。  
1. `cluster.properties` の `vantiq_system_release` を 変更前のバージョンに置き換える。
2. `./gradlew -Pcluster=<CLUSTER-NAME> setupCluster` コマンドを実行する。
3. `./gradlew -Pcluster=<CLUSTER-NAME> deployShared` コマンドを実行する。
4. `./gradlew -Pcluster=<CLUSTER-NAME> deployNginx` コマンドを実行する。


## Kubernetesバージョンアップ作業<a id="kubernetes_version_upgrade_operations"></a>

**すべてのPodで再起動(Nodeの移動)が発生**

### Kubernetes Minor Version Upgrade<a id="k8s_minor_version_upgrade"></a>
[Kubernetesアップグレード](../../../vantiq-cloud-infra-operations/docs/jp/kubernetes-upgrade.md)を参照

**※注意**  
現在のSystem Versionがバージョンアップ後のK8sのバージョンを対応しているか確認しておくこと。  
対応していない場合は現在とバージョンアップ後のK8sのバージョンを対応しているSystem VersionにアップデートしてからK8sのバージョンアップを行うこと。  

バージョンアップ後のK8sのバージョンに対応していないSystem VersionのままK8sのバージョンをあげてしまうとK8s APIのバージョンのdeprecateによりHelmのリリースが更新できなくなってしまうことがある。  
更新できなくなると`UPGRADE FAILED`というようなエラーが発生しPodの更新などができなくなる。  
以下はtelegraf-promで発生した際の例。  

```log
> Task :vantiqSystem:deployTelegrafProm FAILED
Error: UPGRADE FAILED: resource mapping not found for name: "telegraf-prom" namespace: "" from "": no matches for kind "PodDisruptionBudget" in version "policy/v1beta1"
ensure CRDs are installed first
```

このような状況になってしまった場合、Helmのmapkubeapisというプラグインを利用して対応する。  
[helm/helm-mapkubeapis - GitHub](https://github.com/helm/helm-mapkubeapis)  
上記GitHubのReadmeの通りプラグインをインストール後、以下のように修正する。  

```sh
# 対象のリリースを確認
helm ls -A

# mapkubeapisでリリースを修正。以下はtelegraf-promの例
# -n: Namespace 
helm mapkubeapis -n shared telegraf-prom
```


## 更新作業<a id="renew_operations"></a>  

### SSL 証明書を更新する<a id="renew_ssl_certificate"></a>

**Podの再起動は発生しない**

SSL 証明書が期限切れになると、ブラウザーでアクセス時にエラーとなるが、このようになる前に計画的に SSL 証明書を更新が必要である。
![Screen Shot 2021-08-30 at 23.04.52](../../imgs/vantiq-install-maintenance/ssl_expired_error.png)

1. SSL 証明書を取得する。
  - 顧客調達の場合、必要なリードタイムを考慮し、前もって証明書の更新を依頼する。
  - Vantiq 内部で非本番用の場合、[SSLなう](https://sslnow.ml/)などを使って、"Let's Encrypt" の証明書を取得してもよい。
2. SSL 証明書はすべての中間証明書を含む、フルチェーンであること (すべての必要な中間証明書がオリジナルの証明書のファイルにアペンドされていること)。
3. 取得した証明書と秘密鍵 (それぞれ、`fullchain_yyyyMMdd.crt`、`private_yyyyMMdd.key` とする) を `targetCluster/deploy/sensitive` の下へ配置する。古いファイルと名前が重複する場合、古いファイルは別ファイル名にリネームしてバックアップとする。
4. `secrets.yaml` の下記項目を新しい証明書/秘密鍵ファイルのパスに更新する。パスは `targetCluster` を起点とした相対パス (例：deploy/sensitive/sample.crt) で記載する。
  - nginx.default-ssl-cert.files.tls.crt
  - nginx.default-ssl-cert.files.tls.key
  - vantiq.vantiq-ssl-cert.files.tls.crt
  - vantiq.vantiq-ssl-cert.files.tls.key
5. `deploy.yaml`に証明書と秘密鍵が記載されている場合は、下記項目を新しい証明書/秘密鍵ファイルのファイル名に更新する。記載されていない場合は更新不要。
  - nginx.controller.tls.cert
  - nginx.controller.tls.key
  - vantiq.ingress.tls.cert
  - vantiq.ingress.tls.key
6. k8sdeploy_tools のルートで`./gradlew -Pcluster=<cluster name> generateSecrets` を実行する。
7. `./gradlew -Pcluster=<cluster name> deployVantiq` を実行する。`vantiq-ssl-cert` が更新される。
8. `./gradlew -Pcluster=<cluster name> deployNginx` を実行する。`default-ssl-cert` が更新される。
9. ブラウザーでアクセスし、証明書が変わっていることを確認する。

### SSL 証明書を更新する - Rollback<a id="renew_ssl_certificate_rollback"></a>
1. バックアップしておいた証明書と秘密鍵を `targetCluster/deploy/sensitive` の下にリネームして戻す。
2. `secrets.yaml` の下記項目をバックアップしておいた証明書/秘密鍵ファイルのパスに更新する。パスは `targetCluster` を起点とした相対パス (例：deploy/sensitive/sample.crt) で記載する。
  - nginx.default-ssl-cert.files.tls.crt
  - nginx.default-ssl-cert.files.tls.key
  - vantiq.vantiq-ssl-cert.files.tls.crt
  - vantiq.vantiq-ssl-cert.files.tls.key
3. `deploy.yaml`に証明書と秘密鍵が記載されている場合は、下記項目をバックアップしておいた証明書/秘密鍵ファイルのファイル名に更新する。記載されていない場合は更新不要。
  - nginx.controller.tls.cert
  - nginx.controller.tls.key
  - vantiq.ingress.tls.cert
  - vantiq.ingress.tls.key
4. k8sdeploy_tools のルートで`./gradlew -Pcluster=<cluster name> generateSecrets` を実行する。
5. `./gradlew -Pcluster=<cluster name> deployVantiq` を実行する。`vantiq-ssl-cert` が更新される。
6. `./gradlew -Pcluster=<cluster name> deployNginx` を実行する。`default-ssl-cert` が更新される。
7. ブラウザーでアクセスし、証明書が変わっていることを確認する。


### License ファイルを更新する<a id="renew_license_files"></a>

**Vantiq Podの再起動が必要**

1. Vantiq Support から License ファイル (それぞれ、`public_yyyyMMdd.pem`、`license_yyyyMMdd.key` とする) を取得する。
2. 取得した License ファイルを `targetCluster/deploy/sensitive` の下へ配置する。古いファイルと名前が重複する場合、古いファイルは別ファイル名にリネームしてバックアップとする。
3. `secrets.yaml` の下記項目を新しい License ファイルのパスに更新する。パスは `targetCluster` を起点とした相対パス (例：deploy/sensitive/sample.pem) で記載する。
  - vantiq.vantiq-license.files.public.pem
  - vantiq.vantiq-license.files.license.key
4. k8sdeploy_tools のルートで `./gradlew -Pcluster=<cluster name> generateSecrets` を実行する。
5. `./gradlew -Pcluster=<cluster name> deployVantiq` を実行する。
6. secrets を反映させるために、次のコマンドを実行し、vantiq pod の rolling restart をする。`kubectl rollout restart sts -n <vantiq namespace> vantiq`

### License ファイルを更新する - Rollback<a id="renew_license_files_rollback"></a>

**Vantiq Podの再起動が必要**

1. バックアップしておいた License ファイルを `targetCluster/deploy/sensitive` の下にリネームして戻す。
2. `secrets.yaml` の下記項目をバックアップしておいた License ファイルのパスに更新する。パスは `targetCluster` を起点とした相対パス (例：deploy/sensitive/sample.pem) で記載する。
  - vantiq.vantiq-license.files.public.pem
  - vantiq.vantiq-license.files.license.key
3. k8sdeploy_tools のルートで `./gradlew -Pcluster=<cluster name> generateSecrets` を実行する。
4. `./gradlew -Pcluster=<cluster name> deployVantiq` を実行する。
5. secrets を反映させるために、次のコマンドを実行し、vantiq pod の rolling restart をする。`kubectl rollout restart sts -n <vantiq namespace> vantiq`


Reference: https://github.com/Vantiq/k8sdeploy_tools/blob/master/scripts/README.md _(要権限)_

### InfluxDBのPVを拡張する<a id="resize_influxdb_pv"></a>
**InfluxDB Podの再起動が必要**  
[InfluxDB PV拡張手順](./resize_influxdb_pv.md)を参照

### EmailServerを変更する<a id="renew_email_Server"></a> 

**Podの再起動は発生しない**

EmailServerを変更するには、GUIによる修正が2箇所 (GenericEmailSender と keycloak) 必要です。  
また、deployコマンドを実行した場合、以前の設定に戻ってしまうため、yamlファイルを修正します。
yamlファイルの修正はkeycloakのみに反映され、GenericEmailSenderはyamlファイルとは無関係のためGUIでの修正のみとなります。  

1. 新規に利用するEmail ServerのSMTP HOST、PORT、USER/PASSWORDを取得する。
2. Vantiq IDEへsystemユーザでログインしsystem Namespaceへ移動する。
3. Search boxに ”generic”と入力し、enterを押下する。 検索結果 Windowが表示されるので、[system] にチェックをつけ、"GenericEmailSender"をクリックする。
4. Propertyタブを開き、[ConfigをJSONとして編集] にチェックをつけ、表示されたJSONをファイルとして保存し、バックアップとする。
5. Email serverの設定を行い、保存する。
6. Keycloak Admin Consoleへアクセスする。
7. Realm SettingsからEmailタブを開き、Email設定を退避させ、バックアップとする。
8. Email server の設定を行い、保存する。
9. Vantiq IDEから招待メールを送信し、ユーザ登録できることを確認する。
10. deploy.yamlとsecrets.yamlを退避させ、バックアップとする。
11. deploy.yamlを編集する。
```sh
vantiq:
  keycloak:    
    smtp:
      host: <HOST>
      port: <Port>
      from: <source_mail>
      fromDisplayName: Vantiq Operations
      auth: true
      starttls: true
      user: <username>
```
12. secrets.yamlを編集する。
```sh
vantiq:
  keycloak: 
    data:
      smtp.password: <password>
```