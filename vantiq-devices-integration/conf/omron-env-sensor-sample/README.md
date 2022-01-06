[English Version here](README_en.md)

# 【OMRON環境センサー】センサー起動からVantiqへ送信までの手順

### **本手順で必要なもの**
---
- Raspberry Pi 3B+ または 4B
- [Raspberry Pi OS with desktop (32bit)](https://www.raspberrypi.org/software/operating-systems/#raspberry-pi-os-32-bit)
- マウス
- ディスプレイ
- ACアダプタ
- SDカード
- OMRON環境センサー（2JCIE-BU01または2JCIE-BL01）
- サンプルスクリプト（env_usb_observer.py または env_bag_observer.py）
    - センシングした内容をVantiqに送信するサンプルスクリプト
    - 使用する環境センサーが2JCIE-BU01（USB型）なら「env_usb_observer.py」、2JCIE-BL01（バッグ型）なら「env_bag_observer.py」を使用する

### **Vantiq IDEでの準備**
---
1. Vantiq開発環境にて環境センサーのデータの送信先となるTopicを作成する
    1. Add -> Advanced -> Topic... にて+ New Topicをクリックし、Nameに「/devices/env」を設定する
2. アクセストークンを発行する
    1. Administer -> Advanced -> Access Tokensにて+ Newをクリックし、適当な名前をつけ有効期間を設定してアクセストークンを発行する

### **手順**
---
1.  balenaEtcherなどのアプリケーションを使用してRaspberry Pi OSをSDカードに書き込む
2.  Raspberry Piを起動しUIに従って設定を行う
    1. 言語設定
    2. ネットワーク設定（Wifi、SSH）
4. 環境センサーをUSBポートに接続する
5. 環境センサーのMacアドレスを確認する
```
$ sudo hcitool lescan
LE Scan ...
C2:B7:E4:CC:FE:79 Rbt
※「Rbt」が環境センサーのMacアドレス
```
6. サンプルスクリプトを編集し、以下の設定を行う
    1. 準備手順で作成したTopicのエンドポイント
    <br/>例:
    VANTIQ_ENDPOINT = 'https://dev.vantiq.co.jp/api/v1/resources/topics//devices/env'
    2. 準備手順で作成したアクセストークン
    <br/>例:
    VANTIQ_ACCESS_TOKEN = 'abcdefg12345...='
    3. 手順5で確認した環境センサーのMacアドレス
    <br/>例:
    ENV_SENSOR_MAC_ADDRESS = 'C2:B7:E4:CC:FE:79'
7. Raspberry Piの任意のディレクトリにサンプルスクリプトを配置する
8. bluepy(BLEデバイスを制御するPythonモジュール)をインストールする
```
sudo apt install libglib2.0-dev
pip install bluepy
```
9. その他、サンプルスクリプトで使用しているモジュールでRaspberry Piにないものがあればインストールする
```
例:
pip install requests
```
10. サンプルスクリプトを実行し、データが送信されることを確認する
```
例:
$ python env_usb_observer.py
Published Event: 2021/09/21 11:03:46
{'pressure': 1005, 'noise': 42, 'temperature': 29, 'env_sensor_id': 'env_sensor1', 'etvoc': 3, 'light': 44, 'eco2': 422, 'humidity': 55}
```
