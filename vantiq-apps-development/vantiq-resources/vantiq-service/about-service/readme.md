# Vantiq Service の概要

Vantiq を利用するうえで欠かせない Service リソースについて解説します。  

> **公式リファレンス**  
>
> - :globe_with_meridians: [Service Builder Reference Guide](https://dev.vantiq.com/docs/system/services/)
> - :globe_with_meridians: [Resource Reference Guide](https://dev.vantiq.com/docs/system/resourceguide/#services)

## 目次

- [Vantiq Service の概要](#vantiq-service-の概要)
  - [目次](#目次)
  - [Vantiq Service とは](#vantiq-service-とは)
  - [Service の主要機能](#service-の主要機能)
    - [REST API](#rest-api)
  - [Procedure](#procedure)
    - [Public Procedure](#public-procedure)
    - [Private Procedure](#private-procedure)
    - [REST API](#rest-api-1)
    - [補足・注意点](#補足注意点)
  - [Inbound / Outbound](#inbound--outbound)
  - [Event Handler](#event-handler)
    - [Visual Event Handler](#visual-event-handler)
    - [VAIL Event Handler](#vail-event-handler)
    - [Public Event Handler](#public-event-handler)
    - [Private Event Handler](#private-event-handler)
    - [Source Event Handler](#source-event-handler)
    - [Service Event Handler](#service-event-handler)
    - [Topic Event Handler](#topic-event-handler)
    - [Type Event Handler](#type-event-handler)
    - [REST API](#rest-api-2)
  - [State](#state)
  - [カプセル化されたリソースの対照表](#カプセル化されたリソースの対照表)

## Vantiq Service とは

Vantiq Service リソースは、アプリケーションの機能をまとめて **カプセル化** できるリソースです。  

Service を利用することで、アプリケーションを **インターフェイス（Interface）** と **実装（Implement）** に切り分けることができるようになります。  
Service を利用するユーザーは、インターフェイスを介してアプリケーションを利用できるため、開発効率や再利用性が高まります。  

また、 Service には、 Vantiq Catalog を介して他のネームスペースとアプリケーションを共有することができます。  

## Service の主要機能

Service には、以下の5つの主要な機能があります。  

- **Procedure** - 同期処理
- **Inbound** - 非同期のイベントストリーム入力
- **Outbound** - 非同期のイベントストリーム出力
- **EventHandler** - 非同期の処理ロジック
- **State** - インメモリで状態を保持する変数

<img src="./imgs/vantiq-service.png" width=50%>

### REST API

Service の定義を取得できます。  

```shell
GET https://dev.vantiq.com/api/v1/resources/services/<Package名>.<Service名>
```

Service の説明を更新できます。  

```shell
PUT https://dev.vantiq.com/api/v1/resources/services/<Package名>.<Service名>
{
    "name": "MyService"
    , "description": "This is a new description for my service."
}
```

## Procedure

Procedure リソースを Service の1つの要素としてカプセル化することができます。  

Service にカプセル化することで開発効率の向上だけではなく、 Vantiq Catalog を介して他のネームスペースに共有することが可能となり、再利用性が向上します。  

Procedure には下記の2つの種類があります。  

- Public Procedure
- Private Procedure

### Public Procedure

自身の Service 以外からも参照できる Procedure になります。  
Public Procedure には **インターフェイス（Interface）** と **実装（Implement）** の両方が設定できます。  

### Private Procedure

自身の Service からのみ参照できる Procedure になります。  
Private Procedure には **実装（Implement）** のみ設定できます。  

### REST API

```shell
PUT https://dev.vantiq.com/api/v1/resources/services/<Package名>.<Service名>/<Procedure名>
{
    <Procedure parameters>
}
```

> **注意**  
> リクエストボディが空の場合でも、空の JSON を送信するようにしてください。  

### 補足・注意点

- Procedure は同期処理になります。
- Procedure の実行は2分を超える場合、タイムアウトになります。
- Service Procedure は `<Package名>.<Service名>.<Procedure名>` で参照可能になります。
- State のスコープを設定することで、**暗黙的に宣言された State 変数** にアクセスできるようになります。

## Inbound / Outbound

ストリーム入出力（Inbound / Outbound）のインタフェースを定義できます。  

Service の外部から、 `Package名` + `Service名` + `インターフェース名` でイベントストリームを受けたり渡したりできます。  

## Event Handler

ストリーム入出力（Inbound / Outbound）のインターフェイスで受け取ったイベントストリームの処理を担当します。  
以下の2種類の Event Handler を用いて、非同期にイベントストリームを処理します。  

- Visual Event Handler
- VAIL Event Handler

また、データの受け渡し方によって下記の6つの種類に分けられます。  

- Public Event Handler
  - Public Visual Event Handler
  - Public VAIL Event Handler
- Private Event Handler
  - Private Visual Event Handler
  - Private VAIL Event Handler
- Source Event Handler
  - Source Visual Event Handler
  - Source VAIL Event Handler
- Service Event Handler
  - Service Visual Event Handler
  - Service VAIL Event Handler
- Topic Event Handler
  - Topic Visual Event Handler
  - Topic VAIL Event Handler
- Type Event Handler
  - Type Visual Event Handler
  - Type VAIL Event Handler

### Visual Event Handler

Visual Event Handler は GUI ベースのビュジアルなツールを使ってアプリケーションをローコードに実装できます。  
アプリケーションを実装する際は Activity Pattern と呼ばれる、あらかじめ用意されている処理のパターンを組み合わせて開発を行います。  
VAIL を用いたプログラミングも可能なため、柔軟な実装ができます。  

### VAIL Event Handler

VAIL を用いて実装できます。  

### Public Event Handler

自身の Service 以外からもイベントストリームを受け取れる Event Handler になります。  

### Private Event Handler

自身の Service からのみイベントストリームを受け取れる Event Handler になります。  

### Source Event Handler

外部システムとの接続ポイントである Source からイベントストリームを受け取る際に利用する Event Handler になります。  

### Service Event Handler

Service からイベントストリームを受け取る際に利用する Event Handler になります。  

### Topic Event Handler

Topic からイベントストリームを受け取る際に利用する Event Handler になります。  

> **注意**  
> Topic を用いた実装を行うとイベントストリームの流れが把握しづらくなるため、 Topic Event Handler の利用は推奨していません。  

> **補足**  
> Topic Event Handler は初期状態では非表示になっています。  
> Service Event Handler から設定を行うことで利用できるようになります。  

### Type Event Handler

Type に変化があった際のイベントストリームを受け取る際に利用する Event Handler になります。  

> **補足**  
> Type Event Handler は初期状態では非表示になっています。  
> Service Event Handler から設定を行うことで利用できるようになります。  

### REST API

Service の Inbound にイベントストリームを Publish できます。  

```shell
POST https://dev.vantiq.com/api/v1/resources/services/<Package名>.<Service名>/<Inbound名>
{
    <eventData>
}
```

## State

本来、イベントストリーム処理は Procedure の呼び出し間でメモリに状態を保持しません。  
Service リソースを利用することで、メモリ上にデータを保持できる State を利用することができます。  

State は Service 内の Procedure や Visual Event Handler のタスクから参照できます。  
なお、 Service 外から参照する場合は、アクセサ（Getter, Setter などの Procedure）を実装する必要があります。  

State の詳細は下記を参照してください。  

- [Stateful Service とは](../stateful-service/readme.md)

> **補足**  
> State を利用しない場合は Type に状態を保持するのが一般的ですが、イベントストリームが増えれば増えるほど Type にアクセスする際のオーバーヘッドも増えます。  
> よくあるアンチパターンですので、ステートフルなアプリケーションを実装する際は積極的に State を利用してください。  

## カプセル化されたリソースの対照表

Service にカプセル化されたリソースは、機能的に以下の要素に相当します。

|要素|カプセル化されたリソース|
|---|---|
|Inbound, Outbound|Topic|
|Visual Event Handler|App|
|VAIL Event Handler|Rule|
|Procedure|Procedure|
|State|一時保存用途としてのType (クエリは使用不可)|
