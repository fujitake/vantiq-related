# はじめに

本記事では VANTIQ 保守作業において、[k8sdeploy_tools](https://github.com/Vantiq/k8sdeploy_tools) _(要権限)_ に関連し、構築時のトラブルシューティング方法や事例について記載する。

## 前提

- Kubectl ツールを使って k8s クラスタを操作する環境へのアクセスがあること

# 目次

[トラブルシューティング](#the_troubleshooting)  
  - [Grafana Data Source を追加する時、エラーとなる](#error_when_adding_grafana_data_source)  
  - [Azure で Backup の設定ができない](#unable_to_configure_backup_in_azure)  
  - [Grafana でメトリクスが表示されない](#metrics_not_showing_up_in_grafana)  
  - [Keycloak pod が起動しない](#keycloak_pod_will_not_start)  
  - [Vantiq IDE にログインしようとすると、エラーが出る](#error_when_trying_to_login_to_vantiq_ide)  
  - [System Admin 用の key を紛失した、期限切れになった](#lost_or_expired_key_for_system_admin)  

# トラブルシューティング<a id="the_troubleshooting"></a>

### Grafana Data Source を追加する時、エラーとなる<a id="error_when_adding_grafana_data_source"></a>
InfluxDB を追加する時、URLを `http://influxdb-influxdb:8086` としたが、エラーとなる。  
![Screen Shot 2021-08-30 at 21.08.54](../../imgs/vantiq-install-maintenance/datasource_influxdb_error.png)

#### Solution
URL を`http://influxdb:8086`とする。


### Azure で Backup の設定ができない<a id="unable_to_configure_backup_in_azure"></a>

mongodb backup を設定する追加の手順 (Azure)。
`secrets.yaml` の `vantiq` キーの下に、次の設定を追加 (またはコメントアウト) する。

```yaml
vantig:
  dbbackup-creds:
    files:
      credentials: deploy/sensitive/azure_storage_credentials.txt
```
`deploy/sensitive` の下に、`azure_store_credentials.txt` を作成し、次の設定を追加する。
```
export AZURE_STORAGE_ACCOUNT=<ストレージアカウント名>
export AZURE_STORAGE_KEY=<ストレージキー>
```
例)
```
export AZURE_STORAGE_ACCOUNT=vantiqbackupstorage
export AZURE_STORAGE_KEY=XXXXXXX7CGqYriw9X3jwojPiHlc/3Jjhn3/MIEKYAJq0KwJZ9fd6zf9nMNt0DmIJcYfqaGmaM1isY3tayXXXXXXX==
```
`deploy.yaml` の `vantiq` のキーの下に、次を追加する。<bucket名> は任意。

```yaml
vantiq:
  mongodb:
    backup:
    enabled: true
    provider: azure
    schedule: "@daily"
    bucket: <bucket名>
```


### Grafana でメトリクスが表示されない<a id="metrics_not_showing_up_in_grafana"></a>
`Vantiq Resources` の `Request rate`、`Request duration` が表示されない。`MongoDB Monitoring Dashboard` が表示されない。
![Screen Shot 2021-08-30 at 21.31.17](../../imgs/vantiq-install-maintenance/grafana_not_showing.png)


#### InfluxDB にメトリクスが存在するか診断する
データが表示されていないパネルのクエリを調べると、`kubernetes` データベースの `nginx_ingress_controller_requests` が使われているが、これが InfluxDB にあるか確認する。

```sh
# influx-0 の pod のシェルに入る
$ kubectl exec -it influxdb-0 -n shared -- /bin/sh

# influx のシェルに入る
$ influx
Connected to http://localhost:8086 version 1.8.1
InfluxDB shell version: 1.8.1

# データベースの切り替え
> use kubernetes
Using database kubernetes

# 保存されているメトリクスを確認
> show measurements
name: measurements
name
----
cpu
disk
diskio
docker
docker_container_blkio
docker_container_cpu
docker_container_mem
docker_container_status
go_gc_duration_seconds
...
```

#### telegraf でエラーが出ているか診断する
メトリクスがない場合、telegraf 側でエラーが出ているか確認する。

```sh
$ stern -n shared telegraf-* -s 1s

telegraf-prom-86c55969cb-fxmnx telegraf 2021-08-25T23:33:35Z E! [inputs.prometheus] Unable to watch resources: kubernetes api: Failure 403 pods is forbidden: User "system:serviceaccount:shared:telegraf-prom" cannot watch resource "pods" in API group "" at the cluster scope
telegraf-prom-86c55969cb-fxmnx telegraf 2021-08-25T23:33:36Z E! [inputs.prometheus] Unable to watch resources: kubernetes api: Failure 403 pods is forbidden: User "system:serviceaccount:shared:telegraf-prom" cannot watch resource "pods" in API group "" at the cluster scope
telegraf-prom-86c55969cb-fxmnx telegraf 2021-08-25T23:33:37Z E! [inputs.prometheus] Unable to watch resources: kubernetes api: Failure 403 pods is forbidden: User "system:serviceaccount:shared:telegraf-prom" cannot watch resource "pods" in API group "" at the cluster scope
telegraf-prom-86c55969cb-fxmnx telegraf 2021-08-25T23:33:38Z E! [inputs.prometheus] Unable to watch resources: kubernetes api: Failure 403 pods is forbidden: User "system:serviceaccount:shared:telegraf-prom" cannot watch resource "pods" in API group "" at the cluster scope
```

#### Solution
AWS や Azure で、kubernetes クラスタの RBAC を有効にすると、デフォルトでは Cluster レベルの情報にアクセスする権限がない。`Service Account` を作成し、明示的に `telegraf` に対して権限をつける必要がある。

```sh
kubectl apply -f k8s-additional-roles.yaml
```
**k8s-additional-roles.yaml**
```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: influx:cluster:viewer
  labels:
    rbac.authorization.k8s.io/aggregate-view-telegraf: "true"
rules:
  - apiGroups: [""]
#    resources: ["persistentvolumes", "nodes"]
    resources: ["*"]   # 2021/10/7 changed so that kubernetes.cpu_usage_nanocores measurement be obtained
    verbs: ["get", "list"]

---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: influx:telegraf
aggregationRule:
  clusterRoleSelectors:
    - matchLabels:
        rbac.authorization.k8s.io/aggregate-view-telegraf: "true"
    - matchLabels:
        rbac.authorization.k8s.io/aggregate-to-view: "true"
rules: [] # Rules are automatically filled in by the controller manager.
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:

  name: influx:telegraf:viewer
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: influx:telegraf
subjects:
- kind: ServiceAccount
  name: telegraf-ds
  namespace: shared
- kind: ServiceAccount
  name: telegraf-prom
  namespace: shared
```
Reference: https://stackoverflow.com/questions/53908848/kubernetes-pods-nodes-is-forbidden/53909115








### Keycloak pod が起動しない<a id="keycloak_pod_will_not_start"></a>

Keycloak が短い周期でエラーとなり、起動しない。
```
shared         keycloak-0                                       0/1     Error                        2          107s
shared         keycloak-1                                       0/1     Error                        2          113s
shared         keycloak-2                                       0/1     Error                        2          104s
shared         keycloak-0                                       0/1     CrashLoopBackOff             2          113s
shared         keycloak-1                                       0/1     CrashLoopBackOff             2          118s
shared         keycloak-2                                       0/1     CrashLoopBackOff             2          113s
```
初期インストール時によくある問題として、資格情報が正しく設定されてない可能性がある。`kubectl logs` で調べると、次のようなエラーが出ていることがある。

```sh
$ kubectl logs -n shared keycloak-0 -f
Picked up JAVA_TOOL_OPTIONS: -XX:+UseContainerSupport -XX:MaxRAMPercentage=50.0
Added 'keycloak' to '/opt/jboss/keycloak/standalone/configuration/keycloak-add-user.json', restart server to load user
=========================================================================

  Using PostgreSQL database

=========================================================================

Picked up JAVA_TOOL_OPTIONS: -XX:+UseContainerSupport -XX:MaxRAMPercentage=50.0
12:12:33,661 INFO  [org.jboss.modules] (CLI command executor) JBoss Modules version 1.10.0.Final

...
12:13:01,951 WARN  [org.jboss.jca.core.connectionmanager.pool.strategy.OnePool] (ServerService Thread Pool -- 65) IJ000604: Throwable while attempting to get a new connection: null: javax.resource.ResourceException: IJ031084: Unable to create connection
	at org.jboss.ironjacamar.jdbcadapters@1.4.20.Final//org.jboss.jca.adapters.jdbc.local.LocalManagedConnectionFactory.createLocalManagedConnection(LocalManagedConnectionFactory.java:345)

...

Caused by: org.postgresql.util.PSQLException: FATAL: password authentication failed for user "keycloak"
	at org.postgresql.jdbc@42.2.5//org.postgresql.core.v3.ConnectionFactoryImpl.doAuthentication(ConnectionFactoryImpl.java:514)
	at org.postgresql.jdbc@42.2.5//org.postgresql.core.v3.ConnectionFactoryImpl.tryConnect(ConnectionFactoryImpl.java:141)
	at org.postgresql.jdbc@42.2.5//org.postgresql.core.v3.ConnectionFactoryImpl.openConnectionImpl(ConnectionFactoryImpl.java:192)
```

#### Azure Database for PostgreSQL が起動せずエラーになる場合
Azure Database for PostgreSQL の場合、`keycloak.keycloak.persistence` の下に、`dbHost` と `dbUser` をそれぞれ設定する必要がある。

```yaml
keycloak:
  keycloak:
    # This is the password for the initial Keycloak admin user ('keycloak').  This user has
    # complete access to all of the Keycloak realms, so you want to make sure to use a secure
    # value.
#    password: <enter password to use for the Keycloak admin user>

    # This is the connection information used by Keycloak to connect with the PostgreSQL database
    # used to store all user identities.  The host is the DNS name for the PostgreSQL server and
    # the password is the password that was chosen to secure the "keycloak" database (the DB admin
    # user is assumed to be "keycloak").
    persistence:
      dbHost: keycloakvantiqjpinternalprod.postgres.database.azure.com
      dbUser: keycloak@keycloakvantiqjpinternalprod
```

#### その他
[`alpine-f` ツール](./alpine-f.md) を使って、直接 Postgres に繋げてみて、問題を切り分ける。


### Vantiq IDE にログインしようとすると、エラーが出る<a id="error_when_trying_to_login_to_vantiq_ide"></a>

エラーが出てログインできない。
```
{"code":"io.vantiq.server.error","message":"Failed to complete authentication code flow. Please contact your Vantiq administrator and have them confirm the health/configuration of the OAuth server. Request failed due to exception: javax.net.ssl.SSLHandshakeException: Failed to create SSL connection","params":[]}
```

Vantiq pod と keycloak 間で認証の通信がうまく行っていないことが原因である。

#### SSL 証明書が有効かどうか診断する

デフォルトでは自己署名の証明書 (self-signed certificate) を信頼しない。開発環境などで一時的に自己署名の証明書を使用する場合は、明示的に指定する。

```yaml
nginx:
  controller:
    tls:
      cert: cert.perm
      key: key.perm
      # this is sued if you use self-signed SSL
      selfSigned: true
```

#### サーバー間の時刻同期ができてきるか診断する

サーバー間で時刻同期ができていないと、pod 間 の token が無効と見なされてエラーとなる。閉域網で構成する際、時刻同期サービスへ通信ができないと時刻はズレる。
[時刻同期確認ツール](./timestamp_ds.md) を使用し、サーバー間で時刻が同期されているかを確認する。


### Vantiq IDEにログインしようとするとエラーメッセージが出てループする

![login_error_keycloak](../../imgs/vantiq-install-maintenance/login_error_keycloak.gif)

Keycloakにfront-end URLが設定されていないため。
Keycloakの`Frontend URL`を設定する。
1. 対象のRealmの Realm Settings -> Generalタブ に移動する
1. Frontend URLに`https://<ドメイン名>/auth/`と設定する


### System Admin 用の key を紛失した、期限切れになった<a id="lost_or_expired_key_for_system_admin"></a>

System Admin 用 の key は Vantiq pod の再起動時や、48時間で失効するので、DNS レコード登録等の作業で手間取ると初回のログインができなくなる。

Vantiq のデプロイからやり直す必要がある

- `undeplyVantiq` を実施
- `MongoDB` の `pv` と `pvc` を削除
- `deployVantiq` を実施
