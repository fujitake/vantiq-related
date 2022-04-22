# はじめに
Vantiqから直接Azure CosmosDBのAPIと連携する方法を説明する。  
VantiqのProcedureからCosmosDBへドキュメント(データレコード)の作成とドキュメント一覧の取得を行う。

## 動作条件
Vantiq Server v1.34以降

# CosmosDB の構成
本手順ではCosmos DBのAPIを **コア「SQL」** で作成した場合の連携方法を説明する。  
他のAPIを選択して作成した場合は各ドキュメントを参照して必要に応じて変更。

Cosmos DBの作成ができたら「コンテナーの追加」からコンテナーを作成する。設定は以下の通り。
- Database id  
  - 「Create New」を選択し以下を入力
    - Vantiq
- Container id  
  - sensors
- Partition key
  - /sensor_id
 
OKボタンをクリックしコンテナを作成する。

## URIとkeyの取得

APIを利用するためにURIとkeyを **設定 > キー** から取得する。  
**URI** と **プライマリキー** の値をひかえておく。


# Vantiq リソースの作成

## Sourceの作成
以下のSourceを作成する。
- Source Name
  - CosmosDB
- Source Type
  - REMOTE
- Server URI
  - 確認したCosmosDBのURI

## Procedureの作成

### API呼び出しに必要なハッシュ値計算

