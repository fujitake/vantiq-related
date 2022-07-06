## PostgRESTセットアップ手順
- ここでは PostgREST の Dockerコンテナ を用いて、 PostgreSQL と Vantiq を接続します。



## Table Of Contents
- [PostgRESTのインストール](#install)
  - [Dockerコマンドの実行](#docker_run)
  - [Sourceの設定](#source)
- [データベース操作](#db_operation)
  - [SELECT文](#select)
  - [INSERT文](#insert)
  - [UPDATE文](#update)
  - [DELETE文](#delete)



<h2 id="install">1. PostgREST のインストール</h2>
<h3 id="docker_run">1.1. Docker コマンドの実行</h3>

PostgRESTのサイトを元に Docker run コマンドを実行します。
- [PostgREST](https://postgrest.org/en/stable/install.html#docker)

```Shell
docker run --rm --net=host -p 3000:3000 \
    -e PGRST_DB_URI="postgresql://{ホスト名}:{ポート番号}/{DB名}?user={ユーザ名}&password={パスワード}" \
    -e PGRST_DB_SCHEMA="{スキーマ}" \
    -e PGRST_DB_ANON_ROLE="{ロール}" \
    postgrest/postgrest
```


<h3 id="source">1.2. Source の設定</h3>

REMOTE Source の設定を行います。

1. 「General」のタブを開き、「Source Name」に任意の名前を入力し、「Source Type」を「REMOTE」に設定します。
- 例では「Source Name」を「PostgREST_API」としています。
<img src="../../imgs\vantiq-PostgREST\PostgREST_API_General.png">

2. 「Properties」のタブを開き、「Server URI」に PostgREST の URI を入力し、保存します。
- ポート番号は Docker run で指定したポート番号を入力します。
<img src="../../imgs\vantiq-PostgREST\PostgREST_API_Properties.png">



<h2 id="db_operation">2. データベース操作</h2>
サンプルコードに記載されているDBの構造は下記の通りです。

テーブル名：books
PRIMARY KEY：isbn
|id|name|isbn|
|:---:|:---|:---|
|1|神様のメモ帳|978-4-8402-3691-1|
|2|神様のメモ帳2|978-4-8402-3888-5|
|3|神様のメモ帳３|978-4-04-867097-5|


<h3 id="select">2.1. SELECT文</h3>

```JavaScript
PROCEDURE select()

var path = "/books"
var method = "GET"
var headers = {
    "Content-type": "application/json"
}

var response = SELECT ONE FROM SOURCE PostgREST_API WITH path = path, method = method, headers = headers
```
- なお、GET メソッドの場合は、method の省略が可能です。

response
```JSON
[
   {
      "id": 1,
      "name": "神様のメモ帳",
      "isbn": "978-4-8402-3691-1"
   },
   {
      "id": 2,
      "name": "神様のメモ帳2",
      "isbn": "978-4-8402-3888-5"
   },
   {
      "id": 3,
      "name": "神様のメモ帳3",
      "isbn": "978-4-04-867097-5"
   }
]
```


<h3 id="insert">2.2. INSERT文</h3>

```JavaScript
PROCEDURE insert()

var path = "/books"
var method = "POST"
var headers = {
    "Content-type": "application/json"
}
var body = {
    "name": "神様のメモ帳4"
    , "isbn": "978-4-04-867910-7"
}

var response = SELECT ONE FROM SOURCE PostgREST_API WITH path = path, method = method, headers = headers, body = body
```
- なお、body が存在し、POST メソッドの場合は、method の省略が可能です。


<h3 id="update">2.3. UPDATE文</h3>

```JavaScript
PROCEDURE update()

var path = "/books"
var method = "PUT"
var headers = {
    "Content-type": "application/json"
}
var query = {
    "isbn": "eq.978-4-04-867097-5"
}
var body = {
    "id": "3"
    , "name": "神様のメモ帳3"
    , "isbn": "978-4-04-867097-5"
}

var response = SELECT ONE FROM SOURCE PostgREST_API WITH path = path, method = method, headers = headers, query = query, body = body
```
- WEHER句で PRIMARY KEY が設定されているカラムを指定する必要があります。
- PRIMARY KEY が設定されているカラムを含め、すべてのカラムを request body で指定する必要があります。


<h3 id="delete">2.4. DELETE文</h3>

```JavaScript
PROCEDURE delete()

var path = "/books"
var method = "DELETE"
var headers = {
    "Content-type": "application/json"
}
var query = {
    "id": "eq.2"
}

var response = SELECT ONE FROM SOURCE PostgREST_API WITH path = path, method = method, headers = headers, query = query
```
