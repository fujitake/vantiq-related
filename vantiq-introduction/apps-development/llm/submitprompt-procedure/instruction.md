# LLM（SubmitPrompt Procedure）

## 目次

- [LLM（SubmitPrompt Procedure）](#llmsubmitprompt-procedure)
  - [目次](#目次)
  - [1. Namespace の作成と Project のインポート](#1-namespace-の作成と-project-のインポート)
    - [1-1. Namespace の作成](#1-1-namespace-の作成)
    - [1-2. Project のインポート](#1-2-project-のインポート)
  - [2. Vantiq Access Token の発行](#2-vantiq-access-token-の発行)
  - [2. Secret の作成](#2-secret-の作成)
  - [3. LLM の設定](#3-llm-の設定)
  - [4. 既存のアプリケーションの動作確認](#4-既存のアプリケーションの動作確認)
    - [4-1. Log メッセージ画面の表示](#4-1-log-メッセージ画面の表示)
    - [4-2. HTTP POST リクエストの送信](#4-2-http-post-リクエストの送信)
    - [4-3. メッセージの確認](#4-3-メッセージの確認)
  - [5. Procedure の作成](#5-procedure-の作成)
    - [5-1. Interface の作成](#5-1-interface-の作成)
    - [5-2. Procedure の作成](#5-2-procedure-の作成)
    - [5-3. Procedure の実行](#5-3-procedure-の実行)
  - [6. Service Builder を用いたアプリケーションの改修](#6-service-builder-を用いたアプリケーションの改修)
    - [6-1. 【Service Builder】Event Handler の表示](#6-1-service-builderevent-handler-の表示)
    - [6-2. 【SubmitPrompt】既存のタスクの削除](#6-2-submitprompt既存のタスクの削除)
    - [6-3. 【Procedure】プロシージャの呼び出し](#6-3-procedureプロシージャの呼び出し)
    - [6-4. 【LogStream】ログタスクの修正](#6-4-logstreamログタスクの修正)
  - [7. LLM との会話](#7-llm-との会話)
    - [7-1. Log メッセージ画面の表示](#7-1-log-メッセージ画面の表示)
    - [7-2. メッセージの送信と確認](#7-2-メッセージの送信と確認)
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
**LLM（SubmitPrompt Activity）** の Project をインポートしてください。  

詳細は下記を参照してください。  
[Project の管理について - Project のインポート](/vantiq-introduction/apps-development/vantiq-basic/project/readme.md#project-のインポート)


## 2. Vantiq Access Token の発行

Access Token はネームスペースごとに管理されているため、改めて発行します。  

1. メニューバーの `管理` -> `Advanced` -> `Access Tokens` -> `+ 新規` をクリックし ます。

   ![token_01](./imgs/token_01.png)

1. 以下の内容を設定し、 `作成` をクリックします。

   |項目|設定値|備考|
   |-|-|-|
   |Name|RestApiToken||

   ![token_02](./imgs/token_02.png)

1. 発行された `Access Token` をクリックして、クリップボードにコピーされたアクセストークンをテキストエディタなどに保存しておきます。

   ![token_03](./imgs/token_03.png)

## 2. Secret の作成

Secret はネームスペースごとに管理されているため、改めて作成します。  

1. メニューバーの `管理` -> `Advanced` -> `Secrets` -> `+ 新規` をクリックし Secret の新規作成画面を開きます。

   ![secret_01.png](./imgs/secret_01.png)

1. 以下の内容を設定し、保存します。

   |項目|設定値|
   |-|-|
   |Name|com.example.LlmApiKey|
   |Secret|※各種 LLM サービスで発行した API Key|

   ![secret_02](./imgs/secret_02.png)

## 3. LLM の設定

LLM の設定を行います。  
Secret の設定をし直す必要があります。  

1. 画面左側の **Project Contents** から `com.example.GenerativeLLM` ペインを開きます。

   ![project-contents_llm.png](./imgs/project-contents_llm.png)

1. `API Key Secret` を作成した Secret に変更して保存、または確認します。

   ![llm_01.png](./imgs/llm_01.png)

## 4. 既存のアプリケーションの動作確認

以下のエンドポイントに HTTP POST リクエストを行い、データの受信テストを行います。  
※エンドポイントやアクセストークンは適宜書き換えてください。  

`https://dev.vantiq.com/api/v1/resources/services/com.example.LlmApp/LlmInbound`

### 4-1. Log メッセージ画面の表示

1. 画面右下の `Debugging` をクリックします。

1. 右側の `Errors` をクリックし、 `Log メッセージ` にチェックを入れます。

### 4-2. HTTP POST リクエストの送信

#### Post Tester の例

1. 下記の URL を Post Tester を開きます。  
   - :globe_with_meridians: [Post Tester](https://posttester.fiiris.jp/)

1. 以下の設定を行い、 `Send` をクリックします。

   |項目|設定値|備考|
   |-|-|-|
   |URL|https://dev.vantiq.com/api/v1/resources/services/com.example.LlmApp/LlmInbound|※Edge やプライベードクラウドの場合は、 FQDN やプロトコルを適宜書き換えてください。|
   |Token|YrAPMOgLczOEwcXznlNf2b4S7XSu2ynRKIRtPafm0ZE=|※[Vantiq Access Token の発行](#2-vantiq-access-token-の発行) で発行したアクセストークンを入力してください。|
   |Body (JSON)|{"message":"こんにちは"}||

   ![post_tester_01.png](./imgs/post_tester_01.png)

#### cURL の例

1. 以下のコマンドを参考にして、 HTTP POST リクエストを行います。  
   
   ```shell
   curl \
       -X POST \
       -H "Content-Type: application/json" \
       -H "Authorization: Bearer YrAPMOgLczOEwcXznlNf2b4S7XSu2ynRKIRtPafm0ZE=" \
       -d '{"message":"こんにちは"}' \
       "https://dev.vantiq.com/api/v1/resources/services/com.example.LlmApp/LlmInbound"
   ```

### 4-3. メッセージの確認

1. アプリケーションが正しく動いているか確認します。

   ![send_message_01.gif](./imgs/send_message_01.gif)

1. LLM との会話の結果をログ画面で確認します。

   ![send_message_02.png](./imgs/send_message_02.png)

## 5. Procedure の作成

Procedure を作成します。  
今回は Sevice Procedure として作成します。  

> **補足：Procedure 単体で作成する場合**  
> Procedure を単体で作成する場合は、  
> メニューバーの `追加` -> `Advanced` -> `Procedure...` -> `+ 新規 Procedure` から作成できます。  

### 5-1. Interface の作成

1. `Interface` タブの中にある `Procedures` の右側の `＋` をクリックします。

   ![procedure_01.png](./imgs/procedure_01.png)

1. 以下の内容を設定し、 `+ 新規パラメータ` をクリックします。

   |項目|設定値|
   |-|-|
   |Name|mySubmitPormpt|

   ![procedure_02.png](./imgs/procedure_02.png)

1. 以下の内容を設定し、 `保存` をクリックします。

   |項目|設定値|
   |-|-|
   |Name|prompt|
   |Type|String|
   |Required|True|

   ![procedure_03.png](./imgs/procedure_03.png)

### 5-2. Procedure の作成

1. `Implement` タブを開き、 `Unbound Procedures` をクリックして、アコーディオンを開きます。  
   `mySubmitPormpt` の右側の `…` をクリックして、 `Procedure を追加` をクリックします。

   ![procedure_04.png](./imgs/procedure_04.png)

1. `保存` をクリックして、 Service を保存します。

   ![procedure_05.png](./imgs/procedure_05.png)

1. 下記の VAIL コードを入力し、 `保存` をクリックします。

   ```JavaScript
   package com.example
   PROCEDURE LlmApp.mySubmitPormpt(prompt String REQUIRED)
   
   var response = io.vantiq.ai.LLM.submitPrompt("com.example.GenerativeLLM", prompt)
   
   return response
   ```

   ![procedure_06.png](./imgs/procedure_06.png)

### 5-3. Procedure の実行

1. ペイン左上の `実行ボタン` をクリックし、プロシージャを実行してみます。

   ![procedure_07.png](./imgs/procedure_07.png)

1. 引数に任意のメッセージを入力して `実行` をクリックします。

   ![procedure_08.png](./imgs/procedure_08.png)

1. 実行結果を確認し、 `OK` をクリックします。

   ![procedure_09.png](./imgs/procedure_09.png)

## 6. Service Builder を用いたアプリケーションの改修

この手順からアプリケーションの改修を開始します。  

今回は **SubmitPrompt Activity** に変わり **Procedure Activity** を利用します。  
そのために必要な改修を行っていきます。  

### 6-1. 【Service Builder】Event Handler の表示

1. `Implement` タブの中にある `Public` をクリックして、アコーディオンを開きます。  
   `LlmInbound` をクリックして、 Service Builder を開きます。  

   ![service_show_01.png](./imgs/service_show_01.png)

### 6-2. 【SubmitPrompt】既存のタスクの削除

1. `SubmitPrompt` タスクを選択し、 `Delete` キーを押下して削除します。

   ![delete_submitprompt_01.gif](./imgs/delete_submitprompt_01.gif)

### 6-3. 【Procedure】プロシージャの呼び出し

1. Service ペイン左側の `Actions` の中から `Procedure` を選択し、 `EventStream` タスクの上にドロップします。  

   ![add_procedure_01.gif](./imgs/add_procedure_01.gif)

1. `Procedure` タスクをクリックし、 `Configuration` の `クリックして編集` から以下の内容を入力し、 `parameters (Object)` の `<null>` をクリックします。

   |Required Parameter|Value|
   |-|-|
   |procedure (Procedure)|com.example.LlmApp.mySubmitPormpt|

   ![add_procedure_02.png](./imgs/add_procedure_02.png)

1. 以下の内容を入力し、 `OK` クリックしてアプリケーションを保存します。

   |Parameter|VAIL Expression|
   |-|-|
   |prompt|event.message|

   ![add_procedure_03.png](./imgs/add_procedure_03.png)

### 6-4. 【LogStream】ログタスクの修正

1. `LogStream` タスクを選択し、 `Procedure` タスクの上にドロップして、アプリケーションを保存します。  

   ![repair_logstream_01.gif](./imgs/repair_logstream_01.gif)

   > **補足：Downstream イベント**  
   > `Downstream イベント` は `event` を選択します。  
   >
   > ![repair_logstream_02.png](./imgs/repair_logstream_02.png)

## 7. LLM との会話

REST API を用いてメッセージを送信し、 LLM との会話を行ってみます。  

### 7-1. Log メッセージ画面の表示

1. 画面右下の `Debugging` をクリックします。

1. 右側の `Errors` をクリックし、 `Log メッセージ` にチェックを入れます。

### 7-2. メッセージの送信と確認

1. REST クライアントを用いて、任意のメッセージを送信します。

1. アプリケーションが正しく動いているか確認します。

   ![send_message_01.gif](./imgs/send_message_01.gif)

1. LLM との会話の結果をログ画面で確認します。

   ![send_message_02.png](./imgs/send_message_02.png)

## Project のエクスポート

作成したアプリケーションを Project ごとエクスポートします。  
Project のエクスポートを行うことで、他の Namespace にインポートしたり、バックアップとして管理することが出来ます。  

詳細は下記を参照してください。  
[Project の管理について - Project のエクスポート](/vantiq-introduction/apps-development/vantiq-basic/project/readme.md#project-のエクスポート)

## ワークショップの振り返り

1. **Secret**
   1. **Secret** を用いることで、既存のアプリケーションをインポートした場合でも Secret の再設定を行う必要があり、 API Key などを安全に管理できることを学習しました。
1. **Vantiq Access Token** 
   1. Namespace ごとに Access Token が必要なことを学習しました。
1. **Service**
   1. **Procedure** を利用し、独自言語である VAIL を用いた柔軟なアプリ開発ができることを学習しました。
   1. **Procedure Activity** を利用し、作成した Procedure を呼び出す方法を学習しました。

## 参考情報

### プロジェクトファイル



- [LLM（SubmitPrompt Procedure）の実装サンプル（Vantiq 1.40）](./../data/llm_submitprompt-procedure_1.40.zip)
- [LLM（SubmitPrompt Procedure）の実装サンプル（Vantiq 1.37）](./../data/llm_submitprompt-procedure_1.37.zip)

> **注意：プロジェクトのバージョンについて**  
> Vantiq r1.40 以前のプロジェクトファイルは Service 非対応の古いサンプルになります。  
> ドキュメント記載の手順と異なりますので注意してください。  

以上
