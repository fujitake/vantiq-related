# GenAI コンポーネントについて

ここでは GenAI コンポーネントについて解説します。  
App Builder に似ていますが異なる点が多々あります。  
（※記事作成時の Vantiq バージョン： r1.40.13）

- [GenAI コンポーネントについて](#genai-コンポーネントについて)
  - [GenAI ビルダーとは](#genai-ビルダーとは)
  - [導入手順](#導入手順)
  - [導入結果の確認方法](#導入結果の確認方法)

## GenAI ビルダーとは

開発者が（SubmitPromptおよびAnswerQuestionアクティビティパターンを使用して）アプリケーションにGenAIを迅速に追加できるように設計されています。その結果、その動作は比較的固定されており、最も広範なユースケースに対応することを目的としています。ただし、アプリケーションでより特殊なGenAI機能が必要な場合や、最新のGenAIアルゴリズムを活用する必要がある場合もあります。これらの要件に対応することが、 GenAI Builderの目的です。


## 導入手順

1. Organization の Root Namespace を開きます。
1. Vantiq の Reference から `GenAIFlowService project` をダウンロードします。  
   :globe_with_meridians: [Administrators Reference Guide - Deploying the GenAI Flow Service Connector](https://dev.vantiq.com/docs/system/namespaces/#deploying-the-genai-flow-service-connector)
1. メニューバーの `Projects` → `インポート...` をクリックします。
1. `インポートするフォルダまたは zip ファイルをここにドロップ` にダウンロードした `genAIFlowService.zip` ファイルをドロップします。
1. `インポート` をクリックします。

## 導入結果の確認方法

1. メニューバーの `管理` → `Advanced` → `Service Connectors` をクリックします。
1. 一覧に `GenAIFlowService` が追加されていることを確認します。