Azure CosmosDB のAPI呼び出しにはAuthorizationヘッダーにハッシュ値を計算したシグネチャを含めなければいけないため、その値を生成するProcedureを作成しておく。  
生成方法の詳細は[Access control in the Azure Cosmos DB SQL API - Azure Cosmos DB REST API | Microsoft Docs](https://docs.microsoft.com/en-us/rest/api/cosmos-db/access-control-on-cosmosdb-resources)を参照。


```
PROCEDURE getAuthorizationTokenUsingMasterKey(verb, resourceType, resourceId, date, masterKey)

var TYPE = "master"
var VERSION = "1.0"

var key = Decode.base64Raw(masterKey)

var text = ""
text += verb ? (verb.toLowerCase() + "\n") : "\n"
text += resourceType ? (resourceType.toLowerCase() + "\n") : "\n"
text += resourceId ? (resourceId + "\n") : "\n"
text += date ? (date.toLowerCase() + "\n") : "\n"
text += "\n"

var signature = Hash.hmacSha256(key, text)
signature = Encode.base64(signature)
var token = "type=" + TYPE + "&ver=" + VERSION + "&sig=" + signature
token = encodeUriComponent(token)
return token

```

こちらのProcedureを以下のAPI呼び出しを行うProcedure内で呼び出していく。

### documentを作成

documentの作成(CosmosDBへレコードの登録)を行うProcedureを作成する。  
参考: [Create Document - Azure Cosmos DB REST API | Microsoft Docs](https://docs.microsoft.com/en-us/rest/api/cosmos-db/create-a-document)

```
PROCEDURE createDocument()

var REQUEST_METHOD = "POST"
var RESOURCE_TYPE = "docs"
var RESOURCE_ID = "dbs/Vantiq/colls/sensors"
var MASTER_KEY = "<INPUT-YOUR-COSMOSDB-PRIMARY-KEY>"

var now = format("{0, date,EEE',' dd MMM yyyy HH:mm:ss 'GMT'}",now())

var tokem = getAuthorizationTokenUsingMasterKey(REQUEST_METHOD, RESOURCE_TYPE, RESOURCE_ID, now, MASTER_KEY)

var body = {
    "id": "1",
    "sensor_id": "sensor_1",
    "temperature": 19.5
}

var header = {
    "Accept": "application/json",
    "Authorization": token,
    "x-ms-date": now,
    "x-ms-version": "2018-12-31",
    "x-ms-documentdb-partitionkey": "[\"sensor_1\"]"  
}

var requestPath = "/" + RESOURCE_ID + "/docs"

SELECT * FROM SOURCE CosmosDB WITH method = REQUEST_METHOD, headers = header, body = body, path = requestPath

```

Procedureを実行すると以下のような結果が返ってくる。
```json
[
   {
      "id": "1",
      "sensor_id": "sensor_1",
      "temperature": 19.5,
      "_rid": "02MwAIrnwS0FAAAAAAAAAA==",
      "_self": "dbs/02MwAA==/colls/02MwAIrnwS0=/docs/02MwAIrnwS0FAAAAAAAAAA==/",
      "_etag": "\"0000d69a-0000-0700-0000-62610d1a0000\"",
      "_attachments": "attachments/",
      "_ts": 1650527514
   }
]
```

Azure Portalからも作成したsensorsコンテナーのItemsに上記ドキュメントが格納されていることを確認できる。

### documentを取得

documentの一覧を取得するProcedureを作成する。  
参考: [List Documents - Azure Cosmos DB REST API | Microsoft Docs](https://docs.microsoft.com/en-us/rest/api/cosmos-db/list-documents)  

```
PROCEDURE listDocuments()

var REQUEST_METHOD = "GET"
var RESOURCE_TYPE = "docs"
var RESOURCE_ID = "dbs/Vantiq/colls/sensors"
var MASTER_KEY = "<INPUT-YOUR-COSMOSDB-PRIMARY-KEY>"

var now = format("{0, date,EEE',' dd MMM yyyy HH:mm:ss 'GMT'}",now())

var token = getAuthorizationTokenUsingMasterKey(REQUEST_METHOD, RESOURCE_TYPE, RESOURCE_ID, now, MASTER_KEY)

var header = {
    "Accept": "application/json",
    "Authorization": token,
    "x-ms-date": now,
    "x-ms-version": "2018-12-31"
}

var requestPath = "/" + RESOURCE_ID + "/docs"
SELECT * FROM SOURCE CosmosDB WITH method = REQUEST_METHOD, headers = header, path = requestPath

```

Procedureを実行すると以下のように作成したDocumentの一覧を取得できる。

```json
[
   {
      "_rid": "02MwAIrnwS0=",
      "Documents": [
         {
            "id": "1",
            "sensor_id": "sensor_1",
            "temperature": 19.5,
            "_rid": "02MwAIrnwS0FAAAAAAAAAA==",
            "_self": "dbs/02MwAA==/colls/02MwAIrnwS0=/docs/02MwAIrnwS0FAAAAAAAAAA==/",
            "_etag": "\"0000d69a-0000-0700-0000-62610d1a0000\"",
            "_attachments": "attachments/",
            "_ts": 1650527514
         }
      ],
      "_count": 1
   }
]
```

# 既知の問題
## 1. Query Documentsには未対応
Vantiq未対応のリクエストのContent-Typeヘッダーが使えない。  
Query DocumentsにはContent-Typeに「application/query+json」を指定しなければいけない。  
bodyに以下のようなSQLクエリを指定してdocumentを取得できるが、Content-Typeヘッダーに「application/query+json」を指定する必要がある。  
Vantiqでは未対応(指定してもapplication/jsonに置き換えられてしまう)のためエラーで取得できない。  

```json
// サンプルのbody
{
    "query": "SELECT * FROM Items c WHERE c.sensor_id = @subId",
    "parameters": [
        {
            "name": "@subId",
            "value": "sensor_1"
        }
    ]
}
```

参考: [Query Documents - Azure Cosmos DB REST API | Microsoft Docs](https://docs.microsoft.com/en-us/rest/api/cosmos-db/query-documents)


以下のようにPostmanEchoを利用してリクエストを確認すると、application/query+jsonがapplication/jsonに置き換えられてしまっていることが確認できる。

- 呼び出しProcedure
```
PROCEDURE queryDocument()

var REQUEST_METHOD = "POST"
var RESOURCE_TYPE = "docs"
var RESOURCE_ID = "dbs/Vantiq/colls/sensors"
var MASTER_KEY = "<INPUT-YOUR-COSMOSDB-PRIMARY-KEY>"

var now = format("{0, date,EEE',' dd MMM yyyy HH:mm:ss 'GMT'}",now())

var sig = getAuthorizationTokenUsingMasterKey(REQUEST_METHOD, RESOURCE_TYPE, RESOURCE_ID, now, MASTER_KEY)
var token = "type=master&ver=1.0&sig=" + sig

var body = {
    "query": "SELECT * FROM Items c WHERE c.id = \"1\"",
    "parameters": []
}

var header = {
    "Accept": "application/json",
    "Content-Type": "application/query+json",
    "Authorization": token,
    "x-ms-date": now,
    "x-ms-version": "2018-12-31",
    "x-ms-documentdb-isquery": "true" ,
    "x-ms-documentdb-query-enablecrosspartition": "true"
}

var requestPath = "/" + RESOURCE_ID + "/docs"

SELECT * FROM SOURCE PostmanEcho WITH method = REQUEST_METHOD, headers = header, body = body

```

- PostmanEchoからの返り値
```json
[
   {
      "args": {},
      "data": {
         "query": "SELECT * FROM Items c WHERE c.id = \"1\"",
         "parameters": []
      },
      "files": {},
      "form": {},
      "headers": {
         "x-forwarded-proto": "https",
         "x-forwarded-port": "443",
         "host": "postman-echo.com",
         "x-amzn-trace-id": "Root=1-62612939-6f641ca5370035f613e4b2a1",
         "content-length": "68",
         "user-agent": "Vantiq/1.34.0-SNAPSHOT",
         "accept": "application/json",
         "authorization": "type=master&ver=1.0&sig=g+TKhF/oxSrH+msGZNYN2HQbCEELQo+muvDOR5CLsAo=",
         "x-ms-date": "Thu, 21 Apr 2022 09:51:53 GMT",
         "x-ms-version": "2018-12-31",
         "x-ms-documentdb-isquery": "true",
         "x-ms-documentdb-query-enablecrosspartition": "true",
         "content-type": "application/json"
      },
      "json": {
         "query": "SELECT * FROM Items c WHERE c.id = \"1\"",
         "parameters": []
      },
      "url": "https://postman-echo.com/post"
   }
]

```

