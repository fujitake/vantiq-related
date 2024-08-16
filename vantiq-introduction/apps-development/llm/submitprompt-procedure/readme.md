# LLM（SubmitPrompt Procedure）

Vantiq で LLM（大規模言語モデル） を利用する方法を学習します。  
このセッションでは、 LLM アプリを改修し VAIL で実装する方法を学習します。  
（※記事作成時の Vantiq バージョン： r1.39.7）  

## Vantiq で実装するアプリケーションの概要

Service Builder を用いて、アプリケーションを作成していきます。  
アプリケーションの完成イメージは下記のとおりです。  

![app_submitprompt_procedure.gif](./imgs/app_submitprompt_procedure.gif)




## アプリケーションの開発で利用する Activity Pattern の紹介

このワークショップでは下記の Activity Pattern を利用します。

### Procedure Activity

![activitypattern_procedure.png](./imgs/activitypattern_procedure.png)

**Procedure Activity** を利用すると VAIL でコーディングした Procedure を Visual Event Handler 内で呼び出すことができます。  

## 必要なマテリアル

### 各自で準備する Vantiq 以外の要素

以下のいずれかを事前にご用意ください。

- :globe_with_meridians: [OpenAI API Key](https://platform.openai.com/api-keys)
- :globe_with_meridians: [Google AI Studio API Key](https://aistudio.google.com/app/apikey)

### プロジェクトファイル

- [LLM（SubmitPrompt Activity）の実装サンプル（Vantiq 1.40](./../data/llm_submitprompt-activity_1.40.zip)

## ワークショップの手順

アプリケーション開発の詳細は下記のリンクをご確認ください。  

- [手順](./instruction.md)
