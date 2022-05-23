## Overview
This article explains the necessary configurations and integration methods to populate DynamoDB from Vantiq via REST API.

## Configurations
DynamoDB does not have an endpoint to the public, so it is accessed via API Gateway.  
•	Vantiq Cloud (Public)  
•	AWS Dynamo DB  
•	AWS API Gateway  

![Screen Shot 2021-09-05 at 16.35.50](../../imgs/vantiq-aws-dynamodb/overview.png)


### Prerequisite
•	It is assumed that store the data processed in the Vantiq externally as time series data. Therefore, this document only covers the write process.

 
### Configure DynamoDB
Create a table. Set the following keys in consideration of the general use of the API.  
- Partition key = id
- Sort key = timestamp  
![Picture1](../../imgs/vantiq-aws-dynamodb/picture1.png)

### Create a Table Group (Optional)
For ease of management, create a table group for each application, and add the table to the group. This has nothing to do with REST API operations, so it is not necessary to do so.  

![Screen Shot 2021-09-06 at 10.12.35](../../imgs/vantiq-aws-dynamodb/picture2.png)

### Create an IAM Role
Create an IAM Role to operate DynamoDB from API Gateway.

#### Create a Policy
Create a policy named `DynamoDBWriteItem`. Since it inserts into DynamoDB, at least `dynamodb:PutItem` is required in Action.
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "dynamodb:PutItem",
            "Resource": "*"
        }
    ]
}
```

#### Create a Role
Create the DynamoDBWriteItem role and attach the DynamoDBWriteItem policy created in the previous step.  
![picture3](../../imgs/vantiq-aws-dynamodb/picture3.png)

Make a note of the ARN of the created role.  
e.g. `arn:aws:iam::XXXXXXXXX:role/DynamoDBWriteItem`


### Create an API Gateway
#### Basic configuration of API Gateway
Select the REST API. The REST API allows the backend to be an Amazon service (it is not possible with HTTP API).  
![picture4](../../imgs/vantiq-aws-dynamodb/picture4.png)


Select REST as the protocol.
The API name can be something appropriate.  
![picture5](../../imgs/vantiq-aws-dynamodb/picture5.png)



Configure child resources if necessary (the following is configured in the root resource).　
- AWS Region: Region in which DynamoDB is configured
- AWS Service: DynamoDB
- HTTP method: POST (refer to [DynamoDB REST API](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_PutItem.html))
- Action: PutItem (refer to [DynamoDB REST API](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_PutItem.html))
- Execution role: ARN of the created role
- Content Handling: Passthrough (pass the Body as it is to the DynamoDB API)

![picture6](../../imgs/vantiq-aws-dynamodb/picture6.png)

Execute the test.  
![picture7](../../imgs/vantiq-aws-dynamodb/picture7.png)  
![picture8](../../imgs/vantiq-aws-dynamodb/picture8.png)

JSON to be input (as for the format, refer to [API Reference](https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_PutItem.html)).
```json
{
  "TableName": "pump-status",
  "Item": {
    "id": {
      "S": "sensorID"
    },
    "timestamp": {
      "S": "2021-05-27T05:51:04.081Z"
    },
    "temp" : {
      "N": "30.56"
    },
    "rpms" : {
      "N": "4202"
    }
  }
}
```

Confirm that the insertion has been made with the DynamoDB console.  
![picture9](../../imgs/vantiq-aws-dynamodb/picture9.png)


Configure an API key (Optional)  
Create an API key to restrict access.  
![picture10](../../imgs/vantiq-aws-dynamodb/picture10.png)


"Name" can be anything.  
![picture11](../../imgs/vantiq-aws-dynamodb/picture11.png)

Make a note of the API key created.  
e.g. `S4yNrDKZhK4CBahm6axGe7BvwU4 XXXXXXXXXXXXX`

Set the API key as required.  
![picture12](../../imgs/vantiq-aws-dynamodb/picture12.png)


#### Deploy the API
Deploy the API.

![picture13](../../imgs/vantiq-aws-dynamodb/picture13.png)


Stage name: "Stage Name" can be anything. Here, it is "Test".

![picture14](../../imgs/vantiq-aws-dynamodb/picture14.png)  
![picture15](../../imgs/vantiq-aws-dynamodb/picture15.png)



After deploying, make a note of the API endpoint.  
e.g. `https://y39oxxxxxx.execute-api.ap-northeast-1.amazonaws.com/test`
 
### Create the Vantiq Source (REMOTE)

#### Create a Schema Type (Optional)
Define Schema Type as it makes easier to map properties.  
Both `id` and `timestamp` are Required because they are keys.  
![picture16](../../imgs/vantiq-aws-dynamodb/picture16.png)


#### Create a Source
Create a Source to connect to DynamoDB (API Gateway).  
- Source Type: `REMOTE`  
![picture17](../../imgs/vantiq-aws-dynamodb/picture17.png)
- Server URI: Endpoint of the deployed API Gateway
- Content Type: application/json
- Header: JSON
  - x-api-key: The API Key which was created  
![picture18](../../imgs/vantiq-aws-dynamodb/picture18.png)

 The following is the result of "Edit Config as JSON."
