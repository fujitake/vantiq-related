# Vantiq Edge R1.37のインストールと大規模言語モデル関連機能の設定ガイド

# はじめに

本ガイドは、Vantiq Edgeのライセンスを有している方向けのインストールと大規模言語モデル関連機能の設定ガイドとなります。ライセンスファイルの手配、Quay.ioプライベート リポジトリへのアクセス権については、担当営業もしくは担当エンジニアにご相談下さい。

# 前提条件

本ガイドでは、下記を前提条件としております。この条件以外の構成については、本ガイドではカバーしておりません。

## ハードウェア要件

ハードウェアの最小要件は下記となります。Vantiq Edge R1.37と大規模言語モデル関連機能を動作させると3GB程度のメモリを消費します。

- 64ビットx86プロセッサ
- 2GB メインメモリ
- 16GB程度の空きストレージ (コンテナイメージだけで8GB程度必要となります)

## ソフトウェア要件

- 64ビット Linux OS
- [Install Docker Engine](https://docs.docker.com/engine/install/)の手順を参照し、Docker engine及びdocker composeをインストールしていること

## その他の要件

- インターネットアクセスが可能な環境であること
- Vantiq Edgeライセンスファイルを有していること
- VantiqサポートチームよりQuay.ioの適切なリポジトリへのアクセス権の付与を受けていること
- OpenAI APIの有償アカウントを契約しており、API Keyを発行していること
- オプション(httpsでVantiq Edgeにアクセスする場合): フルチェーンのSSL証明書と秘密鍵

# セットアップ手順

compose.yamlを配置するディレクトリにconfigディレクトリを作成し、以下のようにライセンスファイルを配置します。

```
.
└── config
    ├── license.key
    └── public.pem
```

下記をコピーしcompose.yamlを用意します。
```yaml
services:
  vantiq_edge:
    container_name: vantiq_edge_server
    image: quay.io/vantiq/vantiq-edge:1.37.3
    ports:
      - 8080:8080
    depends_on:
      - vantiq_edge_mongo
      - vantiq_edge_qdrant
    restart: unless-stopped
    volumes:
      - ./config/license.key:/opt/vantiq/config/license.key
      - ./config/public.pem:/opt/vantiq/config/public.pem
    networks:
      - vantiq_edge

  vantiq_edge_mongo:
    container_name: vantiq_edge_mongo
    image: bitnami/mongodb:4.2.5
    restart: unless-stopped
    environment:
      - MONGODB_USERNAME=ars
      - MONGODB_PASSWORD=ars
      - MONGODB_DATABASE=ars02
    volumes:
      - vantiq_edge_data:/bitnami:rw
    networks:
      vantiq_edge:
        aliases: [edge-mongo]

  vantiq_ai_assistant:
    container_name: vantiq_ai_assistant
    image: quay.io/vantiq/ai-assistant:1.37.3
    restart: unless-stopped
    network_mode: "service:vantiq_edge"

  vantiq_edge_qdrant:
    container_name: vantiq_edge_qdrant
    image: qdrant/qdrant
    restart: unless-stopped
    volumes:
      - qdrantData:/qdrant/storage
    networks:
      vantiq_edge:
        aliases: [edge-qdrant]

networks:
  vantiq_edge:
    ipam:
      config: []
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

コマンド`docker compose ps`にて起動状態を確認できます。大規模言語モデル関連機能を利用する場合、4つのコンテナが起動します。

```
NAME                  COMMAND                  SERVICE               STATUS              PORTS
vantiq_ai_assistant   "uvicorn app.ai_assi…"   vantiq_ai_assistant   running             
vantiq_edge_mongo     "/opt/bitnami/script…"   vantiq_edge_mongo     running             27017/tcp
vantiq_edge_qdrant    "./entrypoint.sh"        vantiq_edge_qdrant    running             6333-6334/tcp
vantiq_edge_server    "/opt/vantiq/bin/van…"   vantiq_edge           running             0.0.0.0:8080->8080/tcp, :::8080->8080/tcp
```

## オプション: SSL設定
httpsでVantiq Edgeにアクセスしたい場合の設定手順です。
compose.yamlを配置するディレクトリにconfig/certsディレクトリを作成し、以下のようにSSL証明書と秘密鍵ファイルを配置します。
その際にSSL証明書と秘密鍵のファイル名はFQDN名.拡張子としてください。拡張子は証明書はcrt、秘密鍵はkeyです。  
ex: 
https://vantiq.example.comでアクセスしたい場合、SSL証明書と秘密鍵のファイル名は以下のようにしてください。  
- SSL証明書  
  vantiq.example.com.crt
- 秘密鍵  
  vantiq.example.com.key

また、nginxを構成する場合には、アップロードするファイルサイズの上限がデフォルトで1MBとなります。ProejctやLLMのドキュメント読み込みにてエラーが発生する可能性があるため、上限を引き上げておきます。本手順では例として20MBを設定します。
configディレクトリにmy_proxy.confを配置します。  

```
.
└── config
    ├── certs
    │   ├── YOUR.FQDN.CERT-FILE.crt
    │   └── YOUR.FQDN.KEY-FILE.key
    ├── license.key
    ├── public.pem
    └── my_proxy.conf
```

my_proxy.confの内容は次の通りです。  
```
client_max_body_size 20m;
```

compose.yamlを編集します。  
`services.vantiq_edge.environment.VIRTUAL_HOST`にFQDNを設定します。

```yaml
services:
  nginx-proxy:
    image: jwilder/nginx-proxy
    container_name: nginx-proxy
    restart: unless-stopped
    ports:
      - 443:443
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - ./config/certs:/etc/nginx/certs
      - ./config/my_proxy.conf:/etc/nginx/conf.d/my_proxy.conf
    networks:
      - vantiq_edge

  vantiq_edge:
    container_name: vantiq_edge_server
    image: quay.io/vantiq/vantiq-edge:1.37.3
    ports:
      - 8080
    depends_on:
      - vantiq_edge_mongo
      - vantiq_edge_qdrant
    restart: unless-stopped
    volumes:
      - ./config/license.key:/opt/vantiq/config/license.key
      - ./config/public.pem:/opt/vantiq/config/public.pem
    networks:
      - vantiq_edge
    environment:
      VIRTUAL_HOST: <INPUT-YOUR-FQDN>  # FQDNを入力

  vantiq_edge_mongo:
    container_name: vantiq_edge_mongo
    image: bitnami/mongodb:4.2.5
    restart: unless-stopped
    environment:
      - MONGODB_USERNAME=ars
      - MONGODB_PASSWORD=ars
      - MONGODB_DATABASE=ars02
    volumes:
      - vantiq_edge_data:/bitnami:rw
    networks:
      vantiq_edge:
        aliases: [edge-mongo]

  vantiq_ai_assistant:
    container_name: vantiq_ai_assistant
    image: quay.io/vantiq/ai-assistant:1.37.3
    restart: unless-stopped
    network_mode: "service:vantiq_edge"

  vantiq_edge_qdrant:
    container_name: vantiq_edge_qdrant
    image: qdrant/qdrant
    restart: unless-stopped
    volumes:
      - qdrantData:/qdrant/storage
    networks:
      vantiq_edge:
        aliases: [edge-qdrant]

networks:
  vantiq_edge:
    ipam:
      config: []
volumes:
  vantiq_edge_data: {}
  qdrantData: {}
```

起動は通常時と同じく`docker compose up -d`で起動してください。  
DNSなどの名前解決の設定はそれぞれの環境に合わせて設定を行ってください。  
起動と名前解決の設定が完了したら`https://<YOUR-FQDN>`でVantiq EdgeのIDEにアクセスし、起動後の設定を行ってください。

# Vantiq Edge起動後の設定

`http://localhost:8080`など、設定したIPアドレスもしくはホスト名でアクセスします。

下記の管理者アカウントでログインします。

```
Username: system
Password: fxtrt$1492
```

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

