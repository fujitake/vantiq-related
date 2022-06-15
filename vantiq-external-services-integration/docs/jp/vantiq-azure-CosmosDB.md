# はじめに
Vantiqから直接Azure CosmosDBのAPIと連携する方法を説明する。  
VantiqのProcedureからCosmosDBへ
- document(データレコード)の作成
- document一覧の取得
- クエリーを利用し特定のdocumentを取得  

を行う方法を説明する。

## 動作条件
Vantiq Server v1.34以降

# CosmosDB の構成
本手順ではCosmos DBのAPIを **コア「SQL」** で作成した場合の連携方法を説明する。  
他のAPIを選択して作成した場合は各リファレンスを参照して必要に応じて変更。

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

CosmosDBへのdocumentの作成には重複しないIDを指定する必要がある。  
以下の例ではdocumentを登録する際に必要なIDを{センサーID}_{UNIX時間}として生成している。  

**注意:**  
リファレンスにはidが自動作成される表記があるが、それはSDKの場合のみであり、**REST APIを直接利用する場合は該当しない**模様  
=> idを生成する処理が必要  
参照: [No ID supplied on POST = One of the specified inputs is invalid](https://social.msdn.microsoft.com/Forums/en-US/743f610b-ee53-4461-8d0e-108d72c8dd6c/no-id-supplied-on-post-one-of-the-specified-inputs-is-invalid?forum=azurecosmosdb)

```
PROCEDURE createDocument()

var REQUEST_METHOD = "POST"
var RESOURCE_TYPE = "docs"
var RESOURCE_ID = "dbs/Vantiq/colls/sensors"
var MASTER_KEY = "<INPUT-YOUR-COSMOSDB-PRIMARY-KEY>"

// Test sensor data
var SENSOR_ID = "sensor_1"
var TEMPERATURE = 17.2

var now = now()
var date = format("{0, date,EEE',' dd MMM yyyy HH:mm:ss 'GMT'}",now)

var token = getAuthorizationTokenUsingMasterKey(REQUEST_METHOD, RESOURCE_TYPE, RESOURCE_ID, date, MASTER_KEY)

var body = {
    "id": SENSOR_ID + "_" + toString(date(now, "date", "epochMilliseconds")),
    "sensor_id": SENSOR_ID,
    "temperature": TEMPERATURE
}

var header = {
    "Accept": "application/json",
    "Authorization": token,
    "x-ms-date": date,
    "x-ms-version": "2018-12-31",
    "x-ms-documentdb-partitionkey": "[\"" + SENSOR_ID + "\"]"  
}

var requestPath = "/" + RESOURCE_ID + "/docs"

SELECT * FROM SOURCE CosmosDB WITH method = REQUEST_METHOD, headers = header, body = body, path = requestPath

```

Procedureを実行すると以下のような結果が返ってくる。
```json
[
   {
      "id": "sensor_1_1650619266361",
      "sensor_id": "sensor_1",
      "temperature": 17.2,
      "_rid": "02MwAIrnwS0OAAAAAAAAAA==",
      "_self": "dbs/02MwAA==/colls/02MwAIrnwS0=/docs/02MwAIrnwS0OAAAAAAAAAA==/",
      "_etag": "\"0200300c-0000-0700-0000-626273820000\"",
      "_attachments": "attachments/",
      "_ts": 1650619266
   }
]
```

Azure Portalからも作成したsensorsコンテナーのItemsに上記documentが格納されていることを確認できる。

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

Procedureを実行すると以下のように作成したdocumentの一覧を取得できる。

```json
[
   {
      "_rid": "02MwAIrnwS0=",
      "Documents": [
         {
            "id": "sensor_1_1650619266361",
            "sensor_id": "sensor_1",
            "temperature": 17.2,
            "_rid": "02MwAIrnwS0OAAAAAAAAAA==",
            "_self": "dbs/02MwAA==/colls/02MwAIrnwS0=/docs/02MwAIrnwS0OAAAAAAAAAA==/",
            "_etag": "\"0200300c-0000-0700-0000-626273820000\"",
            "_attachments": "attachments/",
            "_ts": 1650619266
         }
      ],
      "_count": 1
   }
]
```


### クエリを利用して特定のdocumentを取得

クエリを利用したdocumentの取得を行うProcedureを作成する。

参考: [Query Documents - Azure Cosmos DB REST API | Microsoft Docs](https://docs.microsoft.com/en-us/rest/api/cosmos-db/query-documents) 

```
PROCEDURE queryDocument()

var REQUEST_METHOD = "POST"
var RESOURCE_TYPE = "docs"
var RESOURCE_ID = "dbs/Vantiq/colls/sensors"
var MASTER_KEY = "<INPUT-YOUR-COSMOSDB-PRIMARY-KEY>"

var QUERY_BODY = {
    "query": "SELECT * FROM Items c WHERE c.sensor_id = \"sensor_1\"",
    "parameters": []
}

var now = format("{0, date,EEE',' dd MMM yyyy HH:mm:ss 'GMT'}",now())

var token = getAuthorizationTokenUsingMasterKey(REQUEST_METHOD, RESOURCE_TYPE, RESOURCE_ID, now, MASTER_KEY)

var header = {
    "Accept": "application/json",
    "Authorization": token,
    "x-ms-date": now,
    "x-ms-version": "2018-12-31",
    "x-ms-documentdb-isquery": "true" ,
    "x-ms-documentdb-query-enablecrosspartition": "true"
}

var requestPath = "/" + RESOURCE_ID + "/docs"

SELECT * FROM SOURCE CosmosDB WITH method = REQUEST_METHOD, headers = header, body = stringify(QUERY_BODY), path = requestPath, contentType = "application/query+json"

```

Procedureを実行すると以下のようなにクエリに該当するdocumentを取得できる。  

```json
[
   {
      "_rid": "02MwAIrnwS0=",
      "Documents": [
         {
            "id": "sensor_1_1650619266361",
            "sensor_id": "sensor_1",
            "temperature": 17.2,
            "_rid": "02MwAIrnwS0OAAAAAAAAAA==",
            "_self": "dbs/02MwAA==/colls/02MwAIrnwS0=/docs/02MwAIrnwS0OAAAAAAAAAA==/",
            "_etag": "\"0200300c-0000-0700-0000-626273820000\"",
            "_attachments": "attachments/",
            "_ts": 1650619266
         },
         {
            "id": "sensor_1_1650619277842",
            "sensor_id": "sensor_1",
            "temperature": 17.7,
            "_rid": "02MwAIrnwS0PAAAAAAAAAA==",
            "_self": "dbs/02MwAA==/colls/02MwAIrnwS0=/docs/02MwAIrnwS0PAAAAAAAAAA==/",
            "_etag": "\"0200320c-0000-0700-0000-6262738d0000\"",
            "_attachments": "attachments/",
            "_ts": 1650619277
         }
      ],
      "_count": 2
   }
]
```

**補足:**    
Vantiqはapplication/query+jsonのContent-Typeに対応していない。(2022/4/25現在）  
そのため、上記の実装では以下を行っている。
- SELECT分のcontentTyeパラメータで"**application/query+json**"を渡す
- application/query+jsonの場合、**bodyをJSONと認識しないので、stringify()でString化**する
