## PostgRESTのセットアップ手順
- ここでは PostgREST の Dockerコンテナ を用いて、 PostgreSQL と Vantiq を接続します

<br />

## Table Of Contents
- [PostgreSQLサーバーの準備](#postgresql)
  - [Azure Database for PostgreSQL](#azure_db)
- [PostgRESTのインストール](#install)
  - [Dockerコマンドの実行](#docker_run)
  - [Sourceの設定](#source)
- [データベース操作](#db_operation)
  - [SELECT文](#select)
  - [INSERT文](#insert)
  - [UPDATE文](#update)
  - [DELETE文](#delete)

<br />

<h2 id="postgresql">1. PostgreSQL サーバーの準備</h2>

PostgREST を利用するための PostgreSQL サーバーの準備を行います。

既存の PostgreSQL サーバーを利用しても構いません。

<br />

<h3 id="azure_db">1.1. Azure Database for PostgreSQL</h3>

今回は簡易的に構築するために、Microsoft Azure サービスの Azure Database for PostgreSQL を利用します。

使用する Azure データベースは「フレキシブル サーバー」を利用します。（他のデータベースでも構いません）

※PostgreSQLの構成は下記の画像を参考にしてください。

<br />

<img src="../../imgs\vantiq-PostgREST\PostgrSQL_Server.png">

<br />

<h2 id="install">2. PostgREST のインストール</h2>
<h3 id="docker_run">2.1. Docker コマンドの実行</h3>

PostgRESTのサイトを元に Docker run コマンドを実行します。

- [PostgREST](https://postgrest.org/en/stable/install.html#docker)

```Shell
docker run --rm --net=host -p 3000:3000 \
    -e PGRST_DB_URI="postgresql://{ホスト名}:{ポート番号}/{DB名}?user={ユーザ名}&password={パスワード}" \
    -e PGRST_DB_SCHEMA="{スキーマ}" \
    -e PGRST_DB_ANON_ROLE="{ロール}" \
    postgrest/postgrest
```

<br />

<h3 id="source">2.2. Source の設定</h3>

REMOTE Source の設定を行います。

1. 「General」タブを開き、「Source Name」に任意の名前を入力し、「Source Type」を「REMOTE」に設定します。

   - 例では「Source Name」を「PostgREST_API」としています

<img src="../../imgs\vantiq-PostgREST\PostgREST_API_General.png">

<br />

2. 「Properties」タブを開き、「Server URI」に PostgREST の URI を入力し、保存します。

   - ポート番号は Docker run で指定したポート番号を入力します

<img src="../../imgs\vantiq-PostgREST\PostgREST_API_Properties.png">

<br />

<h2 id="db_operation">3. データベース操作</h2>

サンプルコードに記載されているDBの構造は下記の通りです。

- テーブル名：books
- PRIMARY KEY：isbn

|id|name|isbn|
|:---:|:---|:---|
|1|サンプルブック|978-4-8402-3691-1|
|2|サンプルブック2|978-4-8402-3888-5|
|3|サンプルブック３|978-4-04-867097-5|

※テーブル名がエンドポイントになります

<br />

<h3 id="select">3.1. SELECT文</h3>

```JavaScript
PROCEDURE select()

var path = "/books"
var method = "GET"
var headers = {
    "Content-type": "application/json"
}

var response = SELECT ONE FROM SOURCE PostgREST_API WITH path = path, method = method, headers = headers
```

※GET メソッドの場合は、method の省略が可能です

<br />

response
```JSON
[
   {
      "id": 1,
      "name": "サンプルブック",
      "isbn": "978-4-8402-3691-1"
   },
   {
      "id": 2,
      "name": "サンプルブック2",
      "isbn": "978-4-8402-3888-5"
   },
   {
      "id": 3,
      "name": "サンプルブック3",
      "isbn": "978-4-04-867097-5"
   }
]
```

<br />

<h3 id="insert">3.2. INSERT文</h3>

```JavaScript
PROCEDURE insert()

var path = "/books"
var method = "POST"
var headers = {
    "Content-type": "application/json"
}
var body = {
    "name": "サンプルブック4"
    , "isbn": "978-4-04-867910-7"
}

var response = SELECT ONE FROM SOURCE PostgREST_API WITH path = path, method = method, headers = headers, body = body
```

※body が存在し、POST メソッドの場合は、method の省略が可能です

<br />

<h3 id="update">3.3. UPDATE文</h3>

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
    , "name": "サンプルブック3"
    , "isbn": "978-4-04-867097-5"
}

var response = SELECT ONE FROM SOURCE PostgREST_API WITH path = path, method = method, headers = headers, query = query, body = body
```

※WEHER句で PRIMARY KEY が設定されているカラムを指定する必要があります

※PRIMARY KEY が設定されているカラムを含め、すべてのカラムを request body で指定する必要があります

<br />

<h3 id="delete">3.4. DELETE文</h3>

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

