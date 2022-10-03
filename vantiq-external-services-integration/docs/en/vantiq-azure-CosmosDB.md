# Introduction
Describe how to collaborate with Azure Cosmos DB APIs directly from Vantiq.  
In this document, describe how to do the following from Vantiq's Procedures to Cosmos DB.  
- Create Documents (data records)  
- Retrieve a list of Documents  
- Retrieve the specific documents with a query   


## Prerequisites
Vantiq Server v1.34 or higher is required  

# Configuration of Cosmos DB
This procedure describes how to collaborate with the Cosmos DB API when it is created with **core "SQL"**.  
If created by selecting other APIs, refer to the respective references and modify as necessary.  

Once Cosmos DB created, create a container from [New Container]. The settings are the followings.  
- Database id  
  - Select "Create new" and provide the following.  
    - Vantiq
- Container id  
  - sensors
- Partition key
  - /sensor_id

Click [OK] button to create the container.  

## Get the value of URI and Key

Get the both URI and Key from **Settings > Keys** to use the API.    
Make a note of the value of both **URI** and **Primary Key**.  


# Create Vantiq Resources

## Create Source
Create the Source with the following settings.  
- Source Name
  - CosmosDB
- Source Type
  - REMOTE
- Server URI
  - Confirmed Cosmos DB URI

## Create Procedures

### Calculate hash values required for API calls

Since API calls to Azure Cosmos DB should include the signature with a calculated hash value in the Authorization header, the Procedure should be created to generate that value.  
As for the details of generation method, refer to [Access control in the Azure Cosmos DB SQL API - Azure Cosmos DB REST API | Microsoft Docs](https://docs.microsoft.com/en-us/rest/api/cosmos-db/access-control-on-cosmosdb-resources).  


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

This Procedure will be called within the Procedure that makes the following API call.  

### Create Document

Create the Procedure that creates a Document (registers records to Cosmos DB).  
Reference: [Create Document - Azure Cosmos DB REST API | Microsoft Docs](https://docs.microsoft.com/en-us/rest/api/cosmos-db/create-a-document)  

It is necessary to specify an ID that does not duplicate when creating a document to CosmosDB.    
In the following example, the ID required for registering a document is generated as {sensor ID}_{UNIX time}.    

**Caution:**  
The reference says that the id is automatically created, but that is only for the SDK, **not for direct use of the REST API**.  
=> Need process to generate id.    
Reference: [No ID supplied on POST = One of the specified inputs is invalid](https://social.msdn.microsoft.com/Forums/en-US/743f610b-ee53-4461-8d0e-108d72c8dd6c/no-id-supplied-on-post-one-of-the-specified-inputs-is-invalid?forum=azurecosmosdb)

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

Executing the Procedure, the following results are returned.  

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

From Azure Portal, it is also possible to confirm that the above document is stored in the Items of the sensors container that was created.  

### Retrieve Documents  

Create the Procedure to retrieve a list of Documents.    
Reference: [List Documents - Azure Cosmos DB REST API | Microsoft Docs](https://docs.microsoft.com/en-us/rest/api/cosmos-db/list-documents)  

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

Once execute the Procedure, it is possible to get the document like the following.

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


### Retrieve the specific documents with a query  

Create the Procedure to retrieve the specific documents with a query.  

Reference: [Query Documents - Azure Cosmos DB REST API | Microsoft Docs](https://docs.microsoft.com/en-us/rest/api/cosmos-db/query-documents)

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

Once execute the Procedure, it is possible to get the document corresponding to the query like the following.  

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

**Remarks:**    
Vantiq does not support Content-Type of application/query+json (as of 4/25/2022).    
Therefore, the above implementation does the followings.  
- Pass "**application/query+json**" as the contentTye parameter of the SELECT statement.  
- With application/query+json, **body is not recognized as JSON, so convert it to a String with stringify()**.
