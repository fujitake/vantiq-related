# 再利用可能なアプリケーションデザインパターン

## デザインパターンの目的

- Vantiqの価値を最大限に発揮させるアプリケーションのデザインパターンを抽象化し、再利用することでベストプラクティスに沿ったアプリケーションのロジックに注力できるようにする。

#### Vantiq アプリケーションの位置づけ

- Vantiqはストリームデータ処理を行うプラットフォームなので、アプリケーションは、**[ラムダアーキテクチャ](https://docs.microsoft.com/ja-jp/azure/architecture/data-guide/big-data/#lambda-architecture)**、**[カッパアーキテクチャ](https://docs.microsoft.com/ja-jp/azure/architecture/data-guide/big-data/#kappa-architecture)** におけるSpeed Layer の位置づけであるべきである。
  - ストリームをリアルタイムで処理する（バッチではない）。パイプを流れるデータをチャンクではなく１件ずつ処理する。従来のデータベース中心のバッチ処理的な発想で実装をすると、特徴を活かすことができなくなる
  - カッパアーキテクチャのように、バッチ処理とストリーム処理で同じ1つのロジックを実装できるのが望ましい。

#### Vantiq アプリケーションの理想形

- Vantiqのアプリケーションの基本形
  - それぞれ独立に外部システムとの接続部である **Source**
  - 流通するデータを柔軟につなぎビジネスロジックを実装する **App**

- Vantiqデザインパターンは、**[Vantiq ”Service”](./../../vantiq-resources/vantiq-service/about-service/readme.md)** リソースを活用することで複雑なロジックも基本形に準拠したアプリケーションを作成する。

![vantiq-ideal-architecture](../../imgs/reusable-design-patterns/vantiq-ideal-architecture.png)


# デザインパターン例

- [再利用可能なアプリケーションデザインパターン](#再利用可能なアプリケーションデザインパターン)
  - [デザインパターンの目的](#デザインパターンの目的)
- [デザインパターン例](#デザインパターン例)
    - [実装に関する注意点](#実装に関する注意点)
  - [入力編](#入力編)
    - [Polling-To-Stream ](#polling-to-stream-)
    - [Observer ](#observer-)
    - [Async API ](#async-api-)
    - [Cached Remote API ](#cached-remote-api-)
    - [In-Memory Master ](#in-memory-master-)
    - [Echo Back ](#echo-back-)
    - [Loopwhile Batch ](#loopwhile-batch-)
    - [Memento ](#memento-)
  - [App 編](#app-編)
    - [Composite Entity ](#composite-entity-)
    - [Transpose ](#transpose-)
    - [Adapter / Bridge ](#adapter--bridge-)
    - [Lookup ](#lookup-)
    - [Upsert State ](#upsert-state-)
    - [Constant ](#constant-)
  - [出力編](#出力編)
    - [Stream-To-Bulk ](#stream-to-bulk-)
    - [External Datasink ](#external-datasink-)
    - [WebSocket ](#websocket-)
    - [Journal ](#journal-)
    - [Smooth Remote Service ](#smooth-remote-service-)

### 実装に関する注意点
- いくつかのデザインパターンは[バージョン1.34](https://community.vantiq.com/forums/topic/1-3-4-release-notes-%e6%97%a5%e6%9c%ac%e8%aa%9e/)の機能に依存しています。それ以前のバージョンにインポートするとコンパイルエラーとなったり、想定通り機能しない可能性があります。
  - [Stateful ServiceにおけるMap型](https://dev.vantiq.co.jp/docs/system/rules/index.html#map) - Stateful Serviceにて従来Object型を使用していたものが置き換えられた
  - Automatic Smoothing – アプリケーション内に過度に流れるイベントを自動的にバッファする
  - [LoopWhile](https://dev.vantiq.co.jp/docs/system/apps/index.html#loop-while) – 複数のタスクに渡る一連の処理をシーケンシャルに実行する


## 入力編


### Polling-To-Stream <a id="polling-to-stream"></a>

<img src="../../imgs/reusable-design-patterns/polling-to-stream.png" width=50%>

**Overview**
- 定期的にPollingしたデータ（ファイル）を個々のレコードに分割して、イベントストリームとして出力する。

**Motivation**
- Pollingしたデータは配列の形になっているが、そのままではストリーム処理に適さない。

**Usage**
- 外部システムのREST APIから最新の差分データの読み込み
- CSVファイルの読み込み
- 主にトランザクションやテレメトリ等のイベントデータ

**Note**
- _Unwind_ - 配列をストリームに変換している。

**Sample Project**
- [PollingToStream.zip](https://github.com/fujitake/vantiq-related/raw/main/vantiq-apps-development/conf/reusable-design-patterns/PollingToStream.zip)

---

### Observer <a id="observer"></a>

<img src="../../imgs/reusable-design-patterns/observer.png" width=50%>


**Overview**
- 緩やかに変化する入力したデータをVantiq上でメモリに保持して定点観測し、差異が発生した時にイベントとして発出する。
- 入力の候補として、Inboundストリームや、Remote SourceにPollingした戻り値 (Polling-To-Streamパターンと併用)、ファイルなど。

**Motivation**
- Vantiqで大きなデータを処理したいが、不必要なMongoDBへの書き込みや処理を発生させたくない。

**Usage**
- 変化の少ない大きなデータの処理（天気予報データ、列車運行情報など）
- 主にトランザクションやテレメトリ等のイベントデータ

**Note**
- _State: LastResult_ -  LastResult: Serviceの State: LastResult に前回(n-1th)のデータを入れる。
- _InputStream_ - 今回（nth)データをフェッチ/入力する
- _DataChange_ - 比較をして、差異を検出やある一定条件を満たしたもののみOutboundストリームとして出力する。

**Sample Project**
- [Observer.zip](https://github.com/fujitake/vantiq-related/raw/main/vantiq-apps-development/conf/reusable-design-patterns/Observer.zip)

---

### Async API <a id="async-api"></a>

<img src="../../imgs/reusable-design-patterns/async-api.png" width=50%>

**Overview**
- 外部システムからService Procedureを同期呼び出し (Request / Response) しながら、派生イベントにより非同期処理を行う

**Motivation**
- 非同期の連携をしたいが、Ackシグナルを確実に受け取るよう実装したい。
- 時間がかる処理でもレスポンス(Ack)が速やかに返るようにしたい

**Usage**
- デバイスなどの状態更新処理
- 制御指示の連携
- 時間がかかるジョブの実行リクエスト

**Note**
- _AsyncProc_ - Procedureの中で Publish To Topicをする。

**Sample Project**
- [AsyncAPI.zip](https://github.com/fujitake/vantiq-related/raw/main/vantiq-apps-development/conf/reusable-design-patterns/AsyncAPI.zip)

---

### Cached Remote API <a id="cached-remote-api"></a>

<img src="../../imgs/reusable-design-patterns/cached-remote-api.png" width=50%>

**Overview**
- 緩やかに変化する大きな参照データに対するREST APIのクエリ結果をキャッシュし、同一のパラメータの呼び出しをキャッシュから返す
- 定期的に期限切れキャッシュをクリアする

**Motivation**
- 参照したい外部サービスのデータが変化する場合、Vantiq上に持つことは難しいので、Remote Sourceで問い合わせるのが妥当だが、Remote Sourceの呼び出しは遅いので、件数が多くなるとボトルネックとなるのを回避する。

**Usage**
- 定期的に更新されるデータ（天気予報、動態人口統計など）の外部サービス呼び出し

**Note**
- _CachedRemoteAPIHelper_ - クエリから PartitionKey を算出するラッパー
- _RemoteService_ - Cache がヒットすれば Cache を返す。ヒットしない、有効期限切れならば Remote Source に問い合わせる。

**Sample Project**
- [CachedRemoteAPI.zip](https://github.com/fujitake/vantiq-related/raw/main/vantiq-apps-development/conf/reusable-design-patterns/CachedRemoteAPI.zip)


---

### In-Memory Master <a id="in-memory-master"></a>
<img src="../../imgs/reusable-design-patterns/in-memory-master.png" width=50%>

**Overview**
- 外部からロードするマスタデータ（またはそれに準ずる参照系データ）をTypeではなくインメモリのStateで保持する。 Stateは、hash検索のみ可能なので、検索に使う列の数の分キャッシュが必要になる。
- ロードする時点で複数のマスターレコードを集約しておくことで、より高速化する。（Composite Entityパターンとの併用）
- Upsert Stateパターンと併用

**Motivation**
- データ統合、エンリッチ処理の高速化。

**Usage**
- 参照用マスタデータ
- データ統合

**Note**
- _UpdateMaster Procedure_ - ServiceのScheduled Procecureや、Initializeで更新をする
- _Purge Procedure_ - 古いデータをStateから定期的に消去する
- V1.35以降であれば、[Cache Service](./../../vantiq-resources/vantiq-service/cache-service/readme.md)でも実現できる。

**Sample Project**
- [InMemoryMaster.zip](https://github.com/fujitake/vantiq-related/raw/main/vantiq-apps-development/conf/reusable-design-patterns/InMemoryMaster.zip)

---

### Echo Back <a id="echo-back"></a>
<img src="../../imgs/reusable-design-patterns/echo-back.png" width=50%>

**Overview**
- BrokerやREST API等を通じて入力したデータをそのままの形で外部向けのBrokerに返す。

**Motivation**
- インテグレーション時に外部システムの視点から正しくデータがつながっているかを確認したい。

**Usage**
- 外部システムとのインテグレーション時の確認用

**Note**
- N/A

**Sample Project**
- [EchoBack.zip](https://github.com/fujitake/vantiq-related/raw/main/vantiq-apps-development/conf/reusable-design-patterns/EchoBack.zip)

---

### Loopwhile Batch <a id="loopwhile-batch"></a>
<img src="../../imgs/reusable-design-patterns/loopwhile-batch.png" width=50%>

**Overview**
- あらかじめ小さく（Vantiqでタイムアウトしない、過負荷にならない程度）分割したバッチのリスト（ファイルリスト、テーブルのサブセット等）を入力し、LoopWhileで順次バッチ実行を行い、実行ごとにステータスを記録する。
- 途中で失敗した場合、記録された進捗ステータスに基づき、全体、もしくは途中から再開させる。
- Async Procedureパターン、Polling-To-Streamパターン等と併用する。

**Motivation**
- 大量の入力が必要な処理を確実に行いたい。
- エラーが一定の確率でおこる前提で、運用を効率化する

**Usage**
- データ統合
- 機械学習データ前処理

**Note**
- N/A

**Sample Project**
- [LoopWhileBatch.zip](https://github.com/fujitake/vantiq-related/raw/main/vantiq-apps-development/conf/reusable-design-patterns/LoopWhileBatch.zip)

---
### Memento <a id="memento"></a>
<img src="../../imgs/reusable-design-patterns/memento.png" width=50%>

**Overview**
- ファイルやデータセット等（日次の履歴など）をラベルを付けて永続化してき、必要な時に復元する。
- 大きなデータセット（例：数万レコードのJSON等）であっても1レコードとして永続化する。
- 保存先のテーブル（Type）には適宜、有効期限や保存容量の上限を設定しておく。（7日など）


**Motivation**
- 処理するロジックに数世代前の入力データが必要で、それを高速に呼び出したい。
- 処理結果に再現性を持たせるために、サーバーの稼働状態によらず数世代分の入力データを保全したい。


**Usage**
- レコード数の多い長期的な過去データとの比較を伴う処理

**Note**
- _Load_ - 呼び出し側でStateに復元する処理を記述する（Upsert State)


**Sample Project**
- [Memento.zip](https://github.com/fujitake/vantiq-related/raw/main/vantiq-apps-development/conf/reusable-design-patterns/Memento.zip)

---

## App 編



### Composite Entity <a id="composite-entity"></a>

<img src="../../imgs/reusable-design-patterns/composite-entity.png" width=50%>

**Overview**
- 複数のエンティティをまとめた複合エンティティで処理を行う

**Motivation**
- テーブルの読み書きの回数を減らす、JoinができないNoSQLに予め非正規化/複合エンティティの形で保存する

**Usage**
- 複数マスタのある場合に検索パフォーマンスを高める
- NoSQLにおいて、リレーション（関連）を最適に表現する
- UI表示用のデータ構造として

**Note**
- N/A

**Sample Project**
- N/A

---

### Transpose <a id="transpose"></a>

<img src="../../imgs/reusable-design-patterns/transpose.png" width=50%>

**Overview**
- AccumulateState タスクを用いて、共通のIDを持つ3つ以上のストリームのプロパティを横並びに入力タイミングに依らない統合をする。
- 起動開始直後などで、 AccumulateState タスクが不完全なプロパティのデータを発出するが、必要に応じて Filter をする。

**Motivation**
- Joinタスクによるストリーム統合はどちらか出力イベントがどちらか一方のタイミングに依存してしまうため、タイミングに依存しない結合をしたい。

**Usage**
- さまざまなストリームの統合

**Note**
- AccumulateState で実装するサンプルコード
```vail
if (!state) {
    // if this is the first time, initialize it.
    state = {     
    }
}

// copy properties if present
state.controlCode = event.controlCode ? event.controlCode : state.controlCode
state.temp        = event.temp ? event.temp : state.temp
state.humidity    = event.humidity ? event.humidity : state.humidity

state.timestamp = event.timestamp
state.machineID = event.machineID
```

**Sample Project**
- [Transpose.zip](https://github.com/fujitake/vantiq-related/raw/main/vantiq-apps-development/conf/reusable-design-patterns/Transpose.zip)

---

### Adapter / Bridge <a id="adapter"></a>

<img src="../../imgs/reusable-design-patterns/adapter.png" width=50%>

**Overview**
- Serviceのインタフェースに入力ストリームの形式を合わせる。
- Service Inbound, Service Outbound, Service Procedureとの接続時に適宜 Transform したり、Procedure でラップすること。

**Motivation**
- Service モジュールの汎用性を損なわずに利用したい。

**Usage**
- さまざま

**Note**
- この例はService Inboundに対するAdapterだが、Service Outbound, Service Procedureインタフェースについても同様のパターンが取れる。

**Sample Project**
- N/A

---

### Lookup <a id="lookup"></a>

<img src="../../imgs/reusable-design-patterns/decorator.png" width=50%>

**Overview**
- 入力ストリームに複数のデータソースを統合しながら段階的に情報を付加していく。
- In-Memory Masterパターン、Cached Remote API、Cached Enrich と併用して効率化する。

**Motivation**
- ストリームの統合だけでなく、REST API問い合わせやEnrichタスクも含めてデータ統合したい

**Usage**
- データ統合

**Note**
- _SomeService.Get()_ - Keyに対するレコードを返す
- _SomeService_, _SomeService2_ タスク - Service Procedureを呼び出し、`Attach Return Value to Return Property`とする。もしくは、`Transformation`でpropertyを追加する。
- _Sink_ - 分析用データであれば Brokerなど通じてVantiq外に連携する

**Sample Project**
- N/A

---
### Upsert State <a id="upsert-state"></a>

<img src="../../imgs/reusable-design-patterns/upsert-state.png" width=50%>

**Overview**
- Service State上で同一キーを持つデータソースが異なるレコードを統合する。
- 複数のデータを非同期に統合する場合は統合が完了した際に必要であればイベントを発出する。
- 入力が配列であればバルクで処理する。

**Motivation**
- バッチで非同期に入力されるデータソース同士を効率よく統合する。

**Usage**
- データ統合

**Note**
- _UpsertState()_ - Stateが保持する同一keyのオブジェクトにプロパティを結合する。
  ```vail
  package jp.co.vantiq.designpattern.upsertstate
  PROCEDURE JoinXXXData.upsertState(keyName String, obj Object, propName String)

  var key = event[keyName]
  joinedState.compute(key, (pKey, value) => {
      if (value == null) {
          value = {}
      }
      value[propName] = obj
      return value
  })
  return true
  ```
- _BulkUpsertState_ - 配列のそれぞれの要素に対して、UpsertState()を実行する。


**Sample Project**
- [UpsertState.zip](https://github.com/fujitake/vantiq-related/raw/main/vantiq-apps-development/conf/reusable-design-patterns/UpsertState.zip)

---
### Constant <a id="constant"></a>
<img src="../../imgs/reusable-design-patterns/const.png" width=50%>

**Overview**
- DB（Type）に保持した定数値をアプリケーションで使用する。
- ビルドなしに定数値の入れ替え、反映を行う。

**Motivation**
- 手作業、または運用のタイミングにより定数を切り替えたい。

**Usage**
- 試験運用時のパラメータ調整
- 調整可能な運用カレンダー作成

**Note**

**Sample Project**
- [Const.zip](https://github.com/fujitake/vantiq-related/raw/main/vantiq-apps-development/conf/reusable-design-patterns/Const.zip)
---

## 出力編



### Stream-To-Bulk <a id="stream-to-bulk"></a>

<img src="../../imgs/reusable-design-patterns/stream-to-bulk.png" width=50%>

**Overview**
- ストリームデータをメモリ上に蓄積し、一定時間、もしくは一定数レコードが溜まった時点でまとめてDBに書き出す。
- Insert, Remote Sourceで外部API連携する処理に適用可能。

**Motivation**
- Vantiq処理においてデータベース操作は比較的パフォーマンスが低く、並行処理中のストリームをそのまま流すとクレジット超過となるのを回避する。
- 外部APIサービスで回数超過による課金を抑えたい。

**Usage**
- Typeへの効率的書き出し
- Remote Sourceへの効率的書き出し

**Note**
- N/A

**Sample Project**
- [StreamToBulkInsert.zip](https://github.com/fujitake/vantiq-related/raw/main/vantiq-apps-development/conf/reusable-design-patterns/StreamToBulkInsert.zip)


---

### External Datasink <a id="external-datasink"></a>

<img src="../../imgs/reusable-design-patterns/external-datasink.png" width=50%>

**Overview**
- Vantiqアプリケーションで処理したデータを蓄積のため、外部に連携する。
- 連携先としてRDB、時系列DBなど

**Motivation**
- Vantiqはデータ分析基盤やアーカイブのためのストレージではないため、目的に応じた外部サービスに連携する

**Usage**
- 過去データの蓄積
- 可視化ダッシュボード、レポーティング、分析基盤への連携

**Note**
- N/A

**Sample Project**
- N/A

---

### WebSocket <a id="websocket"></a>

<img src="../../imgs/reusable-design-patterns/websocket.png" width=50%>

**Overview**
- Vantiq Topicに出力したストリームデータをクライアントアプリからWebSocketで取りに来る

**Motivation**
- クライアントアプリからの過多のポーリングを回避と、リアルタイム性を確保する

**Usage**
- Webクライアントへマップ情報（位置情報）を更新する

**Note**
- N/A

**Sample Project**
- [websocket_client.zip](https://github.com/fujitake/vantiq-related/raw/main/vantiq-apps-development/conf/reusable-design-patterns/websocket_client.zip)
- [WebSocket_Server.zip](https://github.com/fujitake/vantiq-related/raw/main/vantiq-apps-development/conf/reusable-design-patterns/WebSocket_Server.zip)

---

### Journal <a id="journal"></a>
<img src="../../imgs/reusable-design-patterns/journal.png" width=50%>

**Overview**
- インメモリのキャッシュに更新を行い、更新情報についてはJournalを保持し、一定のタイミングでPersistする。

**Motivation**
- Persistencyの確保をしつつ、Typeへの書き込みを最小化する。

**Usage**
- 状態の一時〜永続的保存

**Note**
- _ScheduledProc_ - ServiceのScheduled Procecureで書き込みをする

**Sample Project**
- N/A

---

### Smooth Remote Service <a id="smooth-remote-service"></a>

<img src="../../imgs/reusable-design-patterns/smooth-remote-service.png" width=50%>

**Overview**
- Remote Sourceで外部サービスを呼び出す部分をバッファし、一定時間あたりの呼び出し数を制御する。

**Motivation**
- 外部サービスに対してVantiqの処理が速すぎる場合、Vantiq側で呼び出しをコントロールしてエラーとならないようにする。

**Usage**
- 時間あたりのAPI呼び出し制限がある外部サービスを使用する

**Note**
- N/A

**Sample Project**
- [SmoothRemoteService.zip](https://github.com/fujitake/vantiq-related/raw/main/vantiq-apps-development/conf/reusable-design-patterns/SmoothRemoteService.zip)

---
