# はじめに

本ドキュメントはVantiqEdgeにおけるバージョンアップ手順について記載したものです。

# 前提

VantiqEdgeのインストールが完了していることが前提となります。

# マイナーバージョンアップ

1. MongoDBのバックアップを取る。[手順](tips_vantiq_edge.md#mongodbをバックアップリストアしたい)  

2. `componse.yaml` を開き、`vantiq_edge`の`image`のバージョンを編集する。  
`vantiq_ai_assistant`、`vantiq_genai_flow_service`を構成している場合、これらのバージョンを`vantiq_edge`と同じバージョンを指定して下さい。  
（最新のバージョンについては、サポート担当にお尋ねください）  

> **補足説明**  
> * 1.38→1.39バージョンアップでは[追加の手順](tips_vantiq_edge.md#138139バージョンアップに伴う追加作業)が必要です。  
> * 1.39→1.40バージョンアップでは[追加の手順](tips_vantiq_edge.md#139140バージョンアップに伴う追加作業)が必要です。  

3. `componse.yaml`が存在するディレクトリにて、 `docker compose up -d` を実行する。  
バージョン更新して起動するまで数分かかります。

# マイナーバージョンアップ - Rollback

1. MongoDBのバックアップからリストアする。[手順](tips_vantiq_edge.md#mongodbをバックアップリストアしたい)  

2. `componse.yaml` を開き、`vantiq_edge`の`image`のバージョンを元に戻す。  
`vantiq_ai_assistant`、`vantiq_genai_flow_service`を構成している場合、これらのバージョンを`vantiq_edge`と同じバージョンを指定して下さい。  

3. `componse.yaml`が存在するディレクトリにて、 `docker compose up -d` を実行する。  
バージョン更新して起動するまで数分かかります。