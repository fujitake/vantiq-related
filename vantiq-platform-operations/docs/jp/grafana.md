## Grafana 環境構築全般
- ここでは Grafana の環境構築にまつわるトピックを全般的扱う
## Table Of Contents
- [DB を sqlite3 から grafana-mysql に切替](#2mysql)

<h2 id="2mysql">1. DB を sqlite3 から grafana-mysql に切替</h2>
## Grafana: Email Notification 環境の構築
### 1. deploy.yaml の編集
- 以下の項目を適宜書き換える

|項目|内容|
----|----
|&lt;smtp server host name&gt;|SMTP サーバの名称|
|&lt;from address&gt;|誰から転送されたのか（メールアドレス）|
|&lt;user&gt;|ユーザ名称|
|&lt;password&gt;|パスワード|

- deploy.yaml を以下の様に構成する
<pre>
grafana:
  grafana.ini:
    smtp:
      enabled: true
      host: &lt;smtp server host name&gt;
      from_address &lt;from address&gt;
      user: &lt;user name&gt;
      password: &lt;password&gt;
</pre>

### 2. Task deployVantiq の実行
- 以下の項目を適宜書き換える

|項目|内容|
----|----
|&lt;cluster name&gt;|クラスタ名称|
```
cd ~/k8sdeploy_tools
./gradlew -Pcluster=<cluster name> deployVantiq
```

### 3. Vantiq IDE の設定
- 以下に手順を示す

|項目|内容|
----|----
|ログイン|・system admin アカウントでログイン|
|<img src="../../imgs/grafana/confirm.jpg" width="300px">|・SMTP の設定結果を確認|
|Grafana 表示|・TOP Menu > Administer > grafana|
|<img src="../../imgs/grafana/alertrules.jpg" width="300px">|・Alert Rules 選択|
|<img src="../../imgs/grafana/alerting.jpg" width="300px">|・Notification Channel 選択<br>・New channel をクリック|
|<img src="../../imgs/grafana/setting.jpg" width="300px">|・Email を選択<br>・Addresses: 転送先のメールアドレスを設定（複数可能）<br>・Send Test で確認|
