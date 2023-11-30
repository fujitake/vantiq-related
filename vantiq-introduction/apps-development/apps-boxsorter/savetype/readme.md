# ボックスソーター（中級編・SaveToType）

ボックスソーターアプリを改修して、 Type にデータを保存する方法について学習します。

今回のセッションでは、 `sorting_condition` Type に登録されていない荷物コードがブローカーから送られてきます。  
荷物コードが登録されていない荷物を管理するために、新たに Type を作成し、最新の未登録データを保存します。  

## Vantiq で実装するアプリケーションの概要

App Builder を用いて、アプリケーションを作成していきます。  
アプリケーションの完成イメージは下記のとおりです。  

![boxsorter_savetotype.gif](./imgs/boxsorter_savetotype.gif)

## アプリケーションの開発で利用する Activity Pattern の紹介

このワークショップでは下記の Activity Pattern を利用します。
> 他のワークショップで紹介したものは割愛します。  

### SaveToType Activity

![activitypattern_savetotype.png](./imgs/activitypattern_savetotype.png)

イベントを Type に保存します。  
保存方法は `INSERT` もしくは `UPSERT` になります。  
`UPSERT` を利用する場合は、 Type の設定で `Natural Key` を事前に設定しておく必要があります。  

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
  - [BoxSorterDataGenerator（中級編・SaveToType）](/vantiq-google-colab/code/box-sorter_data-generator_savetype.ipynb)

- Python
  - Python 実行環境
  - [BoxSorterDataGenerator（中級編・SaveToType）](/vantiq-google-colab/code/box-sorter_data-generator_savetype.py)

### 商品マスタデータ

- [sorting_condition.csv](./../data/sorting_condition.csv)

### プロジェクトファイル

- [ボックスソーター（初級編・MQTT）の実装サンプル（Vantiq 1.37）](./../data/box_sorter_mqtt_1.37.zip)

### ドキュメント

- [手順](./instruction.md)
