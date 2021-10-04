# Fluentdを使用したVantiqへのデータ連携
デバイスが取得したメトリクスデータがフラットファイル形式でログファイル等に出力されている場合、fluentdを使ってVantiqに連携することが可能です。
この記事では、nginxのアクセスログを例として設定、データ連携までを説明しています。

## Fluentd の設定方法

- OS として **Windows 10, Linux(Ubuntu 20.04)** を想定している
- 動作確認方法として Vantiq を用いる（Topics を受け取る）
- 正規表現を使ってフラットファイル（nginx のログ）の整形の例
## Table Of Contents
- [Fluentd のインストール（Windows 10）](#instf)
  - [以下のサイトからダウンロード](#download)
  - [Plugin(http_ext) のインストール](#plugin)
  - [設定ファイルの作成](#conf)
  - [起動する](#invoke)
  - [動作確認](#confirm)
- [Fluentd のインストール（Ubuntu 20.04）](#instubnt)
  - [以下のサイトからダウンロード](#dlubuntu)
  - [Plugin(http_ext) のインストール](#plugin-ubnt)
  - [設定ファイルの作成](#conf-ubnt)
  - [起動する](#invoke-ubnt)
  - [動作確認](#confirm-ubnt)
- [正規表現を用いてログを集計する（Vantiq）](#regexp)
  - [正規表現の使い方](#howto)
  - [要素に分解して集計](#analize)

<h2 id="instf">1. Fluentd のインストール（Windows 10）</h2>

<h3 id="download">1.1 以下のサイトからダウンロード</h3>

- [Download Fluentd](https://www.fluentd.org/download)
<img src="../../imgs/fluentd/td-agent-win.jpg" width="70%">

- 2021/09/21 現在 td-agent-4.2.0-x64.msi という名前だが td-agent とは fluentd の安定版のこと
- インストール ウィザードの支持に従ってインストール

<h3 id="plugin">1.2 Plugin(http_ext) のインストール</h3>

- Windows ボタンをクリックすると、以下の様なメニューが表示される
<img src="../../imgs/fluentd/prompt.jpg" width="50%">

- これを右クリックして Administrator として実行する
<img src="../../imgs/fluentd/admin.jpg" width="50%%">

- Vantiq で動作確認を可能にするため Output 用の Plugin (http-ext) を導入する
- ログ ファイル出力用に nginx を用いる
- 以下のコマンドを入力
```
cd \opt\td-agent
td-agent-gem install fluent-plugin-out-http-ext
```
<h3 id="conf">1.3 設定ファイルの作成</h3>

- 念の為バックアップを取る
```
ren etc\td-agent\td-agent.conf etc\td-agent\td-agent.conf.org
```
- 適当なエディタで **etc\td-agent\td-agent.conf** ファイルを作成し以下の内容をコピペする
- ちなみにこの設定は、以下の内容を想定している

|項目|内容|
---|---
|①: Vantiq Topic 名|Vantiq側でイベントを受信するTopicのリソースURL。<br /> 以下の例は`jp.co.vantiq.fluentd`に相当する。|
|②: Access Token|VantiqのターゲットのNamespaceで発行したAccess Token|
|③: path|監視するログのパスとファイル名（ここでは nginx）|
|④: pos_file|監視するログ ファイルのカウント用のパスとファイル名|
```
####
## Output descriptions:
##
<match **>
  @type http_ext
  endpoint_url      https://internal.vantiqjp.com/api/v1/resources/topics//jp.co.vantiq/fluentd # ①
  http_method       post
  serializer        json
  use_ssl           true
  verify_ssl        false
  <headers>
    Authorization Bearer dWXRMtWjRXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX6EtrM= # ②
  </headers>
</match>

####
## Source descriptions:
##
<source>
  @type tail
  path     c:/dev/nginx-1.20.1/logs/access.log # ③
  pos_file c:/var/log/td-agent/access.log.pos  # ④
  tag local.syslog
  <parse>
    @type none
  </parse>
</source>
```

<h3 id="invoke">1.4 起動する</h3>

```
fluentd -c etc\td-agent\td-agent.conf
```

<h3 id="confirm">1.5 動作確認</h3>

- nginx のサイトにアクセスしそのアクセス ログが受信できることを確認する

|Topics|受信データ|
---|---
|<img src="../../imgs/fluentd/result.jpg">|<img src="../../imgs/tskvent.jpg">|

<h2 id="instubnt">2. Fluentd のインストール（Ubuntu 20.04）</h2>

<h3 id="dlubuntu">2.1 以下のサイトからダウンロード</h3>

- amd64 版, arm64 版が存在するので自分の環境に合わせて選択
- [Download Fluentd](https://www.fluentd.org/download)
- Ubuntu **Focal** を選択
<img src="../../imgs/fluentd/td-agent-ubuntu.jpg" width="70%">

- ダウンロードしたフォルダに移動してインストールする
```
cd ~/Downloads
sudo dpkg -i ./td-agent_4.2.0-1_amd64.deb
```
<h3 id="plugin-ubnt">2.2 Plugin(http_ext) のインストール</h3>

```
cd /opt/td-agent
sudo td-agent-gem install fluent-plugin-out-http-ext
```

<h3 id="conf-ubnt">2.3 設定ファイルの作成</h3>

- 適当なエディタで **/opt/td-agent/td-agent.conf** ファイルを作成し以下の内容をコピペする
- ちなみにこの設定は、以下の内容を想定している

|項目|内容|
---|---
|①: Vantiq Topic 名|Vantiq側でイベントを受信するTopicのリソースURL。<br /> 以下の例は`jp.co.vantiq.fluentd`に相当する。|
|②: Access Token|VantiqのターゲットのNamespaceで発行したAccess Token|
|③: path|監視するログのパスとファイル名（ここでは nginx）|
|④: pos_file|監視するログ ファイルのカウント用のパスとファイル名|
```
####
## Output descriptions:
##
<match **>
  @type http_ext
  endpoint_url      https://internal.vantiqjp.com/api/v1/resources/topics//jp.co.vantiq/fluentd # ①
  http_method       post
  serializer        json
  use_ssl           true
  verify_ssl        false
  <headers>
    Authorization Bearer dWXRMtWjRXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX6EtrM= # ②
  </headers>
</match>

####
## Source descriptions:
##
<source>
  @type tail
  path     /var/log/nginx/access.log # ③
  pos_file /var/log/nginx/access.log.pos  # ④
  tag local.syslog
  <parse>
    @type none
  </parse>
</source>
```

<h3 id="invoke-ubnt">2.4 起動する</h3>

```
cd /opt/td-agent
sudo bin/fluentd -c share/td-agent.conf
```

<h3 id="confirm-ubnt">2.5 動作確認</h3>

- nginx のサイトにアクセスしそのアクセス ログが受信できることを確認する

|Topics|受信データ|
---|---
|<img src="../../imgs/fluentd/result.jpg">|<img src="../../imgs/tskevent-ubnt.jpg">|

<h2 id="regexp">3. 正規表現を用いてログを集計する（Vantiq IDE）</h2>
ここでは、VantiqのTopicで受け取ったイベントデータの整形について説明します。

<h3 id="howto">3.1 正規表現の使い方</h3>
VAILコードで正規表現により、文字列内の特定要素を抽出できます。

|項目|内容|
---|---
|&lt;patterns&gt;|Regular Expression のパターン（※）|
|&lt;target&gt;|対象の文字列|

※ Patterns はこの[サイト](https://docs.oracle.com/javase/8/docs/api/java/util/regex/Pattern.html)を参照
```
var re = regExp("<patterns>")
var result = <target>.match(re)
```

<h3 id="analize">3.2 要素に分解して集計</h3>

- 3.2.1 Remote Host 部分を切り取る
```
var reRemote = regExp("^([^ ]*)")
var remoteip = event.message.match(reRemote)
```

- 3.2.2 Stateful Service 用の Type を定義
<img src="../../imgs/fluentd/sstype.jpg" width="60%">

- 3.2.3 初期化処理の定義
```
private PROCEDURE LogSvc.initializePartitionedState()

RemoteData = Concurrent.Map()
```

- 3.2.4 Stateful Service 本体の定義 【注】この処理を呼ぶ前に SpritByGroup で Remote Host 単位に分割しておくこと
```
PROCEDURE LogSvc.countAccess(remote String)

RemoteData.compute(remote, (key, stats) => {
    if (stats == null) {
        stats = {
            remote: remote,
            count: 0
        }
    }
    stats.count += 1    
    log.info(stringify(stats))
    return stats
})
```
- 3.2.5 実行結果の確認
<img src="../../imgs/fluentd/ssresult.jpg" width="50%">
