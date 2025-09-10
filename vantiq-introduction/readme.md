# Vantiq 入門の概要

Vantiq を用いたアプリケーションの開発を行う上で、必要となる知識をワークショップ形式を含め、様々な方法で解説しています。

## 開発環境の準備

Vantiq を利用するための事前準備の方法を解説しています。  
アカウントが既に発行されている場合はこの手順を飛ばしてください。

- [Vantiqアカウント作成（開発者向け）](./apps-development/vantiq-devenv/root_account/readme.md)
- [Vantiqアカウント作成（組織管理者向け）](./apps-development/vantiq-devenv/dev_account/readme.md)

## アプリケーション開発

Vantiq アプリケーションの開発方法をワークショップ形式で解説しています。  

### Vantiq の基本

Vantiq の基本的な扱い方を解説しています。  

1. [Vantiq の Namespace と Project について](./apps-development/vantiq-basic/namespace/readme.md)
1. [Project の管理について](./apps-development/vantiq-basic/project/readme.md)
1. [Vantiq で開発する上での基本事項](./apps-development/vantiq-basic/basic-common/readme.md)

### アプリケーション開発ワークショップ（初級編）

実際に Vantiq を使ってアプリケーションを開発していきます。  
まずは Vantiq IDE の操作に慣れることを目指しましょう。  

表の上から順に実施していただくことを推奨しています。  

#### ワークショップ一覧

|必須|ワークショップ|前提となるワークショップ|対応バージョン|
|:-:|-|-|-|
|◯|[ボックスソーター（Short ver）](./apps-development/boxsorter/short/readme.md)|なし|r1.42|
|◯|[ボックスソーター（REST API）](./apps-development/boxsorter/rest-api/readme.md)|なし|r1.39 ~ r1.41|
|◯|[ボックスソーター（Transformation）](./apps-development/boxsorter/transform/readme.md)|ボックスソーター（REST API）|r1.39 ~ r1.41|
|◯|[ボックスソーター（MQTT）](./apps-development/boxsorter/mqtt/readme.md)|ボックスソーター（Transformation）|r1.39 ~ r1.40|
|◯|[VAIL 入門（基礎）](./apps-development/vail-introductory/vail_basic/vail_basic.md)|なし|r1.39 ~ r1.40|
|◯|[主要な Activity Pattern の紹介](./apps-development/vantiq-basic/major-activity-pattern/readme.md)|なし|-|

> **必須の解説**  
> ◯：必ず実施していただくことを推奨しています。  
> △：追加のワークショップとなるため、余裕がある場合は実施していただくことを推奨しています。  
> ✕：補足的なワークショップになります。

### アプリケーション開発ワークショップ（中級編）

実際のアプリケーション開発に必要となるスキルを身に着けていきます。  

表の上から順に実施していただくことを推奨しています。  

#### ワークショップ一覧

|必須|ワークショップ|前提となるワークショップ|対応バージョン|
|:-:|-|-|-|
|◯|[ボックスソーター（CachedEnrich）](./apps-development/boxsorter/cachedenrich/readme.md)|ボックスソーター（MQTT）|~ r1.39|
|✕|[ボックスソーター（MQTTX）](./apps-development/boxsorter/mqttx/readme.md)|ボックスソーター（MQTT）|~ r1.39|
|◯|[ボックスソーター（SaveToType)](./apps-development/boxsorter/savetype/readme.md)|ボックスソーター（MQTT）|~ r1.39|
|◯|[VAIL 入門（Type の操作）](./apps-development/vail-introductory/vail_type/vail_type.md)|VAIL 入門（基礎）|
|◯|[VAIL 入門（外部へのデータ送信）](./apps-development/vail-introductory/vail_data/vail_data.md)|VAIL 入門（基礎）|
|△|[ボックスソーター（Unwind）](./apps-development/boxsorter/unwind/readme.md)|ボックスソーター（MQTT）|~ r1.39|
|△|[デバッグ方法](./apps-development/debug/readme.md)|なし|~ r1.39|
|△|[Vantiqの基本要素のおさらい](./apps-development/vantiq-basic/basic-resources/readme.md)||
|△|[LLM（SubmitPrompt Activity）](./apps-development/llm/submitprompt-activity/readme.md)|なし|r1.39 ~ r1.40|
|△|[LLM（SubmitPrompt Procedure）](./apps-development/llm/submitprompt-procedure/readme.md)|LLM（SubmitPrompt Activity）|r1.39 ~ r1.40|
|△|[LLM（AccumulateState Activity）](./apps-development/llm/accumulatestate-activity/readme.md)|LLM（SubmitPrompt Procedure）|~ r1.39|
|△|[ボックスソーター（Vantiq REST API・Topic）](./apps-development/boxsorter/vantiq-restapi-topic/readme.md)|ボックスソーター（初級編・REST API）|~ r1.39|
|△|[ボックスソーター（Vantiq REST API・Type）](./apps-development/boxsorter/vantiq-restapi-type/readme.md)|ボックスソーター（初級編・REST API）|~ r1.39|

> **必須の解説**  
> ◯：必ず実施していただくことを推奨しています。  
> △：追加のワークショップとなるため、余裕がある場合は実施していただくことを推奨しています。  
> ✕：補足的なワークショップになります。

### アプリケーション開発ワークショップ（上級編）

実際に Vantiq を使ってアプリケーションを開発していきます。  
表の上から順に実施していただくことを推奨しています。  

#### ワークショップ一覧

|必須|ワークショップ|前提となるワークショップ|
|:-:|-|-|
|-|[~~ボックスソーター（上級編・State）~~](#)|※制作中|

> **必須の解説**  
> ◯：必ず実施していただくことを推奨しています。  
> △：追加のワークショップとなるため、余裕がある場合は実施していただくことを推奨しています。  
> ✕：補足的なワークショップになります。

## インフラ／クラウド入門

Vantiq を利用するにあたって必要となるインフラやクラウドに関する解説をしています。  

### Vantiq Edge

- [Vantiq Edge の要件](./infrastructure-cloud/vantiqedge-requirements/readme.md)
- [Windows 端末で Vantiq Edge をインストールする方法](./infrastructure-cloud/vantiqedge-on-windows/readme.md)
