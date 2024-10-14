# ボックスソーター（Transformation）

ボックスソーターアプリを改修して、データを整形する方法を体験します。  
（※記事作成時の Vantiq バージョン： r1.39.7）  

> **注意**  
> ボックスソーター（REST API）を実施していない場合は、先にそちらを実施してください。  
> - [ボックスソーター（REST API）](./../rest-api/readme.md)

## Vantiq で実装するアプリケーションの概要

Service Builder を用いて、アプリケーションを作成していきます。  
アプリケーションの完成イメージは下記のとおりです。  

![app_boxsorter_transform.gif](./imgs/app_boxsorter_transform.gif)

## アプリケーションの開発で利用する Activity Pattern の紹介

このワークショップでは下記の Activity Pattern を利用します。
> 他のワークショップで紹介したものは割愛します。  

### Transformation Activity

![activitypattern_transformation.png](./imgs/activitypattern_transformation.png)

イベントのデータ整形やフォーマットを変換するために **Transformation** を用います。  

入力データや出力データのスキーマが未定な場合やスキーマが変更になった場合にも活用することができ、スキーマに対して柔軟な対応が可能になります。  

## 必要なマテリアル

### 各自で準備する Vantiq 以外の要素

以下のいずれかを事前にご用意ください。

- Google Colab
  - Google アカウント（※Google Colaboratory を利用するために使用します）
  - [BoxSorterDataGenerator（REST API）](/vantiq-google-colab/code/box-sorter_data-generator_rest-api.ipynb)
  - [BoxSorterDataGenerator（REST API・複数送信用）](/vantiq-google-colab/code/box-sorter_data-generator_rest-api_multi.ipynb)
- Python
  - Python 実行環境
  - [BoxSorterDataGenerator（REST API）](/vantiq-google-colab/code/box-sorter_data-generator_rest-api.py)
  - [BoxSorterDataGenerator（REST API・複数送信用）](/vantiq-google-colab/code/box-sorter_data-generator_rest-api_multi.py)

### 商品マスタデータ

- [com.example.sorting_condition.csv](./../data/com.example.sorting_condition.csv)

### プロジェクトファイル

- [ボックスソーター（REST API）の実装サンプル（Vantiq r1.40）](./../data/box_sorter_restapi_1.40.zip)
- [ボックスソーター（REST API）の実装サンプル（Vantiq r1.39）](./../data/box_sorter_restapi_1.39.zip)
- [ボックスソーター（REST API）の実装サンプル（Vantiq r1.37）](./../data/box_sorter_restapi_1.37.zip)
- [ボックスソーター（REST API）の実装サンプル（Vantiq r1.34）](./../data/box_sorter_restapi_1.34.zip)

> **注意：プロジェクトのバージョンについて**  
> Vantiq r1.39 以前のプロジェクトファイルは Service 非対応の古いサンプルになります。  
> ドキュメント記載の手順と異なりますので注意してください。  

## ワークショップの手順

アプリケーション開発の詳細は下記のリンクをご確認ください。  

- [手順](./instruction.md)
