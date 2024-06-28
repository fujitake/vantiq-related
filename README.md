[English follows Japanese:](https://github.com/fujitake/vantiq-related/tree/main#purpose)
***

## 目的

このリポジトリは、Vantiq 製品に関わる技術的なガイドや設定手順、及び関連サービスとのインテグレーションに関するセットアップ手順などを共有するためのものです。


Vantiq アプリケーション開発者向けの情報となります。初めて Vantiq を触る方向けの情報、Vantiq を使ってクラウドサービスとの連携のサンプルや手順を知りたい方、IoT デバイスやゲートウェイが生成するデータを Vantiq に送信する場合のサンプル、Google Colaboratoryで用意するデータジェネレータなど :globe_with_meridians: [製品リファレンス](https://dev.vantiq.com/docs/system/index.html) ではカバーされていない範囲の情報を提供することを目的としています。

## [Vantiq 入門](./vantiq-introduction/readme.md)

Vantiq を用いたアプリケーションの開発を行う上で、必要となる知識をワークショップ形式などで解説しています。

- [開発環境の準備](./vantiq-introduction/readme.md#開発環境の準備)
- [アプリケーション開発](./vantiq-introduction/readme.md#アプリケーション開発)
- [インフラ／クラウド入門](./vantiq-introduction/readme.md#インフラクラウド入門)

## Vantiq アプリケーション開発関連

### [Vantiq のアプリケーション開発を学ぶ](./vantiq-apps-development)

Vantiq アプリケーション開発チーム向けのアプリ開発に関するガイドや運用に関する情報をまとめています。

### [Google Colaboratory を使ったデータジェネレータ](./vantiq-google-colab)

Google Colaboratory の基本的な使い方やデータジェネレータのサンプルコードを紹介しています。  
Vantiq アプリを開発する際に便利なデータジェネレータを簡単にご用意頂けます。

### [Vantiq とパブリッククラウド サービスとの連携](./vantiq-external-services-integration)

Vantiq アプリケーション開発チーム向けの Vantiq とパブリッククラウド サービスとの連携に関するガイドや設定手順を紹介しています。MQTT や Kafka といったブローカー、データベースサービス、メールサービスとの連携に関するガイドや手順となります。

### [Vantiq とデバイスとの連携](./vantiq-devices-integration)

Vantiq アプリケーション開発チーム向けのVantiqとデバイスを連携させるガイドラインやサンプルコードです。

### [Vantiq とAI/MLとの連携](./vantiq-aiml-integration)

Vantiq アプリケーション開発チーム向けのVantiqとAI/MLを連携させるガイドラインやサンプルコードです。

## Vantiq Private Cloud 関連

Vantiq Private Cloud のインストールと運用管理における対応手順など、インフラチームの方々向けの情報をまとめました。

### [Vantiq Private Cloud 構築のための AWS EKS / Azure AKS インフラ関連情報](./vantiq-cloud-infra-operations)

Vantiq Private Cloud を稼働させるための AWS EKS、Azure AKS に関するガイドや手順となります。こちらで紹介している Terraform スクリプトを実行頂くと、Vantiq Private Cloud に必要な設定一式をご用意頂けます。また、AWS EKS、Azure AKS のバージョンアップの手順も記載しております。

### [Vantiq Private Cloud のインストールと運用管理](./vantiq-platform-operations)

別途用意されたAWS EKS、Azure AKS 環境に対し、Vantiq Private Cloud をインストールする手順や運用管理に関するガイドや手順を紹介しています。運用時に必要となる作業手順やトラブルシューティングガイドもございます。

### [Vantiq Edge のインストール](./vantiq-edge-operations)

Vantiq EdgeをセットアップするためのDocker composeのインストールやVantiq Edgeのインストール手順などを紹介しています。

***

# Purpose
This repository is for sharing various technical guidance and instructions of Vantiq product related knowledges. It also contains public cloud services which potentially integrate with Vantiq.

## Vantiq Application Development related

 Articles for Vantiq beiginners, sample codes and procedure for Vantiq apps Developers who want to integrate with public cloud services, and Python programmers are using IoT Sensors / Gateways / Google Colaboratory send messages to Vantiq.

### [Learning developing Vantiq applications](./vantiq-apps-development)
Guides and learning materials for developing and operating Vantiq Applications.

### [Integration with External Services and Vantiq](./vantiq-external-services-integration/readme_en.md)
Guides and procedures for integrating Vantiq with cloud web services, brokers, and database services.  

### [Integration with IoT devices with Vantiq](./vantiq-devices-integration/readme_en.md)
Guidelines and sample code for integrating Vantiq with devices.

## Vantiq Private Cloud related

Articles for infrastructure management guys include installation preparation of Vantiq Private Cloud and operations.

### [AWS EKS/Azure AKS Infrastructure for Vantiq Private Cloud](./vantiq-cloud-infra-operations)
Terraform codes for setting up AWS ESK and Azure AKS infrastructure run Vantiq Private Cloud instance.

### [Vantiq Private Cloud Installation and Management](./vantiq-platform-operations)
Guides and procedures for the Vantiq Private Cloud Management Team on installing and operating of Vantiq Private Cloud on cloud infrastructure.