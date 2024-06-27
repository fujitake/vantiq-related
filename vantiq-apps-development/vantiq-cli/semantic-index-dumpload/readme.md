# Semantic Index のダンプとロード

Vantiq CLI を用いて Semantic Index のエントリーをダンプする方法とロードする方法を解説します。  
（※記事作成時の Vantiq バージョン： r1.39.3）

事前に Vantiq CLI のインストールを行い、 Semantic Index のダンプやロードを行いたい Namespace の情報をプロファイルに設定しておいてください。  

> **補足**  
> Vantiq CLI のインストールやプロファイルの設定はこちら
> 
> - [Vantiq CLI クイックリファレンス](./../cli-quick-reference/readme.md)

## 目次

- [Semantic Index のダンプとロード](#semantic-index-のダンプとロード)
  - [目次](#目次)
  - [Semantic Index のダンプ](#semantic-index-のダンプ)
  - [Semantic Index のロード](#semantic-index-のロード)

## Semantic Index のダンプ

Semantic Index のダンプを行うには下記のコマンドを使います。  

```PowerShell
vantiq dump semanticindexes <semantic index name> -s <profile> -d <directory>
```

## Semantic Index のロード

ダンプした Semantic Index のロードを行うには下記のコマンドを使います。  

```PowerShell
vantiq load semanticindexes -s <profile> <semantic index name>.dmp
```


