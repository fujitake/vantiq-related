# alpine-f
- k8sクラスタの中から`nslookup`による名前解決の検証や、`psql` でPostgresにアクセスするためのツール。
- 本ツール(バージョン1.3)はamd64のみ対応。（arm64はサポートしない）

## 使用方法
以下のコマンドでデプロイする。
```sh
$ kubectl apply -f https://raw.githubusercontent.com/fujitake/vantiq-related/main/vantiq-platform-operations/conf/tools/alpine-f.yaml
```

alpine-fのシェルに入る
```sh
$ kubectl exec -n vantiqtools -it alpine-f -- ash

/ #
```

以下のコマンドでアンデプロイする。
```sh
$ kubectl delete -f https://raw.githubusercontent.com/fujitake/vantiq-related/main/vantiq-platform-operations/conf/tools/alpine-f.yaml
```

これ以下のコマンドは、alpine-fのシェルで実行できる。

### 名前解決の検証をする

```sh
$ nslookup internal.vantiqjp.com
Server:		10.100.0.10
Address:	10.100.0.10:53

Non-authoritative answer:

Non-authoritative answer:
Name:	internal.vantiqjp.com
Address: 20.194.148.153
```

### Vantiqサービスや、リポジトリへアクセス到達を検証する

```sh
$ curl -visk https://internal.vantiqjp.com
*   Trying 20.194.148.153:443...
* TCP_NODELAY set
* Connected to internal.vantiqjp.com (20.194.148.153) port 443 ('#0')
* ALPN, offering h2
* ALPN, offering http/1.1
* successfully set certificate verify locations:
```
`-v` - 詳細表示  
`-i` - Http Response Header、Bodyの確認  
`-s` - Responseの結果だけを確認する。  
`-k` - SSL認証をスキップする。自己証明書のサイトなど。  



### Postgresの接続を確認する

```sh
$  psql --host=keycloak-postgresql.czjeauchlabl.ap-northeast-1.rds.amazonaws.com --username=keycloak --password --dbname=keycloak
Password:
psql (12.2, server 11.10)
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

keycloak=> \l  # DBをリストする
                                  List of databases
   Name    |  Owner   | Encoding |   Collate   |    Ctype    |   Access privileges   
-----------+----------+----------+-------------+-------------+-----------------------
 keycloak  | keycloak | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 postgres  | keycloak | UTF8     | en_US.UTF-8 | en_US.UTF-8 |
 rdsadmin  | rdsadmin | UTF8     | en_US.UTF-8 | en_US.UTF-8 | rdsadmin=CTc/rdsadmin
 template0 | rdsadmin | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/rdsadmin          +
           |          |          |             |             | rdsadmin=CTc/rdsadmin
 template1 | keycloak | UTF8     | en_US.UTF-8 | en_US.UTF-8 | =c/keycloak          +
           |          |          |             |             | keycloak=CTc/keycloak
(5 rows)
```
[PostgreSQLコマンドチートシート](https://qiita.com/Shitimi_613/items/bcd6a7f4134e6a8f0621)


### Outbound通信時のGlobal IPを確認する
つまり、Internet Gateway、NAT Gateway の Public IP アドレス
```sh
$ curl ifconfig.me
```
