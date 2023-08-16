# 荷物仕分けアプリケーション開発 (SaveToType)

## 目次

- [荷物仕分けアプリケーション開発 (SaveToType)](#荷物仕分けアプリケーション開発-savetotype)
  - [目次](#目次)
  - [0. 事前準備](#0-事前準備)
    - [プロジェクトの準備](#プロジェクトの準備)
    - [入力用 MQTTブローカーの確認](#入力用-mqttブローカーの確認)
    - [Google Colaboratory の設定](#google-colaboratory-の設定)
    - [MQTT Source の確認](#mqtt-source-の確認)
  - [1. アプリケーションの改修（Filter）](#1-アプリケーションの改修filter)
  - [3. 送信結果が正しく仕分けされているか確認する](#3-送信結果が正しく仕分けされているか確認する)

## 0. 事前準備

### プロジェクトの準備

荷物仕分けアプリケーション (Standard) のプロジェクトを開きます。  

> **補足**  
> 荷物仕分けアプリケーション (Standard) のプロジェクトが存在しない場合などは、プロジェクトファイルをインポートしてください。

### 入力用 MQTTブローカーの確認

入力には以下の MQTTブローカーを使用します。

|項目|設定値|備考|
|-|-|-|
|Server URI|mqtt://public.vantiq.com:1883|-|
|Topic|/workshop/jp/yourname/boxinfo|`yourname` の箇所に任意の値を入力する ※英数字のみ|
>この MQTTブローカーはワークショップ用のパブリックなブローカーです。認証は不要です。  
>上記以外の MQTTブローカーを利用しても問題ありません。

### Google Colaboratory の設定

1. 下記のリンクから **データジェネレータ** のページを開く

   - [BoxSorterDataGenerator (SaveToType)](/vantiq-google-colab/docs/jp/box-sorter_data-generator_savetype.ipynb)

   > Google Colaboratory を利用する際は Google アカウントへのログインが必要になります。

1. Github のページ内に表示されている、下記の `Open in Colab` ボタンをクリックして、 Google Colaboratory を開く

   ![OpenGoogleColab](./imgs/open_in_colab_button.png)

1. `# MQTTブローカー設定` に以下の内容を入力する

   |項目|設定値|備考|
   |-|-|-|
   |broker|public.vantiq.com|※変更不要です。|
   |port|1883|※変更不要です。|
   |topic|/workshop/jp/**yourname**/boxinfo|`yourname` の箇所に任意の値を入力します。（※英数字のみ）|
   |client_id||※変更不要です。|
   |username||※変更不要です。|
   |password||※変更不要です。|

1. 上から順に1つずつ `再生ボタン` を押していく  
   実行が終わるのを待ってから、次の `再生ボタン` を押してください。  

   1. `# ライブラリのインストール`（※初回のみ）
   1. `# ライブラリのインポート`（※初回のみ）
   1. `# MQTTブローカー設定`
   1. `# 送信データ設定`
   1. `# MQTT Publisher 本体`

1. エラーが発生していないことを確認し、 `# MQTT Publisher 本体` の左側の `停止ボタン` を押して、一旦、停止させておく

### MQTT Source の確認

Source の設定を行い、メッセージがサブスクライブできるか確認します。  

1. `BoxInfoMqtt` Source のペインを開く

1. 以下の内容が設定されているか確認をする

   |設定順|項目|設定値|設定箇所|
   |-|-|-|-|
   |1|Source Name|BoxInfoMqtt|-|
   |2|Source Type|MQTT|-|
   |3|Server URI|mqtt://public.vantiq.com:1883|`Server URI` タブ|
   |4|Topic|/workshop/jp/yourname/boxinfo <br> ※`yourname` の箇所には疎通確認時に設定した値を使用する|`Topic` タブ|

1. メッセージをサブスクライブできることを確認する
   1. `BoxInfoMqtt` Source のペインの `データの受信テスト`(Test Data Receipt) をクリックする
   1. Google Colaboratory の `# MQTT Publisher 本体` を実行し、メッセージを送信する
   1. `Subscription:BoxInfoMqtt` に Google Colaboratory から送信した内容が表示されることを確認する

      ![sub-test-msg](./imgs/sub-test-msg.png)





## 1. アプリケーションの改修（Filter）

MQTTX からパブリッシュしたメッセージを App の `EventStream` でも受け取れているか確認します。

1. `BoxSorter` App のペインを開く
1. `ReceiveBoxInfo` タスクをクリックし、 `タスク Events を表示` をクリックする
1. MQTTX から疎通確認時と同じようにメッセージを送信する
1. `Subscription:BoxSorter_ReceiveBoxInfo` に MQTTX から送信した内容が表示されることを確認する

## 3. 送信結果が正しく仕分けされているか確認する

MQTTX で送信先の Topic をサブスクライブしておき、正しく仕分けされるか確認します。

1. MQTTX で仕分け指示の送信先の MQTTブローカーに接続し、  
   `/center/tokyo` , `/center/kanagawwa` , `/center/saitama` をサブスクライブする

   <img src="./imgs/result-mqtt.png" width="500">

1. 前の手順の接続は維持したまま、別途入力用の MQTTブローカー `public.vantiq.com` と接続し以下のメッセージを送信する

   **東京物流センター用**

   ```json
   {
       "code": "14961234567890",
       "name": "お茶 24本"
   }
   ```

   **神奈川物流センター用**

   ```json
   {
       "code": "14961234567892",
       "name": "化粧水 36本"
   }
   ```

   **埼玉物流センター用**

   ```json
   {
       "code": "14961234567893",
       "name": "ワイン 12本"
   }
   ```

1. 各物流センターの Topic に正しく仕分け指示が届いていることを確認する

   **例: /center/tokyo Topic に お茶 24本 の仕分け指示が届いている**

   <img src="./imgs/result.png" width="500">

以上
