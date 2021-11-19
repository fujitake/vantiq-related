# Vantiq 1-day Workshop 概要説明

## ポンプ故障検知システム

ポンプ故障検知システムの実装を通じてVantiqの基本機能を学んでいきます。
* __前提__
  * ポンプが５台あり、それぞれに __温度センサー__ と  __回転数センサー__ が付いている
* __実装する機能__
  * 温度が __200__  __度以上__ 、かつ回転数が __4000__  __回以上__ の状態が __20__  __秒間続いた__ 際に「故障」として検出する

## ポンプ故障検知システムの処理の流れ

![ポンプ故障検知システムの処理の流れ](../../imgs/readme/slide3.png)   
&nbsp;&nbsp;&nbsp; **＊ Pump Failure Detection System: ポンプの故障を検知**

## Vantiq 1-day Workshop での処理の流れ
このWorkshopにおいては、センサー/デバイスの代わりに、Dummyデータを生成する **Data Generator** を使用します。

__５台分のポンプの__  __温度__   __と__   __回転数__  __のデータをランダムに__  __Publish__

![Vantiq 1-day Workshop での処理の流れ](../../imgs/readme/slide4.png)  
&nbsp;&nbsp;&nbsp; **＊ Pump Failure Detection System: ポンプの故障を検知**

## Workshopで使用するマテリアル

* Labs：Vantiq 1-day Workshop の手順書
  * 01~06
  * 追加課題: 混雑検出アプリ開発課題
* Lectures:　説明資料
* Materials：手順書で使用する[素材ファイル](../../conf)
  * TraingDataGen\.zip
  * Pumps\.json

## Workshopで準備が必要なもの

* MQTT Broker - Amazon MQ, Mosquittoなど。Internetからアクセスできるもの。
  - 参考: [【速報】新サービスAmazon MQを早速使ってみた！](https://dev.classmethod.jp/articles/re-invent-2017-amazon-mq-first-impression/)

## Vantiq 1-day Workshop の内容

* 以下の内容を通してポンプの故障検知システムを作成します。
  * __Lab01__  __準備__
    * データジェネレータの準備
  * __Lab02 Types__  __（タイプ）__
    * データベースのテーブルのような機能
  * __Lab03 Sources__  __（ソース）__
    * データの送受信で使う機能
  * __Lab04 App Builder__  __（アプリケーションビルダー）__
    * 受信したイベントの処理ロジックの作成
* 以下の内容を通してVantiqと外部システム連携を行います。
  * __Lab05 REST API__
    * 外部システムからVantiqリソースを操作します。
  * __Lab06 REMOTE Source__
    * Vantiqから外部システムのAPIを呼び出します。


## Course Agenda

|Session #|Session      | Type  |Contents Description       |Duration (m)|Material                          |
|:-----:|--------------|:------:|---------------------------|:-:|--------------------------------------------|
|1| VANTIQ で開発する上での基本事項| Lecture||10|[01_Basics](1-01_Basics.md) |
|2| 準備 (データジェネレータの設定)|Lab|データジェネレータの準備 |15|[Lab01_Preparation](2-Lab01_Preparation.md)|
|3| Types (タイプ)|Lab|データベースのテーブルのような機能|20|[Lab02_Types](3-Lab02_Types.md)|
|4|Source (ソース)|Lab|データの送受信で使う機能|20|[Lab03_Sources](4-Lab03_Sources.md)|
|5| App Builder の紹介| Lecture|  |15| [02_AppBuilder](5-02_AppBuilder.md)|
|6|App Builder (アプリケーション ビルダー)|Lab|受信したイベントの処理ロジックの作成|45|[Lab04_AppBuilder](6-Lab04_AppBuilder.md)|
|7| Lab 04 までの復習| Lecture| |15| [03_Review](7-03_Review.md)|
|8|Q&A||質疑応答|15||
|9|VANTIQ REST API|Lab|Vantiq 1-day Workshop の次のステップ| |[Lab05_VANTIQ_REST_API](a08-Lab05_VANTIQ_REST_API.md)|
|10| 他サービスとの連携|Lab|Vantiq 1-day Workshop の次のステップ| |[Lab06_Integrate_other_services](a09-Lab06_Integrate_other_services.md)|
|11| Vantiqのリソース全般の紹介||Reference||[実例を通して Vantiq のリソースを理解する](Vantiq_resources_introduction.md)|
|12| 混雑検出アプリ開発課題|Lab|Vantiq 1-day Workshop の次のステップ| |[混雑検出課題アプリ](a10-dev01_detect_congestion_app.md)|


＊上記のセッションを修了後、開発者の方はより深く理解をするため、[Vantiq アプリケーション開発者コース＆レベル1認定試験](https://community.vantiq.com/courses/vantiq%e3%82%a2%e3%83%97%e3%83%aa%e3%82%b1%e3%83%bc%e3%82%b7%e3%83%a7%e3%83%b3%e9%96%8b%e7%99%ba%e3%82%b3%e3%83%bc%e3%82%b9%ef%bc%86%e3%83%ac%e3%83%99%e3%83%ab1%e8%aa%8d%e5%ae%9a%e8%a9%a6%e9%a8%93v1-2/)（要ログイン）の受講をお勧めします。

## 参考情報
[トラブルシューティング](./troubleshootings.md)