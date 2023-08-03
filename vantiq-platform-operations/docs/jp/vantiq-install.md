# はじめに

本記事では VANTIQ 初回構築作業において、[k8sdeploy_tools](https://github.com/Vantiq/k8sdeploy_tools) _(要権限)_ でカバーされていない補足の説明について記載する。

## 前提

- Kubectl ツールを使って k8s クラスタを操作する環境へのアクセスがあること

kubectl コマンドの簡易的な使い方については[kubectlコマンドの使い方](./kubectl-commnad.md)を参照。

# 目次
[初回構築作業](#quick_reference)  
  - [事前準備 (アクセス権限等)](#preparation_access_permissions)  
  - [事前準備 (作業環境)](#preparation_work_environment)  
- [構築作業](#the_build_work)  


# 初回構築作業 (Quick Reference)<a id="quick_reference"></a>

### 事前準備 (アクセス権限等)<a id="preparation_access_permissions"></a>
- SSL 証明書ファイル (お客様にてご用意いただくもの)
- 有効な Vantiq License ファイル (`license.key`、`public.pem`) ([Vantiq Support, Vantiq担当より取得ください](./how_to_request_license.md))
- DNS Zone の管理権限、もしくは即時対応可能な更新依頼先 (Customer より入手)  
   DNS 管理者が外部の方の場合、事前に相談しておくこと  
   既存の zone であれば、15分程度で有効になる(実際には数分で有効になるはず)  
   新規の zone であれば、最大 48時間程度かかることになる  
- `k8sdeploy_tools`、`k8sdeploy` リポジトリへのアクセス権限 (Vantiq Support より入手)
- `k8sdeploy_clusters_jp` リポジトリへのアクセス権限 (JapanVirtualSRE より入手。Vantiq社内管理の場合のみ。)
- *quay.io* への vantiq リポジトリへのアクセス権限（Vantiq Support より入手)
- SMTPサービスのエンドポイント、および資格情報
- APNs認証キー、FCM用アクセストークン（iOS, AndroidのVantiq Mobileを使用する場合のみ）
- 踏み台サーバのIPアドレス、ユーザー名、ssh秘密鍵（本記事のこれ以降の作業は踏み台サーバ上で行うことを想定する。）
- 作業対象のkubernetesクラスタへのアクセス権


### 事前準備 (作業環境)<a id="preparation_work_environment"></a>
踏み台サーバ上で行うことを想定する。
- 必須ツール
  - java8|11 - Oracle or OpenJDK 最新バージョン(Vantiq r1.35以上をインストールする場合はjava11)
  - git
  - kubectl - 有効なバージョン (Cloud 側の K8s バージョン ± 1以内),kubeconfigの設定を行っておく
  - helm 3 - 最新バージョン
  - aws CLI - EKSの場合

- 任意ツール
  - [git-secret](https://github.com/Vantiq/PStools/tree/main/git-secret) _(要権限)_ - secret、senstive ファイルを git にアップロードする際に必要
  - stern - ログを pod 横断的に確認するのに便利
  - docker CE - 最新バージョン


## 構築作業<a id="the_build_work"></a>

1. 最新バージョンの k8sdeploy_tools を取得する。`git clone https://github.com/Vantiq/k8sdeploy_tools.git` _(要権限)_
2. `k8sdeploy_tools` ディレクトリに移動する。
3. `./gradlew configureClient`を実行する。（この手順はエラーになっても、`helm repo list`を実行してvantiq repoが取得できていればよい。）
4. `.gradle/gradle.properties` の github の k8sdeploy にアクセスし、`username` と `password` を設定する。2段階認証を有効にしている場合、password は "personal access token" となる。
5. `targetCluster`、`vantiqSystem` がないことを確認する。
6. 次のコマンドを実行する。
   `./gradlew configureVantiqSystem`  
   `targetCluster`、`vantiqSystem` が作成されたことを確認する  
   `targetCluster` には、`cluster.properties`、`deploy.yaml` のみが生成される  
7. `targetCluster` ディレクトリに移動する。
8. クラスタ名を決定し、次のコマンドを実行する。
	 `git checkout -b <クラスタ名>`  
     **targetClusterディレクトリで実行すること。後工程の./gradlewコマンドの-PClusterオプションでクラスタ名を指定する必要有**
9.  続けて `cluster.properties` に任意の設定を行う。下記は一例。
   - #`requiredRemote`=`false` のコメントアウトを外す
   - `provider`=`aws` (aws|azure|alicloud|kubeadm)
   - `vantiq_system_release`=`3.10.12` ([k8sdeploy repo](https://github.com/Vantiq/k8sdeploy/releases)で確認できる。K8sバやVantiqバージョンとも依存しており、不明ならばSRE または Supportに要確認)
   - `deployment`=`development` (development はシングル構成、production はトリプルクラスタ構成)
   - `vantiq.installation`=`tkeksfuji7` (クラスタのFQDNのホスト名部分を入力。Vantiq PodがデプロイされるNamespaceになる。)
10. `targetCluster`ディレクトリに `kubeconfig` ファイルを配置し、必要な修正を実施する。  
   kubectl コマンドで対象のClusterへアクセスする際に利用するkubeconfigファイルを配置  
   ファイル名は`kubeconfig`  
   configファイルの取得方法はEKSやAKSなど、それぞれのサービスのドキュメント等を参照し取得  
11. 次のコマンドを実行し、クラスタとの接続を確認する。
	  `./gradlew -Pcluster=<クラスタ名> clusterInfo`  
	  エラーなく正常に client version、server version が返ることを確認する  
	  エラーの場合、`kubeconfig` の記述、kubectl のバージョン不整合などを確認すること  
12. 次のコマンドを実行し、設定ファイルを生成する。
	  `./gradlew -Pcluster=<クラスタ名> setupCluster`  
	  `secrets.yaml` ファイルと `deploy` というディレクトリが生成される  
13. `deploy.yaml` と `secrets.yaml` を修正する。  
    secrets.yamlで指定しているSSL証明書やライセンスファイルなどは`targetCluster/deploy/sensitive`ディレクトリより下に配置しておく  
14. 次のコマンドを実行し、パスワード関連ファイルを生成する。
	`./gradlew -Pcluster=<クラスタ名> generateSecrets`
15. 次のコマンドを実行し、デプロイを実施する。
  `./gradlew -Pcluster=<クラスタ名> deployNginx`  
	`./gradlew -Pcluster=<クラスタ名> deployShared`  
  `./gradlew -Pcluster=<クラスタ名> deployVantiq`  
  まとめて実行する`deploy`コマンドもあるが、podが正しいnodeに配置されるか等、スモールステップで確認する方が無難である。正常に終わらない場合は、deploy.yaml、secrets.yaml の設定を確認する。
16. 次のコマンドにて各種 pod が動作していることを確認する。
	`kubectl get pod -A`
17. Vantiq pod が動作している場合、次のコマンドにて出力される log 内から key を確認し保存する。  
	`kubectl logs pod/vantiq-0 -c vantiq -n <vantiqのnamespace>`
    ```
  	2020-05-06T16:21:57.493 [vert.x-eventloop-thread-7] INFO  i.v.c.i.l.c.VertxIsolatedDeployer - Succeeded in deploying verticle
  	2020-05-06T16:21:58.595 [vert.x-eventloop-thread-0] INFO  io.vantiq.startup - ******************************************************************
  	2020-05-06T16:21:58.595 [vert.x-eventloop-thread-0] INFO  io.vantiq.startup - *          1234567890123456789012345678901234567890=          *
  	2020-05-06T16:21:58.595 [vert.x-eventloop-thread-0] INFO  io.vantiq.startup - ******************************************************************
    ```
    keyは初回ログインの際に必要なため必ず保存しておくこと。  
    **初回起動時のみ表示されるため、確認し忘れた場合はインストールし直しが必要**
18. 次のコマンドを実行し、各種 pod が適切な node に乗っていることを確認する。    
	`kubectl describe nodes | egrep "^Name:|mongodb-[0-2]|vantiq-[0-2]|metrics-|vision-|influxdb-|grafana(-|db)|keycloak-|ingress-nginx|telegraf-prom|zone"`  
	適切なノードに乗っていない場合は、別途手順を確認する
    ```
  	kubectl taint nodes --all key=value:NoSchedule
  	kubectl taint nodes <node名> key:NoSchedule-
  	kubectl scale <deploy or sts> -n <ns> --replicas=1
  	kubectl scale <deploy or sts> -n <ns> --replicas=3
  	kubectl taint nodes --all key:NoSchedule-
    ```
19. 次のコマンドより Load Balancer の DNS 名を確認する。  `kubectl get svc -A`  
    1. 上記DNS名が名前解決できることを確認する。  
      LB にて設定されたホスト名を CNAME (AWS CLB) もしくは Aレコード (Azure LB) で解決できるように設定する  
      Internet-facing: インターネットにて名前解決ができること  
      Internal: Internal ネットワーク内にあるホストから名前解決できること
    2. 上記で確認した DNS 名の CNAME/Aレコードとして、計画している DNS 名を設定する。DNS Zone 管理者に確認すること。  
    3. DNS 登録ができたことを確認する。  

20. Keycloak で system admin ユーザーを作成する。
    1. 次にアクセスする。  
      `https://<ドメイン名>/auth/`  
	   Keycloak ページが表示されるので、`Administrator Console` をクリックする  
	   Keycloak の管理者名とパスワード (`secrets.yaml` の `shared.keycloak.data.password` にて指定した内容) を使いログインする  
	   作成するユーザーは、利用ユーザーとは違い、”System Admin” のため、取り扱いには注意が必要 (Org を自由に作成可能) となる  
    2. メニューにある Manage 配下の Users に移動する
    3. Add User ボタンをクリック
    4. Username を入力し、Save をクリック
    5. 作成したユーザーの Credential タブをクリック
    6. パスワードを設定し、Temporary を off にして Reset Password をクリック
    7. Details タブに移動し、Email verified を ON に変更し Save をクリック
    8. Role mapping タブに移動し、Client roles の realm management を選択する
    9. 全ての Available roles を選択し、Add selected ボタンをクリック
    10. 右上のユーザー名アイコンからログアウト
21. Keycloakの`Frontend URL`を設定する
    1. 対象のRealmの Realm Settings -> Generalタブ に移動する
    2. Frontend URLに`https://<ドメイン名>/auth/`と設定する
22. Vantiq IDE で system namespace の初期設定をする。
    1. 次のページにアクセスし、作成したユーザー名、パスワードでログインする。
  	    `https://<ドメイン名>/`  
       ※上記ステップでログアウトした画面からはログインできないため、先のページ `https://<ドメイン名>/` に移動すること。
  	    作成したユーザー名とパスワードでログインする。  
       上記手順で作成したユーザでは初回のログイン後Request Codeを送信する画面が表示される。  
       Box内に`手順17のVantiq Podのlogで確認しておいたkey`を入力し送信する。
    2. System admin の Grafana 設定を実施する    
	    [Add Grafana dashboard for System users](https://github.com/Vantiq/k8sdeploy_tools/blob/master/docs/Installation.md#add_grafana_dashboards)に従い、設定を行う。
	    `k8sdeploy_tools/vantiqSystem/deploy/vantiq/dashboards` にあるファイルを設定する。
	     インポートすべきファイルは、適切な Branch を選択する必要がある (vantiq_system_release を指定)  
       **それぞれのData Source設定する際、username/passwordは./gradlew createInfluxDBAdmin(deployShared内で実行されれいる)で作成されたREAD権限のものを利用すること。**  
       **各JsonファイルImport時のData source選択では同じData source名を指定すること**  
      - InfluxDB Internal.json -> internals
      - MongoDB Monitoring Dashboard.json -> kubernetes
      - Organization Activitiy.json -> systemDB、kubernetes、vantiqServer
      - Vantiq Resources.json -> kubernetes、vantiqServer

    3. Source: `GenericEmailSender` を修正する  
	    Search box に ”generic” と入力し、enter を押下する。 検索結果 Window が表示されるので、[system] にチェックをつけ、"GenericEmailSender" をクリックする。 適切な email server の設定を行い、[変更の保存] をクリックする  
    4. ノードのプロパティを更新する  
	    [デプロイ] -> [Nodes] で、"self" を選択する。
	    デフォルトの http://localhost:8080 を、デプロイされているドメイン名に変更する（例：https://hr-vantiq.co.jp)
    5. ユーザー向け Organization を作成する  
	    [管理] -> [Organization] を選択し、[新規] アイコンをクリックする。
	    Org Name、Org Description、Namespace (root namespace)、Invite Destination (Org Adminのメールアドレス)、[Make Me The Administrator] をチェック（自分が Org 管理者になる場合）し、[変更の保存] をクリック
    6. Organization 管理者を追加する    
	    Namespace から、作成した organization の root namespace に移動する。
       [管理] -> [ユーザー] を選択し、[新規] をクリックする。
	    Authorization プロパティのアイコンをクリックし、権限を Organization Admin にして [OK] をクリックする。追加するユーザーのメールアドレスを入力し、保存する


