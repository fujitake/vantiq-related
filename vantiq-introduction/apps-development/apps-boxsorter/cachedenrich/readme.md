# ボックスソーター（中級編・CachedEnrich）

ボックスソーターアプリを改修して、メモリ上でデータ処理する方法を体験します。  

> **注意**  
> ボックスソーター（初級編・MQTT）を実施していない場合は、先にそちらを実施してください。  
> - [ボックスソーター（初級編・MQTT）](./../mqtt/readme.md)

## Vantiq で実装するアプリケーションの概要

App Builder を用いて、アプリケーションを作成していきます。  
アプリケーションの完成イメージは下記のとおりです。  

![app_boxsorter_cachedenrich.gif](./imgs/app_boxsorter_cachedenrich.gif)

## アプリケーションの開発で利用する Activity Pattern の紹介

このワークショップでは下記の Activity Pattern を利用します。
> 他のワークショップで紹介したものは割愛します。  

### CachedEnrich Activity

![activitypattern_cachedenrich.png](./imgs/activitypattern_cachedenrich.png)

イベントが通過するたびに Type へのアクセスを行う **Enrich** に代わり、 Type のデータをメモリ上にキャッシュし、より高速な処理ができる **CachedEnrich** を用いるようにします。

### SplitByGroup Activity

![activitypattern_splitbygroup.png](./imgs/activitypattern_splitbygroup.png)

CachedEnrich を用いる上で必要になる Activity Pattern が **SplitByGroup** になります。  

Vantiq ではイベントが複数の処理ノードに分散されて処理されています。  
事前に **SplitByGroup** を用いることで、任意のキー単位でイベントをグルーピングし、処理されるノードが固定されるようにできます。


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
  - [BoxSorterDataGenerator（初級編・MQTT）](/vantiq-google-colab/code/box-sorter_data-generator_mqtt.ipynb)
- Python
  - Python 実行環境
  - [BoxSorterDataGenerator（初級編・MQTT）](/vantiq-google-colab/code/box-sorter_data-generator_mqtt.py)
- MQTTクライアント
  - ご自身の環境から MQTTブローカーに接続し、メッセージをパブリッシュしたりサブスクライブするのに使用します。
  - お好きなクライアントをご利用ください（:globe_with_meridians:[MQTTX](https://mqttx.app/) など）。

### 商品マスタデータ

- [sorting_condition.csv](./../data/sorting_condition.csv)

### プロジェクトファイル

- [ボックスソーター（初級編・MQTT）の実装サンプル（Vantiq 1.37）](./../data/box_sorter_mqtt_1.37.zip)

### ドキュメント

- [手順](./instruction.md)
