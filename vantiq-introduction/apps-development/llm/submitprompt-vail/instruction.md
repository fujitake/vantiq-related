# LLM（SubmitPrompt VAIL）

## 実装の流れ

下記の流れで実装していきます。

1. 【準備】Namespace の作成と Project のインポート
1. 【Secret】各種 LLM の API Key の設定
1. 【LLM】LLM の設定
1. 【Procedure】VAIL を用いた Procedure の作成
1. 【App Builder】LLM アプリケーションの改修
1. 【動作確認】Log メッセージの確認

> リソース名やタスク名は任意のものに変更しても構いません。

## 目次

- [LLM（SubmitPrompt VAIL）](#llmsubmitprompt-vail)
  - [実装の流れ](#実装の流れ)
  - [目次](#目次)
  - [1. Namespace の作成と Project のインポート](#1-namespace-の作成と-project-のインポート)
    - [1-1. Namespace の作成](#1-1-namespace-の作成)
    - [1-2. Project のインポート](#1-2-project-のインポート)
  - [2. Secret を用いた API Key の管理](#2-secret-を用いた-api-key-の管理)
    - [2-1. Secret の作成](#2-1-secret-の作成)
  - [3. LLM の設定](#3-llm-の設定)
    - [3-1. LLM ペインの表示](#3-1-llm-ペインの表示)
    - [3-2. API Key Secret の設定](#3-2-api-key-secret-の設定)
  - [4. 既存のアプリケーションの動作確認](#4-既存のアプリケーションの動作確認)
  - [5. Procedure の作成](#5-procedure-の作成)
    - [5-1. Procedure の作成](#5-1-procedure-の作成)
  - [6. App Builder を用いた App の改修](#6-app-builder-を用いた-app-の改修)
    - [6-1. 【App Builder】App ペインの表示](#6-1-app-builderapp-ペインの表示)
    - [6-2. 【EventStream】Topic データの取得](#6-2-eventstreamtopic-データの取得)
    - [6-3. 【SubmitPrompt】LLM との会話機能の実装](#6-3-submitpromptllm-との会話機能の実装)
    - [6-4. 【LogStream】ログ出力の実装](#6-4-logstreamログ出力の実装)
  - [7. LLM との会話](#7-llm-との会話)
    - [7-1. Log メッセージ画面の表示](#7-1-log-メッセージ画面の表示)
    - [7-2. /Inbound Topic ペインの表示](#7-2-inbound-topic-ペインの表示)
    - [7-3. メッセージの送信](#7-3-メッセージの送信)
    - [7-4. アプリケーションとログの確認](#7-4-アプリケーションとログの確認)
  - [Project のエクスポート](#project-のエクスポート)
  - [ワークショップの振り返り](#ワークショップの振り返り)
  - [参考情報](#参考情報)
    - [プロジェクトファイル](#プロジェクトファイル)

## 1. Namespace の作成と Project のインポート

### 1-1. Namespace の作成

アプリケーションを実装する前に新しく Namespace を作成し、作成した Namespace に切り替えます。  

詳細は下記をご確認ください。  
[Vantiq の Namespace と Project について](/vantiq-introduction/apps-development/vantiq-basic/namespace/namespace.md)

### 1-2. Project のインポート

Namespace の切り替えが出来たら、 Project のインポートを行います。  
**LLM（SubmitPrompt Activity）** の Project をインポートしてください。  

詳細は下記を参照してください。  
[Project の管理について - Project のインポート](/vantiq-introduction/apps-development/vantiq-basic/project/project.md#project-のインポート)

## 2. Secret を用いた API Key の管理

Secret はネームスペースごとに管理されているため、改めて Secret を作成します。  

### 2-1. Secret の作成

1. メニューバーの `管理` -> `Advanced` -> `Secrets` -> `+ 新規` をクリックし Secret の新規作成画面を開きます。

   ![secret_01.png](./imgs/secret_01.png)

1. 以下の内容を設定し、保存します。

   |項目|設定値|
   |-|-|
   |Name|LlmApyKey|
   |Secret|※各種 LLM サービスで発行した API Key|

   ![secret_02](./imgs/secret_02.png)

## 3. LLM の設定

LLM の設定を行っていきます。  
Secret の設定をし直す必要がります。  

### 3-1. LLM ペインの表示

1. 画面左側の **Project Contents** から `LLM` ペインを開きます。

   ![project-contents_llm.png](./imgs/project-contents_llm.png)

### 3-2. API Key Secret の設定

1. `LLM` をクリックし、編集画面を開きます。

   ![llm_01.png](./imgs/llm_01.png)

1. 以下の内容を設定し、 `OK` をクリックします。

   |項目|設定値|
   |-|-|
   |API Key Secret|LlmApiKey|

   ![llm_02.png](./imgs/llm_02.png)

## 4. 既存のアプリケーションの動作確認

`/Inbound` Topic からメッセージを送信し、アプリケーションが正しく動作するか確認します。  

詳細は下記を参照してください。  
[LLM（SubmitPrompt Activity） - 7. LLM との会話](/vantiq-introduction/apps-development/llm/submitprompt-activity/instruction.md#7-llm-との会話)

## 5. Procedure の作成

Procedure を作成します。  

### 5-1. Procedure の作成

1. メニューバーの `追加` -> `Advanced` -> `Procedure...` -> `+ 新規 Procedure` をクリックします。

1. 下記の内容を入力し、保存します。

   ```JavaScript
   PROCEDURE submitPormpt(prompt)

   var response = io.vantiq.ai.LLM.submitPrompt("LLM", prompt)

   return response
   ```

1. ペイン左上の `実行ボタン` をクリックし、プロシージャを実行してみます。












## 6. App Builder を用いた App の改修

この手順からアプリケーションの改修を開始します。  

### 6-1. 【App Builder】App ペインの表示

1. 画面左側の **Project Contents** から `LlmApp` ペインを開きます。

   ![project-contents_app.png](./imgs/project-contents_app.png)



#### App の新規作成

1. メニューバーの `追加` -> `Advanced` -> `App...` -> `+ 新規 App` をクリックしアプリケーションの新規作成画面を開きます。
   
   ![create_app_01.png](./imgs/create_app_01.png)

1. 以下の内容を設定し、保存します。

   |項目|設定値|
   |-|-|
   |Name|LlmApp|

   ![create_app_02.png](./imgs/create_app_02.png)

### 6-2. 【EventStream】Topic データの取得

**EventStream Activity** を使って Topic からデータを受け取れるようにします。  

#### EventStream の設定

1. `Initiate` タスクをクリックし、以下の内容を設定します。  

   |項目|設定値|
   |-|-|
   |Name|LlmInbound|

   ![create_app_03.png](./imgs/create_app_03.png)

1. `Configuration` の `クリックして編集` から以下の内容を入力し、 `OK` をクリックし、アプリケーションを保存します。

   |Required Parameter|Value|
   |-|-|
   |inboundResource (Enumerated)|topics|
   |inboundResourceId (String)|/Inbound|

   ![create_app_04.png](./imgs/create_app_04.png)

### 6-3. 【SubmitPrompt】LLM との会話機能の実装

**SubmitPrompt Activity** を使用して、 LLM との会話機能の実装を行います。

#### SubmitPrompt Activity の実装

1. App ペイン左側の `AI` の中から `SubmitPrompt` を選択し、 `LlmInbound` タスクの上にドロップします。

   ![create_app_05.png](./imgs/create_app_05.png)

1. `SubmitPrompt` タスクをクリックし、 `Configuration` の `クリックして編集` を開き、以下の設定を行いアプリケーションを保存します。

   |Required Parameter|Value|
   |-|-|
   |llm (Enumerated)|LLM (gpt-3.5-turbo)|
   |prompt (VAIL Expression)|event.message|

   ![create_app_06.png](./imgs/create_app_06.png)

### 6-4. 【LogStream】ログ出力の実装

LLM との会話をログに出力して、結果を確認できるようにします。  

#### LogStream Activity の実装

1. App ペイン左側の `Actions` の中から `LogStream` を選択し、 `SubmitPrompt` タスクの上にドロップします。  

   ![create_app_07.png](./imgs/create_app_07.png)

   > **補足**  
   > `Downstream イベント` は `event` を選択します。  
   >
   > ![create_app_08.png](./imgs/create_app_08.png)

## 7. LLM との会話

Topic からメッセージを送信し、 LLM との会話を行ってみます。  

### 7-1. Log メッセージ画面の表示

1. 画面右下の `Debugging` をクリックします。

1. 右側の `Errors` をクリックし、 `Log メッセージ` にチェックを入れます。

### 7-2. /Inbound Topic ペインの表示

1. 画面左側の `Project Contents` から `/Inbound` Topic を開きます。

   ![projectcontents_01.png](./imgs/projectcontents_01.png)

### 7-3. メッセージの送信

1. `/Inbound` Topic ペインから任意のメッセージを入力し、 `Publish` をクリックします。

   ![log_01.png](./imgs/log_01.png)

### 7-4. アプリケーションとログの確認

1. アプリケーションが正しく動いているか確認します。

   ![log_02.png](./imgs/log_02.png)

1. LLM との会話の結果をログ画面で確認します。

   ![log_03.png](./imgs/log_03.png)

## Project のエクスポート

作成したアプリケーションを Project ごとエクスポートします。  
Project のエクスポートを行うことで、他の Namespace にインポートしたり、バックアップとして管理することが出来ます。  

詳細は下記を参照してください。  
[Project の管理について - Project のエクスポート](/vantiq-introduction/apps-development/vantiq-basic/project/project.md#project-のエクスポート)

## ワークショップの振り返り

1. **Secret**
   1. **Secret** を用いることで API Key などを安全に管理できることを学習しました。
1. **LLM** 
   1. **LLM** を用いて LLM の追加を行う方法を学習しました。
1. **Type** 
   1. **Type** を用いてスキーマの設定を行う方法を学習しました。
1. **Topic** 
   1. **Topic** を用いて Vantiq アプリケーション用のエンドポイントを作成する方法を学習しました。
1. **App**
   1. **SubmitPrompt** を用いて LLM と対話する方法を学習しました。

## 参考情報

### プロジェクトファイル

- [LLM（SubmitPrompt Activity）の実装サンプル（Vantiq 1.37）](./../data/llm_submitprompt_1.37.zip)

以上
