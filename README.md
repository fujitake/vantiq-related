[English follows Japanese:](https://github.com/fujitake/vantiq-related/tree/main#purpose)
***

## 目的

このリポジトリは、Vantiq 製品に関わる技術的なガイドや設定手順、及び関連サービスとのインテグレーションに関するセットアップ手順などを共有するためのものです。

## Vantiq アプリケーション開発関連

Vantiq アプリケーション開発者向けの情報となります。初めて Vantiq を触る方向けの情報、Vantiq を使ってクラウドサービスとの連携のサンプルや手順を知りたい方、IoT デバイスやゲートウェイが生成するデータを Vantiq に送信する場合のサンプル、Google Colaboratoryで用意するデータジェネレータなど[製品リファレンス](https://dev.vantiq.co.jp/docs/system/index.html)ではカバーされていない範囲の情報を提供することを目的としています。

### [Vantiq 入門](./vantiq-introduction/readme.md)

Vantiq を用いたアプリケーションの開発を行う上で、必要となる知識をワークショップ形式などで解説しています。

- [開発環境の準備](./vantiq-introduction/readme.md#開発環境の準備)
- [Vantiq の基本](./vantiq-introduction/readme.md#vantiq-の基本)
- [アプリケーション開発入門](./vantiq-introduction/readme.md#アプリケーション開発入門)

### [Vantiq のアプリケーション開発を学ぶ](./vantiq-apps-development)

Vantiq アプリケーション開発チーム向けのアプリ開発に関するガイドや運用に関する情報をまとめています。

- [Vantiqアカウント作成（開発者向け）](./vantiq-apps-development/1-day-workshop/docs/jp/0-01_Prep_for_Account.md)
- [Vantiqアカウント作成（組織管理者向け）](./vantiq-apps-development/1-day-workshop/docs/jp/0-02_Prep_for_Dev_account.md)
- [Vantiq 1-day workshop(v1.34)](./vantiq-apps-development/1-day-workshop/docs/jp/readme.md)
- [Vantiq 1-day workshop(v1.35)](./vantiq-apps-development/1-day-workshop-135/docs/jp/readme.md)
- [実例を通して Vantiq のリソースを理解する](./vantiq-apps-development/vantiq-resources-introduction/docs/jp/Vantiq_resources_introduction.md)
- [VAILの基礎](./vantiq-apps-development/docs/jp/vail_basics.md)
- [デバッグの流れ（デモを通してデバッグの基礎を学ぶ）](./vantiq-apps-development/docs/jp/debug_demo.md)
- [Vantiq Sourceを使った外部へのデータ送信のまとめ](./vantiq-apps-development/docs/jp/data_sending.md)
- [Vantiq Service](./vantiq-apps-development/docs/jp/vantiq-service.md)
- [再利用可能なアプリケーション デザインパターン](./vantiq-apps-development/docs/jp/reusable-design-patterns.md)
- [Vantiqアプリ開発 逆引きリファレンス](./vantiq-apps-development/docs/jp/reverse-lookup.md)
- [VANTIQ CLI クイックリファレンス](./vantiq-apps-development/docs/jp/cli-quick-reference.md)
- [バージョンアップに伴う互換性について](./vantiq-apps-development/docs/jp/incompatibilities.md)

### [Google Colaboratoryを使ったデータジェネレータ](./vantiq-google-colab)

Google Colaboratory の基本的な使い方やデータジェネレータのサンプルコードを紹介しています。Vantiq アプリを開発する際に便利なデータジェネレータを簡単にご用意頂けます。

- [:book: Google Colaboratory の基礎](./vantiq-google-colab/docs/jp/colab_basic_knowledge.md)
- [:computer: MQTT Publisher Sample](./vantiq-google-colab/docs/jp/mqtt_publisher_sample.ipynb)
- [:computer: MQTT Subscriber Sample](./vantiq-google-colab/docs/jp/mqtt_subscriber_sample.ipynb)
- [:beginner: Box Sorter Data Generator (Beginner)](./vantiq-google-colab/docs/jp/box-sorter_data-generator_beginner.ipynb)
- [:beginner: Box Sorter Data Generator (Standard)](./vantiq-google-colab/docs/jp/box-sorter_data-generator_standard.ipynb)


### [Vantiq とパブリッククラウド サービスとの連携](./vantiq-external-services-integration)

Vantiq アプリケーション開発チーム向けの Vantiq とパブリッククラウド サービスとの連携に関するガイドや設定手順を紹介しています。MQTT や Kafka といったブローカー、データベースサービス、メールサービスとの連携に関するガイドや手順となります。

### [Vantiq とデバイスとの連携](./vantiq-devices-integration)

Vantiq アプリケーション開発チーム向けのVantiqとデバイスを連携させるガイドラインやサンプルコードです。

## Vantiq Private Cloud 関連

Vantiq Private Cloud のインストールと運用管理における対応手順など、インフラチームの方々向けの情報をまとめました。

### [Vantiq Private Cloud 構築のための AWS EKS / Azure AKS インフラ関連情報](./vantiq-cloud-infra-operations)

Vantiq Private Cloud を稼働させるための AWS EKS、Azure AKS に関するガイドや手順となります。こちらで紹介している Terraform スクリプトを実行頂くと、Vantiq Private Cloud に必要な設定一式をご用意頂けます。また、AWS EKS、Azure AKS のバージョンアップの手順も記載しております。

### [Vantiq Private Cloud のインストールと運用管理](./vantiq-platform-operations)

別途用意されたAWS EKS、Azure AKS 環境に対し、Vantiq Private Cloud をインストールする手順や運用管理に関するガイドや手順を紹介しています。運用時に必要となる作業手順やトラブルシューティングガイドもございます。

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