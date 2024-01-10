# ボックスソーター（Vantiq REST API・Topic）

## 目次

- [ボックスソーター（Vantiq REST API・Topic）](#ボックスソーターvantiq-rest-apitopic)
  - [目次](#目次)
  - [アプリケーションが前提とする受信内容](#アプリケーションが前提とする受信内容)
  - [1. Namespace の作成と Project のインポート](#1-namespace-の作成と-project-のインポート)
    - [1-1. Namespace の作成](#1-1-namespace-の作成)
    - [1-2. Project のインポート](#1-2-project-のインポート)
  - [2. Vantiq Access Token の発行](#2-vantiq-access-token-の発行)
    - [2-1. Vantiq Access Token の発行](#2-1-vantiq-access-token-の発行)
  - [3. Topic でのデータ受信](#3-topic-でのデータ受信)
    - [3-1. Topic ペインの表示](#3-1-topic-ペインの表示)
    - [3-2. Topic のデータ受信テスト](#3-2-topic-のデータ受信テスト)
  - [ワークショップの振り返り](#ワークショップの振り返り)

## アプリケーションが前提とする受信内容

```json
{
    "code": "14961234567890",
    "name": "お茶 24本"
}
```

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

## 3. Topic でのデータ受信

**Topic** の **データの受信テスト** からデータが受信できるか確認します。  

### 3-1. Topic ペインの表示

1. 画面左側の **Project Contents** から `/BoxInfoApi` Topic を開きます。
   
   ![project-contents_topic.png](./imgs/project-contents_topic.png)

### 3-2. Topic のデータ受信テスト

1. 左上の `データの受信テスト` をクリックします。

   ![boxinfoapi.png](./imgs/boxinfoapi.png)

1. REST API クライアントからデータを POST します。

   - cURL の場合

     ```shell
     curl \
         -X POST \
         -H "Content-Type: application/json" \
         -H "Authorization: Bearer ※VantiqAccessToken" \
         -d '{"code":"10061234567890", "name":"みかん 1kg"}' \
         "https://{VantiqのURL(FQDN)}/api/v1/resources/topics/{Topic名}"
     ```

     コマンド例

     ```shell
     curl \
         -X POST \
         -H "Content-Type: application/json" \
         -H "Authorization: Bearer xaGS9Vk0te88026fk2WLqG9rU2HFUYZ6icjqmeLcKsc=" \
         -d '{"code":"10061234567890", "name":"みかん 1kg"}' \
         "https://dev.vantiq.com/api/v1/resources/topics//BoxInfoApi"
     ```

1. データが受信できていることを確認します。

   ![topic_subscribe.png](./imgs/topic_subscribe.png)

## ワークショップの振り返り

1. **Vantiq REST API**
   1. cURL を利用して Vantiq REST API 経由でデータを Topic に POST する方法を学習しました。

以上