```json
{
    "pollingInterval": 0,
    "uri": "https://xxxxxxxx.execute-api.ap-northeast-1.amazonaws.com/test",
    "query": {},
    "requestDefaults": {
        "contentType": "application/json",
        "headers": {
            "x-api-key": "S4yNrDKZhK4CBahm6axxxxxxxxxxxx"
        }
    }
}
```

#### Create a Procedure (Optional)
Create a Procedure that calls the API to insert into the table.
In the following example, it is assumed that insertions into a large number of tables will to be made utility, by adding the Service prefix of "DynamoDB".
```
PROCEDURE DynamoDB.insertSensorStatus(status SensorStatus)

var msg = {
  "TableName": "pump-status",
  "Item": {
    "id": {
      "S": status.id
    },
    "timestamp": {
      "S": status.timestamp
    },
    "temp" : {
      "N": status.temp.toString()    // DynamoDB API only accepts String Literal
    },
    "rpms" : {
      "N": status.rpms.toString()    // DynamoDB API only accepts String Literal
    }
  }
}

PUBLISH { body: msg } to SOURCE DynamoDBSource USING { method: "POST"}
```

#### Connectivity test
Test connectivity by running the Procedure.  
![picture19](../../imgs/vantiq-aws-dynamodb/picture19.png)


Confirm that the insertion has been made.  
![picture20](../../imgs/vantiq-aws-dynamodb/picture20.png)


### Others

#### For configuring TTL
In the case of DynamoDB, records cannot be deleted in bulk.  Set the TTL to have unnecessary records deleted periodically.
The following code example calculates the unix epoch time 30 days after the current date and adds it as a `ttl` column. It is necessary to configure the TTL accordingly on the DynamoDB side.

```vail
var ttl = now().plusMillis(30 days)

var msg = {
  "TableName": "pump-status",
  "Item": { 
        "id": {
          "S": toString(status.PumpID)
        },
        "timestamp": {
          "S": status.ReceivedAt
        },
        "temp" : {
          "N": status.Temp.toString()    // DynamoDB API only accepts String Literal
        },
        "rpms" : {
          "N": status.RPMS.toString()    // DynamoDB API only accepts String Literal
        },
        "ttl" : {
            "N": date(ttl, "date", "epochMilliseconds").toString() // for  periodically deleting records
        }
    }
}
```
#### Sample code for generic Procedure
The following is the sample code for Procedure. It can be used for general purpose by passing the table name `tableName`, key column `keyCol`, timestamp column `tsCol`, JSON object `obj`, and TTL time (in milliseconds) `ttl`.
It is assumed that the table is created on the DynamoDB side with `id` = Partition key, `timestamp` = Sort key.

```vail
PROCEDURE DynamoDB.insert(tableName String, keyCol String, tsCol String, obj Object, ttl Integer)
 
// include required columns
var record = {
  "TableName": tableName,
  "Item": { 
        "id": {
          "S": toString(obj[keyCol])
        },
        "timestamp": {
          "S": toString(obj[tsCol])
        },
        "ttl" : {
          "N": toString(date(now().plusMillis(ttl), "date", "epochMilliseconds"))    // for  periodically deleting records
        }
    }
}

// include other columns
deleteKey(obj, keyCol)
deleteKey(obj, tsCol)

// populate items from obj
record.Item = DynamoDB.convertToItem(obj, record.Item)

PUBLISH { body: record } to SOURCE DynamoDBSource USING { method: "POST"}
```
```vail
PROCEDURE DynamoDB.convertToItem(obj Object, item Object)

for prop in obj {
    if typeOf(prop.value) == "Integer" or typeOf(prop.value) == "Real" or typeOf(prop.value) == "Decimal"{
        item[prop.key] = {"N": toString(prop.value) }
    } 
    else if typeOf(prop.value) == "String" or typeOf(prop.value) == "DateTime"{
        item[prop.key] = {"S": toString(prop.value) }
    } 
    else if typeOf(prop.value) == "Boolean" {
        item[prop.key] = {"BOOL": toString(prop.value) }
    } 
    else if typeOf(prop.value) == "GeoJSON" or typeOf(prop.value) == "Object"{
        item[prop.key] = {"M": DynamoDB.convertToItem(prop.value, {} ) }
    } 
    else if typeOf(prop.value) == "List" {
               
        if typeOf(prop.value[0]) == "Integer" or typeOf(prop.value[0]) == "Real" 
          or typeOf(prop.value[0]) == "Decimal"{            
            var ns = []
            for n in prop.value {
                push(ns, toString(n)) 
            }
            item[prop.key] = {"NS": ns}
        } 
        else if typeOf(prop.value[0]) == "String"   {
            item[prop.key] = {"SS": prop.value }
        } 
        else if typeOf(prop.value[0]) == "Object" or typeOf(prop.value[0]) == "List" 
            or typeOf(prop.value[0]) == "GeoJSON" or typeOf(prop.value[0]) == "DateTime" {
            var ss = []
            for s in prop.value {
                push(ss, stringify(s)) 
            }
            item[prop.key] = {"SS": ss}
        } 
    }
}

return item
```
 
## Reference
•	https://blog.yuu26.com/api-gateway-dynamodb-json/     _(Japanese)_
