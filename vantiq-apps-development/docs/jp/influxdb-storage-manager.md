# InfluxDB Storage Manager

## Storage Managerとは

- Vantiqでは、データの永続化にMongoDBを使用しています。Vantiq 1.35で追加されたStorage Managerの機能を使用することにより、MongoDB以外のデータベースを使用してデータを永続化しVantiq Typeとして使用することができます。Storage Managerの詳細に関しては[公式リファレンス](https://dev.vantiq.com/docs/system/storagemanagers/index.html)を参照してください。

## InfluxDB Storage Managerについて

- Storage Managerは、使用したいデータベースに合わせて個別に実装する必要がありますが、InfluxDB Cloud用のリファレンスStorage ManagerがVantiqより提供されています。このStorage Managerを使用することで、InfluxDB Cloudを使用してデータを永続化できVantiqアプリでTypeとして使用することができます。

## InfluxDB Storage Managerの使用

### InfluxDB Cloudの準備

InfluxDB Cloud Serverlessを使用するためには、InfluxDB Cloudのアカウントが必要です。アカウントをお持ちでない場合は、[InfluxDB Cloud](https://cloud2.influxdata.com/signup)からアカウントを作成してください。

#### セットアップ

[公式のチュートリアル](https://docs.influxdata.com/influxdb/cloud-serverless/get-started/setup/)にしたがい、InfluxDB をセットアップします。

1. API TOKEN の作成
   VantiqからInfluxDB CloudにアクセスするためのAPI TOKENを作成します。[InfluxDB Cloud](https://cloud2.influxdata.com/)にアクセスし、[Load Data] > [API TOKENS]に移動して`Generate Token`をクリックし、`All Access API Token`を選択します。
   ![GenerateToken](../../imgs/influxdb-storage-manager/apitoken.png)
   作成されたAPI TOKENを控えておきます。
2. バケットの作成
   InfluxDB Cloudにデータを保存するためには、バケットを作成する必要があります。[InfluxDB Cloud](https://cloud2.influxdata.com/)にアクセスし[Load Data] > [Bucket]に移動して`Create Bucket`をクリックします。
   ![CreateBucket](../../imgs/influxdb-storage-manager/createbucket.png)
   ここでは`get-started` バケットを作成します。
3. データの書き込み
   作成したバケットにデータを書き込んでみます。InfluxDBのデータ構造の詳細に関しては、[公式のリファレンス](https://docs.influxdata.com/influxdb/cloud-serverless/reference/syntax/line-protocol/) を参照してください。
   [InfluxDB Cloud](https://cloud2.influxdata.com/)にアクセスし[Load Data] > [Bucket]に移動して書き込みたいバケットの`ADD DATA` をクリック、`Line Protocol` を選択します。
   ![WriteData](../../imgs/influxdb-storage-manager/writedata.png)
   `ENTER MANUALLY` を選択し、以下のデータを入力します。

   ```csv
   home,room=Living\ Room temp=21.1,hum=35.9,co=0 1683532800
   home,room=Kitchen temp=21.0,hum=35.9,co=0 1683532800
   home,room=Living\ Room temp=21.4,hum=35.9,co=0 1683536400
   home,room=Kitchen temp=23.0,hum=36.2,co=0 1683536400
   home,room=Living\ Room temp=21.8,hum=36.0,co=0 1683540000
   home,room=Kitchen temp=22.7,hum=36.1,co=0 1683540000
   home,room=Living\ Room temp=22.2,hum=36.0,co=0 1683543600
   home,room=Kitchen temp=22.4,hum=36.0,co=0 1683543600
   home,room=Living\ Room temp=22.2,hum=35.9,co=0 1683547200
   home,room=Kitchen temp=22.5,hum=36.0,co=0 1683547200
   home,room=Living\ Room temp=22.4,hum=36.0,co=0 1683550800
   home,room=Kitchen temp=22.8,hum=36.5,co=1 1683550800
   home,room=Living\ Room temp=22.3,hum=36.1,co=0 1683554400
   home,room=Kitchen temp=22.8,hum=36.3,co=1 1683554400
   home,room=Living\ Room temp=22.3,hum=36.1,co=1 1683558000
   home,room=Kitchen temp=22.7,hum=36.2,co=3 1683558000
   home,room=Living\ Room temp=22.4,hum=36.0,co=4 1683561600
   home,room=Kitchen temp=22.4,hum=36.0,co=7 1683561600
   home,room=Living\ Room temp=22.6,hum=35.9,co=5 1683565200
   home,room=Kitchen temp=22.7,hum=36.0,co=9 1683565200
   home,room=Living\ Room temp=22.8,hum=36.2,co=9 1683568800
   home,room=Kitchen temp=23.3,hum=36.9,co=18 1683568800
   home,room=Living\ Room temp=22.5,hum=36.3,co=14 1683572400
   home,room=Kitchen temp=23.1,hum=36.6,co=22 1683572400
   home,room=Living\ Room temp=22.2,hum=36.4,co=17 1683576000
   home,room=Kitchen temp=22.7,hum=36.5,co=26 1683576000

   ```

   [Precision]ドロップダウン メニューで [Seconds]を選択し、[Write Data]をクリックしデータを書き込みます。
   ![SaveData](../../imgs/influxdb-storage-manager/savedata.png)
4. データのクエリ
   書き込んだデータをクエリしてみます。[InfluxDB Cloud](https://cloud2.influxdata.com/)にアクセスし[Data Explorer]に移動し、左のSchema Browserの[Bucket]ドロップダウン メニューから `get-started`バケットを選択します。
   エディターに以下のクエリを入力し、[RUN] をクリックするとクエリが実行されます。

   ```sql
    SELECT
      *
    FROM
      home
    WHERE
      time >= '2023-05-08T08:00:00Z'
      AND time <= '2023-05-08T20:00:00Z'
   ```

   ![Query](../../imgs/influxdb-storage-manager/query.png)

   クエリの結果が表示されます。
   ![QueryResult](../../imgs/influxdb-storage-manager/queryresult.png)

### InfluxDB Storage Managerのインストール

1. Vantiq CatalogからInfluxDB Storage ManagerのAssemblyをインストールします。
   1. VantiqのUIで、[追加] > [Assemblies] を選択します。
   1. . `InfluxStorageManager` をクリックし、Assemblyをインストールします。
   ![AddAssembly](../../imgs/influxdb-storage-manager/addassembly.png)
   1. Config を編集します。
   ![Config](../../imgs/influxdb-storage-manager/installconfig.png)
   必要に応じてInfluxURLのOverride値を設定してください。requestDefaults は以下の内容を設定してください。

      ```json
        {
          "headers": {
            "Authorization": "Token <Your Token>"
            },
          "query": {
            "org": "<Your Organization>"
            }
        }
      ```

   1. Project に InfluxStorageManager が追加されました。
   ![InfluxStorageManager](../../imgs/influxdb-storage-manager/influxstoragemanager.png)

### Typeの作成

1. Vantiq UIから新規Typeを作成します。
![CreateType](../../imgs/influxdb-storage-manager/createtype.png)
1. Type名には、InfluxDB の `measurement` を指定します。ここでは `home` となります。
1. Role は永続型の`standard`、Storage Managerは`InfluxStorageManager`が選択可能となっているので選択します。
1. Properties では、InfluxDB のBucket、Tag、Precision を指定します。以下の通り指定します。

   ```json
    { 
        "bucket": "get-started", 
        "tags": [ "room" ], 
        "precision": "s" 
    }
   ```

1. TypeのProperties を追加します。`timestamp`のみがデフォルトで設定されています。 InfluxDB のTag、Field に対応するProperty を追加します。
![AddProperty](../../imgs/influxdb-storage-manager/properties.png)

1. [すべてのレコードを表示]でデータを確認してみます。
![AllRecords](../../imgs/influxdb-storage-manager/showdata.png)

**Note**
InfluxDBは、データを`measurement`、`tag`、`field`の組み合わせからなる`Series` として保存します。co、temp、humの個々のフィールドは別々のSeries（テーブル）に配置されます。Storage Managerは個々のSeriesの内容を結合しないため、Selectの結果は一つのタイムスタンプ・Tag(room) の組み合わせに対しco、temp、humの3種類の結果が返されます。

### Vantiqアプリ内での使用

### SaveToType

1. SaveToType アクティビティを使用したAppを作成します。
![SaveToType](../../imgs/influxdb-storage-manager/savetotypeapp.png)
1. SaveToType アクティビティの設定を行います。
![SaveToTypeConfig](../../imgs/influxdb-storage-manager/savetotypeactivity.png)
1. Eventを発行します。
![PublishEvent](../../imgs/influxdb-storage-manager/savetotypepublishevent.png)
1. InfluxDBにデータが保存されていることを確認します。
![CheckData](../../imgs/influxdb-storage-manager/savetotyperesult.png)

**Warning**
InfluxDBStorageManager のTypeでは、`upsert`オプションは有効にできません。
`Error found during code generation: The type home is managed by InfluxDBStorageManager which does not allow upsert operations. Both update and insert must be supported.`

### Enrich

1. Enrich アクティビティを使用したAppを作成します。
![Enrich](../../imgs/influxdb-storage-manager/enrichapp.png)
1. Enrich アクティビティの設定を行います。
![EnrichConfig](../../imgs/influxdb-storage-manager/enrichactivity.png)
![EnrichConfig2](../../imgs/influxdb-storage-manager/enrichactivity2.png)
Inbound Event のキーでInfluxDBのレコードが一意に取得できればよいのですが、前述の通りco、temp、humの3つのSeriesがあるためEnrich実行時のクエリでデータが3件取得され、Enrichはエラーとなります。
`The generated rule: Enrich failed because: Encountered exception during execution: Sequence contains more than one element!`
データ構造によっては使用可能な場合もあります。
