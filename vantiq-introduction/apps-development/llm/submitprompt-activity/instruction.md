# LLM（SubmitPrompt Activity）

## 目次

- [LLM（SubmitPrompt Activity）](#llmsubmitprompt-activity)
  - [目次](#目次)
  - [1. Namespace の作成と Project の保存](#1-namespace-の作成と-project-の保存)
  - [2. Vantiq Access Token の発行](#2-vantiq-access-token-の発行)
  - [3. LLM リソースの作成](#3-llm-リソースの作成)
  - [4. Service の作成](#4-service-の作成)
    - [4-1. Service の作成](#4-1-service-の作成)
    - [4-2. Inbound Event の作成](#4-2-inbound-event-の作成)
    - [4-3. Public Visual Event Handler の作成](#4-3-public-visual-event-handler-の作成)
    - [4-4. テストデータの送信](#4-4-テストデータの送信)
    - [4-5. データの受信テスト](#4-5-データの受信テスト)
  - [5. Service Builder を用いたアプリケーションの開発](#5-service-builder-を用いたアプリケーションの開発)
    - [5-1. 【SubmitPrompt】LLM との会話機能の実装](#5-1-submitpromptllm-との会話機能の実装)
    - [5-2. 【LogStream】ログ出力の実装](#5-2-logstreamログ出力の実装)
  - [6. LLM との会話](#6-llm-との会話)
    - [6-1. Log メッセージ画面の表示](#6-1-log-メッセージ画面の表示)
    - [6-2. メッセージの送信と確認](#6-2-メッセージの送信と確認)
  - [Project のエクスポート](#project-のエクスポート)
  - [ワークショップの振り返り](#ワークショップの振り返り)
  - [参考情報](#参考情報)
    - [プロジェクトファイル](#プロジェクトファイル)

## 1. Namespace の作成と Project の保存

アプリケーションを実装する前に新しく Namespace を作成し、作成した Namespace に切り替えます。  
あわせてプロジェクトの保存も行っておきます。  

詳細は下記をご確認ください。  
[Vantiq の Namespace と Project について](/vantiq-introduction/apps-development/vantiq-basic/namespace/readme.md)

## 2. Vantiq Access Token の発行

REST クライアントから HTTP POST リクエストを行うために必要なアクセストークンを事前に発行しておきます。  

1. メニューバーの `管理` -> `Advanced` -> `Access Tokens` -> `+ 新規` をクリックし ます。

   ![token_01](./imgs/token_01.png)

1. 以下の内容を設定し、 `作成` をクリックします。

   |項目|設定値|備考|
   |-|-|-|
   |Name|RestApiToken||

   ![token_02](./imgs/token_02.png)

1. 発行された `Access Token` をクリックして、クリップボードにコピーされたアクセストークンをテキストエディタなどに保存しておきます。

   ![token_03](./imgs/token_03.png)

## 3. LLM リソースの作成

LLM リソースの作成を行います。  

1. メニューバーの `追加` -> `LLMs` -> `+ 新規` をクリックし LLM の追加画面を開きます。

   ![llm_01.png](./imgs/llm_01.png)

1. 以下の内容を設定します。  
   ※OpenAI GPT 3.5 Turbo の例

   |項目|設定値|
   |-|-|
   |LLM Name|GenerativeLLM|
   |Package|com.example|
   |Type|Generative|
   |Model Name|gpt-3.5-turbo|

   ![llm_02.png](./imgs/llm_02.png)

1. `API Key Secret` のプルダウンメニューから `-- 新規 Secret を追加--` を選択しましす。

   ![llm_03.png](./imgs/llm_03.png)

1. 以下の内容を設定し、 `OK` をクリックして Secret を作成します。

   |項目|設定値|
   |-|-|
   |Name|LlmApiKey|
   |Package|com.example|
   |Secret|※OpenAI などの LLM サービスで発行した API Key|

   ![llm_04.png](./imgs/llm_04.png)

   > **補足：Secret の管理**  
   > 作成した Secret は、メニューバーの `管理` -> `Advanced` -> `Secrets` から管理できます。  

1. 設定内容を確認し、 `保存` をクリックします。

   ![llm_05.png](./imgs/llm_05.png)

   > **補足：Run Playground**  
   > 作成した LLM は、画面右下の `Run Playground` から動作テストを行うことができます。  
   >
   > ![llm_playground.png](./imgs/llm_playground.png)

## 4. Service の作成

アプリケーションの基礎となる Service を作成します。  

### 4-1. Service の作成

1. メニューバーの `追加` -> `Service...` -> `+ 新規 Service` をクリックし Service の新規作成画面を開きます。
   
   ![create_service_1-1.png](./imgs/create_service_1-1.png)

1. 以下の内容を設定し、 `作成` をクリックします。

   |項目|設定値|
   |-|-|
   |Name|LlmApp|
   |Package|com.example|

   ![create_service_1-2.png](./imgs/create_service_1-2.png)

### 4-2. Inbound Event の作成

1. `Interface` タブの中にある `Inbound` の右側の `＋` をクリックします。

   ![create_service_2-1.png](./imgs/create_service_2-1.png)

1. 以下の内容を設定し、 `Event Schema` のプルダウンメニュー `New Type` を選択します。

   |項目|設定値|備考|
   |-|-|-|
   |Name|LlmInbound||

   ![create_service_2-2.png](./imgs/create_service_2-2.png)

1. 以下の内容を設定し、 `保存` をクリックします。

   |項目|設定値|備考|
   |-|-|-|
   |Name|message||
   |Type|String||

   ![create_service_2-3.png](./imgs/create_service_2-3.png)

### 4-3. Public Visual Event Handler の作成

1. `Implement` タブを開き、 `Unbound Event Types` をクリックして、アコーディオンを開きます。  
   `LlmInbound` の右側の `…` をクリックして、 `Public Visual Event Handler を追加` をクリックします。

   ![create_service_3-1.png](./imgs/create_service_3-1.png)

1. Service を保存します。

   ![create_service_3-2.png](./imgs/create_service_3-2.png)

### 4-4. テストデータの送信

以下のエンドポイントに HTTP POST リクエストを行い、データの受信テストを行います。  
※エンドポイントやアクセストークンは適宜書き換えてください。  

`https://dev.vantiq.com/api/v1/resources/services/com.example.LlmApp/LlmInbound`

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

### 4-5. データの受信テスト

データを受信するとタスクの右上にバッジが表示され、カウントアップされます。  
データを確認するのは下記の操作を行います。  

1. `Event Stream` タスクをクリックします。  
   画面右下の `タスク Events を表示` をクリックします。

   ![receive_test_data_01.png](./imgs/receive_test_data_01.png)

1. 表示された青字の JSON Object をクリックします。  

   ![receive_test_data_02.png](./imgs/receive_test_data_02.png)

1. 想定通りのデータが受信できているか確認します。  

   ![receive_test_data_03.png](./imgs/receive_test_data_03.png)

   > **補足：データの流れについて**  
   > ここまでの手順で、  
   > `Interface` の `Inbound Event` の `LlmInbound Event Type` で受け取ったデータは、  
   > `Implement` の `Public Event Handler` の `LlmInbound Event Handler` に紐づけられています。  
   > `LlmInbound Event Handler` に紐づけられたデータは、ルートタスクである `EventStream Activity` に送られます。  

## 5. Service Builder を用いたアプリケーションの開発

この手順からアプリケーション開発を開始します。  
`EventStream` Activity で取得したデータをイベントとして、処理を実装していきます。  

### 5-1. 【SubmitPrompt】LLM との会話機能の実装

**SubmitPrompt Activity** を使用して、 LLM との会話機能の実装を行います。

#### SubmitPrompt Activity の実装

1. Sevice ペイン左側の `GenAI` の中から `SubmitPrompt` を選択し、 `EventStream` タスクの上にドロップします。

   ![service_submitprompt_01.gif](./imgs/service_submitprompt_01.gif)

1. `SubmitPrompt` タスクをクリックし、 `Configuration` の `クリックして編集` を開き、以下の設定を行いアプリケーションを保存します。

   |Required Parameter|Value|
   |-|-|
   |llm (LLM)|com.example.GenerativeLLM (gpt-3.5-turbo)|
   |prompt (VAIL Expression)|event.message|

   ![service_submitprompt_02.png](./imgs/service_submitprompt_02.png)

### 5-2. 【LogStream】ログ出力の実装

LLM との会話をログに出力して、結果を確認できるようにします。  

#### LogStream Activity の実装

1. Service ペイン左側の `Actions` の中から `LogStream` を選択し、 `SubmitPrompt` タスクの上にドロップします。  

   ![service_logstream_01.png](./imgs/service_logstream_01.png)

   > **補足**  
   > `Downstream イベント` は `event` を選択します。  
   >
   > ![service_logstream_02.png](./imgs/service_logstream_02.png)

## 6. LLM との会話

REST API を用いてメッセージを送信し、 LLM との会話を行ってみます。  

### 6-1. Log メッセージ画面の表示

1. 画面右下の `Debugging` をクリックします。

1. 右側の `Errors` をクリックし、 `Log メッセージ` にチェックを入れます。

### 6-2. メッセージの送信と確認

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
   1. **Secret** を用いることで API Key などを安全に管理できることを学習しました。
1. **LLM** 
   1. **LLM** を用いて LLM の追加を行う方法を学習しました。
1. **Type** 
   1. **Type** を用いてスキーマの設定を行う方法を学習しました。
1. **Service**
   1. **SubmitPrompt Activity** を用いて LLM と対話する方法を学習しました。

## 参考情報

### プロジェクトファイル

- [LLM（SubmitPrompt Activity）の実装サンプル（Vantiq 1.40）](./../data/llm_submitprompt-activity_1.40.zip)
- [LLM（SubmitPrompt Activity）の実装サンプル（Vantiq 1.37）](./../data/llm_submitprompt-activity_1.37.zip)

> **注意：プロジェクトのバージョンについて**  
> Vantiq r1.40 以前のプロジェクトファイルは Service 非対応の古いサンプルになります。  
> ドキュメント記載の手順と異なりますので注意してください。  

以上
