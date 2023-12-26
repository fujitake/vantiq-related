# ボックスソーター（Unwind）

ボックスソーターアプリを改修して、配列データを並列処理する方法について学習します。

今回のセッションでは、荷物のデータが配列としてブローカーから送られてきます。  
この配列のデータをバラして、並列処理を行う追加改修を行います。  

## Vantiq で実装するアプリケーションの概要

App Builder を用いて、アプリケーションを作成していきます。  
アプリケーションの完成イメージは下記のとおりです。  

![boxsorter_unwind.gif](./imgs/boxsorter_unwind.gif)

## アプリケーションの開発で利用する Activity Pattern の紹介

このワークショップでは下記の Activity Pattern を利用します。
> 他のワークショップで紹介したものは割愛します。  

### Unwind Activity

![activitypattern_unwind.png](./imgs/activitypattern_unwind.png)

配列が含まれる1つのイベントを複数のイベントに分割して並列処理を行います。  
分割してから個々のイベントととして並列処理するようになるため、負荷分散になります。  

> **注意**  
> `Unwind` Activity で配列を分割する際は、 **1000件** を上限として利用するようにしてください。

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
  - [BoxSorterDataGenerator (Unwind)](/vantiq-google-colab/code/box-sorter_data-generator_unwind.ipynb)
- Python
  - Python 実行環境
  - [BoxSorterDataGenerator (Unwind)](/vantiq-google-colab/code/box-sorter_data-generator_unwind.py)
- MQTTクライアント
  - ご自身の環境から MQTTブローカーに接続し、メッセージをパブリッシュしたりサブスクライブするのに使用します。
  - お好きなクライアントをご利用ください（:globe_with_meridians:[MQTTX](https://mqttx.app/) など）。

### 商品マスタデータ

- [sorting_condition.csv](./../data/sorting_condition.csv)

### プロジェクトファイル

- [ボックスソーター（MQTT）の実装サンプル（Vantiq 1.37）](./../data/box_sorter_mqtt_1.37.zip)

### ドキュメント

- [手順](./instruction.md)
