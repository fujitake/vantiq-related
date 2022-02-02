## はじめに

この記事では、SORACOMから提供されている[GPSマルチユニット SORACOM Edition](https://soracom.jp/store/5235/)とVantiqのインテグレーション方法を案内します。

この手順をフォローすれば、基本的な設定を終了したGPSマルチユニットのデータをVantiqに送信することができます。

## 前提条件

### ソフトウェア

- 有効なVantiq利用権を有していること
- Vantiq開発環境にて必要なNamespaceを作成済みであること
- Vantiq開発環境にてRESTエンドポイントとして利用するTopicを用意済みであること
- Vantiq開発環境にてAccess Tokenを発行済みであること
- 有効なSORACOMアカウントを有していること

### ハードウェア

- GPSマルチユニット SORACOM Editionを有していること
- GPSマルチユニットの基本的な設定が完了していること
- [GPSマルチユニットのハードウェアセットアップ手順](https://users.soracom.io/ja-jp/guides/iot-devices/gps-multiunit/how-to-use/)
- [GPSマルチユニットのデバイス設定](https://users.soracom.io/ja-jp/guides/iot-devices/gps-multiunit/visualize-harvest/#ステップ-2-gps-マルチユニットのデバイス設定を行う)

## 設定手順

### GPSマルチユニットのデータを確認

GPSマルチユニットのデータがSORACOMコンソールで受信できている状態であることを確認する

SORACOMコンソール左上のMenuからデータ収集・蓄積・可視化の下にあるSORACOM Harvest Dataをクリック

リソースにて適切なSIMが選択されていれば、データ受信の状況が確認できます。リソースが選択されていない場合、何も表示されないので、適切なSIMを選択します。

データは、`{"payload":"(base64エンコードされたデータ)"}`の形で送信されます。

Harvest Dataでは、自動的にbase64デコード処理などが行われます。

```json:
{"value":"{\"lat\":36.292457,\"lon\":138.420748,\"bat\":3,\"rs\":4,\"temp\":12.4,\"humi\":50.9,\"x\":null,\"y\":null,\"z\":null,\"type\":0}"}
```

### データ転送設定

SORACOMでは、いくつかの方法でデータ転送ができます。この記事では、SORACOM Beamを使ってデータ転送する方法を案内します。

SORACOMコンソール左上のMenuからSORACOM Air for セルラーの下にあるSIMグループをクリックします。

設定を行いたいSIMグループの名前をクリックします。

SORACOM Beam 設定のメニューを開き+から`UDP->HTTP/HTTPSエントリポイント`を選択します。GPSマルチユニットでは、`UDP->HTTP/HTTPSエントリポイント`の設定が必要です。

転送先に指定すべき内容のサンプルは下記となります。

- プロトコル: https
- ホスト名: 対象となるVantiq環境のFQDN (例: dev.vantiq.co.jp)
- ポート番号: 443
- パス: /api/v1/resources/topics/soracom/gpsmulti (Vantiq IDEにて作成したTopic名)

ヘッダ操作のカスタムヘッダに`アクション:追加`を指定し`Authorization`として`bearer {vantiq access token}`を設定します。

### Vantiqでの処理

上記まで設定が完了した状態でVantiq Topicは、`{"payload":"(base64エンコードされたデータ)"}`を受信する状態となります。

下記Procedureを用意し、App Builderなどにてイベントを渡すと、base64デコードした必要なデータを取り出すことができます。

```js script:
PROCEDURE gpsmultidecode(event)

var decodedValue = Decode.base64(event.payload)
return decodedValue
```

ここまでで、必要なデータを受信し、Vantiq上で処理できる状態となります。

## SORACOM利用料金について

SORACOMの利用料金は、プロダクト(SIM等の物品)、データ通信(SIMを使った通信量)、アプリケーション連携(外部のCloudサービスとの連携など)、ネットワークから構成されています。

データ通信の料金は、SIMあたりの月額基本料金と通信量課金となります。GPSマルチユニットに含まれる特定地域向け IoT SIMカード plan-D D-300MBは、一枚あたり月額300円(税抜き)となります。

アプリケーション連携の料金は、各サービスによって費用が変わります。GPSマルチユニットに含まれる特定地域向けIoT SIMにてSORACOM Beamを使う場合、１リクエストあたり0.00099円となります。

GPSマルチユニットを10分ごとにデータ送信する設定を行った場合、1ヶ月を30日とすると4320回のリクエストとなり、4.3円となります。ただし、1アカウントあたり月間 100,000リクエストまで毎月無料となります。

[SORACOM 料金計算ツール](https://calculator.soracom.io/#/ja)


## 参考

[SORACOM Beam](https://soracom.jp/services/beam/)

[GPSマルチユニットが送信するデータフォーマット](https://users.soracom.io/ja-jp/guides/iot-devices/gps-multiunit/payload/)
