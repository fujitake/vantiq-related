# ボックスソーター（MQTTX）

ボックスソーターアプリを利用して、 MQTT クライアントの **MQTTX** について学習します。

## 必要なマテリアル

### 各自で準備する Vantiq 以外の要素

以下のものを事前にご用意ください。

- MQTTブローカー
  - Vantiq から仕分け結果を送信する先として使用します。
  - お好きなブローカーをご利用ください。  
    AmazonMQ などマネージドなものを使っても、 ActiveMQ や Mosquitto をご自身でインストールして準備しても構いません。
  - :globe_with_meridians:[The Free Public MQTT Broker by HiveMQ](https://www.hivemq.com/public-mqtt-broker/) のように無料で使用できるブローカーもございます。
  - Vantiq やご自身のクライアントからアクセスできる必要がありますのでインターネット接続できる必要があります。
- MQTTクライアント
  - :globe_with_meridians: [MQTTX Download](https://mqttx.app/downloads)

以下のいずれかを事前にご用意ください。

- Google Colab
  - Google アカウント（※Google Colaboratory を利用するために使用します）
  - [BoxSorterDataGenerator（MQTT）](/vantiq-google-colab/code/box-sorter_data-generator_mqtt.ipynb)
- Python
  - Python 実行環境
  - [BoxSorterDataGenerator（MQTT）](/vantiq-google-colab/code/box-sorter_data-generator_mqtt.py)
- MQTTクライアント
  - ご自身の環境から MQTTブローカーに接続し、メッセージをパブリッシュしたりサブスクライブするのに使用します。
  - お好きなクライアントをご利用ください（:globe_with_meridians:[MQTTX](https://mqttx.app/) など）。

### 商品マスタデータ

- [sorting_condition.csv](./../data/sorting_condition.csv)

### プロジェクトファイル

- [ボックスソーター（MQTT）の実装サンプル（Vantiq 1.37）](./../data/box_sorter_mqtt_1.37.zip)

### ドキュメント

- [手順](./instruction.md)
