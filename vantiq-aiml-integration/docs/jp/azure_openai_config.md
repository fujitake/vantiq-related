# Azure OpenAI のモデルを Vantiq で利用する方法

Azure OpenAI でデプロイしたモデルを Vantiq で利用する方法の解説となります。

## 前提条件

- Azure OpenAI で利用したいモデルのデプロイが出来ていること。

## Azure OpenAI の API Key の設定

Azure OpenAI の API Key を Secret として保存します。

OpenAI の API Key と同様に設定していきます。

1. Azure Portal から Azure OpenAI を開きます。

1. `キーとエンドポイント` を開き、 `キー　1` をコピーします。

   ![azure_openai_apikey.png](./../../imgs/azure_openai_config/azure_openai_apikey.png)

1. Vantiq IDE を開き、メニューバーの `管理` -> `Advanced` -> `Secrets` -> `+ 新規` をクリックし Secret の新規作成画面を開きます。

1. コピーした Azure OpenAI の API キーを保存します。

## Generative LLM の設定方法

OpenAI の LLM と同様に設定していきます。

1. Azure Portal から Azure OpenAI を開きます。

1. `キーとエンドポイント` を開き、 `エンドポイント` をコピーします。

   ![azure_openai_endpoint.png](./../../imgs/azure_openai_config/azure_openai_endpoint.png)

1. `モデル デプロイ` を開き、 `展開の管理` をクリックします。

   ![model_deploy.png](./../../imgs/azure_openai_config/model_deploy.png)

1. 任意の `Generative LLM` の `デプロイ名` をコピーします。

   ![generative_model.png](./../../imgs/azure_openai_config/generative_model.png)

   > **補足**  
   > デプロイ済みのモデルが存在しない場合は、 `+ 新しいデプロイの作成` からモデルをデプロイしてください。

1. Vantiq IDE を開き、メニューバーの `追加` -> `LLMs` -> `+ 新規` をクリックし LLM の追加画面を開きます。

1. 以下の内容を設定し、 `OK` をクリックします。

   |項目|設定値|
   |-|-|
   |LLM Name|※任意の名前|
   |Type|Generative|
   |Model Name|※任意のモデル|
   |config|※下記参照|
   |API Key Secret|※Azure OpenAI の Secret|

   **config の設定値**

   ```json
   {
       "class_name": "langchain.chat_models.AzureChatOpenAI"
       , "azure_deployment": "【Azure OpenAI のデプロイ名】"
       , "azure_endpoint": "【Azure OpenAI のエンドポイント】"
       , "openai_api_version": "2023-05-15"
   }
   ```

   ![generative_config.png](./../../imgs/azure_openai_config/generative_config.png)

## Embedding LLM の設定方法

OpenAI の LLM と同様に設定していきます。

1. Azure Portal から Azure OpenAI を開きます。

1. `キーとエンドポイント` を開き、 `エンドポイント` をコピーします。

   ![azure_openai_endpoint.png](./../../imgs/azure_openai_config/azure_openai_endpoint.png)

1. `モデル デプロイ` を開き、 `展開の管理` をクリックします。

   ![model_deploy.png](./../../imgs/azure_openai_config/model_deploy.png)

1. 任意の `Embedding LLM` の `デプロイ名` をコピーします。

   ![embedding_model.png](./../../imgs/azure_openai_config/embedding_model.png)

   > **補足**  
   > デプロイ済みのモデルが存在しない場合は、 `+ 新しいデプロイの作成` からモデルをデプロイしてください。

1. Vantiq IDE を開き、メニューバーの `追加` -> `LLMs` -> `+ 新規` をクリックし LLM の追加画面を開きます。

1. 以下の内容を設定し、 `OK` をクリックします。

   |項目|設定値|
   |-|-|
   |LLM Name|※任意の名前|
   |Type|Embedding|
   |Model Name|※任意のモデル|
   |config|※下記参照|
   |API Key Secret|※Azure OpenAI の Secret|

   **config の設定値**

   ```json
   {
       "class_name": "langchain.embeddings.AzureOpenAIEmbeddings"
       , "azure_deployment": "text-embedding-ada-002"
       , "azure_endpoint": "https://dev-openai-japaneast.openai.azure.com/"
       , "openai_api_version": "2023-05-15"
   }
   ```

   ![embedding_config.png](./../../imgs/azure_openai_config/embedding_config.png)
