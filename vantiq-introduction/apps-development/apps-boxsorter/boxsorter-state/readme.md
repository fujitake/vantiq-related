# 荷物仕分けアプリケーション (State)

荷物仕分けアプリケーション (Standard) を利用して、 **State** について学習します。

## 荷物仕分けアプリケーション (State) の学習概要

開発した荷物仕分けアプリケーションを通じて Vantiq の State について学びます。  
> **注意**  
> 荷物仕分けアプリケーション (Standard) を実施していない場合は、先に 荷物仕分けアプリケーション (Standard) を実施してください。  
> :link: [荷物仕分けアプリケーション (Standard)](./../boxsorter-standard/readme.md)

### 学習目的

このワークショップの目的は下記のとおりです。

#### 主目的

1. **State** の概要を理解する
1. 特定の Activity Pattern を利用することで、 **State** が自動的に作られることを理解する。
1. **Procedure** の修飾子によって、アクセスできる **State** の種類が変わることを理解する。

#### 副次目的

1. **Global State** や **Partioned State** の概要を理解する。

## State の中身を確認してみる

Vantiq では `State` と呼ばれるリソースを用いることで、データをメモリ上に保持することができます。  
Type と異なり、 MongoDB にアクセスする必要がないため、処理の高速化を図りたい場合には積極的に使用する必要があります。  

今回、 `State` を作成したり操作するといった手順はありませんでした。  
`State` を直接操作するかわりに `Cached Enrich` を使い Type のレコードをメモリ上に保存し、処理の高速化を図るという実装を行いました。  
この際、自動で `State` が作成されています。  
そして、 Cached Enrich は Type から該当レコードを取得し State に格納する、という処理を行なっています。  

本ワークショップでは、 State に格納された Type のレコードを確認していきます。

## 必要なマテリアル

### 商品マスタデータ

- :link: [sorting_condition.csv](./../boxsorter-standard/data/sorting_condition.csv)

### プロジェクトファイル

- :link: [荷物仕分けアプリ (Standard) の実装サンプル（Vantiq 1.34）](./../data/box_sorter_standard_1.34.zip)
- :link: [荷物仕分けアプリ (Standard) の実装サンプル（Vantiq 1.36）](./../data/box_sorter_standard_1.36.zip)

## ドキュメント

:link: [手順](./instruction.md)
