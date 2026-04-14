# Vantiq JDBC Source

Vantiq JDBC Source は Vantiq から JDBC 経由で SQL データベースに接続し、クエリの実行やデータベースのポーリングを行うことを可能にします。ほぼすべての標準 SQL コマンドをサポートしており、VAIL の `SELECT FROM SOURCE` や `PUBLISH` を通してデータベースを操作できます。

## 環境セットアップ

大まかな流れは以下となります。

1. Vantiqサーバーに `JDBC` Sourceを作成する
2. Vantiq extension Source をGithubリポジトリから取得し、JDBC Sourceをビルドする
3. JDBC Source にVantiqサーバーとの接続情報、およびJDBCドライバを設定し、実行する

### 前提

- Vantiq サーバー
  - 開発者用 Namespace を作成済みであること
- JDBC Source 実行環境
  - Java 11 以上がインストールされていること
  - 接続先 SQL データベースに対応した JDBC ドライバ (.jar) が入手済みであること
- 接続対象のSQLデータベース
  - JDBC で接続可能なデータベース (本説明では SQL Server 2022 を例とする)
- Vantiq CLI 実行端末
  - [Vantiq CLI](./cli-quick-reference.md) がインストールされ使用可能であること

本説明では以下の環境での実行例を示します。

- Vantiq サーバー :
  - dev.vantiq.com
- JDBC Source実行環境 / Vantiq CLI実行端末 :
  - Macbook Pro M1
  - Java 11
- 接続対象データベース :
  - SQL Server 2022 (JDBC Driver: `mssql-jdbc-12.8.1.jre11.jar`)

#### Vantiqサーバー

1. 開発者用 Namespace にてアクセストークンを生成します。 
   メニュー >> Admminister >> Advanced >> Access Token 
   生成したアクセストークンは、次ステップのCLI、およびJDBC Source実行環境の`server.config`で使用するため、控えておきます。

