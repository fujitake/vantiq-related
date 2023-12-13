# LLM（SubmitPrompt Activity）

Vantiq で LLM（大規模言語モデル） を利用する方法を学習します。  
このセッションでは、 LLM との対話を行うアプリケーションの実装を行います。  

## Vantiq で利用するリソースなどの解説

Vantiq リソースや各用語について解説します。

### LLM

![resource_llm.png](./imgs/resource_llm.png)

LLM を利用する際に必要となるリソースです。  
一部の LLM は予めインテグレーションされているため、簡単に LLM の利用ができます。  

### Type（Schema）

![resource_type.png](./imgs/resource_type.png)

Type では データ型のみを定義する Schema が利用できます。
スキーマを作成し、 Topic に設定して利用します。

### Secret

Secret リソースを用いることで、 API Key や Token など安全に管理することができます。  

## Vantiq で実装するアプリケーションの概要

App Builder を用いて、アプリケーションを作成していきます。  
アプリケーションの完成イメージは下記のとおりです。  

![app.png](./imgs/app.png)

## アプリケーションの開発で利用する Activity Pattern の紹介

このワークショップでは下記の Activity Pattern を利用します。

### SubmitPrompt Activity

![activitypattern_submitprompt.png](./imgs/activitypattern_submitprompt.png)

指定した LLM にプロンプ​​トを送信することができます。

## 必要なマテリアル

### 各自で準備する Vantiq 以外の要素

以下のいずれかを事前にご用意ください。

- :globe_with_meridians:[OpenAI API Key](https://platform.openai.com/api-keys)

## ワークショップの手順

アプリケーション開発の詳細は下記のリンクをご確認ください。  

- [手順](./instruction.md)
