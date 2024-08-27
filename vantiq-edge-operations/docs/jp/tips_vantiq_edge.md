# はじめに

本ドキュメントは VantiqEdgeインストールおよび保守時のトラブルシューティング過去事例やTipsについて記載したものです。  
本ドキュメントに記載された内容はVantiq Private Cloudは対象外ですので、ご注意下さい。

# 目次
- [はじめに](#はじめに)
- [トラブルシューティング過去事例](#トラブルシューティング過去事例)
- [Tips](#tips)
  - [MongoDBをバックアップ・リストアしたい](#mongodbをバックアップリストアしたい)
  - [1.38→1.39バージョンアップに伴う追加作業](#138139バージョンアップに伴う追加作業)

# トラブルシューティング過去事例
追って公開予定です。

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