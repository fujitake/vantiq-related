# ボックスソーター（入門編・Transformation）

ボックスソーターアプリを改修して、データを整形する方法を体験します。  

> **注意**  
> ボックスソーター（入門編・REST API）を実施していない場合は、先にそちらを実施してください。  
> - [ボックスソーター（入門編・REST API）](./../rest-api/readme.md)

## Vantiq で実装するアプリケーションの概要

App Builder を用いて、アプリケーションを作成していきます。  
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
  - [BoxSorterDataGenerator（入門編・REST API）](/vantiq-google-colab/docs/jp/box-sorter_data-generator_beginner_rest-api.ipynb)
  - [BoxSorterDataGenerator（入門編・REST API・複数送信用）](/vantiq-google-colab/docs/jp/box-sorter_data-generator_beginner_rest-api_multi.ipynb)
- Python
  - Python 実行環境
  - [BoxSorterDataGenerator（入門編・REST API）](/vantiq-google-colab/docs/jp/box-sorter_data-generator_beginner_rest-api.py)
  - [BoxSorterDataGenerator（入門編・REST API・複数送信用）](/vantiq-google-colab/docs/jp/box-sorter_data-generator_beginner_rest-api_multi.py)

### 商品マスタデータ

- [sorting_condition.csv](./../data/sorting_condition.csv)

### プロジェクトファイル

- [ボックスソーター（入門編・REST API）の実装サンプル（Vantiq 1.34）](./../data/box_sorter_beginner_restapi_1.34.zip)
- [ボックスソーター（入門編・REST API）の実装サンプル（Vantiq 1.37）](./../data/box_sorter_beginner_restapi_1.37.zip)

## ワークショップの手順

アプリケーション開発の詳細は下記のリンクをご確認ください。  

- [手順](./instruction.md)
