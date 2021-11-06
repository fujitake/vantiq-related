# はじめに

本記事では VANTIQ 保守作業において、[k8sdeploy_tools](https://github.com/Vantiq/k8sdeploy_tools) _(要権限)_ に関連し、構築時のトラブルシューティング方法や事例について記載する。

## 前提

- Kubectl ツールを使って k8s クラスタを操作する環境へのアクセスがあること

# 目次

  - [Grafana Data Source を追加する時、エラーとなる](#error_when_adding_grafana_data_source)  
  - [Azure で Backup の設定ができない](#unable_to_configure_backup_in_azure)
  - [undeployとdeployを繰り返したら、PVがReleaseされてしまった。再利用したい](#reuse_old_pv)
  - [Grafana でメトリクスが表示されない](#metrics_not_showing_up_in_grafana)  
  - [VantiqバージョンアップしたらGrafanaのDashboardがすべて消えてしまった](#metrics_gone_after_vantiq_update)
  - [Keycloak pod が起動しない](#keycloak_pod_will_not_start)  
  - [Vantiq IDE にログインしようとすると、エラーが出る](#error_when_trying_to_login_to_vantiq_ide)  
  - [System Admin 用の key を紛失した、期限切れになった](#lost_or_expired_key_for_system_admin)  


# Grafana Data Source を追加する時、エラーとなる<a id="error_when_adding_grafana_data_source"></a>
InfluxDB を追加する時、URLを `http://influxdb-influxdb:8086` としたが、エラーとなる。  
![Screen Shot 2021-08-30 at 21.08.54](../../imgs/vantiq-install-maintenance/datasource_influxdb_error.png)

#### Solution
URL を`http://influxdb:8086`とする。


# Azure で Backup の設定ができない<a id="unable_to_configure_backup_in_azure"></a>

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

# undeployとdeployを繰り返したら、PVがReleaseされてしまった。再利用したい。<a id="reuse_old_pv"></a>

`undeploy`と`deploy`を繰り返すと、新しいPVが作られ、古いPVに入った情報が見れなくなる。(status = `Released`)
```
$ kubectl get pv
pvc-a6d5da12-7e3e-4a32-a5b3-bbbbbbbbbbbb   5Gi        RWO            Retain           Bound      shared/grafana                    vantiq-sc               5d21h
pvc-ec37c469-782a-473f-a6f9-aaaaaaaaaaaa   5Gi        RWO            Retain           Released   shared/grafana                    vantiq-sc               247d
```
#### リカバリー手順
1. PV, PVCをマウントしているdeploy or stsのpodを削除する。
```
$ kubectl scale deploy -n shared grafana --replicas=0
deployment.apps/grafana scaled
```
2. PVのclaimRefをクリアする -> PVのStatusが`Available`になり、再利用可。
```
kubectl patch pv pvc-ec37c469-782a-473f-a6f9-aaaaaaaaaaaa -p '{"spec":{"claimRef": null}}'
```
3. PVを要求するPVCを作成する。 PVCはimmutableなのでeditできない。そのため、Volumeを入れ替えたい場合は別途PVCを再作成する。

```sh
vi old-grafana-pvc.yaml
```
```yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: old-grafana-pv
  namespace: shared
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi          
  volumeName: pvc-ec37c469-782a-473f-a6f9-aaaaaaaaaaaa
  storageClassName: vantiq-sc
  volumeMode: Filesystem
```
4. PVCを適用する。
```sh
kubectl apply -f old-grafana-pvc.yaml
```
5. deployment or statefulsetのPVCの参照部分を書き換える。 (`claimName`の部分）
```sh
kubectl edit deploy -n shared grafanna
```
```yaml
...
volumes:
- configMap:
    defaultMode: 420
    name: grafana
  name: config
- name: storage
  persistentVolumeClaim:
    claimName: old-grafana-pv
...
```
6. PV, PVCをマウントしているdeploy or stsのpodを起動する。
```sh
$ kubectl scale deploy -n shared grafana --replicas=1
deployment.apps/grafana scaled
```

#### リカバリーに関する留意事項
- 上記の例においてgrafanaとgrafanadbは依存関係があり、同じnodeでないと起動しない。つまり、grafana, grafanadbのPVが同じAZにある必要がある。PVを意図したAZに再度作成するために、既存のPVCを削除しなければならない場合もある。
- PVやPVCを消してしまったら、必要な特定のモジュールのみデプロイし直すこともできる。例えばGrafanaDB
```sh
./gradlew -Pcluster=vantiq-vantiqjp-internal deployGrafanaDB
```

# Grafana でメトリクスが表示されない<a id="metrics_not_showing_up_in_grafana"></a>
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


# VantiqバージョンアップしたらGrafanaのDashboardがすべて消えてしまった <a id="metrics_gone_after_vantiq_update"></a>

#### 診断：データベースmysqlが正しく設定されているか確認する
`deploy.yaml`の設定が正しくないと、正しく設定値がgrafana起動時に参照されず、grafanaの既定値であるsqlite3になっている可能性がある。`grafana` configmapの`grafana.ini`項目中の、`[database]`以下の状態を確認する。

```bash
kubectl get cm -n shared grafana
```
```
Name:         grafana
Namespace:    shared
Labels:       app.kubernetes.io/instance=grafana
              app.kubernetes.io/managed-by=Helm
              app.kubernetes.io/name=grafana
              app.kubernetes.io/version=7.1.3
              helm.sh/chart=grafana-5.5.5
Annotations:  meta.helm.sh/release-name: grafana
              meta.helm.sh/release-namespace: shared

Data
====
grafana.ini:
----
[analytics]
check_for_updates = true
[auth]
disable_login_form = true
[auth.basic]
enabled = false
[auth.proxy]
auto_sign_up = false
enable_login_token = true
enabled = true
header_name = X-WEBAUTH-USER
header_property = username
[database] # このセクションにmysqlが正しく設定されていない
[grafana_net]
```
正しくはこうなるはず。
```
[database]
host = grafanadb-mysql:3306
type = mysql     # ここが mysql になっている事を確認
user = grafana
```
`grafana-mysql` podのmysqlに入り、テーブルが正しく作成されているか確認する。

```bash
kubectl get po -n shared
```
```
NAME                                             READY   STATUS             RESTARTS   AGE
grafana-yyyyyyyyy-bbbbbb                         1/1     Running            0          3d18h
grafanadb-mysql-xxxxxxxxx-aaaaaa                 1/1     Running            0          3d18h # これが Pod 名称
influxdb-0                                       1/1     Running            0          3d18h
ingress-nginx-controller-6568c69569-ncmhs        1/1     Running            0          13d
```
```bash
kubectl exec -n shared -it grafanadb-mysql-xxxxxxxxx-aaaaaa -- bash
```
```
root@<pod name>:/# mysql -u <user name> -p
Enter password:
Welcome to the MySQL monitor. Commands end with ; or \g.
Your MySQL connection id is 2985
Server version: 5.7.35 MySQL Community Server (GPL)

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| grafana            |
+--------------------+
2 rows in set (0.01 sec)

mysql> use grafana;
Database changed
mysql> show tables;
Empty set (0.00 sec) # テーブルが存在しない
```

#### リカバリー: sqlite3からmysqlへのデータ移行を行う
（これ以降の作業は、mysqlシェルと作業端末のシェルで並行に行うので、ターミナルを2つ用意しておくとよい）
1. `deploy.yaml`の設定を正しくする。`grafana.ini`以下をブランクで残すと既定値がブランクで上書きされてしまう。以下の例では`grafana.ini`自体をコメントアウトする。
```yaml
grafanadb:
  persistence:
    size: 8Gi

grafana:
  persistence:
    size: 5Gi

#  grafana.ini:
#    database:
      # The value here must match the value chosen for the MySQL database password.
#      password: <must match grafanadb.mysqlPassword>
```
2. `./gradlew -Pcluster=<cluster name> deployShared`で、grafana podを更新する。-> grafanaのdatabaseがmysqlに切り替わり、初期化によりmysqlにテーブルが作成されていることを確認する。
```
mysql> show tables;
+----------------------------+
| Tables_in_grafana          |
+----------------------------+
| alert                      |
| alert_configuration        |
| alert_instance             |
| alert_notification         |
| alert_notification_state   |
| alert_rule                 |
| alert_rule_tag             |
| alert_rule_version         |
| annotation                 |
| annotation_tag             |
| api_key                    |
| cache_data                 |
| dashboard                  |
| dashboard_acl              |
| dashboard_provisioning     |
| dashboard_snapshot         |
| dashboard_tag              |
| dashboard_version          |
| data_source                |
| library_element            |
| library_element_connection |
| login_attempt              |
| migration_log              |
| org                        |
| org_user                   |
| playlist                   |
| playlist_item              |
| plugin_setting             |
| preferences                |
| quota                      |
| server_lock                |
| session                    |
| short_url                  |
| star                       |
| tag                        |
| team                       |
| team_member                |
| temp_user                  |
| test_data                  |
| user                       |
| user_auth                  |
| user_auth_token            |
+----------------------------+
```
3. sqlite3 からデータをダンプする。`grafana-insert-less-migration.sql`がダンプされたデータ。

```bash
# 作業端末にsqlite3をインストールする
sudo apt install sqlite3

# 既存のデータをgrafana podからローカルにコピーする
kubectl cp -n shared grafana-yyyyyyyyy-bbbbbb:/var/lib/grafana/grafana.db ./grafana.db

# SQL文の形式でダンプする
sqlite3 grafana.db .dump > grafana.sql

# SQL文のうち、INSERT文のみ抽出する、またその際、migration_logテーブルデータを省く（なぜかは後述）
cat grafana.sql  sed -n '/INSERT/p' > grafana-insert.sql
cat grafana-insert.sql | sed '/migration_log/d' > grafana-insert-less-migration.sql
```
4. ダンプしたデータをmysqlにデータを投入する
```bash
# grafana-mysql podにデータをコピーする
kubectl cp grafana-insert-less-migration-log.sql -n shared grafanadb-mysql-xxxxxxxxx-aaaaaa:/tmp/
```
mysqlシェルから作業
```sql
-- テーブルのレコードをすべて削除するスクリプトを作る。migration_logを除く。
SELECT CONCAT ('DELETE FROM `', table_name, '`;') as statement from information_schema.tables where table_schema ='grafana' and table_name != 'migration_log';
-- スクリプトを適用する
DELETE FROM `alert`;                      
DELETE FROM `alert_configuration`;        
DELETE FROM `alert_instance`;             
DELETE FROM `alert_notification`;         
DELETE FROM `alert_notification_state`;   
DELETE FROM `alert_rule`;                 
DELETE FROM `alert_rule_tag`;             
DELETE FROM `alert_rule_version`;         
DELETE FROM `annotation`;                 
DELETE FROM `annotation_tag`;             
DELETE FROM `api_key`;                    
DELETE FROM `cache_data`;                 
DELETE FROM `dashboard`;                  
DELETE FROM `dashboard_acl`;              
DELETE FROM `dashboard_provisioning`;     
DELETE FROM `dashboard_snapshot`;         
DELETE FROM `dashboard_tag`;              
DELETE FROM `dashboard_version`;          
DELETE FROM `data_source`;                
DELETE FROM `library_element`;            
DELETE FROM `library_element_connection`;
DELETE FROM `login_attempt`;                            
DELETE FROM `org`;                        
DELETE FROM `org_user`;                   
DELETE FROM `playlist`;                   
DELETE FROM `playlist_item`;              
DELETE FROM `plugin_setting`;             
DELETE FROM `preferences`;                
DELETE FROM `quota`;                      
DELETE FROM `server_lock`;                
DELETE FROM `session`;                    
DELETE FROM `short_url`;                  
DELETE FROM `star`;                       
DELETE FROM `tag`;                        
DELETE FROM `team`;                       
DELETE FROM `team_member`;                
DELETE FROM `temp_user`;                  
DELETE FROM `test_data`;                  
DELETE FROM `user`;                       
DELETE FROM `user_auth`;                  
DELETE FROM `user_auth_token`;
-- INSERT文を適用する
source /tmp/grafana-insert-less-migration-log.sql
```

- いくつかのINSERTが失敗する。古いバージョンとスキーマが一致しないことが原因。Insertのエラーはここでは無視する。

5. system adminのdashboardをjsonから再度インポートする
ここまでの作業で、namespace admin用とorganization admin用のdashboardのインポートが完成するが、system adminのいくつかのdashboardについて失敗している。それらについて再度インポートする。
    - Organization Activity
    - InfluxDB Internals
以上。

#### リカバリー手順について補足
- `migration_log`はテーブルスキーマの更新を記録しているらしく、このテーブルのデータを消すと次回の起動時に不要なスキーマ変更を適用しようとしてエラーになる。そのため、このテーブルのデータは変更しない。
- リカバリー作業の途中で失敗した場合、mysqlのテーブルを全削除し、手順2からやり直せばよい。

```sql
-- DROP文を生成
SELECT CONCAT('DROP TABLE ',
  GROUP_CONCAT(CONCAT('`', table_name, '`')), ';') AS statement
  FROM information_schema.tables
  WHERE table_schema = '<table schema name>';
```
- grafana podを再起動
```sh
kubectl rollout restart deploy -n shared grafana
```

# Keycloak pod が起動しない<a id="keycloak_pod_will_not_start"></a>

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

```
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


# Vantiq IDE にログインしようとすると、エラーが出る<a id="error_when_trying_to_login_to_vantiq_ide"></a>

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


# System Admin 用の key を紛失した、期限切れになった<a id="lost_or_expired_key_for_system_admin"></a>

System Admin 用 の key は Vantiq pod の再起動時や、48時間で失効するので、DNS レコード登録等の作業で手間取ると初回のログインができなくなる。

Vantiq のデプロイからやり直す必要がある

- `undeplyVantiq` を実施
- `MongoDB` の `pv` と `pvc` を削除
- `deployVantiq` を実施
