# ボックスソーター（中級編・CachedEnrich）

ボックスソーターアプリを改修して、メモリ上でデータ処理する方法を体験します。  

> **注意**  
> ボックスソーター（入門編・MQTT）を実施していない場合は、先にそちらを実施してください。  
> - [ボックスソーター（入門編・MQTT）](./../mqtt/readme.md)

## Vantiq で実装するアプリケーションの概要

App Builder を用いて、アプリケーションを作成していきます。  
アプリケーションの完成イメージは下記のとおりです。  

![app_boxsorter_mqtt.gif](./imgs/app_boxsorter_mqtt.gif)

## アプリケーションの開発で利用する Activity Pattern の紹介

このワークショップでは下記の Activity Pattern を利用します。
> 他のワークショップで紹介したものは割愛します。  

### EventStream Activity

![activitypattern_eventstream.png](./imgs/activitypattern_eventstream.png)

App を利用する際に必ずルートタスクとして設定されている Activity Pattern が **EventStream** になります。  
**EventStream** はデータの入り口となります。  
今回は **Topic** ではなく、 **Source** からデータを受け取ります。

### PublishToSource Activity

![activitypattern_publishtosource.png](./imgs/activitypattern_publishtosource.png)

イベントデータを **Source** 経由で外部に送信するために **PublishToSource** を用います。

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
  - [BoxSorterDataGenerator（入門編・MQTT）](/vantiq-google-colab/docs/jp/box-sorter_data-generator_beginner_mqtt.ipynb)
- Python
  - Python 実行環境
  - [BoxSorterDataGenerator（入門編・MQTT）](/vantiq-google-colab/docs/jp/box-sorter_data-generator_beginner_mqtt.py)
- MQTTクライアント
  - ご自身の環境から MQTTブローカーに接続し、メッセージをパブリッシュしたりサブスクライブするのに使用します。
  - お好きなクライアントをご利用ください（:globe_with_meridians:[MQTTX](https://mqttx.app/) など）。

### 商品マスタデータ

- [sorting_condition.csv](./../../data/sorting_condition.csv)

### プロジェクトファイル

- [ボックスソーター（入門編・Transformation）の実装サンプル（Vantiq 1.37）](./../../data/box_sorter_beginner_transform_1.37.zip)

### ドキュメント

- [手順](./instruction.md)
