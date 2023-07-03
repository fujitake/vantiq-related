# Vantiq ワークショップ 概要

## 荷物仕分け (Box Sorter) アプリケーション 

読み取った送り先コードで荷物を仕分けするアプリケーションの実装を通じて Vantiq の基本機能を学びます。

## 荷物仕分けシステムの全体のイメージ

<img src="./imgs/overview.png" width="800">

1. バーコードリーダーで荷物のバーコードを読み取る。
1. 読み取った結果を Vantiq に送信する。
1. Vantiq はその結果を元に仕分けを行う。
1. Vantiq は仕分け指示を制御システムに送信する。
1. 制御システムは仕分け指示に従ってソーターを制御する。

[実物のイメージはこちら](https://vimeo.com/301251460?embedded=true&source=vimeo_logo&owner=9547854)

ワークショップでは Vantiq の担当部分である No.3〜4 を実装します。
>No.1〜2 は、 Google Colaboratory を利用し、 TOPIC に読み取り結果のサンプル情報を送信することで代用します。

### Vantiq で実装する荷物仕分け (Box Sorter) アプリケーション 概要

<img src="./imgs/vantiq-app.png" width="600">

このアプリケーションを実装していきます。  
詳細は次のステップで説明しますが、 `Google Colaboratory から情報を取得` 、 `仕分け` 、 `仕分け指示を表示` という処理を行います。

## ドキュメント

- [手順](./instruction.md)
