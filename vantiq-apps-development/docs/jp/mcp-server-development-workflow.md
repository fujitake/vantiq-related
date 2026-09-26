# Vantiq MCP Server の開発ワークフローを支える manifest / context / instruction

Vantiq MCP Server (`io.vantiq.via.mcpServer`) を介すると、AI 開発ツール（Claude Code、VS Code 等）から Vantiq アプリケーションを開発できる。
この記事では、その開発を支える知識と手順のレイヤーである manifest、context、instruction の役割を、Visual Event Handler（VEH）の作成を例にとって説明する。
読み終えると、これらが何を提供し、開発フローのどこで効くのかを具体的に把握できる。

## TOC

- [この記事の対象と前提](#この記事の対象と前提)
- [Vantiq MCP Server を Claude Code に設定する](#vantiq-mcp-server-を-claude-code-に設定する)
- [2種類の MCP プリミティブ（Tools と Resources）](#2種類の-mcp-プリミティブtools-と-resources)
- [ステップで追う開発ワークフロー](#ステップで追う開発ワークフロー)
- [リソースの目次としての manifest](#リソースの目次としての-manifest)
- [context が共有する知識](#context-が共有する知識)
- [instruction が定める操作の手順](#instruction-が定める操作の手順)
- [Visual Event Handler を作成するまでの一連の流れ](#visual-event-handler-を作成するまでの一連の流れ)
- [このワークフローでできることと注意点](#このワークフローでできることと注意点)
- [まとめ](#まとめ)

## この記事の対象と前提

対象読者は、AI 開発ツールを Vantiq MCP Server 経由で接続して開発する Vantiq アプリケーション開発者である。

前提として、Vantiq REST API の基本操作（`select` / `insert` / `update` / `upsert` / `execute` / `publish`）を理解していることを想定する。
これらは MCP の **Tools** として提供されるが、実体は REST API のラッパーである。

この記事が扱うのは、その REST API の手前にある知識と手順のレイヤーである。
すなわち manifest、context、instruction が開発者と AI 開発ツールに何を提供するかを見ていく。

## Vantiq MCP Server を Claude Code に設定する

ワークフローを動かす前に、Claude Code から Vantiq MCP Server へ接続する設定が要る。
接続に必要なものは、接続先の URL とアクセストークンの2つである。

接続先の URL は、利用する Vantiq インスタンスのホストに `/mcp/io.vantiq.via.mcpServer` を付けた形になる。
たとえばホストが `test.vantiq.com` なら、URL は `https://test.vantiq.com/mcp/io.vantiq.via.mcpServer` である。

アクセストークンは、対象 namespace に対して発行する。
発行手順は[Vantiq Access Token の発行方法](../../vantiq-resources/access-token/create-access-token/readme.md)を参照してほしい。
namespace 単位のトークンのほか、org-level トークンを使えば namespace を切り替えられる。

設定の方法は2通りある。
1つは `claude mcp add` コマンドで登録する方法である。

```bash
claude mcp add --transport http vantiqVia \
  https://<vantiq-host>/mcp/io.vantiq.via.mcpServer \
  -H "Authorization: Bearer <accessToken>" \
  --scope user
```

もう1つは、プロジェクトディレクトリに `.mcp.json` を置く方法である。
チームで設定を共有したい場合は、こちらがリポジトリに含められる。

```json
{
  "mcpServers": {
    "vantiqVia": {
      "type": "http",
      "url": "https://<vantiq-host>/mcp/io.vantiq.via.mcpServer",
      "headers": { "Authorization": "Bearer <accessToken>" }
    }
  }
}
```

トークンは秘匿情報なので、`.mcp.json` を共有する場合は平文のトークンをそのままコミットしないよう注意する。

Vantiq IDE の New Project ウィザードを使う方法もある。
プロジェクトタイプに「AI Development」を選ぶと、トークンが生成され、`.mcp.json` の内容と `claude mcp add` コマンドが表示される。
表示された内容をそのまま使えば、ここまでの手作業を省ける。

設定したら、接続できているかを確認する。
Claude Code で `whoami` を呼び、接続先のユーザーと namespace が想定どおりかを確かめる。
続けて `resources/list` を呼び、manifest と context doc の一覧が返れば、開発ワークフローを始められる。

## 2種類の MCP プリミティブ（Tools と Resources）

MCP Server が提供するプリミティブは2種類に分かれる。

| プリミティブ | 役割 | 実体 | 例 |
|---|---|---|---|
| **Tools** | Vantiq を操作する（手） | REST API のラッパー | `select`, `insert`, `update`, `upsert`, `execute`, `publish` |
| **Resources** | 読み取り専用の知識を提供する（頭） | `resources/read` で取得（URI は `vantiq://via/...`） | manifest, context, instruction |

この2つは使われる順序が決まっている。
まず Resources から知識を読み、それに基づいて Tools で操作する。

```
知識を読む（Resources）→ それに基づいて操作する（Tools = REST）
```

この順序を、Visual Event Handler の作成を例に次節で具体化する。

## ステップで追う開発ワークフロー

ここでは「Visual Event Handler（VEH）を作りたい」というタスクを例に、ステップを追う。

1. `resources/list` で一覧を取得する。
   共通 context doc が2件（すべてのリソースで使う共有知識）と、manifest が16件（リソースの種類ごとに1件）返る。
   manifest は authoritative（権威的）であり、他の一般ルールよりも優先される。
2. タスクに対応する manifest（ここでは `vantiq://via/collaborationtypes/manifest.txt`）を読み、参照すべき instruction と context の URI を把握する。
3. 操作に対応する instruction（例: `create-update.txt`）と、必須の base context をロードする。
   context 内の XML タグ参照（例: `<activity_patterns>`）は、必要になった時点で遅延解決する。
4. instruction の手順に従って VEH の JSON 定義を作成し、`insert` または `upsert` で Vantiq に送信する。
5. 保存後、`selectOne` で `currentState` が `complete` であること、サービス側に `vailErrors` がないこと、`implementingResource` が VEH を指していることを確認する。

以降の3節で、manifest、context、instruction の中身を順に見ていく。

## リソースの目次としての manifest

**manifest** は、リソースの種類ごとに1つ存在する目次である。
そのリソースに対してどんな操作が可能で、どの instruction と context を読めばよいかを教える。

collaborationtypes の manifest（`vantiq://via/collaborationtypes/manifest.txt`）は次のような構造を持つ。

```
# Vantiq Visual Event Handlers (VEH)
Vantiq resource: system.collaborationtypes
Natural Key: name
isPackaged: true

## File resource example
  org.test.MyEventHandler → collaborationtypes/org/test/MyEventHandler.json

## Resources
  ### Instructions (uri | description)
    - vantiq://via/collaborationtypes/instructions/create-update.txt | creating or updating a VEH definition
    - vantiq://via/collaborationtypes/instructions/debug.txt        | troubleshooting VEHs
    - vantiq://via/collaborationtypes/instructions/explain.txt      | explaining a VEH
  ### Context — base (always load)
    - vantiq://via/common/context/core-rules.txt        | core rules for all Vantiq resources
    - vantiq://via/projects/context/project-files.md    | file path layout & project membership
  ### Context (uri | tag | description)
    - vantiq://via/collaborationtypes/context/common.txt            | <common_documentation>       | top-level structure, task shape, stream arrays
    - vantiq://via/collaborationtypes/context/event-streams.txt     | <event_stream_documentation> | legal EventStream sources; inbound vs internal
    - vantiq://via/collaborationtypes/context/activity-pattern-list.txt | <activity_patterns>       | all activity patterns available
    - vantiq://via/collaborationtypes/context/common-patterns.txt   | <common_patterns>            | Filter, Branch, Join, SplitByGroup, Procedure の例
    - vantiq://via/collaborationtypes/context/vail-in-handlers.txt   | <veh_vail>                   | VEH タスク内で VAIL を使う
    - vantiq://via/collaborationtypes/context/veh-state.txt          | <veh_state>                  | VEH とサービス状態
```

ここから4つのことが読み取れる。

- Instructions が3つある。
  `create-update`（作成と更新）、`debug`（デバッグ）、`explain`（解説）であり、操作ごとに専用の手順が用意されている。
- Base context は必ずロードする。
  `core-rules.txt` と `project-files.md` が該当する。
- 遅延解決の context がある。
  XML タグ（例: `<activity_patterns>`、`<common_patterns>`）で参照され、必要になった時点でロードする。
  VEH 固有の context は6件あり、トップレベル構造、EventStream のソース仕様、activity パターンの一覧、組み立てパターン例、タスク内 VAIL、VEH とサービス状態を含む。
- 他リソースへの参照がある。
  collaborationtypes の manifest から common の context を参照することもある。

manifest が示す操作セットは、リソースの種類によって違う。
types の manifest（`vantiq://via/types/manifest.txt`）を並べると、その差がわかる。

```
# Vantiq Types
Vantiq resource: system.types
Natural Key: name
isPackaged: true
## File resource example
  org.test.MyType → types/org/test/MyType.json
## Resources
  ### Instructions
    - vantiq://via/types/instructions/create.txt | Instructions for creating a Vantiq type definition
    - vantiq://via/types/instructions/update.txt | Instructions for updating a Vantiq type definition
  ### Context — base (always load)
    - core-rules.txt / project-files.md
  ### Context (uri | tag | description)
    - vantiq://via/types/context/common.txt | <common_documentation> | properties, structure, and rules
```

types の instruction は `create` と `update` の2つである。
VEH（collaborationtypes）には `create-update`、`debug`、`explain` の3つがある。
このように、そのリソースに対してどんな操作が用意されているかは、manifest を見れば一目でわかる。

## context が共有する知識

**context** は、リソースを横断して共有される知識である。
VEH の開発に関わる context は次のように分類できる。

| 内容 | 例 |
|---|---|
| activity パターンのカタログ | EventStream、Filter、SaveToType、Transformation、Procedure、LogStream 等 |
| 組み立てパターン例 | Filter から Action への接続、Branch による分岐、Join による合流 |
| EventStream のソース仕様 | inbound（サービスの event type）と internal（topic 等）の設定方法 |
| トップレベル構造 | `name`、`active`、`isEventHandler`、`assembly` の各フィールド |
| core-rules（共通） | 命名規則、CRUD セマンティクス、OCC と `ars_version`、ファイルパス導出ルール |

context が配る組み立てパターンの一例が、Filter で条件判定して後続の処理に渡す構成である。
次は `vantiq://via/collaborationtypes/context/common-patterns.txt` に含まれる実物の JSON である。

```json
{
  "Source":  {"pattern": "EventStream", "configuration": {"inboundResource": "topics", "inboundResourceId": "/my/topic", "childStreams": ["Check"]}},
  "Check":   {"pattern": "Filter",      "configuration": {"condition": "event.value > 10", "childStreams": ["Log"], "rejectionStreams": []}},
  "Log":     {"pattern": "LogStream",   "configuration": {"level": "info"}}
}
```

この JSON は、VEH の assembly を構成するタスクの接続方法を示している。
各タスクは `pattern` と `configuration` を持ち、下流への接続は `childStreams` 配列にタスク名を書く。
明示的なエッジオブジェクトは不要であり、接続は configuration 内の配列だけで表現する。

このパターンは、VEH を作成するよう求められたときに、サーバーから自動的に提供される。
開発者が同じ知識を別のドキュメントとして持つ必要はない。
正しい知識を適切なタイミングで配るのは MCP Server の役割であり、手元に複製すると二重管理になりサーバー側とのズレを生む。

## instruction が定める操作の手順

**instruction** は、特定の操作（作成、更新、デバッグ等）に対する手順である。
AI 開発ツールに対して、どの役割で、どの手順で、どのルールに従ってその操作を行うかを指示する。

collaborationtypes の create-update instruction（`vantiq://via/collaborationtypes/instructions/create-update.txt`）には、次のような内容が含まれる。

まず、役割を設定する。
Vantiq Visual Event Handler 定義の専門家として、妥当な VEH の JSON 定義を作りサーバーに保存する、という立場である。

次に、VEH 固有のルールを教える。

- プレースホルダを通さない。
  値が不足していれば捏造せず、ユーザーに確認する。
- 未知の activity パターンは定義を必ず参照する。
  `<activity_patterns>` タグで遅延ロードし、パターンの仕様を確認してから使う。
- 明示的なエッジを書かない。
  タスク間の接続は configuration 内の `childStreams`、`rejectionStreams` 等の配列で表現する。
- 命名は PascalCase にする。
  INBOUND ハンドラの名前は `ServiceName.EventTypeName` とする。
- 深くネストした VAIL よりも Procedure パターンを優先する。
  複雑なロジックは Procedure に切り出し、VEH のタスクから呼び出す構成にする。

保存のセマンティクスは「保存＝検証」である。
新規作成は `insert`（resource は `collaborationtypes`）、更新は `upsert` で行う。
サーバーは不正な定義を弾くため、保存が通ればその時点で構文上の妥当性が確認されたことになる。
新規の VEH は同じターンでサービスにも登録する。

保存が成功しても、instruction はここで完了とはしない。
次のステップで状態を確認する。

1. `selectOne` で VEH を取得し、`currentState` が `complete` であることを確認する。
   作成直後は `unbound` の場合もあるため、サービスとの結合後に再度確認する。
2. サービス側を `selectOne` で取得し、`vailErrors` がないことを確認する。
3. event type の `implementingResource` が VEH を指しているか確認する。
4. ユーザーにランタイム検証の可否を確認する。
5. 許可された場合に限り `publish` でイベントを送信して動作を検証する。

## Visual Event Handler を作成するまでの一連の流れ

ここまでの3レイヤーが実際の開発でどう組み合わさるかを、一つの依頼で追う。
依頼は「温度センサーの読み取りを受け、80℃を超えたらアラートを記録する Visual Event Handler を作って」とする。

最初に、AI 開発ツールは `resources/list` を呼び、16件の manifest と2件の共通 context doc を取得する。
タスクが VEH の作成なので、`collaborationtypes` の manifest を選ぶ。

次に、`vantiq://via/collaborationtypes/manifest.txt` を読み、操作に対応する instruction として `create-update.txt` を特定する。
同時に、base context（`core-rules.txt`、`project-files.md`）をロードする必要があることも把握する。

instruction と context をロードすると、「VEH は必ずサービスに登録する」というルールを認識する。
さらに、下流タスクが `event.temperature` のようにイベントのプロパティを参照するなら、EventStream に `schema`（イベント構造を定義した Type）を設定する必要があることもわかる。
schema がないと event が生文字列になり、実行時にプロパティ参照が失敗する。

ここで、作るべきリソースの構成が決まる。

- Type `com.demo.iot.TemperatureReading`（role は schema、プロパティは sensorId と temperature）。EventStream の schema として使う。
- Type `com.demo.iot.TemperatureAlert`（role は standard、プロパティは sensorId、temperature、threshold、raisedAt）。アラートの永続化先。
- Service `com.demo.iot.SensorMonitor`（INBOUND event type `reading`、eventSchema は TemperatureReading、`implementingResource` は VEH を指す）。
- VEH `com.demo.iot.SensorMonitor.reading`（下記の定義）。

instruction のルールと context の組み立てパターンに従い、次のような VEH 定義を生成する。

```json
{
  "name": "com.demo.iot.SensorMonitor.reading",
  "active": true,
  "isEventHandler": true,
  "assembly": {
    "ReadingStream": {
      "pattern": "EventStream",
      "configuration": {
        "inboundResource": "services",
        "inboundResourceId": "com.demo.iot.SensorMonitor",
        "eventTypeName": "reading",
        "schema": "com.demo.iot.TemperatureReading",
        "childStreams": ["CheckThreshold"]
      }
    },
    "CheckThreshold": {
      "pattern": "Filter",
      "configuration": {
        "condition": "event.temperature > 80",
        "childStreams": ["SaveAlert"],
        "rejectionStreams": []
      }
    },
    "SaveAlert": {
      "pattern": "SaveToType",
      "configuration": {
        "type": "com.demo.iot.TemperatureAlert"
      }
    }
  }
}
```

この定義には、VEH の構造上の特徴が反映されている。
ルートタスクの ReadingStream は EventStream パターンであり、サービスの INBOUND event type `reading` からイベントを受ける。
`schema` に TemperatureReading を指定することで、下流の Filter が `event.temperature` を参照できるようになる。
タスク間の接続は `childStreams` の配列で表現し、明示的なエッジオブジェクトは書かない。

生成した VEH を、`insert` ツールで resource `collaborationtypes` として送信する。
保存＝検証であり、サーバーが不正な定義を弾く。

サービスの event type `reading` の `implementingResource` に `system.collaborationtypes/com.demo.iot.SensorMonitor.reading` を設定すると、VEH とサービスが結合する。
なお、サービスを VEH 参照付きで insert した直後に `io.vantiq.service.eventType.implementation.resource.not.found` という vailError が出ることがある。
これは VEH がまだ作成されていない場合の一時的なエラーであり、VEH を作成して結合が済めば解消する。

insert が成功しても、AI 開発ツールはここで止まる。
instruction に従い、次を実行する。

1. `selectOne` で VEH `com.demo.iot.SensorMonitor.reading` を取得する。
   作成直後は `currentState` が `unbound` であっても、サービスとの結合後に `complete` になる。
2. `selectOne` でサービス `com.demo.iot.SensorMonitor` を取得し、`vailErrors` がないことを確認する。
3. event type `reading` の `implementingResource` が `system.collaborationtypes/com.demo.iot.SensorMonitor.reading` を指すか確認する。
4. ユーザーにランタイム検証の可否を確認する。
5. 許可されたら `publish` でテストイベントを送信する。
   宛先は `system.services/com.demo.iot.SensorMonitor/reading` である。

ランタイム検証では、閾値以下と閾値超過の2件を送り分ける。
`{"sensorId":"sensor-01","temperature":25}` を publish するとアラートは記録されず、`{"sensorId":"sensor-01","temperature":95}` を publish すると TemperatureAlert に1件が追加される。
`select` で TemperatureAlert を照会し、レコードが作成されたことを確認する。

SaveToType はイベント（sensorId、temperature）をそのまま保存するため、threshold や raisedAt は空になる。
これらを埋めたい場合は、Filter と SaveToType の間に Transformation パターンを1つ挟めばよい。
VAIL を書く必要はなく、VEH の activity パターンだけで対応できる。

## このワークフローでできることと注意点

このワークフローが開発者にもたらすものを、まず挙げる。

| 項目 | 内容 |
|---|---|
| リソースごとの操作の発見 | manifest を読むだけで、そのリソースにどんな操作が可能かがわかる |
| サーバー提供の知識とサンプル | activity パターンのカタログ、組み立てパターン例、EventStream のソース仕様等が配られ、正確な定義を生成できる |
| 完了検証の組み込み | 保存後の `currentState` チェックやサービス登録確認が手順に入っている |
| ローカルとサーバーの二重永続化 | 成功した定義はローカルファイルとサーバーの両方に保存される |
| 遅延解決による context 管理 | XML タグ参照で、必要な知識だけをオンデマンドにロードできる |

一方で、このワークフローには注意点がある。

- ガイダンスは助言であり、強制ではない。
  instruction や完了検証の手順は AI 開発ツールへの指示であって、ツールがそれをスキップする可能性は残る。
  「手順を読めば必ず守られる」とは言えず、開発者側やハーネスでの規律も要る。
- `ars_version` の省略を防げない。
  OCC のために `ars_version` を含めるべきだが、ツールが省いた場合、サーバーは版の衝突を検知できない。
  更新操作では `ars_version` の付与を確認するとよい。
- manifest の範囲外の操作には手順がない。
  載っていない操作には instruction が存在せず、ツールは一般知識に頼ることになる。
  その場合、manifest ベースの操作より精度は落ちやすい。

## まとめ

- MCP Server は Tools（REST のラッパー）と Resources（知識テキスト）の2種類のプリミティブを提供し、知識を読んでから操作するフローを実現する。
- manifest はリソースごとの目次であり、利用可能な操作（instruction）と必要な知識（context）の在り処を教える。
- context は activity パターンのカタログ、組み立てパターン例、EventStream のソース仕様等の共有知識であり、正確な VEH 定義の生成の土台になる。
- instruction は操作ごとの手順であり、役割設定、VEH 固有のルール、保存のセマンティクス、完了後の確認ステップを指示する。
- 保存後の確認では、`currentState` が `complete` であること、サービス側に `vailErrors` がないこと、`implementingResource` が VEH を指していることを検証し、ランタイムテストまで行って初めて完了とする。

### 代替: VAIL Event Handler 版

VEH のかわりに VAIL で Event Handler を記述することもできる。
Vantiq は VEH を推奨しているが、VAIL 版が必要な場合は `rules` の manifest と instruction を使う。
VAIL 版では `WHEN EVENT OCCURS ON` のパスを `"/services/<Service>/<EventType>"` とし、`/inbound/` のような中間セグメントは付けない。
また VAIL の `RETURN` は本体の最終文にしか置けないため、途中で抜ける早期 return は使えない。
