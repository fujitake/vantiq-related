## How to setup PostgREST
- Here describes how to connect PostgreSQL and Vantiq using PostgREST's Docker container.

<br />

## Table Of Contents
- [Preparation of PostgreSQL](#postgresql)
  - [Azure Database for PostgreSQL](#azure_db)
- [Installation of PostgREST](#install)
  - [Executing Docker commands](#docker_run)
  - [Configuring the Source](#source)
- [Data Manipulation](#db_operation)
  - [SELECT statement](#select)
  - [INSERT statement](#insert)
  - [UPDATE statement](#update)
  - [DELETE statement](#delete)

<br />

<h2 id="postgresql">1. Preparation of PostgreSQL</h2>

Prepare PostgreSQL server for using PostgREST.

It is also acceptable to use an existing PostgreSQL server.

<br />

<h3 id="azure_db">1.1. Azure Database for PostgreSQL</h3>

This time, using Azure Database for PostgreSQL, which is a Microsoft Azure service, to simplify the construction.

The Azure database to be used is "Flexible Server" (other databases are also acceptable).

※ As for the configuration of PostgreSQL, please refer to the following image.

<br />

<img src="../../imgs\vantiq-PostgREST\PostgrSQL_Server.png">

<br />

<h2 id="install">2. Installation of PostgREST</h2>
<h3 id="docker_run">2.1. Executing Docker commands</h3>

Run the `docker run` command according to the PostgREST site.

- [PostgREST](https://postgrest.org/en/stable/install.html#docker)

```Shell
docker run --rm --net=host -p 3000:3000 \
    -e PGRST_DB_URI="postgresql://{host name}:{port number}/{DB name}?user={user name}&password={password}" \
    -e PGRST_DB_SCHEMA="{schema}" \
    -e PGRST_DB_ANON_ROLE="{role}" \
    postgrest/postgrest
```

<br />

<h3 id="source">2.2. Configuring the Source</h3>

Configure the REMOTE Source settings.

1. Go to the [General] tab, provide any name in the [Source Name] field and set the "REMOTE" in the [Source Type].  

   - In this example, [Source Name] is set to "PostgREST_API".

<img src="../../imgs\vantiq-PostgREST\PostgREST_API_General.png">

<br />

2. Go to the [Properties] tab, set the "URI of PostgREST" into the [Server URI] and save it.  

   - As for the port number, provide the port number which is specified with `docker run`.  

<img src="../../imgs\vantiq-PostgREST\PostgREST_API_Properties.png">

<br />

<h2 id="db_operation">3. Data Manipulation</h2>

The DB structure described in the sample code is the following.

- Table name：books
- PRIMARY KEY：isbn

|id|name|isbn|
|:---:|:---|:---|
|1|Sample book|978-4-8402-3691-1|
|2|Sample book 2|978-4-8402-3888-5|
|3|Sample book 3|978-4-04-867097-5|

※ The table name will be the endpoint.  

<br />

<h3 id="select">3.1. SELECT statement</h3>

```JavaScript
PROCEDURE select()

var path = "/books"
var method = "GET"
var headers = {
    "Content-type": "application/json"
}

var response = SELECT ONE FROM SOURCE PostgREST_API WITH path = path, method = method, headers = headers
```

※ If GET method is used, the method can be omitted.

<br />

response
```JSON
[
   {
      "id": 1,
      "name": "Sample book",
      "isbn": "978-4-8402-3691-1"
   },
   {
      "id": 2,
      "name": "Sample book 2",
      "isbn": "978-4-8402-3888-5"
   },
   {
      "id": 3,
      "name": "Sample book 3",
      "isbn": "978-4-04-867097-5"
   }
]
```

<br />

<h3 id="insert">3.2. INSERT statement</h3>

```JavaScript
PROCEDURE insert()

var path = "/books"
var method = "POST"
var headers = {
    "Content-type": "application/json"
}
var body = {
    "name": "Sample book 4"
    , "isbn": "978-4-04-867910-7"
}

var response = SELECT ONE FROM SOURCE PostgREST_API WITH path = path, method = method, headers = headers, body = body
```

※ If the body exists and POST method is used, the method can be omitted.  

<br />

<h3 id="update">3.3. UPDATE statement</h3>

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
    , "name": "Sample book 3"
    , "isbn": "978-4-04-867097-5"
}

var response = SELECT ONE FROM SOURCE PostgREST_API WITH path = path, method = method, headers = headers, query = query, body = body
```

※ The columns with PRIMARY KEY set should be specified in the WHERE clause.

※ All columns should be specified in the request body, including columns with PRIMARY KEY specified.  

<br />

<h3 id="delete">3.4. DELETE statement</h3>

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
