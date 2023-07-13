# 荷物仕分けアプリケーション (Standard)

読み取った送り先コードで荷物を仕分けするアプリケーションの開発を体験します。  

> **補足**  
> 物流センターで利用されている荷物仕分けシステムは下記の様に呼ばれています。
>
> - ボックスソーター (Box sorter)
> - スライドシューソーター (Sliding shoe sorter)
> - サーフィンソーター (Surfing Sorter)

## 荷物仕分け (Box Sorter) アプリケーション の学習概要

荷物仕分けアプリケーションの開発を通じて Vantiq の基本機能や MQTT について学びます。  

> **注意**  
> 荷物仕分けアプリケーション (Beginner) を実施していない場合は、先に 荷物仕分けアプリケーション (Beginner) を実施してください。  
> :link: [荷物仕分けアプリケーション (Beginner)](./../boxsorter-beginner/readme.md)

### 学習目的

このワークショップの目的は下記のとおりです。

#### 主目的

1. **Source リソース** を利用して **MQTT ブローカー** とデータの送受信を行うアプリケーションの開発方法を理解する。
1. 次の **Vantiq リソース** の作成方法を理解する。
   1. **Source** 
1. 次の **Activity Pattern** の使い方を理解する。
   1. **EventStream**
   1. **SplitByGroup**
   1. **CashedEnrich**
   1. **Transformation**
   1. **PublishToSource**
1. 外部システムとの接続ポイントとして、 **Source** を用いることを理解する。
1. **App** の **EventStream** Activity Pattern に **Source** を指定することで、外部からのデータを **App** に引き渡せることを理解する。

#### 副次目的

1. MQTT の概要を理解する。

## 荷物仕分けシステムの全体のイメージ

<img src="./imgs/overview.png" width="800">

1. バーコードリーダーで荷物のバーコードを読み取る。
1. 読み取った結果を MQTTブローカーに送信する。
1. Vantiq は MQTTブローカーから読み取り結果を取得する。
1. Vantiq はその結果を元に仕分け処理を行う。
1. Vantiq は仕分け指示を MQTTブローカーに送信する。
1. 制御システムは仕分け指示を MQTTブローカーから取得する。
1. 制御システムは仕分け指示に従ってソーターを制御する。

:link: [実物のイメージはこちら](https://www.youtube.com/watch?v=1LvaiA3N0E8&t=282s)

ワークショップではVantiqの担当部分である No.3〜5 を実装します。
> No.1〜2 は、 Google Colaboratory を利用し、 MQTTブローカーに読み取り結果のサンプル情報を送信することで代用します。  
> Google Colaboratory の詳細は [こちら](/vantiq-google-colab\docs\jp\colab_basic_knowledge.md) で解説しています。

### Vantiq で利用するリソースなどの解説

Vantiq リソースや各用語について解説します。

#### MQTT

オーバーヘッドの多い **HTTP** プロトコルに変わり、通信量がより少ない **MQTT** プロトコルを利用してデータの送受信を行います。  
また、通信プロトコルの変更に伴い **Topic** ではなく **Soruce** を利用してデータの送受信を行います。

#### Source

Vantiq では、外部システムとの接続ポイントとして、 Source というリソースが用意されています。  
Source を利用することで、様々な通信プロトコルを用いたデータの送受信が可能となります。

## Vantiqで実装する荷物仕分け (Box Sorter) アプリケーション 概要

<img src="./imgs/vantiq-app.png" width="600">

このアプリケーションを実装していきます。  
詳細は次のステップで説明しますが、 `MQTTブローカーから情報を取得` 、`仕分け` 、`仕分け指示を MQTTブローカーに送信` という処理を行います。

### 荷物仕分けアプリケーションで利用する Activity Pattern の紹介

このワークショップでは下記の Activity Pattern を利用します。
> 荷物仕分けアプリケーション (Beginner) で紹介したものは割愛します。  
> 詳細は [こちら](./../boxsorter-beginner/readme.md) を参照してください。

#### EventStream Activity

App を利用する際に必ずルートタスクとして設定されている Activity Pattern が **EventStream** になります。  
**EventStream** はデータの入り口となります。  
今回は **Topic** ではなく、 **Source** からデータを受け取ります。

#### CachedEnrich Activity

イベントが通過するたびに Type へのアクセスを行う **Enrich** に代わり、 Type のデータをメモリ上にキャッシュし、より高速な処理ができる **CachedEnrich** を用いるようにします。

#### SplitByGroup Activity

CachedEnrich を用いる上で必要になる Activity Pattern が **SplitByGroup** になります。  

Vantiq ではイベントが複数の処理ノードに分散されて処理されています。  
事前に **SplitByGroup** を用いることで、任意のキー単位でイベントをグルーピングし、処理されるノードが固定されるようにできます。

#### Transformation Activity

イベントのフォーマットを変換するために **Transformation** を用います。  

入力データや出力データのスキーマが未定な場合やスキーマが変更になった場合にも活用することができ、スキーマに対して柔軟な対応が可能になります。  

#### PublishToSource Activity

イベントデータを **Source** 経由で外部に送信するために **PublishToSource** を用います。

## 各自で準備するVantiq以外の要素(事前にご準備ください)

- MQTTブローカー
  - Vantiq から仕分け結果を送信する先として使用します。
  - お好きなブローカーをご利用ください。  
    AmazonMQ などマネージドなものを使っても、 ActiveMQ や Mosquitto をご自身でインストールして準備しても構いません。
  - [The Free Public MQTT Broker by HiveMQ](https://www.hivemq.com/public-mqtt-broker/) のように無料で使用できるブローカーもございます。
  - Vantiq やご自身のクライアントからアクセスできる必要がありますのでインターネット接続できる必要があります。
- Google アカウント
  - Google Colaboratory を利用するために使用します。
- MQTTクライアント（Google Colaboratory を利用しない場合）
  - ご自身の環境から MQTTブローカーに接続し、メッセージをパブリッシュしたりサブスクライブするのに使用します。
  - お好きなクライアントをご利用ください（[MQTT X](https://mqttx.app/) など）。

## 必要なマテリアル

### 商品マスタデータ

- :link: [sorting_condition.csv](./../data/sorting_condition.csv)

## ドキュメント

:link: [手順](./instruction.md)
