# はじめに

本ドキュメントはVantiqEdgeにおけるバージョンアップ手順について記載したものです。

# 前提

VantiqEdgeのインストールが完了していることが前提となります。

# マイナーバージョンアップ

1. MongoDBのバックアップを取る。[手順](tips_vantiq_edge.md#mongodbをバックアップリストアしたい)  

2. `componse.yaml` を開き、`vantiq_edge`の`image`のバージョンを編集する。  
`vantiq_ai_assistant`、`vantiq_genai_flow_service`を構成している場合、これらのバージョンを`vantiq_edge`と同じバージョンを指定して下さい。  
（最新のバージョンについては、サポート担当にお尋ねください）  
また、`vantiq_edge_qdrant`のバージョンは、`vantiq_edge`のバージョンによって異なりますので、[対応表](setup_vantiq_edge_r137_w_LLM#セットアップ手順)を参考に適切な`vantiq_edge_qdrant`のバージョンを指定して下さい。

3. `componse.yaml`が存在するディレクトリにて、 `docker compose up -d` を実行する。  
バージョン更新して起動するまで数分かかります。

# マイナーバージョンアップ - Rollback

1. MongoDBのバックアップからリストアする。[手順](tips_vantiq_edge.md#mongodbをバックアップリストアしたい)  

2. `compose.yaml` を開き、`vantiq_edge`の`image`のバージョンを元に戻す。  
`vantiq_ai_assistant`、`vantiq_genai_flow_service`を構成している場合、これらのバージョンを`vantiq_edge`と同じバージョンを指定して下さい。  

3. `componse.yaml`が存在するディレクトリにて、 `docker compose up -d` を実行する。  
バージョン更新して起動するまで数分かかります。