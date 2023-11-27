# ボックスソーター（初級編・REST API）

読み取った送り先コードで荷物を仕分けするアプリケーションの開発を体験します。  

> **補足**  
> 物流センターで利用されている荷物仕分けシステムは下記の様に呼ばれています。
>
> - ボックスソーター (Box sorter)
> - スライドシューソーター (Sliding shoe sorter)
> - サーフィンソーター (Surfing Sorter)

## ボックスソーターの全体のイメージ

<img src="./imgs/overview.png" width="800">

1. バーコードリーダーで荷物のバーコードを読み取る。
1. 読み取った結果を REST API を用いて Vantiq に送信する。
1. Vantiq はその結果を元に仕分けを行う。
1. Vantiq は仕分け指示を制御システムに送信する。
1. 制御システムは仕分け指示に従ってソーターを制御する。

:globe_with_meridians: [実物のイメージはこちら](https://www.youtube.com/watch?v=1LvaiA3N0E8&t=282s)

ワークショップでは Vantiq の担当部分である No.3〜4 を実装します。
> No.1〜2 は、 Google Colaboratory を利用し、 TOPIC に読み取り結果のサンプル情報を送信することで代用します。  
> Google Colaboratory の詳細は [こちら](/vantiq-google-colab/docs/colab_basic_knowledge.md) で解説しています。

## Vantiq で利用するリソースなどの解説

Vantiq リソースや各用語について解説します。

### Topic

![resource_topic.png](./imgs/resource_topic.png)

Vantiq 内部でデータの受け渡しに利用するエンドポイントになります。  
また、外部からデータを受け渡す際の REST API のエンドポイントとして用いることもできます。

### Type

![resource_type.png](./imgs/resource_type.png)

Vantiq 内部でデータを保存するために利用します。  
内部的には NoSQL の MongoDB を利用しています。  
Activity Pattern や VAIL からデータの読み書きが出来ます。  
外部から REST API を用いて、データの読み書きをすることも出来ます。  

主にマスタデータの保存やデータの一時的な保存に利用されることが多いです。  

> **注意**  
> Type は NoSQL のため、 RDB とは異なり、リレーションシップやトランザクション処理は出来ません。  

### App (App Builder)

![resource_app.png](./imgs/resource_app.png)

App は GUI でアプリケーションの作成ができるツールになります。  
あらかじめ用意されている処理のパターンを組み合わせて開発を行います。  
用意されたパターンで対応できない場合は、プログラミングも可能なため柔軟な実装ができます。

## Vantiq で実装するアプリケーションの概要

App Builder を用いて、アプリケーションを作成していきます。  
アプリケーションの完成イメージは下記のとおりです。  

![app_boxsorter_restapi.gif](./imgs/app_boxsorter_restapi.gif)

## アプリケーションの開発で利用する Activity Pattern の紹介

このワークショップでは下記の Activity Pattern を利用します。

### EventStream Activity

![activitypattern_eventstream.png](./imgs/activitypattern_eventstream.png)

App を利用する際に必ずルートタスクとして設定されている Activity Pattern が **EventStream** になります。  
**EventStream** はデータの入り口となります。  
**EventStream** の入力元に **Topic** を指定することで、 Vantiq 内部からのデータを受け取ったり、 外部からの HTTP POST されたデータを受け取ることができます。

### Enrich Activity

![activitypattern_enrich.png](./imgs/activitypattern_enrich.png)

イベントに対して Type に保存されているレコードを追加します。  
イベントが通過するたびに Type へのアクセスが発生するため、パフォーマンスの低下には注意してください。

### Filter Activity

![activitypattern_filter.png](./imgs/activitypattern_filter.png)

**Filter** に設定した条件に合致するイベントのみを通過させます。  
条件に合致しなかったイベントは破棄されるため、注意してください。  
複数の **Filter** を利用することで、 `if / else if / else` の様に分岐させることや `Switch 文` の様に用いることができます。

### LogStream Activity

![activitypattern_logstream.png](./imgs/activitypattern_logstream.png)

イベントデータをログに出力します。  
今回は仕分け指示が正しく行われているかを確認するために利用します。

## 必要なマテリアル

### 各自で準備する Vantiq 以外の要素

以下のいずれかを事前にご用意ください。

- Google Colab
  - Google アカウント（※Google Colaboratory を利用するために使用します）
  - [BoxSorterDataGenerator（初級編・REST API）](/vantiq-google-colab/code/box-sorter_data-generator_rest-api.ipynb)
  - [BoxSorterDataGenerator（初級編・REST API・複数送信用）](/vantiq-google-colab/code/box-sorter_data-generator_rest-api_multi.ipynb)
- Python
  - Python 実行環境
  - [BoxSorterDataGenerator（初級編・REST API）](/vantiq-google-colab/code/box-sorter_data-generator_rest-api.py)
  - [BoxSorterDataGenerator（初級編・REST API・複数送信用）](/vantiq-google-colab/code/box-sorter_data-generator_rest-api_multi.py)

### 商品マスタデータ

- [sorting_condition.csv](./../data/sorting_condition.csv)

## ワークショップの手順

アプリケーション開発の詳細は下記のリンクをご確認ください。  

- [手順](./instruction.md)
