# GenAI Flow Service Connector の導入方法

GenAI Builder を利用する場合は、 Organization に `GenAI Flow Service Connector` が導入されている必要があります。  
本記事では、その `GenAI Flow Service Connector` を導入する方法について解説します。  
（※記事作成時の Vantiq バージョン： r1.40.13）

## 前提条件

Organization に `GenAI Flow Service Connector` を導入するには `Organization Admin` 権限が必要になります。

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
