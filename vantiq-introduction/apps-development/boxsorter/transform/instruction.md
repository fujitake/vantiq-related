# ボックスソーター（Transformation）

## アプリケーションが想定している受信内容

```json
{
    "code": "14961234567890",
    "name": "お茶 24本"
}
```

## 目次

- [ボックスソーター（Transformation）](#ボックスソーターtransformation)
  - [アプリケーションが想定している受信内容](#アプリケーションが想定している受信内容)
  - [目次](#目次)
  - [1. Namespace の作成と Project のインポート](#1-namespace-の作成と-project-のインポート)
    - [1-1. Namespace の作成](#1-1-namespace-の作成)
    - [1-2. Project のインポート](#1-2-project-のインポート)
  - [2. データジェネレータの準備](#2-データジェネレータの準備)
    - [2-1. Vantiq Access Token の発行](#2-1-vantiq-access-token-の発行)
    - [2-2. Google Colaboratory の設定](#2-2-google-colaboratory-の設定)
  - [3. 既存のアプリケーションの動作確認](#3-既存のアプリケーションの動作確認)
    - [3-1. EventHandler の表示](#3-1-eventhandler-の表示)
    - [3-2. データの受信テスト](#3-2-データの受信テスト)
  - [4. Service Builder を用いたボックスソーターアプリの改修](#4-service-builder-を用いたボックスソーターアプリの改修)
    - [4-1. 【Transformation】イベントデータの整形](#4-1-transformationイベントデータの整形)
    - [4-3. 【Filter】仕分け条件の修正](#4-3-filter仕分け条件の修正)
  - [5. 仕分け結果の確認](#5-仕分け結果の確認)
    - [5-1. Log メッセージ画面の表示](#5-1-log-メッセージ画面の表示)
    - [5-2. Log の確認](#5-2-log-の確認)
  - [Project のエクスポート](#project-のエクスポート)
  - [ワークショップの振り返り](#ワークショップの振り返り)
  - [参考情報](#参考情報)
    - [プロジェクトファイル](#プロジェクトファイル)

## 1. Namespace の作成と Project のインポート

### 1-1. Namespace の作成

アプリケーションを実装する前に新しく Namespace を作成し、作成した Namespace に切り替えます。  

詳細は下記をご確認ください。  
[Vantiq の Namespace と Project について](/vantiq-introduction/apps-development/vantiq-basic/namespace/readme.md)

### 1-2. Project のインポート

Namespace の切り替えが出来たら、 Project のインポートを行います。  
**ボックスソーター（REST API）** の Project をインポートしてください。  

詳細は下記を参照してください。  
[Project の管理について - Project のインポート](/vantiq-introduction/apps-development/vantiq-basic/project/readme.md#project-のインポート)

## 2. データジェネレータの準備

Google Colaboratory を使用して、ダミーデータの生成します。  
Google Colaboratory を利用するにあたり、事前に **Vantiq Access Token** を発行する必要があります。  

**Vantiq Access Token** は Namespace ごとに発行する必要があります。

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

   ![colab-badge.svg](./imgs/colab-badge.svg)

1. `# 設定情報` に以下を参考にして、必要な内容を入力します。

   |項目|設定値|備考|
   |-|-|-|
   |url|https://dev.vantiq.com/api/v1/resources/services/com.example.BoxSorter/ReceiveBoxInfo|SSL化されていないサーバーの場合は、 `https://` を `http://` に置き換えてください。|
   |accesstoken|7tFxPj4JuNFnuwmGcEadU_6apA1r3Iji2N7AZS5HuVU=|上記で発行した Access Token|

   ![google_colab_setting](./imgs/google_colab_setting.png)

1. 上から順に1つずつ `再生ボタン` を押していきます。  
   実行が終わるのを待ってから、次の `再生ボタン` を押してください。  

   ![google_colab_run](./imgs/google_colab_run.png)

## 3. 既存のアプリケーションの動作確認

**Service** の **EventHandler** からデータが正しく受信できているか確認します。  

### 3-1. EventHandler の表示

1. 画面左側の **Project Contents** から `ReceiveBoxInfo` Event Handler を開きます。

   ![project_contents_service.png](./imgs/project_contents_service.png)

### 3-2. データの受信テスト

1. `Event Stream` タスクをクリックします。  
   画面右下の `タスク Events を表示` をクリックします。

   ![receive_test_data_01.png](./imgs/receive_test_data_01.png)

1. 表示された青字の JSON Object をクリックします。  

   ![receive_test_data_02.png](./imgs/receive_test_data_02.png)

1. 想定通りのデータが受信できているか確認します。  

   ![receive_test_data_03.png](./imgs/receive_test_data_03.png)

## 4. Service Builder を用いたボックスソーターアプリの改修

この手順からアプリケーションの改修を開始します。  

### 4-1. 【Transformation】イベントデータの整形

**Transformation Activity** を追加して、イベントデータを整形をします。  

#### Transformation Activity の実装

1. **Modifiers** の中から `Transformation` を選択し、 `AttachCondition` タスクと `Filter Activity` の間の **矢印** の上にドロップします。

1. 不要な **矢印** を選択し、 `Delete` キーを押下します。

1. 上記の作業を繰り返し、すべての **Filter Activity** を配置し直します。

   ![boxsorter_transform.gif](./imgs/boxsorter_transform.gif)

1. `Transformation` タスクをクリックし、 `Configuration` の `クリックして編集` を開きます。  
   `transformation (Union)` の `<null>` をクリックして、以下の内容を入力し、 `OK` をクリックします。

   |Outbound Property|Transformation Expression|
   |-|-|
   |code|event.code|
   |name|event.name|
   |center_id|event.sorting_condition.center_id|
   |center_name|event.sorting_condition.center_name|

   ![transformation_setting.png](./imgs/transformation_setting.png)

### 4-3. 【Filter】仕分け条件の修正

**Transformation Activity** を利用して、イベントの整形をしたため、後続タスクの **Filter Activity** の条件式を修正する必要があります。

#### Filter Activity の修正

1. 各 **Filter Activity** を選択し、 `Configuration` の `クリックして編集` を開きます。  
   `condition (Union)` の `条件式` をクリックして、以下の内容を入力し、 `OK` をクリックします。

   |物流センター|設定項目|設定値|
   |-|-|-|
   |東京物流センター|condition|event.center_id == 1|
   |神奈川物流センター|condition|event.center_id == 2|
   |埼玉物流センター|condition|event.center_id == 3|

## 5. 仕分け結果の確認

Log 画面から `LogStream` のログデータを確認します。  

### 5-1. Log メッセージ画面の表示

1. 画面右下の `Debugging` をクリックします。

1. 右側の `Errors` をクリックし、 `Log メッセージ` にチェックを入れます。

### 5-2. Log の確認

1. 各物流センターごとに正しく仕分け指示が表示されていることを確認します。

   **例: 各物流センターごとに Log メッセージ が表示されている**

   ![Log メッセージ](./imgs/log-message.png)

## Project のエクスポート

作成したアプリケーションを Project ごとエクスポートします。  

詳細は下記を参照してください。  
[Project の管理について - Project のエクスポート](/vantiq-introduction/apps-development/vantiq-basic/project/readme.md#project-のエクスポート)

## ワークショップの振り返り

1. **Project**
   1. Namespace に Project をインポートする方法を学習しました。
1. **Vantiq Access Token** 
   1. Namespace ごとに Vantiq Access Token が必要なことを学習しました。
1. **Service**
   1. Service の修正方法を学習しました。
   1. **Transformation Activity** を用いて、データの整形方法を学習しました。

## 参考情報

### プロジェクトファイル

- [ボックスソーター（Transformation）の実装サンプル（Vantiq 1.40）](./../data/box_sorter_transform_1.40.zip)
- [ボックスソーター（Transformation）の実装サンプル（Vantiq 1.39）](./../data/box_sorter_transform_1.39.zip)

以上