1. 新しい Source Type `JDBC`を追加します。
   1. [`jdbcImpl.json`](https://github.com/Vantiq/vantiq-extension-sources/blob/master/jdbcSource/src/test/resources/jdbcImpl.json) をダウンロードして、CLIを実行するディレクトリに置きます。

   1. Vantig CLI から以下のコマンドを実行します。
   （[参照](https://github.com/Vantiq/vantiq-extension-sources/blob/master/pythonExecSource/docs/Usage.md#defining-the-source-in-vantiq)）

        ```sh
        vantiq -s <profileName> load sourceimpls jdbcImpl.json
        ```

        もしくは

        ```sh
        vantiq -b https://<host> -t <ACCESS_TOKEN> load sourceimpls jdbcImpl.json
        ```

   1. メニュー Add >> Source >> New Source で、Source新規作成 ペインを開き、Source Type: `JDBC` が追加されていることを確認します。

1. Sourceを作成します。指定するパラメータは以下のとおりです。

   - Source Type: `JDBC`  （前ステップで作成したもの）
   - Source Name: 任意の名前 （ただし後のステップでJDBC Source実行環境の `server.config` で指定したものと一致させること。)
   Sourceを作成した後、JDBC Source実行環境から接続要求があると、直ちに接続が確立します。

1. Source の Properties を設定します。以下は SQL Server 2022 に接続する場合の例です。

    ```json
    {
        "vantiq": {
            "packageRows": "true"
        },
        "jdbcConfig": {
            "general": {
                "username": "sqlUsername",
                "password": "sqlPassword",
                "dbURL": "jdbc:sqlserver://localhost:1433;databaseName=myDB;encrypt=true;trustServerCertificate=true"
            }
        }
    }
    ```

    SQL Server の JDBC URL 例は `jdbc:sqlserver://<host>:<port>;databaseName=<db>;encrypt=true;trustServerCertificate=true` の形式です。本番環境では `trustServerCertificate=false` とし、適切な証明書検証を行ってください。

    - `vantiq.packageRows` : 必須。 `"true"` を指定します。
    - `jdbcConfig.general.username` : 必須。SQL データベースへの接続ユーザー名。
    - `jdbcConfig.general.password` : 必須。SQL データベースへの接続パスワード。
    - `jdbcConfig.general.dbURL` : 必須。接続先データベースの JDBC URL。

    `asynchronousProcessing`, `maxActiveTasks`, `maxQueuedTasks`, `pollTime`, `pollQuery` などの任意設定項目もあります。詳細は [ドキュメント](https://github.com/Vantiq/vantiq-extension-sources/tree/master/jdbcSource#source-configuration) を参照してください。

#### JDBC Source 実行環境

1. 接続先 SQL データベースに対応した JDBC ドライバ (.jar ファイル) をダウンロードし、任意のディレクトリに配置します。本例では Microsoft JDBC Driver for SQL Server (`mssql-jdbc-12.8.1.jre11.jar`) を使用します。SQL Server 2022 は JDBC Driver 12.x 系でサポートされており、Java 11 環境では `jre11` 版を選択します。

1. JDBC ドライバの場所を環境変数 `JDBC_DRIVER_LOC` に設定します。この環境変数はビルド時にクラスパスへ追加されます。

    ```sh
    export JDBC_DRIVER_LOC=/Users/yourName/somePath/mssql-jdbc-12.8.1.jre11.jar
    ```

1. [Vantiq Extension Source](https://github.com/Vantiq/vantiq-extension-sources/tree/master) からリポジトリをpullします。 `git clone` もしくは、zipでダウンロードして展開します。

1. `<リポジトリをダウンロードした場所>/vantiq-extension-sources` に移動し、`./gradlew jdbcSource:assemble` を実行します。

    `jdbcSource:assemble` のみを実行する場合、リポジトリルートの `gradle.properties` に `dockerRegistry` / `pathToRepo` を設定する必要はありません（これらは Docker イメージのビルド／公開 `buildConnectorImage` を行う場合にのみ必要なプロパティです）。

1. `<リポジトリをダウンロードした場所>/vantiq-extension-sources/jdbcSource/build/distributions` に実行ファイルを含む zip と tarファイルが作成されているので、いずれかを利用します。このファイルに実行ファイルが含まれます。

    ```sh
    jdbcSource
    ├-- build
        ├-- distributions
            ├-- jdbcSource.zip    # これを任意のディレクトリで解凍する
            ├-- jdbcSource.tar
    ```

1. `jdbcSource` を展開すると以下が得られます。これ以降の説明は`jdbcSource` を起点とします。

    ```sh
    .
    ├-- jdbcSource
        ├-- bin
            ├-- jdbcSource       # shell
            ├-- jdbcSource.bat   # bat
            ...
    ```

1. `server.config` を作成し、以下のいずれかの場所に配置します。

    - `<install location>/jdbcSource/serverConfig/server.config`
    - `<install location>/jdbcSource/server.config`

    ```properties
    targetServer = https://dev.vantiq.com
    authToken = P91-WB0Gjs1-C7iM3VdYG70CeFRzPllS4tU_xxxxxxx=
    sources = JDBC1
    ```

    `targetServer` : Vantiqサーバーのホスト
    `authToken` : アクセストークン。 `Vantiqサーバーのアクセストークンを生成する` ステップにて生成したもの。
    `sources` : Sourceの名前。`Vantiqサーバーの Source を作成する` ステップにて指定した名前。

1. `./bin/jdbcSource` を実行すると起動します。 Sourceと接続を確立します。

### 動作確認

接続が確立すると、Vantiq 側から VAIL を用いて SQL クエリを実行できるようになります。以下は Source 名を `JDBC1` とした場合の例です。

1. テーブルを作成します。 PUBLISH 文を使って DDL を発行します。

    ```sql
    PROCEDURE createTable()

    try {
        var sqlQuery = "create table Test(id int not null, age int not null, first varchar (255), last varchar (255));"
        PUBLISH {"query":sqlQuery} to SOURCE JDBC1
    } catch (error) {
        exception(error.code, error.message)
    }
    ```

1. データを INSERT します。

    ```sql
    PROCEDURE insertJDBC()

    try {
        FOR i in range(0, 5) {
            var id = i.toString()
            var age = (20+i).toString()
            var first = "Firstname" + i.toString()
            var last = "Lastname" + i.toString()

            var sqlQuery = "INSERT INTO Test VALUES (" + id + ", " + age + ", '" + first + "', '" + last + "');"
            PUBLISH {"query":sqlQuery} to SOURCE JDBC1
        }
    } catch (error) {
        exception(error.code, error.message)
    }
    ```

1. SELECT 文で結果を取得します。 VAIL の `SELECT FROM SOURCE` 構文を使用し、 `WITH` 句に SQL クエリを指定します。

    ```sql
    PROCEDURE queryJDBC()

    try {
        SELECT * FROM SOURCE JDBC1 AS results WITH
        query: "SELECT id, first, last, age FROM Test",
        bundleFactor: 500
        {
            FOR (row in results) {
                log.info("row: " + stringify(row))
            }
        }
    } catch (error) {
        exception(error.code, error.message)
    }
    ```

    `bundleFactor` は 1 メッセージにバンドルされる行数を指定するパラメータです。指定しない場合は既定値の 500 が使用されます。

1. Procedure を実行し、ログ出力などでクエリ結果を確認します。

なお、Source Properties の `jdbcConfig.general` で `pollTime` と `pollQuery` を指定すると、一定間隔で SQL クエリ (SELECT) が実行され、その結果が Source への Notification として送信されます。 Notification は Rule などで受け取ることができます。詳細は [README](https://github.com/Vantiq/vantiq-extension-sources/blob/master/jdbcSource/README.md) を参照してください。

## Reference

- [Vantiq JDBC Source Readme](https://github.com/Vantiq/vantiq-extension-sources/blob/master/jdbcSource/README.md)
