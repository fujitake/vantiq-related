# ボックスソーター（Vantiq REST API・Type）

## 目次

- [ボックスソーター（Vantiq REST API・Type）](#ボックスソーターvantiq-rest-apitype)
  - [目次](#目次)
  - [1. Namespace の作成と Project のインポート](#1-namespace-の作成と-project-のインポート)
    - [1-1. Namespace の作成](#1-1-namespace-の作成)
    - [1-2. Project のインポート](#1-2-project-のインポート)
  - [2. Vantiq Access Token の発行](#2-vantiq-access-token-の発行)
    - [2-1. Vantiq Access Token の発行](#2-1-vantiq-access-token-の発行)
  - [3. Type のデータの取得](#3-type-のデータの取得)
    - [3-1. データの取得](#3-1-データの取得)
  - [4. Type のデータの追加](#4-type-のデータの追加)
    - [4-1. データの追加](#4-1-データの追加)
  - [5. Type のデータの更新](#5-type-のデータの更新)
    - [5-1. データの更新](#5-1-データの更新)
  - [6. Type のデータの削除](#6-type-のデータの削除)
    - [6-1. データの削除](#6-1-データの削除)
  - [ワークショップの振り返り](#ワークショップの振り返り)

## 1. Namespace の作成と Project のインポート

### 1-1. Namespace の作成

アプリケーションを実装する前に新しく Namespace を作成し、作成した Namespace に切り替えます。  

詳細は下記をご確認ください。  
[Vantiq の Namespace と Project について](/vantiq-introduction/apps-development/vantiq-basic/namespace/readme.md)

### 1-2. Project のインポート

Namespace の切り替えが出来たら、 Project のインポートを行います。  
**ボックスソーター（初級編・REST API）** の Project をインポートしてください。  

詳細は下記を参照してください。  
[Project の管理について - Project のインポート](/vantiq-introduction/apps-development/vantiq-basic/project/readme.md#project-のインポート)

## 2. Vantiq Access Token の発行

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

## 3. Type のデータの取得

**Type** のデータを取得してみます。  
データの取得を行う場合は **GET メソッド** を利用します。  

### 3-1. データの取得

1. REST API クライアントから GET リクエストを実行します。

   - cURL の場合

     ```shell
     curl \
         -X GET \
         -H 'Authorization: Bearer 【VantiqAccessToken】' \
         'https://【VantiqのURL(FQDN)】/api/v1/resources/custom/【Type名】'
     ```

     コマンド例

     ```shell
     curl \
         -X GET \
         -H 'Authorization: Bearer xaGS9Vk0te88026fk2WLqG9rU2HFUYZ6icjqmeLcKsc=' \
         'https://internal.vantiq.com/api/v1/resources/custom/sorting_condition'
     ```

1. 取得したデータが下記の様になっているか確認します。  

   ```json
   [
       {
           "_id": "658aad47f416c472004d9382",
           "center_id": 3,
           "center_name": "埼玉物流センター",
           "code": "14961234567893",
           "ars_namespace": "IG_ImportTest_01",
           "ars_version": 1,
           "ars_createdAt": "2023-12-26T10:39:03.753Z",
           "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143"
       },
       {
           "_id": "658aad47f416c472004d9383",
           "center_id": 2,
           "center_name": "神奈川物流センター",
           "code": "14961234567892",
           "ars_namespace": "IG_ImportTest_01",
           "ars_version": 1,
           "ars_createdAt": "2023-12-26T10:39:03.752Z",
           "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143"
       },
       {
           "_id": "658aad47f416c472004d9384",
           "center_id": 1,
           "center_name": "東京物流センター",
           "code": "14961234567890",
           "ars_namespace": "IG_ImportTest_01",
           "ars_version": 1,
           "ars_createdAt": "2023-12-26T10:39:03.752Z",
           "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143"
       }
   ]
   ```

   > ※見やすくするためにドキュメントフォーマットをしています。

## 4. Type のデータの追加

**Type** にデータを追加してみます。  
データの追加を行う場合は **POST メソッド** を利用します。  

### 4-1. データの追加

1. REST API クライアントから POST リクエストを実行します。

   - cURL の場合

     ```shell
     curl \
         -X POST \
         -H 'Content-Type: application/json' \
         -H 'Authorization: Bearer 【VantiqAccessToken】' \
         -d '{【追加したいデータ(JSON)】}' \
         'https://【VantiqのURL(FQDN)】/api/v1/resources/custom/【Type名】'
     ```

     コマンド例

     ```shell
     curl \
         -X POST \
         -H 'Content-Type: application/json' \
         -H 'Authorization: Bearer xaGS9Vk0te88026fk2WLqG9rU2HFUYZ6icjqmeLcKsc=' \
         -d '{"code":"10061234567890", "center_id":"1", "center_name":"東京物流センター"}' \
         'https://internal.vantiq.com/api/v1/resources/custom/sorting_condition'
     ```

1. レスポンスを確認してみます。  

   ```json
   {
       "code": "10061234567890",
       "center_id": 1,
       "center_name": "東京物流センター",
       "ars_namespace": "IG_ImportTest_01",
       "ars_version": 1,
       "ars_createdAt": "2024-01-10T02:31:53.603Z",
       "ars_createdBy": "api2__ig_importtest_01",
       "_id": "659e0199a0c4423f0c59db15"
   }
   ```

   > ※見やすくするためにドキュメントフォーマットをしています。

1. sorting_condition Type の `すべてのレコードを表示` をクリックし、レコードが追加されていることを確認します。

   ![type_01.png](./imgs/type_01.png)

## 5. Type のデータの更新

**Type** のデータを更新してみます。  
データの更新を行う場合は **PUT メソッド** を利用します。  

### 5-1. データの更新

1. REST API クライアントから PUT リクエストを実行します。

   - cURL の場合

     ```shell
     curl \
         -X PUT \
         -g \
         -H 'Content-Type: application/json' \
         -H 'Authorization: Bearer 【VantiqAccessToken】' \
         -d '{【更新したいデータ(JSON)】}' \
         'https://【VantiqのURL(FQDN)】/api/v1/resources/custom/【Type名】?where={【条件式】}'
     ```

     コマンド例

     ```shell
     curl \
         -X PUT \
         -g \
         -H 'Content-Type: application/json' \
         -H 'Authorization: Bearer xaGS9Vk0te88026fk2WLqG9rU2HFUYZ6icjqmeLcKsc=' \
         -d '{"center_id":"2", "center_name":"神奈川物流センター"}' \
         'https://internal.vantiq.com/api/v1/resources/custom/sorting_condition?where={"code":"10061234567890"}'
     ```

1. レスポンスを確認してみます。  

   ```json
   {
       "center_id": 2,
       "center_name": "神奈川物流センター",
       "ars_modifiedAt": "2024-01-12T07:11:21.495Z",
       "ars_modifiedBy": "api2__ig_importtest_01"
   }
   ```

   > ※見やすくするためにドキュメントフォーマットをしています。

1. sorting_condition Type の `すべてのレコードを表示` をクリックし、レコードが更新されていることを確認します。

   ![type_02.png](./imgs/type_02.png)

## 6. Type のデータの削除

**Type** のデータを削除してみます。  
データの削除を行う場合は **DELETE メソッド** を利用します。  

### 6-1. データの削除

1. REST API クライアントから DELETE リクエストを実行します。

   - cURL の場合

     ```shell
     curl \
         -X DELETE \
         -g \
         -H 'Content-Type: application/json' \
         -H 'Authorization: Bearer 【VantiqAccessToken】' \
         'https://【VantiqのURL(FQDN)】/api/v1/resources/custom/【Type名】?where={【条件式】}'
     ```

     コマンド例

     ```shell
     curl \
         -X DELETE \
         -g \
         -H 'Content-Type: application/json' \
         -H 'Authorization: Bearer xaGS9Vk0te88026fk2WLqG9rU2HFUYZ6icjqmeLcKsc=' \
         'https://internal.vantiq.com/api/v1/resources/custom/sorting_condition?where={"code":"10061234567890"}'
     ```

1. レスポンスは空のオブジェクトになります。  

   ```json
   {}
   ```

1. sorting_condition Type の `すべてのレコードを表示` をクリックし、レコードが削除されていることを確認します。

   ![type_03.png](./imgs/type_03.png)

## ワークショップの振り返り

1. **Vantiq REST API**
   1. cURL を利用して Vantiq REST API 経由で Type のデータを操作する方法を学習しました。

以上
