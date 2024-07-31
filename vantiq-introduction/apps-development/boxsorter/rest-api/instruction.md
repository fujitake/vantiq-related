# ボックスソーター（REST API）

## 実装の流れ

下記の流れで実装していきます。

1. 【準備】Namespace の作成と Project の保存、データジェネレータの準備
1. 【Topic】REST API 用のエンドポイントの作成
1. 【Type】マスタデータの取り込み
1. 【App Builder】ボックスソーターアプリの開発
1. 【動作確認】仕分け結果の確認

> リソース名やタスク名は任意のものに変更しても構いません。

## 目次

- [ボックスソーター（REST API）](#ボックスソーターrest-api)
  - [実装の流れ](#実装の流れ)
  - [目次](#目次)
  - [アプリケーションが前提とする受信内容](#アプリケーションが前提とする受信内容)
  - [1. Namespace の作成と Project の保存](#1-namespace-の作成と-project-の保存)
  - [2. データジェネレータの準備](#2-データジェネレータの準備)
    - [2-1. Vantiq Access Token の発行](#2-1-vantiq-access-token-の発行)
    - [2-2. Google Colaboratory の設定](#2-2-google-colaboratory-の設定)
  - [3. Topic を用いた REST API エンドポイントの作成](#3-topic-を用いた-rest-api-エンドポイントの作成)
    - [3-1. Topic の作成](#3-1-topic-の作成)
    - [3-2. データの受信テスト](#3-2-データの受信テスト)
  - [4. Type を用いたマスタデータの作成](#4-type-を用いたマスタデータの作成)
    - [4-1. Type の作成](#4-1-type-の作成)
    - [4-2. マスタデータのインポート](#4-2-マスタデータのインポート)
  - [5. App Builder を用いた App の開発](#5-app-builder-を用いた-app-の開発)
    - [5-1. 【App Builder】アプリケーションの作成](#5-1-app-builderアプリケーションの作成)
    - [5-2. 【EventStream】Topic データの取得](#5-2-eventstreamtopic-データの取得)
    - [5-3. 【Enrich】仕分け条件の追加](#5-3-enrich仕分け条件の追加)
    - [5-4. 【Filter】仕分け処理の実装](#5-4-filter仕分け処理の実装)
    - [5-5. 【LogStream】仕分け指示のログ出力の実装](#5-5-logstream仕分け指示のログ出力の実装)
  - [6. 仕分け結果の確認](#6-仕分け結果の確認)
    - [6-1. Log メッセージ画面の表示](#6-1-log-メッセージ画面の表示)
    - [6-2. Log の確認](#6-2-log-の確認)
  - [Project のエクスポート](#project-のエクスポート)
  - [ワークショップの振り返り](#ワークショップの振り返り)
  - [参考情報](#参考情報)
    - [プロジェクトファイル](#プロジェクトファイル)

## アプリケーションが前提とする受信内容

```json
{
    "code": "14961234567890",
    "name": "お茶 24本"
}
```

## 1. Namespace の作成と Project の保存

アプリケーションを実装する前に新しく Namespace を作成し、作成した Namespace に切り替えます。  
あわせてプロジェクトの保存も行っておきます。  

詳細は下記をご確認ください。  
[Vantiq の Namespace と Project について](/vantiq-introduction/apps-development/vantiq-basic/namespace/readme.md)

## 2. データジェネレータの準備

Google Colaboratory を使用して、ダミーデータの生成します。  
Google Colaboratory を利用するにあたり、事前に **Vantiq Access Token** を発行する必要があります。  

### 2-1. Vantiq Access Token の発行

1. メニューバーの `管理` -> `Advanced` -> `Access Tokens` -> `+ 新規` をクリックし Token の新規作成画面を開きます。

   ![accesstoken_01](./imgs/accesstoken_01.png)

1. 以下の内容を設定し、保存します。

   |項目|設定値|備考|
   |-|-|-|
   |Name|BoxDataToken|左記以外の名前でも問題ありません。|

   ![accesstoken_02](./imgs/accesstoken_02.png)

1. 発行された `Access Token` をクリックして、クリップボードにコピーしておきます。

   ![accesstoken_03](./imgs/accesstoken_03.png)

### 2-2. Google Colaboratory の設定

1. 下記のリンクから **データジェネレータ** のページを開きます。

   - [BoxSorterDataGenerator（REST API）](/vantiq-google-colab/code/box-sorter_data-generator_rest-api.ipynb)

      > Google Colaboratory を利用する際は Google アカウントへのログインが必要になります。

1. Github のページ内に表示されている、下記の `Open in Colab` ボタンをクリックして、 Google Colaboratory を開きます。

   ![OpenGoogleColab](./imgs/open_in_colab_button.png)

1. `# 設定情報` に以下の内容を入力します。

   |項目|設定値|備考|
   |-|-|-|
   |url|https://【VantiqのURL(FQDN)】/api/v1/resources/topics//BoxInfoApi|SSL化されていないサーバーの場合は、 `https://` を `http://` に置き換えてください。|
   |accesstoken|7tFxPj4JuNFnuwmGcEadU_6apA1r3Iji2N7AZS5HuVU=|上記で発行した Access Token|

   ![google_colab_setting](./imgs/google_colab_setting.png)

1. 上から順に1つずつ `再生ボタン` を押していきます。  
   実行が終わるのを待ってから、次の `再生ボタン` を押してください。  

   ![google_colab_run](./imgs/google_colab_run.png)

## 3. Topic を用いた REST API エンドポイントの作成

サーバーからデータを受信したい場合、エンドポイントが必要です。  
これは Vantiq でも同じです。  
Vantiq の Topic がエンドポイントになります。  

### 3-1. Topic の作成

1. メニューバーの `追加` -> `Advanced` -> `Topic...` -> `+ 新規 Topic` をクリックし Topic の新規作成画面を開きます。
   
   ![create_topic_01.png](./imgs/create_topic_01.png)

1. 以下の内容を設定し、保存します。

   |項目|設定値|設定箇所|
   |-|-|-|
   |Name|/BoxInfoApi|-|

   ![create_topic_02.png](./imgs/create_topic_02.png)

   > 上記以外にも設定できる項目はありますが本ワークショップでは使用しません。

### 3-2. データの受信テスト

1. `/BoxInfoApi` Topicのペインを開き `データの受信テスト` をクリックします。

   ![create_topic_03.png](./imgs/create_topic_03.png)

   > `Subscription: /BoxInfoApi` というペインが新たに開かれます。データを受信するとここに取得した内容が表示されます。
1. `Subscription: /BoxInfoApi` に Google Colaboratory から受信した内容が表示されることを確認します。

   ![receive-test-data.png](./imgs/receive-test-data.png)

## 4. Type を用いたマスタデータの作成

このアプリケーションが受け取るデータの内容は、以下のように `code` と `name` だけが含まれています。

```json
{
    "code": "14961234567890",
    "name": "お茶 24本"
}
```

仕分けをしていくにあたり、その判断材料となる情報を追加する必要があります。  
Vantiq では **Enrich Activity** という Activity Pattern が用意されており、イベントに対して Type に保存されたレコードの内容を追加することができます。  

あらかじめ仕分けの判断材料となる情報を保持した Type が必要となります。  
Type を作成した後に CSV ファイルをインポートします。  

> **補足説明**  
> マスタデータなどを Type へインポートする方法は CSV ファイル以外にも、 REST API を用いて Type を更新するといった方法があります。  

### 4-1. Type の作成

1. メニューバーの `追加` -> `Type...` -> `+ 新規 Type` をクリックして Type の新規作成画面を開きます。

   ![create_type_01.png](./imgs/create_type_01.png)

1. 以下の内容を入力して `OK` をクリックします。

   |項目|設定値|
   |-|-|
   |Name|sorting_condition|
   |Role|standard|

   ![create_type_02.png](./imgs/create_type_02.png)

1. `sorting_condition` のペインが表示されるので、以下の設定を行い、保存します。

   **Properties タブ**
   |プロパティ名|データ型|Required|
   |-|-|-|
   |code|String|✅|
   |center_id|Integer|✅|
   |center_name|String|✅|

   ![create_type_03.png](./imgs/create_type_03.png)

   ![create_type_04.png](./imgs/create_type_04.png)

   ![create_type_05.png](./imgs/create_type_05.png)

### 4-2. マスタデータのインポート

1. メニューバーの `Projects` -> `インポート...` を開き、 `Select Import Type:` を `Data` に設定します。

   ![csv_import_01.png](./imgs/csv_import_01.png)

1. `インポートする CSV ファイルまたは JSON ファイルをここにドロップ` の箇所に [sorting_condition.csv](./../data/sorting_condition.csv) をドロップし `インポート` をクリックします。

   ![csv_import_02.png](./imgs/csv_import_02.png)

   > **注意**  
   > Type にレコードをインポートする際は `Data` を選択する必要があります。  
   > デフォルトは `Projects` になっているので注意してください。  

   > **注意**  
   > インポートする CSV ファイルのファイル名と作成した Type のリソース名が完全に一致している必要があります。  
   > ファイル名が異なる場合は、 CSV ファイルを Type のリソース名にあわせてリネームしてください。  

1. `sorting_condition` Type のペインを開き、上部にある `すべてのレコードを表示` をクリックしてインポートが成功しているか確認します。

   ![csv_import_03.png](./imgs/csv_import_03.png)

   ![csv_import_04.png](./imgs/csv_import_04.png)

## 5. App Builder を用いた App の開発

この手順からアプリケーション開発を開始します。  
Topic で取得したデータをイベントとして、処理を実装していきます。

### 5-1. 【App Builder】アプリケーションの作成

App Builder を用いて、 App を新規作成します。

#### App の新規作成

1. メニューバーの `追加` -> `Advanced` -> `App...` -> `+ 新規 App` をクリックしアプリケーションの新規作成画面を開きます。
   
   ![create_app_01.png](./imgs/create_app_01.png)

1. `Name` に `BoxSorter` と入力し `OK` をクリックします。

   ![create_app_02.png](./imgs/create_app_02.png)

### 5-2. 【EventStream】Topic データの取得

**EventStream Activity** を使って Topic からデータを受け取ります。  
受け取ったデータはイベントとして、アプリケーションで利用可能な状態になります。

> `BoxSorter` のペインが開かれますので、ここから開発作業を進めていきます。  
> デフォルトで `Initiate` タスクが作成されます。

#### EventStream の設定

1. `Initiate` タスクをクリックし、 `Name` に `ReceiveBoxInfo` と入力します。

   ![create_app_03.png](./imgs/create_app_03.png)

   > アプリケーションのルートとなるタスクに設定される Activity Pattern は常に **EventStream Activity** になります。

1. `Configuration` の `クリックして編集` から以下の内容を入力し、 `OK` をクリックします。

   |項目|設定値|
   |-|-|
   |inboundResource|topics|
   |inboundResourceId|/BoxInfoApi|

   ![create_app_04.png](./imgs/create_app_04.png)

   ![create_app_05.png](./imgs/create_app_05.png)

1. App Builder のペインの上部にあるフロッピーディスクのアイコンをクリックし、アプリケーションを保存します。

   ![create_app_06.png](./imgs/create_app_06.png)

1. `ReceiveBoxInfo` タスクをクリックし、 `タスク Events を表示` をクリックします。

   ![create_app_07.png](./imgs/create_app_07.png)

   > `Subscription:BoxSorter_ReceiveBoxInfo` が開かれます。ここには ReceiveBoxInfo タスクの処理結果が表示されます。

1. データジェネレーターからダミーデータを送信し、受信した内容を確認します。  
   送信された内容が `Subscription:BoxSorter_ReceiveBoxInfo` に表示されることを確認します。

   ![create_app_08.png](./imgs/create_app_08.png)

   > ここまでの手順で、アプリケーションが Topic で受信した内容を扱える状態まで実装できました。

### 5-3. 【Enrich】仕分け条件の追加

**Enrich Activity** を使用して、 Type のデータをイベントに追加します。

#### Enrich Activity の実装

1. App ペイン左側の `Modifiers` の中から `Enrich` を選択し、 `ReceiveBoxInfo` タスクの上にドロップします。

   ![app_enrich_01.gif](./imgs/app_enrich_01.gif)

1. `Enrich` タスクをクリックし、タスク名を設定します。

   |項目|設定値|
   |-|-|
   |Name|AttachCondition|

1. `Configuration` の `クリックして編集` を開き、以下の設定を行いアプリケーションを保存します。

   <details>
   <summary>Vantiq Version 1.35 以前の場合</summary>

   |項目|設定値|備考|
   |-|-|-|
   |associatedType|sorting_condition|-|

   `foreignKeys` の `<null>` をクリックし、下記の設定を行います。

   1. `+ アイテムの追加` をクリックします。

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

   ![app_enrich_02.png](./imgs/app_enrich_02.png)

   1. `+ 外部キーのプロパティを追加する` をクリックします。

      |項目|設定値|備考|
      |-|-|-|
      |Associated Type Property|code|Type 側のプロパティ|
      |Foreign Key Expression|event.code|イベント側のプロパティ|

      ![app_enrich_03.png](./imgs/app_enrich_03.png)
   </details>

   > VAIL で書くとすると `SELECT ONE FROM sorting_condition WHERE code == code` ということになります。

1. `AttachCondition` タスクをクリックし、 `タスク Events を表示` から、 Enrich の動作確認を行います。  
   下記のようなイベントになっていることを確認します。

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

### 5-4. 【Filter】仕分け処理の実装

特定の物流センターのイベントのみが通過できるフローを実装することで、仕分けを行います。  
今回は「東京」「神奈川」「埼玉」の3つの物流センター単位で仕分けをしますので、 **Filter Activity** を設定したタスクを3つ実装します。

物流センターとその ID は以下の関係になっています。
|物流センター|物流センターID|
|-|-|
|東京|1|
|神奈川|2|
|埼玉|3|

この物流センターID `center_id` で仕分けをします。

#### Filter Activity の実装

1. App ペイン左側の `Filters` の中から `Filter` を選択し、 `AttachCondition` タスクの上にドロップします。  
   この作業を3回繰り返し、3つの **Filter Activity** を配置します。

   ![app_filter_01.gif](./imgs/app_filter_01.gif)

1. 各 **Filter Activity** の `タスク名` の設定と `Configuration` の `クリックして編集` から `condition (Union)` に条件式の設定を行い、アプリケーションを保存します。  

   1. 東京物流センター

      |項目|設定値|
      |-|-|
      |Name|ExtractToTokyo|
      |condition (Union)|event.sorting_condition.center_id == 1|

   1. 神奈川物流センター

      |項目|設定値|
      |-|-|
      |Name|ExtractToKanagawa|
      |condition (Union)|event.sorting_condition.center_id == 2|

   1. 埼玉物流センター

      |項目|設定値|
      |-|-|
      |Name|ExtractToSaitama|
      |condition (Union)|event.sorting_condition.center_id == 3|

1. 各 **Filter Activity** で `タスク Events を表示` を行い、それぞれ適切なイベントのみが通過しているか確認します。

   - 東京物流センター： `ExtractToTokyo`

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

   - 神奈川物流センター： `ExtractToKanagawa`

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

   - 埼玉物流センター： `ExtractToSaitama`

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

### 5-5. 【LogStream】仕分け指示のログ出力の実装

ここまでの実装で仕分けができるようになりましたので、その結果を **Log メッセージ** に表示します。

#### LogStream Activity の実装

1. App ペイン左側の `Actions` の中から `LogStream` を選択し、各 **Filter Activity** の上にドロップします。  
   この作業を3回繰り返し、3つの **LogStream Activity** を配置します。

   ![app_logstream_01.gif](./imgs/app_logstream_01.gif)

1. 各 **LogStream Activity** の `タスク名` の設定と `Configuration` の `クリックして編集` から `level` の設定を行い、アプリケーションを保存します。  

   1. 東京物流センター

      |項目|設定値|
      |-|-|
      |Name|LogToTokyo|
      |level (Enumerated)|info|

   1. 神奈川物流センター

      |項目|設定値|
      |-|-|
      |Name|LogToKanagawa|
      |level (Enumerated)|info|

   1. 埼玉物流センター

      |項目|設定値|
      |-|-|
      |Name|LogToSaitama|
      |level (Enumerated)|info|

## 6. 仕分け結果の確認

データジェネレータからダミーデータを送信しておき、正しく仕分けされるか確認します。

### 6-1. Log メッセージ画面の表示

1. 画面右下の `Debugging` をクリックします。

1. 右側の `Errors` をクリックし、 `Log メッセージ` にチェックを入れます。

### 6-2. Log の確認

1. 各物流センターごとに正しく仕分け指示が表示されていることを確認します。

   **例: 各物流センターごとに Log メッセージ が表示されている**

   ![Log メッセージ](./imgs/log-message.png)

## Project のエクスポート

作成したアプリケーションを Project ごとエクスポートします。  
Project のエクスポートを行うことで、他の Namespace にインポートしたり、バックアップとして管理することが出来ます。  

詳細は下記を参照してください。  
[Project の管理について - Project のエクスポート](/vantiq-introduction/apps-development/vantiq-basic/project/readme.md#project-のエクスポート)

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

## 参考情報

### プロジェクトファイル

- [ボックスソーター（REST API）の実装サンプル（Vantiq r1.40）](./../data/box_sorter_restapi_1.40.zip)
- [ボックスソーター（REST API）の実装サンプル（Vantiq r1.37）](./../data/box_sorter_restapi_1.37.zip)
- [ボックスソーター（REST API）の実装サンプル（Vantiq r1.34）](./../data/box_sorter_restapi_1.34.zip)

> **注意**  
> Vantiq r1.40 以前のプロジェクトファイルは Service 非対応の古いサンプルになります。  
> ドキュメント記載の手順と異なりますので注意してください。  

以上
