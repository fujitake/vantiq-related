[English follows Japanese:](#overview-of-getting-started-with-vantiq)
***

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
|△|[ボックスソーター（Vantiq REST API・Topic）](./apps-development/boxsorter/vantiq-restapi-topic/readme.md)|ボックスソーター（REST API）|~ r1.39|
|△|[ボックスソーター（Vantiq REST API・Type）](./apps-development/boxsorter/vantiq-restapi-type/readme.md)|ボックスソーター（REST API）|~ r1.39|

> **必須の解説**  
> ◯：必ず実施していただくことを推奨しています。  
> △：追加のワークショップとなるため、余裕がある場合は実施していただくことを推奨しています。  
> ✕：補足的なワークショップになります。  

## インフラ／クラウド入門

Vantiq を利用するにあたって必要となるインフラやクラウドに関する解説をしています。  

### Vantiq Edge

- [Vantiq Edge の要件](./infrastructure-cloud/vantiqedge-requirements/readme.md)
- [Windows 端末で Vantiq Edge をインストールする方法](./infrastructure-cloud/vantiqedge-on-windows/readme.md)

***

# Overview of Getting Started with Vantiq

This guide explains the essential knowledge required for developing applications with Vantiq, using various methods including a workshop format.

## Development Environment Setup

This section explains how to prepare for using Vantiq.  
If your account has already been issued, please skip this step.  

- [Creating a Vantiq Account (for Developers)](./apps-development/vantiq-devenv/root_account/readme.md)
- [Creating a Vantiq Account (for Organization Administrators)](./apps-development/vantiq-devenv/dev_account/readme.md)

## Application Development

This section explains how to develop Vantiq applications in a workshop format.  

### Vantiq Basics

Here, we explain the fundamental concepts of using Vantiq.  

1. [About Vantiq Namespaces and Projects](./apps-development/vantiq-basic/namespace/readme.md)
1. [About Project Management](./apps-development/vantiq-basic/project/readme.md)
1. [Basic Principles for Developing with Vantiq](./apps-development/vantiq-basic/basic-common/readme.md)

### Application Development Workshop (Beginner Level)

You will develop an application by actually using Vantiq.  
First, let's aim to get familiar with operating the Vantiq IDE.  

It is recommended to follow the steps in order from the top of the table.  

#### Workshop List

|Required|Workshop|Prerequisites|Supported Version|
|:-:|-|-|-|
|Yes|[Box Sorter (Short ver)](./apps-development/boxsorter/short/readme.md)|None|r1.42|
|Yes|[Box Sorter (REST API)](./apps-development/boxsorter/rest-api/readme.md)|None|r1.39 ~ r1.41|
|Yes|[Box Sorter (Transformation)](./apps-development/boxsorter/transform/readme.md)|Box Sorter (REST API)|r1.39 ~ r1.41|
|Yes|[Box Sorter (MQTT)](./apps-development/boxsorter/mqtt/readme.md)|Box Sorter (Transformation)|r1.39 ~ r1.40|
|Yes|[Introduction to VAIL (Basic)](./apps-development/vail-introductory/vail_basic/vail_basic.md)|None|r1.39 ~ r1.40|
|Yes|[Introduction to Major Activity Patterns](./apps-development/vantiq-basic/major-activity-pattern/readme.md)|None|-|

> **Explanation of "Required"**  
> Yes: Completion is strongly recommended.  
> No: An additional workshop, recommended if time permits.  
> Neither: This is a supplementary workshop.  

### Application Development Workshop (Intermediate Level)

Here you will acquire the skills necessary for actual application development.  

It is recommended to follow the steps in order from the top of the table.  

#### Workshop List

|Required|Workshop|Prerequisites|Supported Version|
|:-:|-|-|-|
|Yes|[Box Sorter (CachedEnrich)](./apps-development/boxsorter/cachedenrich/readme.md)|Box Sorter (MQTT)|~ r1.39|
|No|[Box Sorter (MQTTX)](./apps-development/boxsorter/mqttx/readme.md)|Box Sorter (MQTT)|~ r1.39|
|Yes|[Box Sorter (SaveToType)](./apps-development/boxsorter/savetype/readme.md)|Box Sorter (MQTT)|~ r1.39|
|Yes|[Introduction to VAIL (Type Operations)](./apps-development/vail-introductory/vail_type/vail_type.md)|Introduction to VAIL (Basic)|
|Yes|[Introduction to VAIL (Sending Data Externally)](./apps-development/vail-introductory/vail_data/vail_data.md)|Introduction to VAIL (Basic)|
|Neither|[Box Sorter (Unwind)](./apps-development/boxsorter/unwind/readme.md)|Box Sorter (MQTT)|~ r1.39|
|Neither|[Debugging Methods](./apps-development/debug/readme.md)|None|~ r1.39|
|Neither|[Review of Vantiq's Basic Elements](./apps-development/vantiq-basic/basic-resources/readme.md)||
|Neither|[LLM (SubmitPrompt Activity)](./apps-development/llm/submitprompt-activity/readme.md)|None|r1.39 ~ r1.40|
|Neither|[LLM (SubmitPrompt Procedure)](./apps-development/llm/submitprompt-procedure/readme.md)|LLM (SubmitPrompt Activity)|r1.39 ~ r1.40|
|Neither|[LLM (AccumulateState Activity)](./apps-development/llm/accumulatestate-activity/readme.md)|LLM (SubmitPrompt Procedure)|~ r1.39|
|Neither|[Box Sorter (Vantiq REST API - Topic)](./apps-development/boxsorter/vantiq-restapi-topic/readme.md)|Box Sorter (REST API)|~ r1.39|
|Neither|[Box Sorter (Vantiq REST API - Type)](./apps-development/boxsorter/vantiq-restapi-type/readme.md)|Box Sorter (REST API)|~ r1.39|

> **Explanation of "Required"**  
> Yes: Completion is strongly recommended.  
> No: An additional workshop, recommended if time permits.  
> Neither: This is a supplementary workshop.  

## Introduction to Infrastructure / Cloud

This section explains the infrastructure and cloud concepts required for using Vantiq.  

### Vantiq Edge

- [Vantiq Edge Requirements](./infrastructure-cloud/vantiqedge-requirements/readme.md)
- [How to Install Vantiq Edge on a Windows Device](./infrastructure-cloud/vantiqedge-on-windows/readme.md)
