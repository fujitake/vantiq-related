# はじめに

本記事は クラスタ定義ファイルの管理方法として [Centrally by a Vantiq Customer](https://github.com/Vantiq/k8sdeploy_tools/blob/master/docs/CustomerManagedDefinition.md) _(要権限)_ を選択した場合のVantiq Private Cloud 初回構築作業のクイックリファレンスです。  
詳細に関しては [k8sdeploy_tools](https://github.com/Vantiq/k8sdeploy_tools) _(要権限)_ のドキュメントを参照してください。

## 前提

- kubectl ツールを使って k8s クラスタを操作する環境へのアクセスがあること

kubectl コマンドの簡易的な使い方については[kubectlコマンドの使い方](./kubectl-commnad.md)を参照。

# 目次
[初回構築作業](#quick_reference)  
  - [事前準備 (アクセス権限等)](#preparation_access_permissions)  
  - [事前準備 (作業環境)](#preparation_work_environment)  
- [構築作業](#the_build_work)  

[クラスタ定義のリポジトリ登録](#manage_clusterDef)

# 初回構築作業 (Quick Reference)<a id="quick_reference"></a>

### 事前準備 (アクセス権限等)<a id="preparation_access_permissions"></a>
- SSL 証明書ファイル (お客様にてご用意いただくもの)
- 有効な Vantiq License ファイル (`license.key`、`public.pem`) ([Vantiq Support, Vantiq担当より取得ください](./how_to_request_license.md))
- DNS Zone の管理権限、もしくは即時対応可能な更新依頼先 (Customer より入手)  
   DNS 管理者が外部の方の場合、事前に相談しておくこと  
   既存の zone であれば、15分程度で有効になる(実際には数分で有効になるはず)  
   新規の zone であれば、最大 48時間程度かかることになる  
- `k8sdeploy_tools`、`k8sdeploy` リポジトリへのアクセス権限 (Vantiq Support より入手)
- `k8sdeploy_clusters_jp` リポジトリへのアクセス権限 (JapanVirtualSRE より入手。Vantiq社内管理の場合のみ)
- *quay.io* への vantiq リポジトリへのアクセス権限 (Vantiq Support より入手)
- SMTPサービスのエンドポイント、および資格情報
- APNs認証キー、FCM用アクセストークン（iOS, AndroidのVantiq Mobileを使用する場合のみ）
- 踏み台サーバのIPアドレス、ユーザー名、ssh秘密鍵（本記事のこれ以降の作業は踏み台サーバ上で行うことを想定する）
- 作業対象のkubernetesクラスタへのアクセス権  
  EKSの場合はAWS CLIのセットアップが必要


### 事前準備 (作業環境)<a id="preparation_work_environment"></a>
踏み台サーバ上で行うことを想定する。
- 必須ツール
  - java8|11 - Oracle or OpenJDK 最新バージョン(Vantiq r1.35以上をインストールする場合はjava11)
  - git
  - kubectl - 有効なバージョン (Cloud 側の K8s バージョン ± 1以内),kubeconfigの設定を行っておく
  - helm 3 - 最新バージョン
  - aws CLI - EKSの場合
  - kubeseal - SealedSecretsでの機密情報の暗号化に利用

- 任意ツール
  - stern - ログを pod 横断的に確認するのに便利
  - docker CE - 最新バージョン


## 構築作業<a id="the_build_work"></a>

1. 最新バージョンの k8sdeploy_tools を取得する。  
   `git clone https://github.com/Vantiq/k8sdeploy_tools.git` _(要権限)_
1. `k8sdeploy_tools` ディレクトリに移動する。
1. `./gradlew configureClient` コマンドを実行する。（この手順はエラーになっても、`helm repo list`を実行してvantiq repoが取得できていればよい）
1. `.gradle/gradle.properties` に、`gitUsername` 、 `gitPassword`、 `clusterRepo` を設定する。  
2段階認証を有効にしている場合、`gitPassword` は "personal access token" となる。  
`clusterRepo` はクラスタ定義を管理するリモートリポジトリのURIを設定する。（対象リポジトリはこの時点では未作成）  
1. `k8sdeploy_tools` ディレクトリ配下に `targetCluster`、`vantiqSystem` ディレクトリがないことを確認する。
1. `./gradlew configureVantiqSystem` コマンドを実行する。  
   `targetCluster`、`vantiqSystem` ディレクトリが作成されたことを確認する。  
   `targetCluster` ディレクトリ配下には、`cluster.properties`、`deploy.yaml` のみが生成される。  
1. `.gradle/gradle.properties` の `clusterRepo` に設定したリポジトリを空のリポジトリとして新規作成する。  
1. `targetCluster` ディレクトリに移動する。
1. 次のコマンドでローカル クラスタ リポジトリの origin を設定し、ローカル リポジトリから origin にファイルをプッシュする。  
    - `git branch -M master`
    - `git remote add origin <ClusterRepoURI>`
    - `git push -u origin master`
    - `git remote show origin` （origin設定確認用コマンド）
1. クラスタ名を決定し、 `git checkout -b <クラスタ名>` コマンドを実行して新規ブランチを作成する。  
     **`targetCluster` ディレクトリで実行すること。後工程の `./gradlew` コマンドの `-PCluster` オプションでクラスタ名を指定する必要有。**  
     **EKSの場合、`~/.aws/credentials` ファイルにクラスタ名のプロファイルを作成する必要有。**  
1. `git push -u origin <クラスタ名>` コマンドを実行し、新規ブランチをリモートリポジトリに反映する。  
1.  続けて `cluster.properties` に任意の設定を行う。下記は一例。  
    - `requiredRemote`=`true`
    - `provider`=`aws` (aws|azure|alicloud|kubeadm)
    - `vantiq_system_release`=`3.17.5` （最新バージョンは [k8sdeploy repo](https://github.com/Vantiq/k8sdeploy/releases) _(要権限)_ で確認可能。KubernetesやVantiqのバージョンとも依存しているため、 [ReleaseMap](https://github.com/Vantiq/k8sdeploy/blob/master/ReleaseMap.md) _(要権限)_ を要確認。不明ならば SRE または Support に確認）
    - `deployment`=`development` (development はシングル構成、production はトリプルクラスタ構成)
    - `vantiq.installation`=`<Vantiq v-host and namespace>` (クラスタのFQDNのホスト名部分を入力。Vantiq PodがデプロイされるNamespaceになる。)
    - `enableSealedSecrets`=`true`（SealedSecretsを利用するため）
1. `targetCluster`ディレクトリに `kubeconfig` ファイルを配置し、必要な修正を実施する。  
   kubectl コマンドで対象のClusterへアクセスする際に利用するkubeconfigファイルを配置。  
   ファイル名は `kubeconfig` 。  
   configファイルの取得方法はEKSやAKSなど、それぞれのサービスのドキュメント等を参照。  
1. `k8sdeploy_tools` ディレクトリに移動する。
1. `./gradlew -Pcluster=<クラスタ名> clusterInfo` コマンドを実行し、クラスタとの接続を確認する。  
	  エラーなく正常に client version、server version が返ることを確認する。  
	  エラーの場合、`kubeconfig` の設定、クラスタとkubectlのバージョン不整合などを確認すること。  
1. `./gradlew -Pcluster=<クラスタ名> setupCluster` コマンドを実行する。  
	  `targetCluster` ディレクトリ配下に`secrets.yaml` ファイルと `deploy` ディレクトリが生成される。  
    `kube-system` Namespace に SealedSecrets コントローラーがデプロイされる。  
1. `kubectl get pod -n kube-system` コマンドを実行し、 SealedSecrets コントローラーが実行中（Running）であることを確認する。  
1. `./gradlew -Pcluster=<クラスタ名> configureSealedSecrets` コマンドを実行する。  
1. `kubectl get secret/sealed-secrets-XXXX -n kube-system -o yaml > <出力先ファイルパス>` コマンドを実行してクラスタ内のシーリングキーを抽出し、安全な場所に保管する。  
    **シーリングキーは、クラスタを再構築する場合に必要。**  
    **キーが漏洩するとシークレットが危険に晒されるため、認証情報等と同様に安全な方法で保管する。**  
1. `deploy.yaml` と `secrets.yaml` を編集する。  
    secrets.yamlで指定しているSSL証明書やライセンスファイルなどは `targetCluster/deploy/sensitive` ディレクトリより下に配置しておく。  
    設定項目の詳細に関しては [Installing Vantiq - Deployment Tasks](https://github.com/Vantiq/k8sdeploy_tools/blob/master/docs/Installation.md#deployment-tasks) _(要権限)_ や [deploy.yamlのカスタマイズ構成](./deploy_yaml_config.md) を参照。  
    **system version が3.11.2以降の場合は、MongoDBのBackupが不要であっても `secrets.yaml` でcredentialファイルの設定を行う必要有。（credentialファイルの内容はダミーで問題無し）**  
    **credentialファイルの設定をしないとVantiq Podが起動しないため注意。**  
1. `./gradlew -Pcluster=<クラスタ名> generateSecrets` コマンドを実行し、シークレットファイルを生成する。
  指定するファイルや値を間違えてしまった場合は、`secrets.yaml`やファイルを更新した後、上記コマンドを再度実行する必要有  
  **既存の問題で`generateSecrets`を実行しても更新されない場合がある。その際にはtargetCluster/deploy/secrets/＜Component＞/＜secret yaml file＞を消してから再度`generateSecrets`を実行すること。**  
  **Vantiqのライセンスなどk8sのSecretに反映された後にPodの再起動を必要とするものがあるため注意。**  
1. 次のコマンドを実行し、デプロイを実施する。  
  **Vantiq Pod起動後、48時間以内にVantiq IDE ログインまで行う必要有。**  
  **48時間経過すると初回ログイン時に必要なkeyが無効化されるためインストールし直し。**  
    - `./gradlew -Pcluster=<クラスタ名> deployNginx`  
    - `./gradlew -Pcluster=<クラスタ名> deployShared`  
    - `./gradlew -Pcluster=<クラスタ名> createInfluxDBAdmin`  
    - `./gradlew -Pcluster=<クラスタ名> deployVantiq`  
    - `./gradlew -Pcluster=<クラスタ名> grafanaPostInstallSetup` **※2025年6月以前のバージョンの場合は実行不要**  

    まとめて実行する`deploy`コマンドもあるが、podが正しいnodeに配置されるか等、スモールステップで確認する方が無難である。正常に終わらない場合は、deploy.yaml、secrets.yaml の設定を確認する。
1. `kubectl get pod -A` コマンドにて各種 pod が動作していることを確認する。  
1. Vantiq pod が動作している場合、次のコマンドにて出力される log 内から key を確認し保存する。  
	`kubectl logs pod/vantiq-0 -c vantiq -n <vantiqのnamespace>`
    ```
  	2020-05-06T16:21:57.493 [vert.x-eventloop-thread-7] INFO  i.v.c.i.l.c.VertxIsolatedDeployer - Succeeded in deploying verticle
  	2020-05-06T16:21:58.595 [vert.x-eventloop-thread-0] INFO  io.vantiq.startup - ******************************************************************
  	2020-05-06T16:21:58.595 [vert.x-eventloop-thread-0] INFO  io.vantiq.startup - *          1234567890123456789012345678901234567890=          *
  	2020-05-06T16:21:58.595 [vert.x-eventloop-thread-0] INFO  io.vantiq.startup - ******************************************************************
    ```
    keyは初回ログインの際に必要なため必ず保存しておくこと。  
    **初回起動時のみ表示されるため、確認し忘れた場合はインストールし直しが必要。keyの有効期限は48時間。**
1. 次のコマンドを実行し、各種 pod が適切な node に乗っていることを確認する。    
	`kubectl describe nodes | egrep "^Name:|mongodb-[0-2]|vantiq-[0-2]|metrics-|vision-|influxdb-|grafana(-|db)|keycloak-|ingress-nginx|telegraf-prom|zone"`  
	適切なノードに乗っていない場合は、別途手順を確認する
    ```
  	kubectl taint nodes --all key=value:NoSchedule
  	kubectl taint nodes <node名> key:NoSchedule-
  	kubectl scale <deploy or sts> -n <ns> --replicas=1
  	kubectl scale <deploy or sts> -n <ns> --replicas=3
  	kubectl taint nodes --all key:NoSchedule-
    ```
1. `kubectl get svc -A` コマンドを実行し、 Load Balancer の DNS 名を確認する。  
    1. 上記DNS名が名前解決できることを確認する。  
      LB にて設定されたホスト名を CNAME (AWS CLB) もしくは Aレコード (Azure LB) で解決できるように設定する  
      Internet-facing: インターネットにて名前解決ができること  
      Internal: Internal ネットワーク内にあるホストから名前解決できること
    1. 上記で確認した DNS 名の CNAME/Aレコードとして、計画している DNS 名を設定する。DNS Zone 管理者に確認すること。  
    1. DNS 登録ができたことを確認する。  

1. Keycloak で system admin ユーザーを作成する。
    1. 次のページにアクセスする。  
      `https://<ドメイン名>/auth/`  
	   Keycloak の管理者名とパスワード (`secrets.yaml` の `shared.keycloak.data.password` にて指定した内容) を使いログインする。  
	   作成するユーザーは ”System Admin” 権限 (Org を自由に作成可能) のため、取り扱いには注意が必要となる。  
    1. メニューにあるRealm一覧から [Vantiq Platform Deployment] を選択する。
    1. メニューにある Users に移動する。
    1. [Create new User] ボタンをクリック。
    1. Username を入力し、[Save] ボタンをクリック。
    1. 作成したユーザーの Credentials タブをクリック。
    1. パスワードを設定し、Temporary を off にして [Save] ボタンをクリック。
    1. Details タブに移動し、Email verified を ON に変更し [Save] ボタンをクリック。  
    1. Role mapping タブに移動し、[Assign role] をクリックし、[Filter by clients] を選択する。
    1. 全ての role を選択し、[Assign] ボタンをクリック。
    1. 右上のユーザー名アイコンからログアウト。
1. Vantiq IDE で system namespace の初期設定をする。
    1. 次のページにアクセスする。※  
  	    `https://<ドメイン名>/`  
       **※上記ステップでKeycloakからログアウトした画面からはログインできないため、前述のURL `https://<ドメイン名>/` を指定して移動すること。**  
  	   Keycloakで作成した ”System Admin” 権限のユーザー名、パスワードでログインする。  
       初回ログイン時、Request Code を送信する画面が表示される。  
       Box内に`Vantiq Podのlogで確認しておいたkey`を入力し、[送信]ボタンをクリックする。
    1. System admin の Grafana 設定を実施する。 ※   
    **※[Grafana System Dashboards and Data Sources](https://github.com/Vantiq/k8sdeploy_tools/blob/master/docs/Installation.md#grafana-system-dashboards-and-data-sources) _(要権限)_ に記載されている通り、2025年6月以降にリリースされた k8sdeploy_tools ではシステムダッシュボードとデータソースを作成するタスク `grafanaPostInstallSetup` が実装されたため、手動での設定は不要。**  
    **2025年6月以前のバージョンを利用する場合は、以下の手順に従い設定する。**  
       1. system namespaceのメニューから [管理] -> [Grafana] を選択し、Grafana画面を起動する。
       1. Grafana画面のメニューから [Administration] -> [Data sources] を選択する。
       1. [Add data source] ボタンをクリックする。  
       1. データソースタイプとして [InfluxDB] を選択し、以下の表を参考に各パラメータを設定する。  

          | Name | URL | Database | Credentials | Min Time Interval |  
          |------|-----|----------|-------------|-------------------|  
          | systemDB | http://influxdb:8086 | system | ※ | 30s |  
          | vantiqServer| http://influxdb:8086 | vantiq_server | ※ | 30s |  
          | kubernetes | http://influxdb:8086 | kubernetes |  ※ | 30s |  
          | internals | http://influxdb:8086 | \_internal | ※ | 10s |  

          **※それぞれのデータソースを設定する際、username/passwordは`createInfluxDBAdmin`タスクで作成されたREAD権限のものを利用すること。詳細は [k8sdeploy repo](https://github.com/Vantiq/k8sdeploy/blob/master/deploy/shared/influxdb/createAdminJob.yaml) _(要権限)_ を参照。**  

       1. [Save & Test] ボタンをクリックし、「Data source is working」というメッセージが表示されることを確認する。  
       1. Grafana画面のメニューから [Dashboards] を選択する。  
       1. [New] ボタンをクリックし、表示されたプルダウンリストから [Import] を選択する。  
       1. `k8sdeploy_tools/vantiqSystem/deploy/vantiq/dashboards` ディレクトリ配下にある以下のファイルを [Upload dashboard JSON file] にドラッグ&ドロップする。  
             - InfluxDB Internals.json
             - Metric Collection Resources.json
             - MongoDB Monitoring Dashboard.json
             - UserDB Monitoring Dashboard.json
             - Organization Activity.json
             - Organization Activity with Top Namespaces.json
             - Vantiq Resources.json
             - Vantiq Iso Resources.json
       1. ダッシュボード設定画面下部の Options セクションで必要なデータソースを選択し、[Import] ボタンをクリックする。※  
       **※各JsonファイルImport時のデータソース選択では、画面に表示されているデータソース名と同じデータソースを指定すること。**  

    1. Source: `GenericEmailSender` を修正する  
	    Search box に ”generic” と入力し、enter を押下する。 検索結果 Window が表示されるので、[system] にチェックをつけ、"GenericEmailSender" をクリックする。 適切な email server の設定を行い、[変更の保存] をクリックする  
    1. ノードのプロパティを更新する  
	    [デプロイ] -> [Nodes] で、"self" を選択する。
	    デフォルトの http://localhost:8080 を、デプロイされているドメイン名に変更する (例：https://hr-vantiq.co.jp)
    1. ユーザー向け Organization を作成する  
	    [管理] -> [Organization] を選択し、[新規] アイコンをクリックする。
	    Org Name、Org Description、Namespace (root namespace)、Invite Destination (Org Adminのメールアドレス)、[Make Me The Administrator] をチェック（自分が Org 管理者になる場合）し、[変更の保存] をクリック
    1. Organization 管理者を追加する    
	    Namespace から、作成した organization の root namespace に移動する。
       [管理] -> [ユーザー] を選択し、[新規] をクリックする。
	    Authorization プロパティのアイコンをクリックし、権限を Organization Admin にして [OK] をクリックする。追加するユーザーのメールアドレスを入力し、保存する
1. LLM機能を利用する場合は、追加で[こちら](../jp/add_llm_component.md)の手順を実施し、LLM コンポーネントをデプロイすること。

# クラスタ定義のリポジトリ登録<a id="manage_clusterDef"></a>

Vantiq Private Cloud 環境構築後、`k8sdeploy_tools/targetCluster` ディレクトリ配下にあるクラスター定義ファイルをリモートリポジトリへ登録する。  
パスワード等の機密情報が含まれるファイルをリモートリポジトリへアップロードしないように `.gitignore` ファイルを設定する。  
`.gitignore` ファイルのデフォルト設定で対象外とされているファイルは以下の通り。  

  - secrets.yaml  
  - deploy/sensitive ディレクトリ配下のファイル全て  

必要に応じて、`.gitignore` ファイルに対象外とするファイル設定を追加する。  
`.gitignore` ファイルの設定完了後、以下の手順を実行する。  

1. `targetCluster` ディレクトリへ移動する。 
1. `git status` コマンドを実行し、変更差分を確認する。  
1. `git add <登録対象ファイル>` コマンドを実行し、ワークツリーからインデックスへのファイル登録を行う。登録対象ファイルが多い場合は `git add .` コマンドでカレントディレクトリ配下を一括登録も可能。  
1. `git commit -m <コミットメッセージ>` コマンドを実行し、変更内容をローカルブランチにコミットする。  
1. `git push -u origin <クラスタ名>` コマンドを実行し、ローカルの変更内容をリモートリポジトリへアップロードする。  
1. マージリクエスト（プルリクエスト）を作成し、リポジトリ管理者へ送信する。管理者は変更内容を確認し、問題なければリクエストを承認、変更を master ブランチへ反映する。  