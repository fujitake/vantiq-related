# VAIL 入門（外部へのデータ送信）

**VAIL** を用いて外部にデータを送信する方法を解説します。  

## 目次

- [VAIL 入門（外部へのデータ送信）](#vail-入門外部へのデータ送信)
  - [目次](#目次)
  - [データ送信・取得](#データ送信取得)
    - [MQTTブローカーへの送信イメージ](#mqttブローカーへの送信イメージ)
  - [HTTP](#http)
    - [HTTP Remote Source の設定](#http-remote-source-の設定)
    - [GET リクエスト](#get-リクエスト)
    - [GET リクエスト（パスパラメータ）](#get-リクエストパスパラメータ)
    - [GET リクエスト（クエリパラメータ）](#get-リクエストクエリパラメータ)
    - [GET リクエスト（ヘッダー）](#get-リクエストヘッダー)
    - [POST リクエスト（SELECT 文）](#post-リクエストselect-文)
    - [POST リクエスト（PUBLISH 文）](#post-リクエストpublish-文)
    - [POST リクエスト（USING 句）](#post-リクエストusing-句)
    - [POST リクエスト（USING 句なし）](#post-リクエストusing-句なし)
    - [PUBLISH 文の注意点](#publish-文の注意点)
  - [MQTT、AMQP、Kafka](#mqttamqpkafka)
    - [MQTT Source の設定](#mqtt-source-の設定)
    - [MQTT ブローカーへのパブリッシュ](#mqtt-ブローカーへのパブリッシュ)
    - [注意点](#注意点)
  - [備考](#備考)
    - [Source を変数に置き換える場合](#source-を変数に置き換える場合)
  - [実装サンプル](#実装サンプル)

## データ送信・取得

外部のブローカーへのデータ送信や他サービスの API を実行する際に、使用する構文についての説明です。  
プロトコルごとに一部異なる部分がありますが、基本的な構文は同じです。  
PUBLISH 文 と SELECT 文を使用することができます。  

### MQTTブローカーへの送信イメージ

![mqtt](./imgs/mqtt.gif)

## HTTP

まずは、 HTTP Remote Source を作成し、 HTTP の GET リクエストや POST リクエストを試してみます。  

### HTTP Remote Source の設定

ナビゲーションメニューの `追加` → `Source` から `新規 Source` をクリックします。  
下記の内容を設定します。  

#### General

|設定項目|設定値|
|:---|:---|
|Source Name|VantiqRender|
|Source Type|REMOTE|

#### Properties

|設定項目|設定値|
|:---|:---|
|Server URI|https://vantiq.onrender.com|

> **補足**  
> 上記の API は Python FastAPI で作成した API サンプルになります。  
> [Render](https://render.com/) という外部サービスで動作しています。  
> なお、サンプル API のコードは [こちら](./data/VantiqApiTestTools.zip) から確認いただけます。

### GET リクエスト

HTTP GET の最もシンプルな例は、次の記述になります。  
この例では `response` に GET した内容が入ります。  

```JavaScript
PROCEDURE get1()

var response = SELECT FROM SOURCE VantiqRender
return response
```

> エンドポイントや Authorization の設定などは Source 側で設定済みです。  
> なお、これらの設定は VAIL 側、 Source 側どちらにでも設定することができます。  

**結果**

```JavaScript
[
   {
      "message": "Hello, world!",
      "timestamp": "2023-08-10T02:27:24.743590"
   }
]
```

### GET リクエスト（パスパラメータ）

次の例では、 VAIL 側に設定値を記述しています。  
`WITH` 句を使うことで、設定値をリクエストに反映させることができます。  

まずは、 `path` を設定してみます。  
`path` を設定すると Souce の `Source URI に設定設定されている URI + path` でリクエストします。  
つまり Source に `https://vantiq.onrender.com` と設定されている場合は `https://vantiq.onrender.com/horoscope` となります。  

```JavaScript
PROCEDURE get2()

var path = "/horoscope"
var response = SELECT FROM SOURCE VantiqRender WITH path = path
return response
```

**結果**

```JavaScript
[
    "山羊座"
]
```

### GET リクエスト（クエリパラメータ）

次に `query` はクエリパラメータを設定してみます。  

```JavaScript
PROCEDURE get3()

var path = "/horoscope"
var query = {
    "month": 12
}
var response = SELECT FROM SOURCE VantiqRender WITH path = path, query = query
return response
```

**結果**

```JavaScript
[
    "魚座"
]
```

### GET リクエスト（ヘッダー）

ヘッダーを設定する場合は、 `headers` を用います。  

```JavaScript
PROCEDURE get4()

var path = "/auth-area"
var headers = {
    "Content-type": "application/json",
    "Authorization": "vantiq-token"
}
var response = SELECT FROM SOURCE VantiqRender WITH path = path, headers = headers
return response
```

**結果**

```JavaScript
[
   "Get OK"
]
```

### POST リクエスト（SELECT 文）

POST したい場合は SELECT 文と PUBLISH 文の両方を使用できます。  

SELECT 文を使用する場合、デフォルトのメソットは `GET` になります。  
POST をしたい場合は `WITH` 句を使用してメソッドに POST を設定します。  
また POST したい内容も設定します。  

```JavaScript
PROCEDURE post1()

var data = {
    id: 1,
    value: "Hello"
}
var response = SELECT FROM SOURCE VantiqRender WITH method = "POST", body = data
```

**結果**

```JavaScript
[
    {
        "message": "Hello, world!",
        "timestamp": "2023-08-10T07:04:40.013170",
        "request": {
            "body": "{\"id\":1,\"value\":\"Hello\"}"
        }
    }
]
```

### POST リクエスト（PUBLISH 文）

PUBLISH 文を使用する場合はデフォルトで POST になります。  
従って、 body 以外の追加設定は必要ありません。  

```JavaScript
PROCEDURE post2()

var data = {
    id: 1,
    value: "Hello"
}
PUBLISH { body: data } TO SOURCE VantiqRender
```

**結果**

```JavaScript
true
```

### POST リクエスト（USING 句）

SELECT 文の時のように設定値を VAIL 側で持たせたい場合は、 WITH 句ではなく `USING` 句を使います。  
WITH 句とは記述方法が異なり、 object 形式を使用します。  
USING 句を使用せず、 body と合わせて1つの Object で記述することもできます。  

```JavaScript
PROCEDURE post3()

var data = {
    id: 1,
    value: "Hello"
}
var config = {
    method: "PUT",
    path: "/anything"
}
PUBLISH { body: data } TO SOURCE VantiqRender USING config
```

**結果**

```JavaScript
true
```

### POST リクエスト（USING 句なし）

USING 句を使わない場合は次のようになります。  

```JavaScript
PROCEDURE post4()

var data = {
    id: 1,
    value: "Hello"
}
PUBLISH { body: data, method: "PUT", path: "/anything" } TO SOURCE VantiqRender
```

**結果**

```JavaScript
true
```

### PUBLISH 文の注意点

PUBLISH 文で注意が必要なのは `{ body: data }` の部分です。  
HTTP POST の場合、 key に `body` が必要です。  
例えば `{ message: data }` などとするとエラーとなります。  

SELECT 文と PUBLISH 文をどう使い分けるかに関しては `返り値` が必要かどうかで決まります。  SELECT 文の場合は GET の時と同様に、レスポンス内容が返り値となります。  
PUBLISH 文は単純に POST が成功したかどうかを `true` か `false` のみで返します。  

PUT や DELETE などこの他のメソッドに関しては、 SELECT 文、 PUBLISH 文いずれもデフォルトのメソッドではありませんので `method` に設定を行って使用してください。  

## MQTT、AMQP、Kafka

次は、 MQTT Source を作成し、 MQTT ブローカーにメッセージを PUBLISH してみます。  
MQTT や AMQP 、 Kafka などのブローカーにメッセージを PUBLISH する際には PUBLISH 文を使用します。  

### MQTT Source の設定

ナビゲーションメニューの `追加` → `Source` から `新規 Source` をクリックします。  
下記の内容を設定します。  

#### General

|設定項目|設定値|
|:---|:---|
|Source Name|VantiqMqttBroker|
|Source Type|MQTT|

#### Server URI

`+ Server URI を追加` をクリックし、下記の内容を設定します。

|設定項目|設定値|
|:---|:---|
|Server URI|mqtt://public.vantiq.com:1883|

> 上記の MQTT ブローカーは、検証用のパブリックなブローカーとなっています。  

### MQTT ブローカーへのパブリッシュ

次の例は MQTT ブローカーに PUBLISH する例です。  
AMQP や Kafka の場合でもほとんど同じ記述になります。  

```JavaScript
PROCEDURE mqtt1()

var data = {
    id: 1,
    value: "Hello"
}
var config = {
    topic: "/test/event"
}
PUBLISH { message: data } TO SOURCE VantiqMqttBroker USING config
//PUBLISH { topic: "/test/event", message: data } TO SOURCE VantiqMqttBroker
```

**結果**

```JavaScript
true
```

送信先となる `topic` の設定が必要となります。  

### 注意点

注意点は HTTP の時と同様に `{ message: data }` の部分です。  
HTTPでは key を `body` にする必要がありましたが、 `MQTT` と `AMQP` の場合は `message` 、 `Kafka` の場合は `value` になります。  

#### プロトコルと Key の一覧表

|プロトコル|Key|
|:---|:---|
|HTTP|body|
|MQTT|message|
|AMQP|message|
|Kafka|value|

## 備考

### Source を変数に置き換える場合

Source を変数に置き換える場合は、下記のように変数名に `@` をつけて使用します。

これは、 SELECT 文でも PUBLISH 文でも利用できます。

```JavaScript
PROCEDURE sourceName1()

var sourceName = "VantiqRender"
var response = SELECT FROM SOURCE @sourceName
return response
```

Procedure で引数を受け取る場合は下記のようになります。

```JavaScript
PROCEDURE sourceName2(sourceName String)

var response = SELECT FROM SOURCE @sourceName
return response
```

:globe_with_meridians: [VAIL Reference Guide ： Variable References](https://dev.vantiq.com/docs/system/rules/index.html#variable-references)

## 実装サンプル

- [VAIL 入門（基礎）の実装サンプル（Vantiq 1.37）](./data/vail_data_1.37.zip)
