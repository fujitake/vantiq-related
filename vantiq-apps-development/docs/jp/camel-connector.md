# Vantiq Camel Connector

Vantiq Camel Connector は Apache Camelがサポートする既製のメッセージングルーティングを介して、Vantiqが組み込みで対応していないプロトコルの統合を可能にします。

![iamge1](../../imgs/camel-connector/picture1.png)

## Apache Camelについて
Apache Camel は、オープンソースの統合フレームワークであり、異なるアプリケーションやシステム間でデータやプロセスを連携させるフレームワークです。
Apache Camel自体の説明は、Qiita記事等を参照してください。


### Component

Apache Camelは 200あまりの既製のコンポーネントがあります。
-  [Camel COMPONENTS](https://camel.apache.org/components/4.0.x/)


### 基本要素、用語

データ連携を定義する Route が基本単位です。 Route には連携元を表す Source (`from`)と、連携先である Sink (`to`)があります。

- Route - メッセージの送信の経路
- Endopoint - Camelから見た外部システムとの接続部分
- Component - エンドポイントへの接続する
- ルート間の同期、非同期
    - 同期 ー 直接呼び出し
    - 非同期 ー キューを挟む
- ルーティング
    - 条件分岐
    - 分割
    - 集約
    - スロットル
    - フィルタ
    - 動的ルーティング
    - ロードバランサー
    - マルチキャスト

Qiitaの記事
- [統合フレームワーク　Apache Camelのメッセージルーティングの基本](https://qiita.com/mkyz08/items/db3083a761cb92828926)


## 使用検討に関して考慮すること

以下のポイントを考慮して使用するか検討してください。

利用しない理由
- Vantiqアプリ内で設定を持つため、密結合になります。 Vantiq本体と一体で保守運用する理由がないのであれば、運用の責任分界点を明確にする観点から独立したコンポーネントとして疎結合が望ましい。
- 蓄積されたデータを読み込む処理を含むのであれば、一般的なETLツールを検討するのが。

利用する理由
- ソースとなるシステムが発生したイベントを連携したい
- 閉じたネットワークにあるデータソースと外にあるVantiqが連携する必要がある
- Vantiqから出力するイベントを連携したり、蓄積させる必要がある

## 環境セットアップ

大まかな流れは手順は以下となります。
1. Vantiqサーバーに `Camel` Sourceを作成する
2. Vantiq extension Source をリポジトリが取得し、Camel Connectorをビルドする
3. Camel Connector にVantiqサーバーとの接続情報を設定し、実行する


### Precondition
- Vantiq サーバー
  - Vantiq 1.36 or later が用意されていること
  - 開発者用 Namespace を作成済みであること
- Camel Connector 実行環境
  - Java 11 以上がインストールされていること
  - インターネットへアクセスできること（Camel実行に必要なライブラリをダウンロードする）
- [Vantiq CLI](./cli-quick-reference.md) がインストールされていること

### 環境

この説明では以下の環境の作業を例にしています。
- "Vantiq サーバー" : 
  - dev.vantiq.com
- "Camel Connector実行環境" : 
  - Macbook Pro M1 
  - Java 11
- "ローカル環境" (CLI実行環境)
  - Macbook Pro M1 
  - Java 11


#### Vantiqサーバー

1. 開発者用 Namespace にてアクセストークンを生成します。 
   メニュー >> Admminister >> Advanced >> Access Token 
   生成したアクセストークンは、次ステップのCLI、およびApache Camel実行環境の`server.config`で使用するため、控えておきます。

2. 新しい Source Type `CAMEL_SOURCE`を追加します。
   1. [`CAMEL_SOURCE.json`](https://github.com/Vantiq/vantiq-extension-sources/blob/master/camelSource/src/main/resources/CAMEL_SOURCE.json) をダウンロードして、CLIを実行するディレクトリに置きます。
   2. Vantig CLI から以下のコマンドを実行します。
   （[参照](https://github.com/Vantiq/vantiq-extension-sources/blob/master/pythonExecSource/docs/Usage.md#defining-the-source-in-vantiq)）

    ```sh
    vantiq -s <profileName> load sourceimpls CAMEL_SOURCE.json
    ```
    もしくは
    ```sh
    vantiq -b https://<host> -t <ACCESS_TOKEN> load sourceimpls CAMEL_SOURCE.json
    ```

   3. メニュー Add >> Source >> New Source で、Source新規作成 ペインを開き、Source Type: `CAMEL_SOURCE` が追加されていることを確認します。


3. Sourceを作成します。指定するパラメータは以下のとおりです。
   -  Source Type: `CAMEL_SOURCE`  （前ステップで作成したもの） 
   -  Source Name: 任意の名前 （ただし後のステップでCamel Connector実行環境の `server.config` で指定したものと一致させること。)
   Sourceを作成した後、Camel Connector実行環境から接続要求があると、直ちに接続が確立します。

4. Source の Properties を設定します。
    ```json
    {
        "camelRuntime": {
            "appName": "<app_name>",
            "routesDocument": "<document name>"
        }
    }
    ```
    `appName` - 任意の名前
    `routesDocument` - Vantiq Document の名前を指定する。 yaml もしくは xml. Camelのルート定義を記載する。設定例は「設定例」の項を参照。  


#### Camel Connector 実行環境

1. [Vantiq Extension Source](https://github.com/Vantiq/vantiq-extension-sources/tree/master) からリポジトリをpullします。 `git pull` もしくは、zipでダウンロードして展開します。

2. `<リポジトリをダウンロードした場所>/vantiq-extension-sources` に移動し、`./gradlew camelConnector:assemble` を実行します。

3. `<リポジトリをダウンロードした場所>/vantiq-extension-sources/camelConnector/build/distributions` に実行ファイルを含む zip と tarファイルが作成されているので、でいずれかを利用します。このファイルに実行ファイルが含まれます。

    ```sh
    camelConnector
    ├-- build
        ├-- distributions
            ├-- camelConnector.zip    # これを任意のディレクトリで解凍する
            ├-- camelConnector.tar
    ```

4. `camelConnector` を展開すると以下が得られます。これ以降の説明は`camelConnector` を起点とします。

    ```sh
    .
    ├-- camelConnector
        ├-- bin
            ├-- camelConnector       # shell
            ├-- camelConnector.bat   # bat
        ├-- lib        
            ├-- camel-api-3.18.3.jar
            ├-- camel-base-3.18.3.jar
            ...
    ```

5.  `server.config` を作成し、`camelConnector`に配置します。

    ```properties
    targetServer = https://dev.vantiq.com
    authToken = P91-WB0Gjs1-C7iM3VdYG70CeFRzPllS4tU_xxxxxxx=
    sources = jp.co.vantiq.test.camel.CamelSource  
    ```

    `targetServer` : Vantiqサーバーのホスト
    `authToken` : アクセストークン。 Vantiqサーバーのアクセストークンを生成する、ステップにて生成したもの。
    `sources` : Sourceの名前。Vantiqサーバーの Source を作成するステップにて指定した名前。

6. `./camelconnector/bin/camelConnector` を実行すると起動します。 Sourceと接続を確立します。 Sourceを介してルート設定をダウンロードを得ると、動作に必要なライブラリを実行時にダウンロードし、`componentCache` に追加します。

    ```sh
    .
    ├-- camelConnector
        ├-- bin
            ├-- camelConnector       
        ├-- lib        
    ├-- componentCache
    ├-- componentLib
    ├-- server.config
    ```


## 設定例

- Vantiq から外部コンポーネントへメッセージを Publish するエンドポイントは、 `from.uri: vantiq://server.config` と書きます。
- Vantiq が外部コンポーネントからのメッセージを Subscribe するエンドポイント、 `to.uri: vantiq://server.config` と書きます。

### Vantiq から AWS SQS へメッセージを送信する

```yaml
- route:
   id: "SQS Source"
   from:
      uri: "vantiq://server.config"
      steps:
      - log:
          message: '"Got ${body}"'
          loggingLevel: INFO
      - to:
          uri: "aws2-sqs:ABCDE_SQS"
          parameters: 
            accessKey: "RAW(AKIAXMUMJ5XXXXXXXXXX)"
            secretKey: "RAW(RZxX8uNprefNUsRVjLQzRGgXXXXXXXXXXXX)"
            region: "ap-northeast-1"
```

### AWS SQS から Vantiqへメッセージを送信する

```yaml
- route:
    id: SQS Sink
    from:
      uri: aws2-sqs:ABCDE_SQS
      parameters:
        accessKey: RAW(AKIAXMUMJ5XXXXXXXXXX)
        secretKey: RAW(RZxX8uNprefNUsRVjLQzRGgXXXXXXXXXXXX)
        region: "ap-northeast-1"
        delay: 100
        greedy: true
      steps:
        - to:
            uri: vantiq://server.config
```

### ファイルシステムからのデータをストリームで読み込み

- ローカルのファイルシステムのディレクトリを監視し、csvファイルが置かれるとレコードを読み取りVantiqへ送信する。
- 処理済みのファイルは別のディレクトリに退避する。

```yaml
- route:
    id: csvimport
    from:
      uri: file:csv_source?delete=true&antInclude=*.csv
      steps:
        - multicast:
            parallelProcessing: false
            steps:
              - to:
                  uri: direct:toVantiq
              - to:
                  uri: file:csv_target/
- route:
    id: toVantiq
    from: 
      uri: direct:toVantiq
      steps:
      - log:
          message: "Processing CSV file: ${headers.CamelFileName}"
      - unmarshal:
          csv:
            useMaps: "true"
            captureHeaderRecord: "true"
      - split:
          simple: ${body}
          parallelProcessing: false
          steps:
            - log:
                message: "Headers: ${headers} Body: ${body}"
            - to:
                uri: vantiq://server.config

```


## Reference

- [Vantiq Camel Connector Readme](https://github.com/Vantiq/vantiq-extension-sources/blob/master/camelConnector/README.md)