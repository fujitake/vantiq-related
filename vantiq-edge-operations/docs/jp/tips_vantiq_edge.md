# はじめに

本ドキュメントは VantiqEdgeインストールおよび保守時のトラブルシューティング過去事例やTipsについて記載したものです。  
本ドキュメントに記載された内容はVantiq Private Cloudは対象外ですので、ご注意下さい。

# 目次
- [はじめに](#はじめに)
- [トラブルシューティング過去事例](#トラブルシューティング過去事例)
  - ["no space left on device"エラーが発生した](#no-space-left-on-deviceエラーが発生した)
  - ["Compilation error"が発生した](#compilation-errorが発生した)
  - ["Could not reach service connector AIAssistantService to execute procedure load_index_entry"エラーが発生した](#could-not-reach-service-connector-aiassistantservice-to-execute-procedure-load_index_entryエラーが発生した)
- [Tips](#tips)
  - [MongoDBをバックアップ・リストアしたい](#mongodbをバックアップリストアしたい)
  - [Qdrantをバックアップ・リストアしたい](#semanticindexqdrant-collectionをバックアップリストアしたい)
  - [1.38→1.39バージョンアップに伴う追加作業](#138139バージョンアップに伴う追加作業)
  - [1.39→1.40バージョンアップに伴う追加作業](#139140バージョンアップに伴う追加作業)

# トラブルシューティング過去事例

## "no space left on device"エラーが発生した

VantiqEdgeのインストールにて、`docker compose up -d`を実行したのち、"no space left on device"と表示されコンテナが起動しないケースがあります。  
必要なストレージサイズを確保できていないことが原因となりますので、VantiqEdgeの要件である32GBを確保した上で、再度コマンドを実行して下さい。    
ストレージとは、AWSの場合はEBS、Azureの場合はManagedDiskのことを指します。

## "Compilation error"が発生した

VantiqEdgeの起動後に、systemユーザにてログインすると、ナビゲーションバーの⚠マークに赤くカウントされた数字が表示されるケースがあります。  

![](./picture/warningsign.png)

詳細を確認すると、procedureのコンパイルエラーが発生しているはずです。  
次の例では、`Broker.updateSchema`procedureとなっていますが、他のprocedureの場合もあります。  

![](./picture/compileerror.png)

この場合考えられる原因は2つあります。  
① ハードウェア要件を満たすCPU・Memoryが確保できていない  
② VantiqEdgeの初回起動処理を停止してしまった

①の場合、要件を満たすサイズに変更して下さい。Memoryは8GBで、CPUは2vcpuで動作することを確認しております。  
その後、MongoDBのDocker Volumeを一度削除し、再度`docker compose up -d`でコンテナを起動させてください。
VantiqEdgeの初回起動処理がはじめから行われます。
> **MongoDB Docker Volumeの削除方法**  
> `docker volume ls` を実行すると、MongoDBのDocker Volume名が確認できます。`<ディレクトリ名>_vantiq_edge_data`となっているVolumeです。`docker volume rm <MongoDB Docker Volume名>`で削除することができます。

②の場合は、`docker compose up -d`の実行後、VantiqEdgeコンテナでは初回起動処理が行われますが、その途中に`docker restart vantiq_edge_server`等で一時停止させてしまうことを指しています。  
VantiqEdgeの起動処理が完了するのにはしばらく時間がかかります。 
起動が遅いからという理由等でコンテナを再起動してしまうとコンパイルエラーが発生します。  
この場合もMongoDBのDocker Volumeを一度削除し、再度`docker compose up -d`でVantiqEdgeの初回起動処理をはじめからやり直して下さい。

なお、VantiqEdgeの初回起動処理は、コンテナログにて次のメッセージが表示されれば、完了したとみなせます。

```
Succeeded in deploying verticle
```

## "Could not reach service connector AIAssistantService to execute procedure load_index_entry"エラーが発生した

Vantiq IDE画面にて、"Could not reach service connector AIAssistantService to execute procedure load_index_entry"というエラーが発生するケースがあります。  

![](./picture/load_index_entry_error.png)

この場合、AI Assistantがハングアップしているため、次のコマンドで再起動して下さい。  
```
docker restart vantiq_ai_assistant
```

# Tips

## MongoDBをバックアップ・リストアしたい
### 1. MongoDBバックアップ

VantiqEdgeのcompose.yamlが存在するディレクトリへ移動する。  

```sh
. (<- ここがルート)
|-- compose.yaml
|-- config
    |-- license.key 
    |-- public.pem
```

Vantiq Edgeコンテナを停止する。

```sh
$ docker stop vantiq_edge_server
```

mongodumpを実行する。  
完了すると、コンテナ上の/tmp/ars02以下にダンプファイルが出力されます。

```sh
$ docker compose exec vantiq_edge_mongo mongodump -u ars -p ars -d ars02 --gzip -o /tmp/
```

コンテナ上のダンプファイルをホストにコピーする。

```sh
$ docker compose cp vantiq_edge_mongo:/tmp/ars02 ./
```

コンテナ上のダンプファイルを削除する。

```sh
$ docker compose exec vantiq_edge_mongo rm -fr /tmp/ars02
```

### 2. MongoDBリストア

VantiqEdgeのcompose.yamlが存在するディレクトリへ移動する。  
`ars02`ディレクトリが存在することを確認する。  

```sh
. (<- ここがルート)
|-- compose.yaml
|-- ars02/
|-- config
    |-- license.key 
    |-- public.pem
```

ダンプ(ars02)をコンテナにコピーする。
```sh
$ docker compose cp ars02 vantiq_edge_mongo:/tmp/
```

リストアを実行する。
```sh
$ docker compose exec vantiq_edge_mongo mongorestore -u ars -p ars -d ars02 --gzip --drop /tmp/ars02
```

## SemanticIndex(Qdrant Collection)をバックアップ・リストアしたい

### 前提

- [Vantiq CLI](https://dev.vantiq.com/docs/system/cli/index.html) がインストールされていること
- [profile](https://dev.vantiq.com/docs/system/cli/index.html#profile) が設定されていて、対象のVantiqEdge環境に接続できること
- 対象のVantiq環境にSemantic Indexが作成されていること 

### 1. SemanticIndexバックアップ
バックアップは、SemanticIndex毎に取得することになります。
```
vantiq dump semanticindexes <semanticindex名> -s <profile名> -d <バックアップファイル格納先ディレクトリ>
```
指定したディレクトリに、`<SemanticIndex名>.dmpファイル`が出力されるはずです。  
※5MB分のテキストファイルでは、30秒ほどでバックアップが完了することを確認しております。

### 2. SemanticIndexリストア
```
vantiq load semanticindexes -s <profile名> <dmpファイル>
```
※5MB分のテキストファイルでは、10分ほどでリストアが完了することを確認しております。


## 1.38→1.39バージョンアップに伴う追加作業
1.38→1.39バージョンアップでは、通常のバージョンアップに加えて次の作業を実施する必要があります。  
* vantiq_genai_flow_serviceコンテナを追加する必要がある。
* Qdrantのバージョンをv1.9.2に変更する必要がある。

vantiq_genai_flow_serviceコンテナを追加するため、`compose.yaml`の編集時に、`services`セクションに次の内容を挿入して下さい。  
<バージョン>の箇所は希望するバージョンに書き換えて下さい。  
```
  vantiq_genai_flow_service:
    container_name: vantiq_genai_flow_service
    image: quay.io/vantiq/genaiflowservice:<バージョン>
    restart: unless-stopped
    command: ["uvicorn", "app.genaiflow_service:app", "--host", "0.0.0.0", "--port", "8889"]
    network_mode: "service:vantiq_edge"
```

また、Qdrantのバージョンをv1.9.2とするため、次のように、Qdrantの`image`タグを`v1.9.2`として下さい。

```
  vantiq_edge_qdrant:
    container_name: vantiq_edge_qdrant
    image: qdrant/qdrant:v1.9.2
    restart: unless-stopped
    volumes:
      - qdrantData:/qdrant/storage
    networks:
      vantiq_edge:
        aliases: [edge-qdrant]
```

編集が完了すると、[こちら](setup_vantiq_edge_r139_w_LLM.md)に記載された`compose.yaml`と同じような内容になるはずです。  

## 1.39→1.40バージョンアップに伴う追加作業
1.39→1.40バージョンアップでは、通常のバージョンアップに加えて次の作業を実施する必要があります。  
* vantiq_unstructured_apiコンテナを追加する必要がある。

vantiq_unstructured_apiコンテナを追加するため、`compose.yaml`の編集時に、`services`の最終セクションに次の内容を挿入して下さい。  
```
  vantiq_unstructured_api:
    container_name: vantiq_unstructured_api
    image: quay.io/vantiq/unstructured-api:0.0.73
    restart: unless-stopped
    environment:
      - PORT=18000
      - UNSTRUCTURED_PARALLEL_MODE_ENABLED=true
      - UNSTRUCTURED_PARALLEL_MODE_URL=http://localhost:18000/general/v0/general
      - UNSTRUCTURED_PARALLEL_MODE_SPLIT_SIZE=20
      - UNSTRUCTURED_PARALLEL_MODE_THREADS=4
      - UNSTRUCTURED_DOWNLOAD_THREADS=4
    network_mode: "service:vantiq_edge"
```

編集が完了すると、[こちら](setup_vantiq_edge_r140_w_LLM.md)に記載された`compose.yaml`と同じような内容になるはずです。  