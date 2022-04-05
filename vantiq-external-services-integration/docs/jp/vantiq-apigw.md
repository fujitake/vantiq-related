# API Gatewayと組み合わせたデザインパターン

## API Gatewayを使用する一般的な利点
- 認証基盤と連携して、セキュリティ管理を一元化できる
- クオータによる制限をかける
- クラウドAPI Gatewayは背後にあるPaaSサービスのプライベートエンドポイントと仲介する
- インタフェースのアダプタとしての利用する
- APIのバージョン管理ができる


## Vantiqが直接連携できないサービス例
以下のようなケースにおいては、Vantiqはサービスと直接連携ができないため、API Gatewayを活用する。
- ネットワーク的にリーチできない（パブリックネットワークのVantiqからプライベートネットワーク上のサービスエンドポイントへの接続）
- Vantiqがサポートするプロトコル（REST、WebSocket、MQTT、AMQP、Kafka、SMTP…)以外接続が必要である
- REST APIでVantiqがサポートするContent-Type（application/json, text/csvなど）以外のレスポンスを返す
- REST APIでリクエストの都度、リクエストメッセージに対して暗号化署名が必要である

### プライベートサービスエンドポイントとの連携
例）Amazon DynamoDBはプライベートのサービスエンドポイントのみ公開している。 Amazon API Gatewayを介して連携する。

```mermaid
flowchart LR
  V[Vantiq]
  subgraph AWS
    A(API Gateway)
    D[(DynamoDB)]
    A -->|PutItem| D
  end
  V -->|POST| A
```

### メッセージを署名する
例）Azure CosmoDBはCosmosDBが提供する暗号化キーで署名したものをリクエストヘッダーに付加する必要がある。その処理をAPI Gatewayで透過的に行う。
```mermaid
flowchart LR
  V[Vantiq]
  V <-->|POST| A
  subgraph AZ[Azure]
    direction LR
    A(API Gateway)
    C[(CosmosDB)]
    A -->|POST<br />署名を算出しヘッダーに付加| C
    C --> A
  end
```

### デバイスとVantiqを疎結合化
例）デバイスは一度設置すると更新が難しい（トークン、URLなど）。一方、Vantiq側のエンドポイントが変わる可能性もある。API Gatewayにより、API層を抽象化し、セキュリティを一元的に管理する。

```mermaid
flowchart LR
  V[Vantiq]
  A[API Gateway]
  D[IoT GWs]
  D -->|'https://api.xxxxx.com'<br />Vantiqアクセストークン以外<br />ex.デバイス識別や証明書による接続| A
  A -->|`https://dev.vantiq.co.jp/api/v1/resources/yyy`<br />Vantiqアクセストークンによる接続| V
```
- 'api/v1/resources/yyy'は将来的に変わる可能性もある。
- API Gatewayで統合的に認証管理ができる

### データ形式の変換
Vantiqがサポートしない形式のデータを変換して渡す
例）
- 画像（バイナリ）→ Base64に変換 or 外部ストレージ保存の上、画像URLを取得
- Content-Typeの書き換え

```mermaid
flowchart LR
  V[Vantiq]
  T[サードパーティサービス]
  V -->|1. 画像をリクエスト<br />returns 6. 画像URL| A
  subgraph aws[AWS]
    direction LR
    A[API Gateway]
    S[(S3)]
    A --> |4. PNGデータ<br />returns 5. 画像URL| S
  end
  A -->|2. 画像をリクエスト<br />returns 3. PNGデータ| T
```
