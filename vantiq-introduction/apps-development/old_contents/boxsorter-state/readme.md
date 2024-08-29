# 荷物仕分けアプリケーション (State)

荷物仕分けアプリケーション (Standard) を利用して、 **State** について学習します。

## 荷物仕分けアプリケーション (State) の学習概要

開発した荷物仕分けアプリケーションを通じて Vantiq の State について学びます。  
> **注意**  
> 荷物仕分けアプリケーション (Standard) を実施していない場合は、先に 荷物仕分けアプリケーション (Standard) を実施してください。  
> - [荷物仕分けアプリケーション (Standard)](./../boxsorter-standard/readme.md)

### 学習目的

このワークショップの目的は下記のとおりです。

#### 主目的

1. **State** の概要を理解する
1. 特定の Activity Pattern を利用することで、 **State** が自動的に作られることを理解する。
1. **Procedure** の修飾子によって、アクセスできる **State** の種類が変わることを理解する。

#### 副次目的

1. **Global State** や **Partioned State** の概要を理解する。

## State の中身を確認してみる

Vantiq では `State` と呼ばれるリソースを用いることで、データをメモリ上に保持することができます。  
Type と異なり、 MongoDB にアクセスする必要がないため、処理の高速化を図りたい場合には積極的に使用する必要があります。  

今回、 `State` を作成したり操作するといった手順はありませんでした。  
`State` を直接操作するかわりに `Cached Enrich` を使い Type のレコードをメモリ上に保存し、処理の高速化を図るという実装を行いました。  
この際、自動で `State` が作成されています。  
そして、 Cached Enrich は Type から該当レコードを取得し State に格納する、という処理を行なっています。  

本ワークショップでは、 State に格納された Type のレコードを確認していきます。

## 必要なマテリアル

### 各自で準備する Vantiq 以外の要素

以下のものを事前にご用意ください。

- MQTTブローカー
  - Vantiq から仕分け結果を送信する先として使用します。
  - お好きなブローカーをご利用ください。  
    AmazonMQ などマネージドなものを使っても、 ActiveMQ や Mosquitto をご自身でインストールして準備しても構いません。
  - :globe_with_meridians:[The Free Public MQTT Broker by HiveMQ](https://www.hivemq.com/public-mqtt-broker/) のように無料で使用できるブローカーもございます。
  - Vantiq やご自身のクライアントからアクセスできる必要がありますのでインターネット接続できる必要があります。

以下のいずれかを事前にご用意ください。

- Google Colab
  - Google アカウント（※Google Colaboratory を利用するために使用します）
  - [BoxSorterDataGenerator (Standard)](/vantiq-google-colab/docs/jp/box-sorter_data-generator_standard.ipynb)
- Python
  - Python 実行環境
  - [BoxSorterDataGenerator (Standard)](/vantiq-google-colab/docs/jp/box-sorter_data-generator_standard.py)
- MQTTクライアント
  - ご自身の環境から MQTTブローカーに接続し、メッセージをパブリッシュしたりサブスクライブするのに使用します。
  - お好きなクライアントをご利用ください（:globe_with_meridians:[MQTTX](https://mqttx.app/) など）。

### 商品マスタデータ

- [sorting_condition.csv](./../data/sorting_condition.csv)

### プロジェクトファイル

- [荷物仕分けアプリ (Standard) の実装サンプル（Vantiq 1.34）](./../data/box_sorter_standard_1.34.zip)
- [荷物仕分けアプリ (Standard) の実装サンプル（Vantiq 1.36）](./../data/box_sorter_standard_1.36.zip)

### ドキュメント

- [手順](./instruction.md)
