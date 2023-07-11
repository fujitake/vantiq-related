# 荷物仕分けアプリケーション開発 (State)

## 目次

- [荷物仕分けアプリケーション開発 (State)](#荷物仕分けアプリケーション開発-state)
  - [目次](#目次)
  - [0. 事前準備](#0-事前準備)
  - [1. 自動生成されたリソースを確認する](#1-自動生成されたリソースを確認する)
  - [2. Procedure を使って State の中身を確認してみる](#2-procedure-を使って-state-の中身を確認してみる)
  - [3. Procedure を作って State に含まれる全ての要素を確認してみる](#3-procedure-を作って-state-に含まれる全ての要素を確認してみる)
  - [State の補足説明](#state-の補足説明)
  - [Next step](#next-step)

## 0. 事前準備

荷物仕分けアプリケーション (Standard) のプロジェクトを開きます。  

> **補足**  
> 荷物仕分けアプリケーション (Standard) のプロジェクトが存在しない場合などは、プロジェクトファイルをインポートしてください。

## 1. 自動生成されたリソースを確認する

まずアプリケーションを作成すると自動で「apps.services.<アプリケーション名>」の `Service` が作成されます。  
Service とは、任意の機能単位で Vantiq のリソースをカプセル化する機能です。※ここでは Service の詳細については割愛します。

> 今回の例であれば荷物仕分けアプリケーション機能単位でリソースをグルーピングするようなイメージです。

State はこの Service 単位で管理されます。

開発画面左の `Project Contents` を確認してみます。

<img src="./imgs/project-contents.png" width="300">

以下が作成されていることがわかります。

|種別|リソース名|
|-|-|
|Service|apps.services.BoxSorter|
|Procedure|apps.services.BoxSorter.AttachConditionStateGet|
|Procedure|apps.services.BoxSorter.AttachConditionStateGetForEvent|
|Procedure|apps.services.BoxSorter.AttachConditionStateReset|
|Procedure|apps.services.BoxSorter.AttachConditionStateUpdateForEvent|

`Service` と、 `Procedure` が自動生成されていることがわかります。  
Cached Enrich 関連の Procedure は `apps.services.<アプリケーション名>.<Cached Enrichを設定したTask名>State***` という名前で生成されます。

これらの Procedure は `State` を操作するための Procedure です。
|Procedure|内容|
|-|-|
|***StateGet|Stateから値を取得する|
|***StateGetForEvent|Cached Enrichの設定で指定されたキーをもとにStateから値を取得し、Eventに追加する|
|***StateReset|Stateをリセットする|
|***StateUpdateForEvent|Typeのレコードを取得しStateをその内容で更新する|

自動生成された State も確認してみます。  
State は Service の中に作成されます。

1. `apps.services.BoxSorter` -> `Implement` タブ -> `State` -> `Partitioned State Type` を開く

<img src="./imgs/state.png" width="400">

`<Cached Enrichを設定したTask名>State` である `AttachConditionState` が作成されていることが確認できます。

この State に Procedure でアクセスすることで格納されている内容を確認することができます。

## 2. Procedure を使って State の中身を確認してみる

`***StateGet` の Procedure は Cached Enrich の設定で指定したキーを引数にして、それに該当する値を返します。

`sorting_condition` Type には以下のレコードが保存されていました。
|center_id|center_name|code|
|-|-|-|
|1|東京物流センター|14961234567890|
|2|神奈川物流センター|14961234567892|
|3|埼玉物流センター|14961234567893|

そして `code` をキーとしてイベントに対してレコードを追加していました。

つまり `apps.services.BoxSorter.AttachConditionStateGet` を実行し、引数に `code` の値を設定するとそれに該当する State の要素を取得できます。

1. `apps.services.BoxSorter.AttachConditionStateGet` を開き、以下の内容で実行する

   |パラメータ名|center_name|
   |-|-|
   |partitionKey|14961234567890|

1. 以下のような結果が返ることを確認する

   ```json
   {
       "expiresAt": "2022-11-10T05:31:32.701Z",
       "value": {
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
   ```

   > Cached Enrich が `code` の値が `14961234567890` であるイベントを処理する際に追加する内容が State に格納されていることがわかります。

## 3. Procedure を作って State に含まれる全ての要素を確認してみる

次に、キー単位ではなく State に含まれる全ての要素を確認してみます。  
これには Procedure を実装する必要があります。

1. `apps.services.BoxSorter` -> `Implement` タブを開き `Procedures` の `+` をクリックし、 `New Procedure` をクリックする

   <img src="./imgs/service-proc.png" width="300">

1. 新規の Procedure が表示されるので以下の内容をペーストし保存する

   ```js
   package apps.services
   multi partition PROCEDURE BoxSorter.getEntries()
   AttachConditionState.entrySet()
   ```

   このProcedure は `AttachConditionState` State に含まれる全ての要素を取得します。  
   
   VANTIQ 上を流れるイベントストリームは、複数のノードに分散されて処理されます。  
   この際、イベントストリームがどのノードで処理されるかは決まっておらず、負荷に応じて分散されています。  
   今回、 Cached Enrich の前に `SplitByGroup` を使ったことで、不規則に分散していたイベントストリームが `SplitByGroup` の `groupBy` で指定した値ごとに同じノードで処理が行われるようになりました。  

   Procedure を宣言する際に `multi partition` という修飾子をつけることで、分散した全ノードから要素を取得することができます。  
   
   > 保存するとインターフェースの修復をするかの確認ダイアログが表示されますので、 `インターフェースの修復` をクリックするようにしてください。  

   > `Service Builder` の詳細については割愛します。  

1. 実行し、結果を確認する

   <img src="./imgs/exec-service-proc.png" width="600">

   ```json
   [
       [
           {
               "14961234567892": {
                   "expiresAt": "2022-11-17T01:33:08.201Z",
                   "value": {
                   "_id": "636210de304f430ecd9a61c6",
                   "center_id": 2,
                   "center_name": "神奈川物流センター",
                   "code": "14961234567892",
                   "ars_namespace": "workshop_134",
                   "ars_version": 2,
                   "ars_createdAt": "2022-11-02T06:40:30.984Z",
                   "ars_createdBy": "yshimizu",
                   "ars_modifiedAt": "2022-11-08T06:00:11.637Z",
                   "ars_modifiedBy": "yshimizu"
                   }
               }
           },
           {
               "14961234567893": {
                   "expiresAt": "2022-11-17T01:33:13.198Z",
                   "value": {
                   "_id": "636210de304f430ecd9a61c7",
                   "center_id": 3,
                   "center_name": "埼玉物流センター",
                   "code": "14961234567893",
                   "ars_namespace": "workshop_134",
                   "ars_version": 2,
                   "ars_createdAt": "2022-11-02T06:40:30.989Z",
                   "ars_createdBy": "yshimizu",
                   "ars_modifiedAt": "2022-11-08T06:00:11.644Z",
                   "ars_modifiedBy": "yshimizu"
                   }
               }
           },
           {
               "14961234567890": {
                   "expiresAt": "2022-11-10T05:31:32.701Z",
                   "value": {
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
       ]
   ]
   ```

code が `14961234567890` 、`14961234567892` 、`14961234567893` の要素が State に格納されていることがわかります。

## State の補足説明

State はここで述べた以外にも様々な特徴や使い方があります。  
詳しくは下記のドキュメント等を御覧ください。  

- State とは？
  - [Vantiq Serviceとは - State](./../docs/jp/vantiq-service.md#state)
  - [Stateful Serviceとは](./../docs/jp/vantiq-service.md#stateful-serviceとは)
- State の種類と Procedure
  - [Stateful Serviceとは - Global State](./../docs/jp/vantiq-service.md#global-state)
  - [Stateful Serviceとは - Partioned State + Partitioned Procedure](./../docs/jp/vantiq-service.md#partioned-state--partitioned-procedure)
  - [Stateful Serviceとは - Partioned State + Multi-Partitioned Procedure](./../docs/jp/vantiq-service.md#partioned-state--multi-partitioned-procedure)
- State を利用するアクティビティ
  - [Stateful Serviceとは - Stateful なアクティビティパターン](./../docs/jp/vantiq-service.md#stateful-なアクティビティパターン)
- State の冗長化
  - [Stateful Serviceとは - Replication Factor](./../docs/jp/vantiq-service.md#replication-factor)
- State を使う上で欠かせない Service とは？
  - [Vantiq Serviceとは](./../docs/jp/vantiq-service.md#vantiq-serviceとは)

## Next step

開発者の方は、より深く理解をするため [Vantiq アプリケーション開発者コース＆レベル1認定試験](https://community.vantiq.com/courses/%e3%82%a2%e3%83%97%e3%83%aa%e3%82%b1%e3%83%bc%e3%82%b7%e3%83%a7%e3%83%b3%e9%96%8b%e7%99%ba%e8%80%85-level-1-%e3%82%b3%e3%83%bc%e3%82%b9-%e6%97%a5%e6%9c%ac%e8%aa%9e/) （要ログイン）の受講をお勧めします。

以上
