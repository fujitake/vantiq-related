# LLM（SubmitPrompt Activity）

Vantiq で LLM（大規模言語モデル） を利用する方法を学習します。  
このセッションでは、 LLM との対話を行うアプリケーションの実装を行います。  
（※記事作成時の Vantiq バージョン： r1.39.7）  

## Vantiq で利用するリソースなどの解説

Vantiq リソースや各用語について解説します。

### Secret

Secret リソースを用いることで、 API Key や Token など安全に管理することができます。  

### Package

![resource_package.png](./imgs/resource_package.png)

Package とは、アプリケーションを目的に合わせてグループ化するための機能です。  
Package を用いて、アプリケーションをグルーピングしておくことで、他のプロジェクトへの再利用がしやすくなります。  

Package 名を命名する際は、一意な名前を付けるようにしましょう。  

### Service

![resource_service.png](./imgs/resource_service.png)

Service とは、関連した機能をまとめてカプセル化し、1つにまとめるためのリソースです。  
Service を用いることで様々なメリットがありますが、ここでは Java におけるクラスのような概念だと思っておいてください。  

Service を用いることで、 GUI でアプリケーションの作成ができます。  
アプリケーションの作成は、あらかじめ用意されている処理のパターン（Activity Pattern）を組み合わせて開発を行います。  
用意されたパターンで対応できない場合は、 VAIL という独自言語を用いてプログラミングすることも可能なため、柔軟な実装ができます。  

### LLM

![resource_llm.png](./imgs/resource_llm.png)

LLM を利用する際に必要となるリソースです。  
一部の LLM は予めインテグレーションされているため、簡単に LLM の利用ができます。  

### Type（Schema）

![resource_type.png](./imgs/resource_type.png)

Type ではデータを保存する Standard 以外に、データ型のみを定義する Schema が利用できます。  
今回は Service の Interface の作成時にあわせてスキーマを作成します。  

## Vantiq で実装するアプリケーションの概要

Service Builder を用いて、アプリケーションを作成していきます。  
アプリケーションの完成イメージは下記のとおりです。  

![app_submitprompt_activity.gif](./imgs/app_submitprompt_activity.gif)

## アプリケーションの開発で利用する Activity Pattern の紹介

このワークショップでは下記の Activity Pattern を利用します。

### EventStream Activity

![activitypattern_eventstream.png](./imgs/activitypattern_eventstream.png)

アプリケーションを作成する際に必ずルートタスクとして設定されている Activity Pattern が **EventStream** になります。  
**EventStream** はデータの入り口となります。  
Vantiq 内部からのデータを受け取ったり、 外部からの HTTP POST されたデータを受け取ることができます。  

### SubmitPrompt Activity

![activitypattern_submitprompt.png](./imgs/activitypattern_submitprompt.png)

指定した LLM にプロンプ​​トを送信することができます。

### LogStream Activity

![activitypattern_logstream.png](./imgs/activitypattern_logstream.png)

イベントデータをログに出力します。  
今回は仕分け指示が正しく行われているかを確認するために利用します。  

## 必要なマテリアル

### 各自で準備する Vantiq 以外の要素

以下のいずれかを事前にご用意ください。

- LLM API Key
  - :globe_with_meridians: [OpenAI API Key](https://platform.openai.com/api-keys)
  - :globe_with_meridians: [Google AI Studio API Key](https://aistudio.google.com/app/apikey)
- REST クライアント（使い慣れているものでOK）
  - cURL
  - Postman
  - Talend API Tester
  - VSCode REST Client

## ワークショップの手順

アプリケーション開発の詳細は下記のリンクをご確認ください。  

- [手順](./instruction.md)
