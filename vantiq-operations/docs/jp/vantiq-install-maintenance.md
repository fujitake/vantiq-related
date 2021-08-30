# はじめに

本記事ではVANTIQ保守作業において、[k8sdeploy_tools](https://github.com/Vantiq/k8sdeploy_tools)でカバーされていない補足の説明や、構築時のトラブルシューティング方法や事例について記載する。

## 前提

- Kubectlツールを使ってk8sクラスタを操作する環境へのアクセスがあること

# 目次

(TOC to be added)

## Maintenance

### SSL証明書を更新する
SSL証明書が期限切れになると、ブラウザでアクセス時にエラーとなるが、このようになる前に計画的にSSL証明書を更新が必要である。
![Screen Shot 2021-08-30 at 23.04.52](../../imgs/vantiq-install-maintenance/ssl_expired_error.png)

1. SSL証明書を取得する。
  - 顧客調達の場合、必要なリードタイムを考慮し、前もって証明書の更新を依頼する。
  - Vantiq内部で非本番用の場合、[SSLなう](https://sslnow.ml/)などを使って、Let's Encryptの証明書を取得してもよい。
2.  SSL証明書はすべての中間証明書を含む、フルチェーンであること。（すべての必要な中間照明書がオリジナルの証明書のファイルにアペンドされていること）
3. 取得した証明書と秘密鍵(それぞれ、`fullchain.crt`、`private.key`とする)を`targetCluster/deploy/sensitive`の下の該当するファイルと置き換える。
4. k8sdeploy_toolsのルートで`./gradlew -Pcluster=<cluster name> generateSecrets`を実行する。
5. `./gradlew -Pcluster=<cluster name> deployVantiq`を実行する。
6. ブラウザでアクセスし、証明書が変わっていることを確認する。


## Troubleshooting

### Grafana Data Source追加する時、エラーとなる
InfluxDBを追加する時、URLを`http://influxdb-influxdb:8086`としたが、エラーとなる。
![Screen Shot 2021-08-30 at 21.08.54](../../imgs/vantiq-install-maintenance/datasource_influxdb_error.png)

Solution: URLを`http://influxdb:8086`とする。


### AzureでBackupの設定ができない

mongodb backupを設定する追加の手順。(Azure)
`secrets.yaml`の`vantiq`キーの下に、以下の設定を追加（or コメントアウト）

```yaml
vantig:
  dbbackup-creds:
    files:
      credentials: deploy/sensitive/azure_storage_credentials.txt
```
`deploy/sensitive`の下に、`azure_store_credentials.txt`を作成し、以下の設定を追加。
```
export AZURE_STORAGE_ACCOUNT=<ストレージアカウント名>
export AZURE_STORAGE_KEY=<ストレージキー>
```
例)
```
export AZURE_STORAGE_ACCOUNT=vantiqbackupstorage
export AZURE_STORAGE_KEY=XXXXXXX7CGqYriw9X3jwojPiHlc/3Jjhn3/MIEKYAJq0KwJZ9fd6zf9nMNt0DmIJcYfqaGmaM1isY3tayXXXXXXX==
```
`deploy.yaml`の`vantiq`のキーの下に、以下を追加。<bucket名>は任意.

```yaml
vantiq:
  mongodb:
    backup:
    enabled: true
    provider: azure
    schedule: "@daily"
    bucket: <bucket名>
```


### Grafanaでメトリクスが表示されない
`Vantiq Resources`の`Request rate`、`Request duration`が表示されない。`MongoDB Monitoring Dashboard`が表示されない。
![Screen Shot 2021-08-30 at 21.31.17](../../imgs/vantiq-install-maintenance/grafana_not_showing.png)


#### InfluxDBにメトリクスが存在するか診断する
データが表示されていないパネルのクエリを調べると、`kubernetes`データベースの`nginx_ingress_controller_requests`が使われているが、これがInfluxDBにあるか確認する。

```sh
# influx-0のpodのシェルに入る
$ kubectl exec -it influxdb-0 -n shared -- /bin/sh

# influxのシェルに入る
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

#### telegrafでエラーが出ているか診断する
メトリクスがない場合、telegraf側でエラーが出ているか確認する。

```sh
$ stern -n shared telegraf-* -s 1s

telegraf-prom-86c55969cb-fxmnx telegraf 2021-08-25T23:33:35Z E! [inputs.prometheus] Unable to watch resources: kubernetes api: Failure 403 pods is forbidden: User "system:serviceaccount:shared:telegraf-prom" cannot watch resource "pods" in API group "" at the cluster scope
telegraf-prom-86c55969cb-fxmnx telegraf 2021-08-25T23:33:36Z E! [inputs.prometheus] Unable to watch resources: kubernetes api: Failure 403 pods is forbidden: User "system:serviceaccount:shared:telegraf-prom" cannot watch resource "pods" in API group "" at the cluster scope
telegraf-prom-86c55969cb-fxmnx telegraf 2021-08-25T23:33:37Z E! [inputs.prometheus] Unable to watch resources: kubernetes api: Failure 403 pods is forbidden: User "system:serviceaccount:shared:telegraf-prom" cannot watch resource "pods" in API group "" at the cluster scope
telegraf-prom-86c55969cb-fxmnx telegraf 2021-08-25T23:33:38Z E! [inputs.prometheus] Unable to watch resources: kubernetes api: Failure 403 pods is forbidden: User "system:serviceaccount:shared:telegraf-prom" cannot watch resource "pods" in API group "" at the cluster scope
```

#### Solution
AWSやAzureで、kubernetesクラスタのRBACを有効にすると、デフォルトではClusterレベルの情報にアクセスする権限がない。`Service Account`を作成し、明示的に`telegraf`に対して権限をつける必要がある。

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
    resources: ["persistentvolumes", "nodes"]
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








### keycloak podが起動しない

Keycloakが短い周期でエラーとなり、起動しない。
```
shared         keycloak-0                                       0/1     Error                        2          107s
shared         keycloak-1                                       0/1     Error                        2          113s
shared         keycloak-2                                       0/1     Error                        2          104s
shared         keycloak-0                                       0/1     CrashLoopBackOff             2          113s
shared         keycloak-1                                       0/1     CrashLoopBackOff             2          118s
shared         keycloak-2                                       0/1     CrashLoopBackOff             2          113s
```
初期インストール時によくある問題として、資格情報が正しく設定されてない可能性がある。`kubectl logs`で調べると、以下のようなエラーが出ていることがある。

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

#### Azure Database for PostgreSQLが起動せずエラーになる場合
Azure Database for PostgreSQLの場合、`keycloak.keycloak.persistence`の下に、`dbHost`と`dbUser`をそれぞれ設定する必要がある。

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
[`alpine-f`ツール](./alpine-f.md)を使って、直接Postgresに繋げてみて、問題を切り分ける。
