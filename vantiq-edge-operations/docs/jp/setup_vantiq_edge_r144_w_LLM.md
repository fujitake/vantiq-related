# Vantiq Edge(R1.44以降)のインストールと大規模言語モデル関連機能の設定ガイド

# はじめに

本ガイドは、Vantiq Edgeのライセンスを有している方向けのインストールと大規模言語モデル関連機能の設定ガイドとなります。ライセンスファイルの手配、Quay.ioプライベート リポジトリへのアクセス権については、担当営業もしくは担当エンジニアにご相談下さい。

# 前提条件

本ガイドでは、下記を前提条件としております。この条件以外の構成については、本ガイドではカバーしておりません。

## ハードウェア要件

ハードウェアの最小要件は下記となります。  

- 64ビットx86プロセッサ
- 16GB メインメモリ
- 64GBの空きストレージ

## ソフトウェア要件

- 64ビット Linux OS
- [Install Docker Engine](https://docs.docker.com/engine/install/)の手順を参照し、Docker engine及びdocker composeをインストールしていること

## その他の要件

- インターネットアクセスが可能な環境であること
- Vantiq Edgeライセンスファイルを有していること
- VantiqサポートチームよりQuay.ioの適切なリポジトリへのアクセス権の付与を受けていること
- OpenAI APIの有償アカウントを契約しており、API Keyを発行していること

# セットアップ手順

compose.yamlを配置するディレクトリにconfigディレクトリを作成し、以下のようにライセンスファイルを配置します。

```
.
└── config
    ├── license.key
    └── public.pem
```

下記をコピーしcompose.yamlを用意します。  
・`vantiq-edge`のバージョンは適宜変更して下さい。  
・`vantiq-edge`と`vantiq_ai_assistant`は同じバージョンにして下さい。  
・`vantiq_genai_flow_service`と`vantiq_unstructured_api`を利用する場合はコメントアウトを外してください。その場合`vantiq_genai_flow_service`は`vantiq-edge`と同じバージョンにして下さい。  
・`mongodb`のイメージは`bitnamilegacy`に移動しています。


```yaml
services:
  vantiq_edge_netns:
    container_name: vantiq_edge_netns
    image: registry.k8s.io/pause:3.10
    restart: unless-stopped
    networks:
      - vantiq_edge
    ports:
      - 8080:8080

  vantiq_edge:
    container_name: vantiq_edge_server
    image: quay.io/vantiq/vantiq-edge:1.xx.x
    depends_on:
      - vantiq_edge_netns
      - vantiq_edge_mongo
      - vantiq_edge_qdrant
    restart: unless-stopped
    volumes:
      - ./config/license.key:/opt/vantiq/config/license.key
      - ./config/public.pem:/opt/vantiq/config/public.pem
    network_mode: "service:vantiq_edge_netns"

  vantiq_edge_mongo:
    container_name: vantiq_edge_mongo
    image: bitnamilegacy/mongodb:4.2.21
    restart: unless-stopped
    environment:
      - MONGODB_USERNAME=ars
      - MONGODB_PASSWORD=ars
      - MONGODB_DATABASE=ars02
      - MONGODB_ROOT_USER=root
      - MONGODB_ROOT_PASSWORD=ars
    volumes:
      - vantiq_edge_data:/bitnami:rw
    networks:
      vantiq_edge:
        aliases: [edge-mongo]

  vantiq_ai_assistant:
    container_name: vantiq_ai_assistant
    image: quay.io/vantiq/ai-assistant:1.xx.x
    depends_on:
      - vantiq_edge_netns
    restart: unless-stopped
    environment:
      # 0 if the default semantic index ingest is not used; higher while loading a large document set
      - WORKER_POOL_SIZE=1
    network_mode: "service:vantiq_edge_netns"

#  vantiq_genai_flow_service:
#    container_name: vantiq_genai_flow_service
#    image: quay.io/vantiq/genaiflowservice:1.xx.x
#    depends_on:
#      - vantiq_edge_netns
#    restart: unless-stopped
#    command: ["uvicorn", "app.genaiflow_service:app", "--host", "0.0.0.0", "--port", "8889"]
#    network_mode: "service:vantiq_edge_netns"

  vantiq_edge_qdrant:
    container_name: vantiq_edge_qdrant
    image: qdrant/qdrant:v1.13.6
    restart: unless-stopped
    volumes:
      - qdrantData:/qdrant/storage
    networks:
      vantiq_edge:
        aliases: [edge-qdrant]

#  vantiq_unstructured_api:
#    container_name: vantiq_unstructured_api
#    image: quay.io/vantiq/unstructured-api:0.1.2
#    depends_on:
#      - vantiq_edge_netns
#    restart: unless-stopped
#    environment:
#      - PORT=18000
#      - UNSTRUCTURED_PARALLEL_MODE_ENABLED=true
#      - UNSTRUCTURED_PARALLEL_MODE_URL=http://localhost:18000/general/v0/general
#      - UNSTRUCTURED_PARALLEL_MODE_SPLIT_SIZE=20
#      - UNSTRUCTURED_PARALLEL_MODE_THREADS=4
#      - UNSTRUCTURED_DOWNLOAD_THREADS=4
#    network_mode: "service:vantiq_edge_netns"

networks:
  vantiq_edge:
volumes:
  vantiq_edge_data: {}
  qdrantData: {}
```

ディレクトリ構成とファイルを再度確認して下さい。

```
.
├── compose.yaml
└── config
    ├── license.key
    └── public.pem
```

`docker login quay.io`コマンドで quay.ioにご自分のアカウントを使ってログインして下さい。

> [!NOTE]
> ログインしていない状態でdocker compose up -dを実行すると、下記のようなエラーが出力されます。quay.ioにログインしていることをご確認の上、実行して下さい。
> 
> Error response from daemon: unauthorized: access to the requested resource is not authorized

`compose.yaml`がある作業ディレクトリにて下記コマンドを実行します。初回起動時はイメージのダウンロードと起動時の設定のため、時間がかかります。

```
docker compose up -d
```

コマンド`docker compose ps`にて起動状態を確認できます。

```
NAME                        IMAGE                                   COMMAND                  SERVICE                     CREATED          STATUS          PORTS
vantiq_ai_assistant         quay.io/vantiq/ai-assistant:1.44        "uvicorn app.ai_assi…"   vantiq_ai_assistant         13 seconds ago   Up 13 seconds   
vantiq_edge_mongo           bitnamilegacy/mongodb:4.2.21            "/opt/bitnami/script…"   vantiq_edge_mongo           25 seconds ago   Up 13 seconds   27017/tcp
vantiq_edge_netns           registry.k8s.io/pause:3.10              "/pause"                 vantiq_edge_netns           25 seconds ago   Up 13 seconds   0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp
vantiq_edge_qdrant          qdrant/qdrant:v1.13.6                   "./entrypoint.sh"        vantiq_edge_qdrant          25 seconds ago   Up 13 seconds   6333-6334/tcp
vantiq_edge_server          quay.io/vantiq/vantiq-edge:1.44         "/opt/vantiq/bin/van…"   vantiq_edge                 13 seconds ago   Up 13 seconds   
vantiq_genai_flow_service   quay.io/vantiq/genaiflowservice:1.44    "uvicorn app.genaifl…"   vantiq_genai_flow_service   13 seconds ago   Up 13 seconds   
vantiq_unstructured_api     quay.io/vantiq/unstructured-api:0.1.2   "scripts/app-start.sh"   vantiq_unstructured_api     13 seconds ago   Up 13 seconds   
```

## オプション: SSL設定
Vantiq Edgeコンテナ自体にSSL (HTTPS) の終端機能はありません。  
ただし、一般的なWEBアプリと同様に、Vantiq Edgeコンテナの手前にリバースプロキシやロードバランサーを配置することでHTTPS通信を実現することは可能です。※1  

具体的な設定手順は利用するサービス、アプリケーションによって異なるため、各利用環境に合わせた設定が必要となります。  
以下ではSSL設定の参考例として、**①AWS環境でELBを利用する場合の設定手順** 、 **②Azure環境でApplication Gatewayを利用する場合の設定手順** を紹介します。※2  

**※1 Vantiq社が本設定をサポートする訳ではございません。本作業は、ご自身でご対応ください。**  
**※2 本手順は2026年9月時点のものです。利用している各サービスの更新に伴い、変わる可能性があります。**  

### ① AWS環境でELBを利用する場合
<details>

<summary>手順を表示</summary>

#### 前提条件
AWS環境でELBを作成・配置する場合、異なるAZにあるサブネットが最低2つ必要になります。  
作業前にELBを配置する予定のVPCの設定を確認してください。  

#### 設定手順
EC2インスタンスを作成し、同インスタンス上でVantiq Edgeコンテナを実行します。  
Vantiq Edgeを起動するまでの手順は、 [セットアップ手順](#セットアップ手順) の内容と同様です。  

ACMを使用してELBに適用する証明書をリクエストします。  
証明書の自動更新のため、検証方法は `DNS検証` を選択しています。  
![](./picture/setting_ssl_using_ALB_001.png)
![](./picture/setting_ssl_using_ALB_002.png)

証明書のリクエスト完了時に表示されるCNAMEレコードを利用しているDNSサービスに登録します。  
Route53を利用してドメインを管理している場合は、ACMコンソールからワンボタンでレコード登録できます。  
![](./picture/setting_ssl_using_ALB_003.png)

CNAMEレコードをDNSサービスに登録してしばらく経つと証明書のステータスが「**発行済み**」に変わります。  
![](./picture/setting_ssl_using_ALB_004.png)

証明書の発行が完了したら、ELBおよび関連リソースを作成します。  
始めにELB用セキュリティグループを作成し、HTTPS通信を許可するインバウンドルールを追加します。  
![](./picture/setting_ssl_using_ALB_005.png)

ELB用セキュリティグループの作成・設定が完了したら、ELBからVantiq Edgeへの通信を許可するためにVantiq Edge実行インスタンス用セキュリティグループのインバウンドルールにELB用セキュリティグループを追加します。  
![](./picture/setting_ssl_using_ALB_006.png)

次にターゲットグループを作成します。  
今回の手順ではVantiq Edge実行インスタンスとELBは同VPCに配置するため、  
ターゲットとしてVantiq Edge実行インスタンスとvantiq_edge_serverコンテナの待受けポート (8080番) を指定します。ヘルスチェックパスは`/healthz`を指定します。  
![](./picture/setting_ssl_using_ALB_007.png)
![](./picture/setting_ssl_using_ALB_008.png)

ターゲットグループ作成直後はELBとの関連付けがされておらず、ターゲットへのヘルスチェックも未実施です。  
![](./picture/setting_ssl_using_ALB_009.png)

続いてELBを作成します。ELBのタイプは`Application Load Balancer`を選択します。  
![](./picture/setting_ssl_using_ALB_010.png)

ELBが利用するセキュリティグループに前手順で作成したELB用セキュリティグループを指定します。  
リスナーとルーティングの設定として、`HTTPS:443`リスナーを追加し、転送先に前手順で作成したターゲットグループを指定します。  
セキュリティリスナーの設定で証明書の取得先として`ACM`を選択し、前手順で発行した証明書を指定します。  
![](./picture/setting_ssl_using_ALB_011.png)
![](./picture/setting_ssl_using_ALB_012.png)

ELBの作成が完了し設定に問題がなければ、ターゲットグループのヘルスチェック結果が「**正常**」となります。  
![](./picture/setting_ssl_using_ALB_013.png)

利用しているDNSサービスにELBのDNS名をCNAMEレコードとして追加します (本手順ではRoute53を使用しています)  
![](./picture/setting_ssl_using_ALB_014.png)

DNS設定の反映には数秒～数分掛かります。設定が反映されれば `https://<YOUR-FQDN>` でVantiq EdgeのIDEへ接続可能になります。
![](./picture/setting_ssl_using_ALB_015.png)

</details>

### ② Azure環境でApplication Gatewayを利用する場合
<details>

<summary>手順を表示</summary>

#### 前提条件
Azure環境でApplication Gatewayを作成・配置する場合、VNet内に専用サブネットが必要になります。  
VantiqEdge実行ノード (VM) と同じサブネットに同居できないため、事前にVM用とAppGW用のサブネットを用意する必要があります。  

#### 設定手順
VM (Virtual Machine) を作成し、同VM上でVantiq Edgeコンテナを実行します。  
Vantiq Edgeを起動するまでの手順は、 [セットアップ手順](#セットアップ手順) の内容と同様です。  

Application Gatewayを作成します。  
![](./picture/setting_ssl_using_AppGW_001.png)
![](./picture/setting_ssl_using_AppGW_002.png)

Application Gatewayの設定はおおまかにフロントエンド、ルーティング規則、バックエンドの3つの要素で構成されます。  
フロントエンドではApplication Gatewayにアクセスする際のIPアドレスを指定します。  
![](./picture/setting_ssl_using_AppGW_003.png)

バックエンドにはApplication Gatewayへのトラフィックを送信するターゲットを設定します。今回はターゲットとしてVantiq Edge実行ノード (VM) を指定します。  
![](./picture/setting_ssl_using_AppGW_004.png)

ルーティング規則にはフロントエンドとバックエンドを繋ぐルールを設定します。  
リスナーではフロントエンド側の設定を行います。Vantiq Edgeとの通信暗号化のため、プロトコルとしてHTTPSを指定し、暗号化に利用するSSL証明書を指定します。  
SSL証明書の指定方法は、Application Gatewayへ証明書ファイル(PFX形式)を直接アップロードする、もしくはKeyVaultに登録した証明書を指定する方法が選択可能です。  
![](./picture/setting_ssl_using_AppGW_005.png)
![](./picture/setting_ssl_using_AppGW_006.png)

バックエンドターゲットにはバックエンド側のルールを設定します。トラフィックの送信先として前手順で作成したバックエンドプールを指定し、バックエンドとの通信プロトコル (HTTP)、ポート番号 (8080番) を設定します。  
![](./picture/setting_ssl_using_AppGW_007.png)
![](./picture/setting_ssl_using_AppGW_008.png)

Application Gatewayの設定が完了したら、作成ボタンをクリックします。Application Gatewayのデプロイが完了するまでには5～15分程度掛かります。  
![](./picture/setting_ssl_using_AppGW_009.png)

Application Gatewayのデプロイが完了したら、Vantiq Edge実行ノード (VM) 側で通信を受け付けるための設定を行います。  
VMに紐づいているNSGの受信セキュリティ規則に対して、Application GatewayからVMへの通信を許可するルールを追加します。  
![](./picture/setting_ssl_using_AppGW_010.png)

利用しているDNSサービスにApplication GatewayのパブリックIPアドレスをAレコードとして追加します (本手順ではRoute53を使用しています)  
![](./picture/setting_ssl_using_AppGW_011.png)

DNS設定の反映には数秒～数分掛かります。設定が反映されれば `https://<YOUR-FQDN>` でVantiq EdgeのIDEへ接続可能になります。
![](./picture/setting_ssl_using_AppGW_012.png)

</details>


# Vantiq Edge起動後の設定

`http://localhost:8080`など、設定したIPアドレスもしくはホスト名でアクセスします。

下記の管理者アカウントでログインします。

```
Username: system
Password: fxtrt$1492
```

画面上にて、エラーが発生していないことを確認して下さい。  
エラーが発生していると、ナビゲーションバーにて、赤くカウントされた数字が表示されます。これが表示されないのが正しい状態です。  
![](./picture/warningsign.png)

[こちら](https://community.vantiq.com/wp-content/uploads/2022/06/edge-install-ja-2.html#admin_tasks)を参照の上、システム管理者としてOrganizationとユーザとを作成して下さい。

`Administer -> Users'からシステム管理者のパスワードを適宜変更して下さい。

## 大規模言語モデルによる開発アシスタント機能を使う場合

AI Design Assistantなど、大規模言語モデルによる開発アシスタント機能を使う場合、有償のOpenAI API Keyが必要となります。事前にEmbeddingして用意したデータを使うことになるためです。

システム管理者にてログインした状態で、system namespaceにて作業を行なって下さい。`Administer -> Advanced -> Secrets`にてSecretsの設定ウインドウを開きます。`OPENAI_API_KEY`の部分がリンクになっているのでクリックし、Secret:にご自分のOpenAI API Keyを入力し、Saveして下さい。

本機能の動作確認は、ログアウトし、別途作成したOrganizationとユーザにてご確認下さい。手順は、`http://{your ip address}:8080/docs/system/tutorials/quickstart/index.html`にございます。

# 停止方法

作業ディレクトリにて以下のコマンドを実行します。
```
docker compose down
```

