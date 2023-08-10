# VAIL データ操作

`VAIL` でデータ操作を行う方法を解説します。  

## 目次

- [VAIL データ操作](#vail-データ操作)
  - [目次](#目次)
  - [データ操作](#データ操作)
    - [Members Type](#members-type)
    - [保持しているデータ（計3件）](#保持しているデータ計3件)
    - [サンプル](#サンプル)
  - [SELECT (取得)](#select-取得)
    - [1. 全件、全プロパティを取得](#1-全件全プロパティを取得)
    - [2. 全件、特定のプロパティを取得](#2-全件特定のプロパティを取得)
    - [3. WHEREによる絞り込み](#3-whereによる絞り込み)
    - [4. 該当するレコードが1件のみと予めわかっている場合](#4-該当するレコードが1件のみと予めわかっている場合)
  - [INSERT (追加)](#insert-追加)
  - [UPDATE (更新)](#update-更新)
  - [UPSERT (既存レコードがない場合はINSERT、既存がある場合はUPDATE)](#upsert-既存レコードがない場合はinsert既存がある場合はupdate)
  - [DELETE (削除)](#delete-削除)
  - [Bulk INSERT (一括追加), Bulk UPSERT (一括追加/更新)](#bulk-insert-一括追加-bulk-upsert-一括追加更新)
    - [Bulk INSERT (一括追加)](#bulk-insert-一括追加)
  - [データ送信・取得](#データ送信取得)
    - [HTTP](#http)
    - [MQTT、AMQP、Kafka](#mqttamqpkafka)
    - [備考](#備考)

## データ操作

Vantiq では下記の SQL のようなクエリを使用して Type に保存されているデータの操作を行うことができます。

- SELECT
- INSERT
- UPDATE
- UPSERT
- DELETE

このセッションでは、以下の `Members` という Type がある仮定で説明を行います。

### Members Type

Members Type のプロパティは次のとおりです。

| プロパティ | 型 | 必須 | ナチュラルキー |　インデックス | ユニーク |
| :---: | :---: | :---: | :---: | :---: | :---: |
| id | Integer | ◯ | ◯ | ◯ | ◯ |
| name | String | ◯ | - | - | - |
| age | Integer | - | - | - | - |

### 保持しているデータ（計3件）

Members Type で保持しているレコードは次のとおりです。

|id|name|age|
|:---:|:---|---:|
|0|Suzuki|21|
|1|Yamada|35|
|3|Tanaka|23|
|4|Yamada|42|

### サンプル

Type のサンプルは [こちら](./data/VailSample_Type.zip) からダウンロードできます。  
Project にインポートして利用してください。  

## SELECT (取得)

### 1. 全件、全プロパティを取得

Members Type から全レコード、全プロパティを取得します。  

```JavaScript
PROCEDURE VailSampleProcedure()

var members = SELECT * FROM Members

return members
```

> **Point**  
> `var members = SELECT FROM members`  
> というように `SELECT` と `FROM` の間の `*` を省略することもできます。

結果

```JavaScript
[
    {
        "_id": "64c8bc976807117ef26b0b53",
        "age": 23,
        "id": 3,
        "name": "Tanaka",
        "ars_namespace": "VAIL",
        "ars_version": 1,
        "ars_createdAt": "2023-08-01T08:04:39.264Z",
        "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143"
    },
    {
        "_id": "64c8bc976807117ef26b0b54",
        "age": 35,
        "id": 1,
        "name": "Yamada",
        "ars_namespace": "VAIL",
        "ars_version": 1,
        "ars_createdAt": "2023-08-01T08:04:39.264Z",
        "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143"
    },
    {
        "_id": "64c8bc976807117ef26b0b55",
        "age": 21,
        "id": 0,
        "name": "Suzuki",
        "ars_namespace": "VAIL",
        "ars_version": 1,
        "ars_createdAt": "2023-08-01T08:04:39.264Z",
        "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143"
    },
    {
        "_id": "64d1d48e6807117ef2841fb4",
        "id": 4,
        "name": "Yamada",
        "age": 42,
        "ars_namespace": "VAIL",
        "ars_version": 1,
        "ars_createdAt": "2023-08-08T05:37:18.438Z",
        "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143"
    }
]
```

> **補足**  
> `_id`、`ars_*` はシステムが自動で付与するプロパティです。

### 2. 全件、特定のプロパティを取得

Member Type から全レコードの `name` プロパティのみを取得します。  

```JavaScript
PROCEDURE VailSampleProcedure()

var members = SELECT name FROM Members

return members
```

結果

```JavaScript
[
    {
        "_id": "64c8bc976807117ef26b0b53",
        "name": "Tanaka"
    },
    {
        "_id": "64c8bc976807117ef26b0b54",
        "name": "Yamada"
    },
    {
        "_id": "64c8bc976807117ef26b0b55",
        "name": "Suzuki"
    },
    {
        "_id": "64d1d48e6807117ef2841fb4",
        "name": "Yamada"
    }
]
```

> **補足**  
> `_id` はこの場合でも含まれてしまいます。
>
> システムプロパティを含みたくない場合は、 `Utils.stripSystemProperties(object)` を用います。  
>
> ```JavaScript
> PROCEDURE VailSampleProcedure()
> 
> var members = SELECT name FROM Members
> var new_members = []
> for(member in members){
>     var new_member = Utils.stripSystemProperties(member)
>     push(new_members, new_member)
> }
> 
> return new_members
> ```
>
> 結果
>
> ```JavaScript
> [
>     {
>         "name": "Tanaka"
>     },
>     {
>         "name": "Yamada"
>     },
>     {
>         "name": "Suzuki"
>     },
>     {
>         "name": "Yamada"
>     }
> ]
> ```

### 3. WHEREによる絞り込み

SELECT 文を使用する際に WHERE 句を使った絞り込みができます。  

WHERE 句の条件に合致するレコードのみを取得します。  

```JavaScript
PROCEDURE VailSampleProcedure()

var members = SELECT id, name FROM Members WHERE id == 1

return members
```

結果

```JavaScript
[
    {
        "_id": "64c8bc976807117ef26b0b54",
        "id": 1,
        "name": "Yamada"
    }
]
```

### 4. 該当するレコードが1件のみと予めわかっている場合

WHERE 句の条件に合致するレコードが、1件だけだとわかっている場合は `SELECT ONE` を使用します。  
通常の `SELECT` は **配列** が戻り値になりますが、 `SELECT ONE` を使用した場合は **Object** が返り値となります。  

```JavaScript
PROCEDURE VailSampleProcedure()

var member = SELECT ONE id, name FROM Members WHERE id == 1

return member
```

結果

```JavaScript
{
    "_id": "64c8bc976807117ef26b0b54",
    "id": 1,
    "name": "Yamada"
}
```

なお、該当するレコードが複数件存在する場合はエラーとなます。  

```JavaScript
PROCEDURE VailSampleProcedure()

var member = SELECT ONE id, name FROM Members WHERE name == "Yamada"

return member
```

Error

```Error
HTTP Status 400 () （WHILE executing Procedure 'VailSampleProcedure'）:

com.accessg2.ag2rs.data.duplicate.object.found: More than one instance of type: Members__VAIL with qual: {name=Yamada} was found.
```

また、該当するレコードが1件も存在しない場合は `null` が返り値となります。  

```JavaScript
PROCEDURE VailSampleProcedure()

var member = SELECT ONE id, name FROM Members WHERE id == 2

return member
```

結果

```JavaScript
null
```

該当する必須の関連データが存在しない場合 `null` を返すのではなく明示的にエラーにしたい場合があります。（例:デバイスから送信されたイベントにセンサーのマスタデータを紐付けたい場合など）

その場合は `SELECT EXACTLY ONE` を使用することでレコードが存在しない場合にエラーを発生させることができます。

```JavaScript
PROCEDURE VailSampleProcedure()

var member = SELECT EXACTLY ONE id, name FROM Members WHERE id == 2

return member
```

Error

```Error
HTTP Status 400 () （WHILE executing Procedure 'VailSampleProcedure'）:

io.vantiq.resource.not.found: The requested instance ('{id=2}') of the Members resource could not be found.
```

![select-one-ex](./imgs/select-one-ex.gif)

## INSERT (追加)

![insert](./imgs/insert.gif)

Members Type に以下のレコードが追加されます。  

|id|name|age|
|:---:|:---:|:---:|
|5|Noah|50|

```JavaScript
PROCEDURE VailSampleProcedure()

var member = {
    id: 5,
    name: "Sato",
    age: 50
}
INSERT Members(member)
```

結果

```JavaScript
{
    "id": 5,
    "name": "Sato",
    "age": 50,
    "ars_namespace": "VAIL",
    "ars_version": 1,
    "ars_createdAt": "2023-08-08T06:14:14.325Z",
    "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143",
    "_id": "64d1dd3697788056d6075c07"
}
```

なお、上記の INSERT 文は次のように書くこともできます。

```JavaScript
PROCEDURE VailSampleProcedure()

INSERT Members(id: 5, name: "Sato", age: 50)
```

今回の Members Type では `age` プロパティは必須項目ではありません。  
そのため、以下のように実行しても処理は成功します。  
必須項目を抜いたり、ユニーク設定をしている項目で既存レコードと重複がある場合はエラーになります。  

```JavaScript
PROCEDURE VailSampleProcedure()

var member = {
    id: 6,
    name: "Nakamura"
}
INSERT Members(member)
```

結果

```JavaScript
{
    "id": 6,
    "name": "Nakamura",
    "ars_namespace": "VAIL",
    "ars_version": 1,
    "ars_createdAt": "2023-08-08T06:25:45.460Z",
    "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143",
    "_id": "64d1dfe96da9080881f0be7e"
}
```

## UPDATE (更新)

![update](./imgs/update.gif)

WHERE句の条件に合致するレコードを全て更新します。  

Members Type の更新されるレコード
|id|name|age|
|:---:|:---:|:---:|
|6|Nakamura|60|

```JavaScript
PROCEDURE VailSampleProcedure()

UPDATE Members(age: 60) WHERE id == 6
```

結果

```JavaScript
{
    "age": 60,
    "ars_modifiedAt": "2023-08-08T06:27:42.723Z",
    "ars_modifiedBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143"
}
```

UPDATE 文は WHERE 句が必須ですが、 INSERT 文のように更新するプロパティを Object で記述することもできます。  

```JavaScript
PROCEDURE VailSampleProcedure()

var member = {
    name: "Taro Yamada",
    age: 70
}
UPDATE Members(member) WHERE id == 4
```

結果

```JavaScript
{
   "name": "Taro Yamada",
   "age": 70,
   "ars_modifiedAt": "2023-08-08T06:36:27.030Z",
   "ars_modifiedBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143"
}
```

## UPSERT (既存レコードがない場合はINSERT、既存がある場合はUPDATE)

![upsert](./imgs/upsert.gif)

Natural Key（ナチュラルキー）を基準として（今回の場合は `id`）、既存レコードがない場合は INSERT され、ある場合は UPDATE されます。  
ナチュラルキーが設定されていない Type に対して UPSERT は使用できません。

`id` が `10` のレコードが存在しない場合に次のVAILを実行するとINSERTされます。

Membets Type に追加されるレコード
|id|name|age|
|:---:|:---:|:---:|
|10|Kaneko|80|

```JavaScript
PROCEDURE VailSampleProcedure()

var member = {
    id: 10,
    name: "Kaneko",
    age: 80
}
UPSERT Members(member)
```

結果

```JavaScript
{
    "id": 10,
    "name": "Kaneko",
    "age": 80,
    "ars_namespace": "VAIL",
    "ars_version": 1,
    "ars_createdAt": "2023-08-08T09:00:04.415Z",
    "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143",
    "_id": "64d2041497788056d60768d6"
}
```

`id 1` のように既にレコードが存在する場合は UPDATE されます。  

Membets Type の更新されるレコード
|id|name|age|
|:---:|:---:|:---:|
|1|Yamada|25|

```JavaScript
PROCEDURE VailSampleProcedure()

var member = {
    id: 1,
    age: 25
}
UPSERT Members(member)
```

結果

```JavaScript
{
    "id": 1,
    "age": 25,
    "ars_modifiedAt": "2023-08-08T09:03:06.312Z",
    "ars_modifiedBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143",
    "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143",
    "ars_createdAt": "2023-08-01T08:04:39.264Z",
    "ars_namespace": "VAIL",
    "ars_version": 1,
    "_id": "64c8bc976807117ef26b0b54"
}
```

UPSERT 文で使用する Object には `ナチュラルキーに設定されたプロパティ` と `更新したい全てのプロパティ` が必要です。  

INSERT 、 UPDATE のように次のように記述することもできます。  

```JavaScript
PROCEDURE VailSampleProcedure()

UPSERT Members(id: 1, age: 28)
```

結果

```JavaScript
{
    "id": 1,
    "age": 28,
    "ars_modifiedAt": "2023-08-08T09:06:02.554Z",
    "ars_modifiedBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143",
    "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143",
    "ars_createdAt": "2023-08-01T08:04:39.264Z",
    "ars_namespace": "VAIL",
    "ars_version": 2,
    "_id": "64c8bc976807117ef26b0b54"
}
```

## DELETE (削除)

![delete](./imgs/delete.gif)

WHERE句の条件に合致するレコードを全て削除します。

Members Type から削除されるレコード
|id|name|age|
|:---:|:---:|:---:|
|5|Sato|50|

```JavaScript
PROCEDURE VailSampleProcedure()

DELETE Members WHERE id == 5
```

結果

```JavaScript
1
```

## Bulk INSERT (一括追加), Bulk UPSERT (一括追加/更新)

**INSERT** や **UPSERT** では、一括でデータの追加や更新ができる **Bulk INSERT** や **Bulk UPSERT** が利用できます。  

### Bulk INSERT (一括追加)

通常の **INSERT 文** と同様に記述し、値を配列で渡します。

```javaScript
PROCEDURE VailSampleProcedure()

var members = [
    {
        id: 11,
        name: "Watanabe",
        age: 38
    }, {
        id: 12,
        name: "Sasaki",
        age: 27
    }, {
        id: 13,
        name: "Kobayashi",
        age: 28
    }
]
INSERT Members(members)
```

結果

```JavaScript
{
    "id": 11,
    "name": "Watanabe",
    "age": 38,
    "ars_namespace": "VAIL",
    "ars_version": 1,
    "ars_createdAt": "2023-08-08T09:16:58.113Z",
    "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143",
    "_id": "64d2080a6da9080881f0c97c"
}
```

#### Bulk UPSERT (一括追加/更新)

通常の **UPSERT 文** と同様に記述し、値を配列で渡します。

```JavaScript
PROCEDURE VailSampleProcedure()

var members = [
    {
        id: 11,
        name: "Watanabe",
        age: 28
    }, {
        id: 12,
        name: "Sasaki",
        age: 17
    }, {
        id: 13,
        name: "Kobayashi",
        age: 18
    }
]
UPSERT Members(members)
```

結果

```JavaScript
{
    "id": 13,
    "name": "Kobayashi",
    "age": 18,
    "ars_modifiedAt": "2023-08-08T09:18:29.389Z",
    "ars_modifiedBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143",
    "ars_createdBy": "e9cc46d7-77cc-4929-8261-40ddceb8b143",
    "ars_createdAt": "2023-08-08T09:16:58.113Z",
    "ars_namespace": "VAIL",
    "ars_version": 1,
    "_id": "64d2080a6da9080881f0c97a"
}
```

## データ送信・取得

外部のブローカーへのデータ送信や他サービスのAPIの実行をする際に使用する構文についての説明です。
プロトコルごとに一部異なる部分がありますが、基本は同じです。PUBLISH文、SELECT文を使用することができます。

**MQTTブローカーへの送信イメージ**

![mqtt](../../imgs/vail-basics/gif/mqtt.gif)

### HTTP

#### GET
---
最もシンプルな例は次のような記述になります。ExternalAPIは`REMOTE` Sourceです。
エンドポイントやAuthorizationはSource側に設定済みです。これらの設定はVAIL側、Source側どちらにでも設定することができます。この例では`response`にGETした内容が入ります。
```JavaScript
var response = SELECT FROM SOURCE ExternalAPI
```

次の例では、VAIL側に設定値を記述しています。`WITH`句を使うことで設定値をリクエストに反映させることができます。`path`を設定するとSouceの`Source URIに設定設定されているURI + path`でリクエストします。つまりSourceに`https://xxxx.com`と設定されている場合は`https://xxxx.com/anything`となります。`headers`はヘッダーの設定、`query`はクエリパラメータです。
```JavaScript
var path = "/anything"
var headers = {
    "Content-type": "application/json",
    "Authorization": "xxxxxxxx"
}
var query = {
    xxx_id: 100
}
var response = SELECT FROM SOURCE ExternalAPI WITH path = path, headers = headers, query = query
```



#### POST
---
POSTしたい場合はSELECT文とPUBLISH文の両方を使用できます。

SELECT文を使用する場合デフォルトではメソットは`GET`になります。POSTしたい場合は`WITH`句を使用してPOSTを設定します。またPOSTしたい内容も設定します。
```JavaScript
var data = {
    id: 1,
    value: "Hello"
}
var response = SELECT FROM SOURCE ExternalAPI WITH method = "POST", body = data
```

PUBLISH文を使用する場合、こちらはデフォルトでPOSTになりますのでbody以外の追加の設定は必要ありません。
```JavaScript
var data = {
    id: 1,
    value: "Hello"
}
PUBLISH { body: data } TO SOURCE ExternalAPI
```

SELECT文の時のように設定値をVAIL側で持たせたい場合はWITH句ではなく`USING`句を使います。WITH句と記述方法が異なり、objectを使用します。USING句を使用せず、bodyと合わせて一つのObjectで書くこともできます。
```JavaScript
var data = {
    id: 1,
    value: "Hello"
}
var config = {
    method: "PUT",
    path: "/anything"
}
PUBLISH { body: data } TO SOURCE ExternalAPI USING config
//PUBLISH { body: data, method: "PUT", path: "/anything" } TO SOURCE ExternalAPI
```

PUBLISH文で注意が必要なのは`{ body: data }`の部分です。HTTP POSTの場合、keyに`body`が必要です。
例えば`{ message: data }`などとするとエラーとなります。

SELECT文とPUBLISH文をどう使い分けるかに関しては`返り値`が必要かどうかで決定します。SELECT文の場合はGETの時と同様、レスポンス内容が返り値となります。PUBLISH文は単純にPOSTが成功したかどうかを`true`か`false`のみで返します。

PUTやDELETEなどこの他のメソッドに関しては、SELECT文、PUBLISH文いずれもデフォルトのメソッドではありませんので`method`に設定を行って使用してください。



### MQTT、AMQP、Kafka

ブローカーにPUBLISHする際にはPUBLISH文を使用します。次の例はMQTTブローカーにPUBLISHする例ですがAMQP、Kafkaの場合でもほとんど同じです。

```JavaScript
var data = {
    id: 1,
    value: "Hello"
}
var config = {
    topic: "/test/event"
}
PUBLISH { message: data } TO SOURCE MqttBroker USING config
//PUBLISH { topic: "/test/event", message: data } TO SOURCE MqttBroker
```
送信先となる`topic`の設定が必要となります。

注意点はHTTPの時と同様に`{ message: data }`の部分です。HTTPでは`body`がkeyとなる必要がありますが、`MQTTとAMQP`の場合は`message`、`Kafka`の場合は`value`がkeyとなる必要があります。



### 備考

#### Sourceを変数に置き換える場合

Sourceを変数に置き換える場合は、下記のように変数名に`@`をつけて使用します。

これは、SELECT文でもPUBLISH文でも利用できます。

※下記の例ではSource名を`ExternalAPI`としています。

```JavaScript
var sourceName = "ExternalAPI"
var response = SELECT FROM SOURCE @sourceName
```

Procedureで引数を受け取る場合は下記のようになります。

```JavaScript
PROCEDURE getUsers(sourceName String)
var response = SELECT FROM SOURCE @sourceName
return response
```

[VAIL Reference Guide ： Variable References](https://dev.vantiq.com/docs/system/rules/index.html#variable-references)

