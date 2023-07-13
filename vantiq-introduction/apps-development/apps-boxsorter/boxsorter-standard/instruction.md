# 荷物仕分けアプリケーション開発 (Standard)

## 実装の流れ

下記の流れで実装していきます。

1. 【Source】Vantiq で入力用の MQTTブローカーのデータをサブスクライブする
1. 【App Builder】荷物仕分けアプリの開発
1. 【動作確認】送信結果が正しく仕分けされているか確認する

## 目次

- [荷物仕分けアプリケーション開発 (Standard)](#荷物仕分けアプリケーション開発-standard)
  - [実装の流れ](#実装の流れ)
  - [目次](#目次)
  - [実装詳細](#実装詳細)
    - [アプリケーションが前提とする受信内容](#アプリケーションが前提とする受信内容)
    - [実装するリソース](#実装するリソース)
  - [0.【準備】Google Colaboratory の動作確認](#0準備google-colaboratory-の動作確認)
    - [Google Colaboratory の設定](#google-colaboratory-の設定)
  - [1. 【Source】Vantiq で MQTTブローカーのデータをサブスクライブする](#1-sourcevantiq-で-mqttブローカーのデータをサブスクライブする)
  - [2. 【App Builder】荷物仕分けアプリケーション開発](#2-app-builder荷物仕分けアプリケーション開発)
    - [1. アプリケーションを作成する](#1-アプリケーションを作成する)
    - [2.【EventStream】Source でサブスクライブした内容をアプリケーションで受け取る](#2eventstreamsource-でサブスクライブした内容をアプリケーションで受け取る)
    - [3. 【SplitByGroup】イベントの処理ノードを荷物のコード単位で振り分ける](#3-splitbygroupイベントの処理ノードを荷物のコード単位で振り分ける)
    - [4.【Cached Enrich】仕分け条件をイベントに追加する](#4cached-enrich仕分け条件をイベントに追加する)
    - [5. 【Transformation】必要なフォーマットにイベントを変換する](#5-transformation必要なフォーマットにイベントを変換する)
    - [6. 【Filter】条件に合致したイベントだけを通過させ、仕分けする](#6-filter条件に合致したイベントだけを通過させ仕分けする)
    - [7. 【PublishToSource】仕分け指示をSource経由でMQTTブローカーに送信する](#7-publishtosource仕分け指示をsource経由でmqttブローカーに送信する)
  - [3.【動作確認】送信結果が正しく仕分けされているか確認する](#3動作確認送信結果が正しく仕分けされているか確認する)
    - [Google Colaboratory の設定](#google-colaboratory-の設定-1)
  - [補足説明](#補足説明)
  - [参考情報](#参考情報)
    - [プロジェクトファイル](#プロジェクトファイル)

## 実装詳細

### アプリケーションが前提とする受信内容

```json
{
    "code": "14961234567890",
    "name": "お茶 24本"
}
```

|項目|データ型|
|-|-|
|code|String|
|name|String|

### 実装するリソース

#### Source

|種別|リソース名|役割|
|-|-|-|
|MQTT|BoxInfoMqtt|荷物の仕分け情報の受信用の MQTTクライアント|
|MQTT|SortingResultMqtt|仕分け指示の送信用の MQTTクライアント|

#### App

|リソース名|役割|
|-|-|
|BoxSorter|荷物の仕分け|

##### BoxSorter 詳細

|Activity Pattern|タスク名|役割|
|-|-|-|
|EventStream|ReceiveBoxInfo|Source でサブスクライブした内容をアプリで受け取る|
|SplitByGroup|SplitByCode|イベントの処理ノードを荷物の送り先コード単位で振り分ける|
|Cached Enrich|AttachCondition|仕分け条件をイベントに追加する<br/><span style="color:blue;">※本ワークショップでは荷物を物流センター単位で仕分けます<span>|
|Transformation|TransformForMqtt|必要なフォーマットにイベントを変換する|
|Filter|ExtractToTokyo<br/>ExtractToKanagawa<br/>ExtractToSaitama|条件に合致したイベントだけを通過させ、仕分けする|
|PublishToSource|PublishToTokyo<br/>PublishToKanagawa<br/>PublishToSaitama|仕分け指示を Source 経由で MQTTブローカーに送信する|

> リソース名やタスク名は任意のものに変更しても構いません

> App Builder や Activity Pattern の基礎について確認したい方は [こちら](https://github.com/fujitake/vantiq-related/blob/main/vantiq-apps-development/1-day-workshop/docs/jp/5-02_AppBuilder.md) を参照してください。

#### Type

|種別|リソース名|役割|
|-|-|-|
|Standard|sorting_condition|仕分けに必要な情報を保持|

##### sorting_condition 詳細

|プロパティ名|データ型|論理名|
|-|-|-|
|code|String|送り先コード|
|center_id|Integer|物流センターの ID|
|center_name|String|物流センター名|

> Vantiq のリソースの基礎について確認したい方は [こちら](https://github.com/fujitake/vantiq-related/blob/main/vantiq-apps-development/1-day-workshop/docs/jp/0-10_BasicResources.md) を参照してください。

## 0.【準備】Google Colaboratory の動作確認

Google Colaboratory を使用して、ダミーデータの生成します。  

ダミーデータを送受信するあたって、以下の MQTTブローカーを使用します。
|項目|設定値|備考|
|-|-|-|
|Server URI|mqtt://public.vantiq.com:1883|-|
|Topic|/workshop/jp/yourname/boxinfo|`yourname` の箇所に任意の値を入力する ※英数字のみ|
>この MQTTブローカーはワークショップ用のパブリックなブローカーです。認証は不要です。  
>上記以外の MQTTブローカーを利用しても問題ありません。

### Google Colaboratory の設定

1. 下記のリンクから **データジェネレータ** のページを開く

   - [BoxSorterDataGenerator (Standard)](/vantiq-google-colab/docs/jp/box-sorter_data-generator_standard.ipynb)

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

## 1. 【Source】Vantiq で MQTTブローカーのデータをサブスクライブする

MQTTブローカーと接続したい場合、 MQTTクライアントが必要です。これは Vantiq でも同じです。  
Vantiq の Source は MQTT に対応しており、これがクライアントになります。

1. MQTT Source を作成する
   1. メニューバーの `追加` -> `Source...` -> `+ 新規 Source` をクリックし Source の新規作成画面を開く

   1. 以下の内容を設定し、保存する

      |設定順|項目|設定値|設定箇所|
      |-|-|-|-|
      |1|Source Name|BoxInfoMqtt|-|
      |2|Source Type|MQTT|-|
      |3|Server URI|mqtt://public.vantiq.com:1883|`Server URI` タブ -> `+ Server URI を追加`|
      |4|Topic|/workshop/jp/yourname/boxinfo <br> ※`yourname` の箇所には Google Colaboratory の設定時に設定した値を使用する|`Topic` タブ -> `+ Topic を追加`|
      > 上記以外にも設定できる項目はありますが本ワークショップでは使用しません。

   1. メッセージをサブスクライブできることを確認する
      1. `BoxInfoMqtt` Source のペインを開き `データの受信テスト`(Test Data Receipt) をクリックする
         > `Subscription:BoxInfoMqtt`というペインが新たに開かれます。メッセージをサブスクライブするとここに取得した内容が表示されます。
      1. Google Colaboratory からメッセージを送信する
      1. `Subscription:BoxInfoMqtt` に Google Colaboratory から送信した内容が表示されることを確認する

         ![sub-test-msg](./imgs/sub-test-msg.png)

## 2. 【App Builder】荷物仕分けアプリケーション開発

この手順からアプリケーション開発を開始します。  
MQTTブローカーから取得したメッセージをイベントとして、処理を実装していきます。

### 1. アプリケーションを作成する

1. メニューバーの `追加` -> `Advanced` -> `App...` -> `+ 新規 App` をクリックしアプリケーションの新規作成画面を開く

1. `Name` に `BoxSorter` と入力し `OK` をクリックする

   > `BoxSorter` のペインが開かれますのでここから開発作業を進めていきます。デフォルトで `Initiate` タスクが作成されます。

   > アプリケーションのルートとなるタスクに設定される Activity Pattern は常に `EventStream` Activity になります。

   <img src="./imgs/box-sorter-init.png" width="400">

### 2.【EventStream】Source でサブスクライブした内容をアプリケーションで受け取る

`EventStream` を使って外部から取得したメッセージをイベントとしてアプリケーションに渡します。

1. `Initiate` タスクをクリックし、 `Name` に `ReceiveBoxInfo` と入力する
1. `Configuration` の `クリックして編集` から以下の内容を入力し、 `OK` をクリックする
   
   |項目|設定値|
   |-|-|
   |inboundResource|sources|
   |inboundResourceId|BoxInfoMqtt|

1. App Builder のペインの上部にあるフロッピーディスクのアイコンをクリックし、アプリケーションを保存する

1. `ReceiveBoxInfo` タスクを右クリックし、 `タスク Events を表示` をクリックする
   > `Subscription:BoxSorter_ReceiveBoxInfo` が開かれます。ここには ReceiveBoxInfo タスクの処理結果が表示されます。

1. Google Colaboratory のデータジェネレーターを起動し、ダミーデータを送信します。送信された内容が `Subscription:BoxSorter_ReceiveBoxInfo` に表示されることを確認する
   > この手順で、アプリケーションが MQTT Source(BoxInfoMqtt) 経由で受信した内容を扱える状態まで実装できています。

### 3. 【SplitByGroup】イベントの処理ノードを荷物のコード単位で振り分ける

`SplitByGroup` は任意のキー単位でイベントをグルーピングし、そのグループごとに処理が実行されるノードを振り分けます。  
この次の手順でメモリ上にデータを保存する処理（Cached Enrich）を実装しますが、 `SplitByGroup` の次にその処理を入れることで使用するメモリを任意のキー単位で分散させることができます。

1. `ReceiveBoxInfo` タスクを右クリックし、 `新規タスクとリンク` から新しいタスクを後続に追加する

   1. 新規タスクとリンクダイアログが表示されるので以下の内容を入力し `OK` をクリックする

      |項目|設定値|
      |-|-|
      |Activity Pattern|SplitByGroup|
      |タスク Name|SplitByCode|

   1. `Configuration` から以下の設定を行いアプリケーションを保存する

      |項目|設定値|
      |-|-|
      |groupBy|event.code|

### 4.【Cached Enrich】仕分け条件をイベントに追加する

このアプリケーションが受け取る元の内容は以下のように `code` と `name` だけが含まれているデータです。

```json
{
    "code": "14961234567890",
    "name": "お茶 24本"
}
```

仕分けをして行くにあたり、その判断材料となる情報を追加する必要があります。  
Vantiqでは `Enrich` という Activity Pattern が用意されており、イベントに対して Type に保存されたレコードの内容を追加することができます。  
`Cached Enrich` はメモリ上にデータをキャッシュすることで、二回目以降の処理を高速化をする方式です。  

|項目|設定値|詳細|
|-|-|-|
|Enrich|イベントにTypeのレコードを追加する|毎回MongoDBに対してクエリを発行する|
|Cached Enrich|イベントにTypeのレコードを追加する|初回のみMongoDBに対してクエリを発行する。MongoDBから取得した内容をStateに保存し、以降そこからデータを取得する|

あらかじめ仕分けの判断材料となる情報を保持した Type を作成しておき、これらの Activity でその Type の情報を取得してイベントに追加します。  
一旦アプリケーションから離れ、 Type の作成とレコード追加を行います。  

1. `sorting_condition` Type を作成する
   1. メニューバーの `追加` -> `Type...` -> `+ 新規 Type` をクリックして Type の新規作成画面を開き、以下の内容を入力して `OK` をクリックする

      |項目|設定値|
      |-|-|
      |Name|sorting_condition|
      |Role|standard|

   1. `sorting_condition` のペインが表示されるので、タブごとに以下の設定を行い保存する

      **Properties タブ**
      |プロパティ名|データ型|Required|
      |-|-|-|
      |code|String|✅|
      |center_id|Integer|✅|
      |center_name|String|✅|

      **Indexes タブ**
      |項目|設定値|Is Unigue|
      |-|-|-|
      |Key|code|✅|

      **Natural Keys タブ**
      |項目|設定値|
      |-|-|
      |Key|code|

   1. `sorting_condition` Type にデータをインポートする
      1. メニューバーの `Projects` -> `インポート...` を開き、 `Select Import Type:` を `Data` に設定する
      1. `インポートする CSV ファイルまたは JSON ファイルをここにドロップ` の箇所に [sorting_condition.csv](./data/sorting_condition.csv) をドロップし `インポート` をクリックする

         > Type にレコードをインポートする際は `Data` を選択する必要があります。  
         > デフォルトは `Projects` になっているので注意してください。  

         > インポートする CSV ファイルのファイル名は `sorting_condition.csv` になっている必要があります。  
         > ファイル名が異なる場合は `sorting_condition.csv` にリネームしてください。  

      1. `sorting_condition` Type のペインを開き、上部にある `すべてのレコードを表示` をクリックしてインポートが成功しているか確認する

         |center_id|center_name|code|
         |-|-|-|
         |1|東京物流センター|14961234567890|
         |2|神奈川物流センター|14961234567892|
         |3|埼玉物流センター|14961234567893|

   これで Type とレコードが用意できたのでアプリケーションの開発に戻ります。  
   今回は `Cached Enrich` を使用します。  
   事前に `SplitByGroup` を使用しているため、使用するメモリは任意のキーでグルーピングされて分散されます。

1. `SplitByCode` タスクを追加した際と同じ手順で、 `SplitByCode` の次に以下のタスクを追加する
   1. `新規タスクとリンク` ダイアログが表示されるので以下の内容を入力し `OK` をクリックする

      |項目|設定値|
      |-|-|
      |Activity Pattern|Enrich|
      |タスク Name|AttachCondition|

   1. `AttachCondition` タスクをクリックし、 `Configuration` から以下の設定を行いアプリケーションを保存する

      <details>
      <summary>Vantiq Version 1.34 の場合</summary>

      |項目|設定値|備考|
      |-|-|-|
      |associatedType|sorting_condition|-|
      |refreshInterval|1 day|キャッシュの更新頻度|

      `foreignKeys` の `<null>` をクリックし、下記の設定を行います。

      1. `+ アイテムの追加` をクリックする

         |項目|設定値|備考|
         |-|-|-|
         |Value|code|この項目に設定したプロパティがクエリの条件になる|
      </details>
      
      <details>
      <summary>Vantiq Version 1.36 の場合</summary>
      
      |項目|設定値|備考|
      |-|-|-|
      |associatedType|sorting_condition|-|
      |refreshInterval|1 day|キャッシュの更新頻度|

      `foreignKeys` の `<null>` をクリックし、下記の設定を行います。

      1. `+ 外部キーのプロパティを追加する` をクリックする

         |項目|設定値|備考|
         |-|-|-|
         |Associated Type Property|code|Type 側のプロパティ|
         |Foreign Key Expression|event.code|イベント側のプロパティ|
      </details>

      > VAIL で書くとすると `SELECT ONE FROM sorting_condition WHERE code == code` ということになります。

1. Google Colaboratory からメッセージ（ダミーデータ）を送信し、 Cached Enrich の動作を確認する
   1. `AttachCondition` タスクを右クリックし、 `タスク Events を表示` をクリックして Subscription を表示する
   1. Google Colaboratory のデータジェネレータを起動し、メッセージを送信する
      > 送信先の MQTTブローカー、 Topic はこれまでと同じです。

   1. Vantiq の開発画面に戻り、表示しておいた Subscription に以下のようなイベントが表示されていることを確認する

      ```json
      {
          "code": "14961234567890",
          "name": "お茶 24本",
          "sorting_condition": {
              "_id": "649d30c7c32b66791581af76",
              "center_id": 1,
              "center_name": "東京物流センター",
              "code": "14961234567890",
              "ars_namespace": "BoxSorter",
              "ars_version": 1,
              "ars_createdAt": "2023-06-29T07:20:39.157Z",
              "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143"
          }
      }
      ```

      > `_id` や `ars_***` はシステム側で自動生成されるプロパティのため、この例と同じにはなりません。

      `sorting_condition` というプロパティが追加されており、物流センターに関する情報を追加することができました。

### 5. 【Transformation】必要なフォーマットにイベントを変換する

本ワークショップでは仕分け指示を MQTTブローカーに送信します。

送信時に利用するプロトコルによって必要なフォーマットが異なり、 MQTT 場合は `message` プロパティの `value` として実際に送信したい内容を含める必要があります。

```json
{
    "message": <送信したい内容>
}
```

> プロトコルによってどのようなフォーマットになるかを確認したい方は [こちら](/vantiq-apps-development/docs/jp/data_sending.md#samples) を参照してください。

Vantiq では `Transformation` Activity を使うことで、フォーマットの変換ができます。  

本ワークショップでは `Transformation` Activity 使って、下記のフォーマットにイベントを変換します。

```json
{
   "message": {
      "code": "14961234567890",
      "name": "お茶 24本",
      "sorting_condition": {
         "_id": "636210de304f430ecd9a61c5",
         "center_id": 1,
         "center_name": "東京物流センター",
         "code": "14961234567890",
         "ars_namespace": "workshop_134",
         "ars_version": 2,
         "ars_createdAt": "2022-11-02T06:40:30.894Z",
         "ars_createdBy": "yshimizu",
         "ars_modifiedAt": "2022-11-08T06:00:11.354Z",
         "ars_modifiedBy": "yshimizu"
      }
   }
}
```

1. `AttachCondition` タスクの次に以下のタスクを追加する

   |項目|設定値|
   |-|-|
   |Activity Pattern|Transformation|
   |タスク Name|TransformForMqtt|

1. `TransformForMqtt` に以下の設定を行いアプリケーションを保存する

   <table>
   <tr>
       <th>大項目</th>
       <th>小項目</th>
       <th>設定値</th>
   </tr>
   <tr>
       <td rowspan="2">transformation</td>
       <td>Outbound Property</td>
       <td>message</td>
   </tr>
   <tr>
       <td>Transformation Expression</td>
       <td>event</td>
   </tr>
   </table>

   <img src="./imgs/transformation-conf.png" width="500">

1. `タスク Events を表示` で Subscription を開き、イベントのフォーマットが変換されていることを確認する

   ```json
   {
       "message": {
           "code": "14961234567892",
           "name": "化粧水 36本",
           "time": "2023-07-06 09:07:45",
           "sorting_condition": {
               "_id": "64a67e76c32b6679159e9fca",
               "center_id": 2,
               "center_name": "神奈川物流センター",
               "code": "14961234567892",
               "ars_namespace": "BoxSorterStandard_test",
               "ars_version": 1,
               "ars_createdAt": "2023-07-06T08:42:30.523Z",
               "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143"
           }
       }
   }
   ```

   上記のように `message` の `value` に Transformation 前のイベントが入ったことを確認してください。

### 6. 【Filter】条件に合致したイベントだけを通過させ、仕分けする

特定の物流センターのイベントのみが通過できるフローを実装することで仕分けを行います。  
今回は「東京」「神奈川」「埼玉」の3つの物流センター単位で仕分けをしますので `Filter` Activity を設定したタスクを3つ実装します。

物流センターとその ID は以下の関係になっています。
|物流センター|物流センターID|
|-|-|
|東京|1|
|神奈川|2|
|埼玉|3|

この物流センターID `center_id` で仕分けをします。

1. `TransformForMqtt` タスクの次に以下のタスクを追加し、アプリケーションを保存する
   1. 東京物流センター用

      |項目|設定値|
      |-|-|
      |Activity Pattern|Filter|
      |タスク Name|ExtractToTokyo|

      #### ExtractToTokyo の設定

      |項目|設定値|備考|
      |-|-|-|
      |condition|event.message.sorting_condition.center_id == 1|東京物流センターのIDは `1`|

   1. 神奈川物流センター用

      |項目|設定値|
      |-|-|
      |Activity Pattern|Filter|
      |タスク Name|ExtractToKanagawa|

      #### ExtractToKanagawa の設定

      |項目|設定値|備考|
      |-|-|-|
      |condition|event.message.sorting_condition.center_id == 2|神奈川物流センターのIDは `2`|

   1. 埼玉物流センター用

      |項目|設定値|
      |-|-|
      |Activity Pattern|Filter|
      |タスク Name|ExtractToSaitama|

      #### ExtractToSaitama の設定

      |項目|設定値|備考|
      |-|-|-|
      |condition|event.message.sorting_condition.center_id == 3|埼玉物流センターのIDは `3`|

1. 3つの `ExtractTo***` タスクで `タスク Events を表示` を行い、それぞれ適切なイベントのみ通過しているか確認する
   1. Google Colaboratory からダミーデータをパブリッシュする

   1. 各 Subscription でイベントを適切なイベントだけ通過しているか確認する
      - `ExtractToTokyo` の Subscription に以下のイベント **のみ** が表示されていること

        ```json
        {
            "message": {
                "code": "14961234567890",
                "name": "お茶 24本",
                "time": "2023-07-06 09:19:48",
                "sorting_condition": {
                    "_id": "64a67e76c32b6679159e9fc9",
                    "center_id": 1,
                    "center_name": "東京物流センター",
                    "code": "14961234567890",
                    "ars_namespace": "BoxSorterStandard_test",
                    "ars_version": 1,
                    "ars_createdAt": "2023-07-06T08:42:30.455Z",
                    "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143"
                }
            }
        }
        ```

      - `ExtractToKanagawa` の Subscription に以下のイベント **のみ** が表示されていること

        ```json
        {
            "message": {
                "code": "14961234567892",
                "name": "化粧水 36本",
                "time": "2023-07-06 09:21:06",
                "sorting_condition": {
                    "_id": "64a67e76c32b6679159e9fca",
                    "center_id": 2,
                    "center_name": "神奈川物流センター",
                    "code": "14961234567892",
                    "ars_namespace": "BoxSorterStandard_test",
                    "ars_version": 1,
                    "ars_createdAt": "2023-07-06T08:42:30.523Z",
                    "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143"
                }
            }
        }
        ```

      - `ExtractToSaitama` の Subscription に以下のイベント **のみ** が表示されていること

        ```json
        {
             "message": {
                 "code": "14961234567893",
                 "name": "ワイン 12本",
                 "time": "2023-07-06 09:22:26",
                 "sorting_condition": {
                     "_id": "64a67e76c32b6679159e9fcb",
                     "center_id": 3,
                     "center_name": "埼玉物流センター",
                     "code": "14961234567893",
                     "ars_namespace": "BoxSorterStandard_test",
                     "ars_version": 1,
                     "ars_createdAt": "2023-07-06T08:42:30.592Z",
                     "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143"
                 }
             }
        }
        ```

### 7. 【PublishToSource】仕分け指示をSource経由でMQTTブローカーに送信する

ここまでの実装で仕分けができるようになりましたので、その結果を MQTTブローカーにパブリッシュします。  

受信用の MQTTブローカーには `public.vantiq.com` を使用しましたが、送信用の MQTTブローカーはご自身で事前に準備いただいたものを使用します。  

本ワークショップでは、 物流センターごとに異なる Topic にメッセージをパブリッシュします。  

> #### 補足説明
> 物流センターごとに MQTTブローカーを用意するのは現実的ではありません。  
> そのため、全ての物流センターで同一の MQTTブローカーにメッセージをパブリッシュします。  
> 一方、MQTTブローカー内のメッセージは MQTT の Topic ごとに別れて管理されています。  
> 従って、パブリッシュする際の Topic を物流センターごとに変えることで、物流センターごとに仕分け指示データを別けることができるようになります。  

まずは、送信先の MQTTブローカー用に Source を作成します。  

1. 以下の内容でMQTT Sourceを作成する

   |項目|設定値|備考|
   |-|-|-|
   |Source Name|SortingResultMqtt|-|
   |Source Type|MQTT|-|
   |Server URI|<ご自身のブローカー>|プロトコルとポートが必要<br/>**例：**<br/>非SSL：`mqtt://your-broker.com:1883`<br/>SSL：`mqtts://your-broker.com:8883`|
   > 送信のみに使用しますので Topic の設定は必要ありません。  
   > Topic は送信時に指定します。

   アプリケーションに戻り、送信処理を実装します。

1. 各 `ExtractTo***` タスクの次に、それぞれ以下のタスクを追加してからアプリケーションを保存する

   > 送信先の Topic として物流センターごとに  
   > **`/center/tokyo`** 、**`/center/kanagawa`** 、**`/center/saitama`**  
   > を使用しますが、 HiveMQ の Public MQTT Broker などパブリックな環境を使用する場合は、他人と重複する可能性があるため、  
   > **`/center/yourname/tokyo`** とするなどして重複を避けるようにしてください。

   1. `ExtractToTokyo` タスクの次:

      |項目|設定値|
      |-|-|
      |Activity Pattern|PublishToSource|
      |タスク Name|PublishToTokyo|

      #### PublishToTokyo の設定

      |項目|設定値|備考|
      |-|-|-|
      |source|SortingResultMqtt|-|
      |sourceConfig|{"topic": "/center/tokyo"}|MQTTブローカーの `/center/tokyo` Topic に送信|

   1. `ExtractToKanagawa` タスクの次:

      |項目|設定値|
      |-|-|
      |Activity Pattern|PublishToSource|
      |タスク Name|PublishToKanagawa|

      #### PublishToKanagawa の設定

      |項目|設定値|備考|
      |-|-|-|
      |source|SortingResultMqtt|-|
      |sourceConfig|{"topic": "/center/kanagawa"}|MQTTブローカーの `/center/kanagawa` Topic に送信|

   1. `ExtractToSaitama` タスクの次:

      |項目|設定値|
      |-|-|
      |Activity Pattern|PublishToSource|
      |タスク Name|PublishToSaitama|

      #### PublishToSaitama の設定

      |項目|設定値|備考|
      |-|-|-|
      |source|SortingResultMqtt|-|
      |sourceConfig|{"topic": "/center/saitama"}|MQTTブローカーの `/center/saitama` Topic に送信|

## 3.【動作確認】送信結果が正しく仕分けされているか確認する

MQTTクライアントで送信先の Topic をサブスクライブしておき、正しく仕分けされるか確認します。  

本ワークショップでは、 Google Colaboratory を利用して、サブスクライブを行います。  

> MQTTクライアントは Google Colaboratory の Python スクリプト以外でも大丈夫です。  
>  
> 例：
> - :link: [MQTTX](https://mqttx.app/)
> - :link: [Try MQTT Browser Client](https://www.hivemq.com/demos/websocket-client/) （HiveMQ が提供する Web アプリ）

### Google Colaboratory の設定

1. 下記のリンクから **サブスクライブアプリ** のページを開く

   - [BoxSorterDataSubscriber (Standard)](/vantiq-google-colab/docs/jp/box-sorter_data-subscriber_standard.ipynb)

      > Google Colaboratory を利用する際は Google アカウントへのログインが必要になります。

1. Github のページ内に表示されている、下記の `Open in Colab` ボタンをクリックして、 Google Colaboratory を開く

   ![OpenGoogleColab](./imgs/open_in_colab_button.png)

1. `# MQTTブローカー設定` に以下の内容を入力する

   |項目|設定値|備考|
   |-|-|-|
   |broker|<ご自身のブローカー>|**例：**`broker.hivemq.com`|
   |port|<ご自身のブローカーのポート番号>|**例：**<br/>非SSL：`1883`<br/>SSL：`8883`|
   |topic|<送信先として設定した Topic 名>|**例：**`/center/tokyo`|
   |client_id||※変更不要です。|
   |username||※変更不要です。|
   |password||※変更不要です。|

   > 本スクリプトでは、1つの Topic しかサブスクライブできません。  
   > そのため、物流センターごとに Topic 名を書き換えてサブスクライブする必要があります。

1. 上から順に1つずつ `再生ボタン` を押していく  
   実行が終わるのを待ってから、次の `再生ボタン` を押してください。  

   1. `# ライブラリのインストール`（※初回のみ）
   1. `# ライブラリのインポート`（※初回のみ）
   1. `# MQTTブローカー設定`
   1. `# MQTT Subscriber 本体`

   <br/>

   > **サブスクライブする Topic を変更する場合**  
   > 1. `# MQTT Subscriber 本体` の `停止ボタン` を押して、スクリプトを停止させる。
   > 1. `# MQTTブローカー設定` の `Topic` 変数を書き換える。
   > 1. `# MQTTブローカー設定` の `再生ボタン` を押して変数を反映させる。
   > 1. `# MQTT Subscriber 本体` の `再生ボタン` を押してサブスクライブを開始する。

1. 各物流センターのTopicに正しく仕分け指示が届いていることを確認する

   **例: /center/tokyo Topic に お茶 24本 の仕分け指示が届いている**

   ![result.png](./imgs/result.png)

## 補足説明

Type の NaturalKey については、下記を参照してください。

- [Type の NaturalKey とは？](/vantiq-apps-development/docs/jp/reverse-lookup.md#type-の-naturalkey-とは)

## 参考情報

### プロジェクトファイル

- [荷物仕分けアプリ (Standard) の実装サンプル（Vantiq 1.34）](./../data/box_sorter_standard_1.34.zip)
- [荷物仕分けアプリ (Standard) の実装サンプル（Vantiq 1.36）](./../data/box_sorter_standard_1.36.zip)

以上
