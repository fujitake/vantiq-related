# **事前準備（データジェネレーターの設定）**

使用するデータジェネレーターの zip ファイル  
- [`TrainingDataGen.zip`](./../../conf/TrainingDataGen.zip)


## ***Step 1***
1. MQTT Broker Server を用意します。（※Internetからアクセスできるもの）  
   下記に一例をあげます。  
   - MQTT Broker  
      - Amazon MQ  
      - Mosquitto  
      - [HIVEMQ Public MQTT Broker](https://www.hivemq.com/public-mqtt-broker/)  
   - 参考: [【速報】新サービスAmazon MQを早速使ってみた！](https://dev.classmethod.jp/articles/re-invent-2017-amazon-mq-first-impression/)  
1. MQTT Broker Server の URI をメモしておきます。  

### 注意点

- パブリックな MQTT Broker Server は、不意に接続が切断されてしまうということがあるため、利用する際は注意してください。  
  Source のアクティブ化などについては [Source のアクティブ化](./0-04_SourceActivate.md) を参照してください。

## ***Step 2***

[VANTIQ の開発環境](https://dev.vantiq.co.jp) にログインします。  

## ***Step 3***

1. 「新規 Project」ウィンドウが表示されるので、「新規 Vantiq Namespace」を選択し、Name に **データジェネレーター** 用の Namespace 名を入力して、「_続行_」をクリックします。  
   （例：TrainingDataGenNS）  
   <img src="../../imgs/Lab01/image0.png" width=70%>

### 参考

- [2.3: リソースの整理](https://community.vantiq.com/courses/vantiq%e3%82%a2%e3%83%97%e3%83%aa%e3%82%b1%e3%83%bc%e3%82%b7%e3%83%a7%e3%83%b3%e9%96%8b%e7%99%ba%e3%82%b3%e3%83%bc%e3%82%b9%ef%bc%86%e3%83%ac%e3%83%99%e3%83%ab1%e8%aa%8d%e5%ae%9a%e8%a9%a6%e9%a8%93v1-2/lessons/2-vantiq%e3%83%97%e3%83%a9%e3%83%83%e3%83%88%e3%83%95%e3%82%a9%e3%83%bc%e3%83%a0%e3%81%ae%e7%b4%b9%e4%bb%8b/topic/2-3-%e3%83%aa%e3%82%bd%e3%83%bc%e3%82%b9%e3%81%ae%e6%95%b4%e7%90%86/)


## ***Step 4（データジェネレーターのインポート）***

＊ 複数台のポンプにそれぞれ取り付けられた温度センサーと回転数センサーからのデータを擬似的に発生させるデータジェネレーターを準備します。  

1. 「Projects」 > 「インポート...」 を開き、「Project またはデータのインポート」ウィンドウを開きます。  
   事前に配布したデータジェネレーターの zip ファイル 「[`TrainingDataGen.zip`](https://github.com/fujitake/vantiq-related/raw/main/vantiq-apps-development/1-day-workshop/conf/TrainingDataGen.zip)」をドラッグ&ドロップします。  

   <img src="../../imgs/Lab01/image006.png" width=70%>

1. 「_インポート_」をクリックします。

1. インポートすると確認ダイアログが表示されるので「_リロード_」をクリックします。

## ***Step 5 (MQTT Broker の設定)***<a id="mqtt_broker_setting"></a>

＊ サンプルデータを生成するためのサーバーの設定をご自身で準備された MQTT Broker に設定します。  

1. 「追加」 > 「Source...」 を開き、「Sources」ウィンドウを開きます。

1. `TrainingDataGenMQTT` をクリックし、「Source」ウィンドウを開きます。

1. 「Server URI」タブをクリックします。

1. 「編集」(小さい鉛筆) アイコンをクリックし、「Server URI の編集」ダイアログを開きます。  

   <img src="../../imgs/Lab01/image02.png" width=60%>

1. 「Server URI:」には、仮の値が設定されているので、ご自身で準備された MQTT Broker サーバーの URI に設定し直してください。「OK」をクリックします。  

   <img src="../../imgs/Lab01/image03.png" width=60%>

1. タイトルバーの右上にある _アクティブ状態オンに_ アイコンをクリックして、Source をアクティブにします。

   <img src="../../imgs/Lab01/image002.png" width=60%>

1. 隣にある _変更の保存_ アイコンをクリックして、保存します。


## ***Step 6（データジェネレーターの設定）***<a id="data_generator_setting"></a>

＊ 本ワークショップでは複数台存在するポンプそれぞれに温度センサーと回転数センサーが設置されており、データが送信されるという状況を前提にアプリケーションの作成を進めます。  
データジェネレーターを使用して、その状況を擬似的に再現します。

<img src="../../imgs/Lab01/image7.png" width=80%>

1. 「TrainingDataGeneratorClient」の「起動」 > 「_現在保存されているClientをClient Launcher(RTC)で実行_」をクリックし、データジェネレーターをブラウザーで開きます。  

   ＊ 今回のように VANTIQ で開発された Client は「**VANTIQ Client Launcher**」というアプリケーションで起動できます。  

   ![RTC](../../imgs/Lab01/RTC.gif)  

1. データジェネレーターを開いたら、上部にある _Setup_ をクリックします。  

   ![Setup button](../../imgs/Lab01/image9.png)

1. テキストボックスに「_5_」と入力します。 ＊ 半角で入力してください。

    <img src="../../imgs/Lab01/image010.png" width=25%>

1. _Update Number Pumps_ ボタンをクリックします。

1. 表に PumpNo 1\~5 が表示されていることを確認します。

1. MQTT の Topic 名を以下のように入力します。  

   RPMSSensor Topic： "_/***unique name***/pump/RPMS_"  
   TempSensor Topic： "_/***unique name***/pump/Temp_"  

   ＊ **_unique name_** の箇所には **会社名+ワークショップ名** など **他人と重複しない** 任意の値を入力してください。また、topic 名に**ダブルクォーテーションは含みません**。topic 名の**前後に半角スペースが入らないよう**にしてください。  

1. _Update Topics_ ボタンをクリックします。

   <img src="../../imgs/Lab01/image11.png" width=78%>

1. 上部にある _Date Generator_ をクリックし、画面を切り替えます。

   ![Data Generator](../../imgs/Lab01/image12.png)

1. _Start Generator_ ボタンをクリックし、約 6秒後に 「Last Message」 ウインドウにデータが表示されることを確認します。

 ＊ 以上で、ワークショップの事前準備は終了です。


# その他の補足説明

## ダミーデータの生成方法

1. 以下のようにして、**Data Generator** を開きます。  

   ![RTC](../../imgs/Lab03/RTC.gif)  

1. _Start Generator_ ボタンをクリックして温度と回転数データの生成を開始します。


## ポンプの異常を発生させる方法

1. データジェネレーターを開き、「Set Status of Pump」下の _Select a Pump_ プルダウンから「Pump 1」を選択します。

1. _Normal_ プルダウンから「High Temp & RPMS」を選択し、_Update Pump Status_ ボタンをクリックします (PumpID 1 のポンプの温度と回転数が高い数値になります)。

1. _Start Generator_ ボタンをクリックしてデータ生成を開始します。

## ***▷確認ポイント***

- データジェネレータでデータの生成ができない場合  
  Source がアクティブになっているか確認してください。  
  詳しくは [Source のアクティブ化](./0-04_SourceActivate.md) を参照してください。
