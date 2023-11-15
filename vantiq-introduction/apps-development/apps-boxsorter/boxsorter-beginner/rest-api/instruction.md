# ボックスソーター（入門編・REST API）

## 実装の流れ

下記の流れで実装していきます。

1. 【準備】Namespace の作成と Project の保存、データジェネレータの準備
1. 【Topic】Vantiq で REST API 用のエンドポイントを作成する
1. 【Type】Vantiq マスタデータを取り込む
1. 【App Builder】ボックスソーターアプリの開発
1. 【動作確認】送信結果が正しく仕分けされているか確認する

> リソース名やタスク名は任意のものに変更しても構いません。

## 目次

- [ボックスソーター（入門編・REST API）](#ボックスソーター入門編rest-api)
  - [実装の流れ](#実装の流れ)
  - [目次](#目次)
  - [アプリケーションが前提とする受信内容](#アプリケーションが前提とする受信内容)
  - [1.【準備】Namespace の作成と Project の保存](#1準備namespace-の作成と-project-の保存)
  - [2.【準備】データジェネレータの準備](#2準備データジェネレータの準備)
    - [Vantiq Access Token の発行](#vantiq-access-token-の発行)
    - [Google Colaboratory の設定](#google-colaboratory-の設定)
  - [3. Topic を用いた REST API エンドポイントの作成](#3-topic-を用いた-rest-api-エンドポイントの作成)
    - [Topic の作成](#topic-の作成)
  - [4. Type を用いたマスタデータの作成](#4-type-を用いたマスタデータの作成)
    - [Type の作成](#type-の作成)
  - [5. App Builder を用いた App の開発](#5-app-builder-を用いた-app-の開発)
    - [1. アプリケーションの作成](#1-アプリケーションの作成)
    - [2.【EventStream】Topic で受信した内容をアプリケーションで受け取る](#2eventstreamtopic-で受信した内容をアプリケーションで受け取る)
    - [3.【Enrich】仕分け条件をイベントに追加する](#3enrich仕分け条件をイベントに追加する)
    - [4. 【Filter】条件に合致したイベントだけを通過させ、仕分けする](#4-filter条件に合致したイベントだけを通過させ仕分けする)
    - [5. 【LogStream】仕分け指示をログとして表示](#5-logstream仕分け指示をログとして表示)
  - [6.【動作確認】送信結果が正しく仕分けされているか確認する](#6動作確認送信結果が正しく仕分けされているか確認する)
  - [Project のエクスポート](#project-のエクスポート)
  - [ワークショップの振り返り](#ワークショップの振り返り)
  - [補足説明](#補足説明)
  - [参考情報](#参考情報)
    - [プロジェクトファイル](#プロジェクトファイル)

## アプリケーションが前提とする受信内容

```json
{
    "code": "14961234567890",
    "name": "お茶 24本"
}
```

## 1.【準備】Namespace の作成と Project の保存

アプリケーションを実装する前に新しく Namespace を作成し、作成した Namespace に切り替えます。  
あわせてプロジェクトの保存も行っておきます。  

詳細は下記をご確認ください。  
[Vantiq の Namespace と Project について](/vantiq-introduction/apps-development/vantiq-basic/namespace/namespace.md)

## 2.【準備】データジェネレータの準備

Google Colaboratory を使用して、ダミーデータの生成します。  
Google Colaboratory を利用するにあたり、事前に **Vantiq Access Token** を発行する必要があります。  

### Vantiq Access Token の発行

1. メニューバーの `管理` -> `Advanced` -> `Access Tokens` -> `+ 新規` をクリックし Token の新規作成画面を開く

   ![accesstoken_01](./imgs/accesstoken_01.png)

1. 以下の内容を設定し、保存する

   |項目|設定値|備考|
   |-|-|-|
   |Name|BoxDataToken|左記以外の名前でも問題ありません。|

   ![accesstoken_02](./imgs/accesstoken_02.png)

1. 発行された `Access Token` をクリックして、クリップボードにコピーしておく

   ![accesstoken_03](./imgs/accesstoken_03.png)

### Google Colaboratory の設定

1. 下記のリンクから **データジェネレータ** のページを開く

   - [BoxSorterDataGenerator（入門編・REST API）](/vantiq-google-colab/docs/jp/box-sorter_data-generator_beginner_rest-api.ipynb)

      > Google Colaboratory を利用する際は Google アカウントへのログインが必要になります。

1. Github のページ内に表示されている、下記の `Open in Colab` ボタンをクリックして、 Google Colaboratory を開く

   ![OpenGoogleColab](./imgs/open_in_colab_button.png)

1. `# 設定情報` に以下の内容を入力する

   |項目|設定値|備考|
   |-|-|-|
   |url|https://{VantiqのURL(FQDN)}/api/v1/resources/topics//BoxInfoApi|SSL化されていないサーバーの場合は、 `https://` を `http://` に置き換えてください。|
   |accesstoken|7tFxPj4JuNFnuwmGcEadU_6apA1r3Iji2N7AZS5HuVU=|上記で発行した Access Token|

   ![google_colab_setting](./imgs/google_colab_setting.png)

1. 上から順に1つずつ `再生ボタン` を押していく  
   実行が終わるのを待ってから、次の `再生ボタン` を押してください。  

   ![google_colab_run](./imgs/google_colab_run.png)

## 3. Topic を用いた REST API エンドポイントの作成

サーバーからデータを受信したい場合、エンドポイントが必要です。  
これは Vantiq でも同じです。  
Vantiq の Topic がエンドポイントになります。  

### Topic の作成

1. メニューバーの `追加` -> `Advanced` -> `Topic...` -> `+ 新規 Topic` をクリックし Topic の新規作成画面を開く
   
   ![create_topic_01.png](./imgs/create_topic_01.png)

1. 以下の内容を設定し、保存する

   |項目|設定値|設定箇所|
   |-|-|-|
   |Name|/BoxInfoApi|-|

   ![create_topic_02.png](./imgs/create_topic_02.png)

   > 上記以外にも設定できる項目はありますが本ワークショップでは使用しません。

1. データを受信できることを確認する
   1. `/BoxInfoApi` Topicのペインを開き `データの受信テスト` をクリックする

      ![create_topic_03.png](./imgs/create_topic_03.png)

      > `Subscription: /BoxInfoApi` というペインが新たに開かれます。データを受信するとここに取得した内容が表示されます。
   1. `Subscription: /BoxInfoApi` に Google Colaboratory から受信した内容が表示されることを確認する

      ![receive-test-data.png](./imgs/receive-test-data.png)

## 4. Type を用いたマスタデータの作成

このアプリケーションが受け取る元の内容は以下のように `code` と `name` だけが含まれているデータです。

```json
{
    "code": "14961234567890",
    "name": "お茶 24本"
}
```

仕分けをしていくにあたり、その判断材料となる情報を追加する必要があります。  
Vantiq では `Enrich` という Activity Pattern が用意されており、イベントに対して Type に保存されたレコードの内容を追加することができます。  

|項目|設定値|詳細|
|-|-|-|
|Enrich|イベントに Type のレコードを追加する|毎回 MongoDB に対してクエリを発行する|

あらかじめ仕分けの判断材料となる情報を保持した Type を作成しておき、これらの Activity でその Type の情報を取得してイベントに追加します。  
一旦アプリケーションから離れ、 Type の作成とレコード追加を行います。  

### Type の作成

1. `sorting_condition` Type を作成する
   1. メニューバーの `追加` -> `Type...` -> `+ 新規 Type` をクリックして Type の新規作成画面を開き、以下の内容を入力して `OK` をクリックする

      |項目|設定値|
      |-|-|
      |Name|sorting_condition|
      |Role|standard|

      ![create_type_01.png](./imgs/create_type_01.png)

      ![create_type_02.png](./imgs/create_type_02.png)

   1. `sorting_condition` のペインが表示されるので、タブごとに以下の設定を行い保存する

      > **Properties** の設定が終わったら、一度保存しておきます。

      **Properties タブ**
      |プロパティ名|データ型|Required|
      |-|-|-|
      |code|String|✅|
      |center_id|Integer|✅|
      |center_name|String|✅|

      ![create_type_03.png](./imgs/create_type_03.png)

      ![create_type_04.png](./imgs/create_type_04.png)

      ![create_type_05.png](./imgs/create_type_05.png)

      **Indexes タブ**
      |項目|設定値|Is Unigue|
      |-|-|-|
      |Key|code|✅|

      ![create_type_06.png](./imgs/create_type_06.png)

      ![create_type_07.png](./imgs/create_type_07.png)

      **Natural Keys タブ**
      |項目|設定値|
      |-|-|
      |Key|code|

      ![create_type_08.png](./imgs/create_type_08.png)

      ![create_type_09.png](./imgs/create_type_09.png)

1. `sorting_condition` Type にデータをインポートする
   1. メニューバーの `Projects` -> `インポート...` を開き、 `Select Import Type:` を `Data` に設定する

      ![csv_import_01.png](./imgs/csv_import_01.png)

   1. `インポートする CSV ファイルまたは JSON ファイルをここにドロップ` の箇所に [sorting_condition.csv](./../../data/sorting_condition.csv) をドロップし `インポート` をクリックする

      ![csv_import_02.png](./imgs/csv_import_02.png)

      > Type にレコードをインポートする際は `Data` を選択する必要があります。  
      > デフォルトは `Projects` になっているので注意してください。  

      > インポートする CSV ファイルのファイル名は `sorting_condition.csv` になっている必要があります。  
      > ファイル名が異なる場合は `sorting_condition.csv` にリネームしてください。  

   1. `sorting_condition` Type のペインを開き、上部にある `すべてのレコードを表示` をクリックしてインポートが成功しているか確認する

      ![csv_import_03.png](./imgs/csv_import_03.png)

      ![csv_import_04.png](./imgs/csv_import_04.png)

## 5. App Builder を用いた App の開発

この手順からアプリケーション開発を開始します。  
Topic で取得したデータをイベントとして、処理を実装していきます。

### 1. アプリケーションの作成

1. メニューバーの `追加` -> `Advanced` -> `App...` -> `+ 新規 App` をクリックしアプリケーションの新規作成画面を開く
   
   ![create_app_01.png](./imgs/create_app_01.png)

1. `Name` に `BoxSorter` と入力し `OK` をクリックする

   ![create_app_02.png](./imgs/create_app_02.png)

### 2.【EventStream】Topic で受信した内容をアプリケーションで受け取る

`EventStream` を使って外部から取得したデータをイベントとしてアプリケーションに渡します。

> `BoxSorter` のペインが開かれますのでここから開発作業を進めていきます。デフォルトで `Initiate` タスクが作成されます。

1. `Initiate` タスクをクリックし、 `Name` に `ReceiveBoxInfo` と入力する

   ![create_app_03.png](./imgs/create_app_03.png)

   > アプリケーションのルートとなるタスクに設定される Activity Pattern は常に `EventStream` Activity になります。

1. `Configuration` の `クリックして編集` から以下の内容を入力し、 `OK` をクリックする

   |項目|設定値|
   |-|-|
   |inboundResource|topics|
   |inboundResourceId|/BoxInfoApi|

   ![create_app_04.png](./imgs/create_app_04.png)

   ![create_app_05.png](./imgs/create_app_05.png)

1. App Builder のペインの上部にあるフロッピーディスクのアイコンをクリックし、アプリケーションを保存する

   ![create_app_06.png](./imgs/create_app_06.png)

1. `ReceiveBoxInfo` タスクを右クリックし、 `タスク Events を表示` をクリックする

   ![create_app_07.png](./imgs/create_app_07.png)

   > `Subscription:BoxSorter_ReceiveBoxInfo` が開かれます。ここには ReceiveBoxInfo タスクの処理結果が表示されます。

1. Google Colaboratory のデータジェネレーターを起動し、ダミーデータを送信します。  
   送信された内容が `Subscription:BoxSorter_ReceiveBoxInfo` に表示されることを確認します。ｄ；

   ![create_app_08.png](./imgs/create_app_08.png)

   > この手順で、アプリケーションが Topic で受信した内容を扱える状態まで実装できています。

### 3.【Enrich】仕分け条件をイベントに追加する

`Enrich` Activity Pattern を使用して、 Type のデータを追加します。

1. 画面左側の **Project Contents** から **BoxSorter App** を開きます。

   ![project-contents_app.png](./imgs/project-contents_app.png)

1. `ReceiveBoxInfo` タスクを右クリックし、 `新規タスクとリンク` から新しいタスクを後続に追加する
   1. `新規タスクとリンク` ダイアログが表示されるので以下の内容を入力し `OK` をクリックする

      |項目|設定値|
      |-|-|
      |Activity Pattern|Enrich|
      |タスク Name|AttachCondition|

   1. `AttachCondition` タスクをクリックし、 `Configuration` から以下の設定を行いアプリケーションを保存する

      <details>
      <summary>Vantiq Version 1.35 以前の場合</summary>

      |項目|設定値|備考|
      |-|-|-|
      |associatedType|sorting_condition|-|

      `foreignKeys` の `<null>` をクリックし、下記の設定を行います。

      1. `+ アイテムの追加` をクリックする

         |項目|設定値|備考|
         |-|-|-|
         |Value|code|この項目に設定したプロパティがクエリの条件になる|
      </details>
      
      <details>
      <summary>Vantiq Version 1.36 以降の場合</summary>
      
      |項目|設定値|備考|
      |-|-|-|
      |associatedType|sorting_condition|-|

      `foreignKeys` の `<null>` をクリックし、下記の設定を行います。

      ![app_enrich_01.png](./imgs/app_enrich_01.png)

      1. `+ 外部キーのプロパティを追加する` をクリックする

         |項目|設定値|備考|
         |-|-|-|
         |Associated Type Property|code|Type 側のプロパティ|
         |Foreign Key Expression|event.code|イベント側のプロパティ|

         ![app_enrich_02.png](./imgs/app_enrich_02.png)
      </details>

   > VAIL で書くとすると `SELECT ONE FROM sorting_condition WHERE code == code` ということになります。

1. Google Colaboratory からダミーデータを送信し、 Enrich の動作を確認する
   1. `AttachCondition` タスクを右クリックし、 `タスク Events を表示` をクリックして Subscription を表示する
   1. Google Colaboratory のデータジェネレータを起動し、ダミーデータを送信する
      > 送信先のエンドポイントなどはこれまでと同じです。

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

### 4. 【Filter】条件に合致したイベントだけを通過させ、仕分けする

特定の物流センターのイベントのみが通過できるフローを実装することで仕分けを行います。  
今回は「東京」「神奈川」「埼玉」の3つの物流センター単位で仕分けをしますので `Filter` Activity を設定したタスクを3つ実装します。

物流センターとその ID は以下の関係になっています。
|物流センター|物流センターID|
|-|-|
|東京|1|
|神奈川|2|
|埼玉|3|

この物流センターID `center_id` で仕分けをします。

1. `AttachCondition` タスクの次に以下のタスクを追加し、アプリケーションを保存する
   1. 東京物流センター用

      |項目|設定値|
      |-|-|
      |Activity Pattern|Filter|
      |Task Name|ExtractToTokyo|

      #### ExtractToTokyo の設定

      |項目|設定値|備考|
      |-|-|-|
      |condition|event.sorting_condition.center_id == 1|東京物流センターのIDは `1`|

   1. 神奈川物流センター用

      |項目|設定値|
      |-|-|
      |Activity Pattern|Filter|
      |Task Name|ExtractToKanagawa|

      #### ExtractToKanagawa の設定

      |項目|設定値|備考|
      |-|-|-|
      |condition|event.sorting_condition.center_id == 2|神奈川物流センターのIDは `2`|

   1. 埼玉物流センター用

      |項目|設定値|
      |-|-|
      |Activity Pattern|Filter|
      |Task Name|ExtractToSaitama|

      #### ExtractToSaitama の設定

      |項目|設定値|備考|
      |-|-|-|
      |condition|event.sorting_condition.center_id == 3|埼玉物流センターのIDは `3`|

1. 3つの `ExtractTo***` タスクで `タスク Events を表示` を行い、それぞれ適切なイベントのみ通過しているか確認する
   1. Google Colaboratory からダミーデータを送信する

   1. 各 Subscription でイベントを適切なイベントだけ通過しているか確認する
      - `ExtractToTokyo` の Subscription に以下のイベント **のみ** が表示されていること

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

      - `ExtractToKanagawa` の Subscription に以下のイベント **のみ** が表示されていること

        ```json
        {
            "code": "14961234567892",
            "name": "化粧水 36本",
            "sorting_condition": {
                "_id": "649d30c7c32b66791581af77",
                "center_id": 2,
                "center_name": "神奈川物流センター",
                "code": "14961234567892",
                "ars_namespace": "BoxSorter",
                "ars_version": 1,
                "ars_createdAt": "2023-06-29T07:20:39.200Z",
                "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143"
            }
        }
        ```

      - `ExtractToSaitama` の Subscription に以下のイベント **のみ** が表示されていること

        ```json
        {
            "code": "14961234567893",
            "name": "ワイン 12本",
            "sorting_condition": {
                "_id": "649d30c7c32b66791581af78",
                "center_id": 3,
                "center_name": "埼玉物流センター",
                "code": "14961234567893",
                "ars_namespace": "BoxSorter",
                "ars_version": 1,
                "ars_createdAt": "2023-06-29T07:20:39.244Z",
                "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143"
            }
        }
        ```

### 5. 【LogStream】仕分け指示をログとして表示

ここまでの実装で仕分けができるようになりましたので、その結果を **Log メッセージ** に表示します。

1. 各 `ExtractTo***` タスクの次に、それぞれ以下のタスクを追加してからアプリケーションを保存する

   1. `ExtractToTokyo` タスクの次:

      |項目|設定値|
      |-|-|
      |Activity Pattern|LogStream|
      |タスク Name|LogToTokyo|

      #### LogToTokyo の設定

      |項目|設定値|備考|
      |-|-|-|
      |level|info|-|

   1. `ExtractToKanagawa` タスクの次:

      |項目|設定値|
      |-|-|
      |Activity Pattern|LogStream|
      |タスク Name|LogToKanagawa|

      #### LogToKanagawa の設定

      |項目|設定値|備考|
      |-|-|-|
      |level|info|-|

   1. `ExtractToSaitama` タスクの次:

      |項目|設定値|
      |-|-|
      |Activity Pattern|LogStream|
      |タスク Name|LogToSaitama|

      #### LogToSaitama の設定

      |項目|設定値|備考|
      |-|-|-|
      |level|info|-|

## 6.【動作確認】送信結果が正しく仕分けされているか確認する

Google Colaboratory からダミーデータを送信しておき、正しく仕分けされるか確認します。

1. Google Colaboratory からダミーデータを送信する

1. Log メッセージ 画面を表示する
   1. 画面右下の `Debugging` をクリックする

   1. 右側の `Errors` をクリックし、 `Log メッセージ` にチェックを入れる

1. 各物流センターごとに正しく仕分け指示が表示されていることを確認する

   **例: 各物流センターごとに Log メッセージ が表示されている**

   ![Log メッセージ](./imgs/log-message.png)

## Project のエクスポート

作成したアプリケーションを Project ごとエクスポートします。  
Project のエクスポートを行うことで、他の Namespace にインポートしたり、バックアップとして管理することが出来ます。  

詳細は下記を参照してください。  
[Project の管理について - Project のエクスポート](/vantiq-introduction/apps-development/vantiq-basic/project/project.md#project-のエクスポート)

## ワークショップの振り返り

1. **Topic**
   1. **Topic** は **REST API** のエンドポイントとして利用できます。
   1. **データの受信テスト** から正しくデータを受信できていることを確認しました。
1. **Type** 
   1. **Type** を作成し、マスタデータをインポートしました。
   1. **すべてのレコードを表示** からデータが正しくインポートできているか確認しました。
   1. **Type** へのデータの書き込みは CSV ファイルなどのインポート以外に REST API を用いた追加や更新もできます。
1. **App**
   1. **App Builder** を用いて GUI ベースでアプリケーションを開発しました。
   1. **タスクイベントの表示** からイベントデータを逐次確認する方法を学習しました。
   1. **EventStream Activity** を用いて **Topic** で受信したデータを受け取りました。
   1. **Enrich Activity** を用いて **Type** のデータをイベントデータに結合しました。
   1. **Filter Activity** を用いてセンターIDごとにイベントを仕分けしました。
   1. **LogStream Activity** を用いてデータの確認方法を学習しました。

## 補足説明

Type の NaturalKey については、下記を参照してください。

- [Type の NaturalKey とは？](/vantiq-apps-development/docs/jp/reverse-lookup.md#type-の-naturalkey-とは)

## 参考情報

### プロジェクトファイル

- [ボックスソーター（入門編・REST API）の実装サンプル（Vantiq 1.34）](./../../data/box_sorter_beginner_restapi_1.34.zip)
- [ボックスソーター（入門編・REST API）の実装サンプル（Vantiq 1.36）](./../../data/box_sorter_beginner_restapi_1.36.zip)

以上
