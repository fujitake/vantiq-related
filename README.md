
## Purpose
This repository is for sharing various technical guidance and instructions of Vantiq product.

### [Vantiq Application Development related](./vantiq-apps-development)
Guides and learning materials for developing and operating Vantiq Applications.
- [Vantiq 1-day workshop](./vantiq-apps-development/1-day-workshop/docs/eng/readme.md)
- [Understanding Vantiq Resources through real-world example](./vantiq-apps-development/vantiq-resources-introduction/docs/eng/Vantiq_resources_introduction.md)
- [Set up Vantiq External Lifecycle Management](./vantiq-apps-development/docs/eng/Vantiq_ExtLifecycleManagement_SetupProcedure.md)

### [Vantiq with External Services Integration](./vantiq-external-services-integration)
Guides and procedures for integrating Vantiq with cloud web services, brokers, and database services.  
- [Amazon MQ](./vantiq-external-services-integration/docs/en/vantiq-aws-AmazonMQ.md)
- [Amazon DynamoDB](./vantiq-external-services-integration/docs/en/vantiq-aws-dynamodb.md)
- [Amazon Managed Streaming For Kafka (MSK)](./vantiq-external-services-integration/docs/en/vantiq-aws-msk.md)
- [Azure Event Hubs](./vantiq-external-services-integration/docs/en/vantiq-azure-EventHubs.md)
- [GCP Pub/Sub](./vantiq-external-services-integration/docs/en/vantiq-gcp-PubSub.md)
- [SendGrid](./vantiq-external-services-integration/docs/en/vantiq-sendgrid.md)


### [Vantiq with Devices Integration](./vantiq-devices-integration)
Guidelines and sample code for integrating Vantiq with devices.  
- [Edge - Vantiq configuration Data integration Guideline](./vantiq-devices-integration/docs/eng/device-to-vantiq.md)
- Connector samples
  - [Python Code](./vantiq-devices-integration/conf/vantiq-restapi-mqtt-amqp-python-sample) / [Vantiq Project](./vantiq-devices-integration/conf/vantiq-restapi-mqtt-amqp-python-sample/vantiq-project-sample.zip)
  - [fluentd](./vantiq-devices-integration/docs/eng/fluentd.md)
- [Device connection samples](./vantiq-devices-integration/readme_en.md#device_sample)


### [Vantiq Cloud Infrastructure related](./vantiq-cloud-infra-operations)
Guides and instructions on AWS, Azure cloud infrastructure and Kubernetes clusters to run Vantiq.  
- [AWS EKS for Vantiq with Terraform](./vantiq-cloud-infra-operations/terraform_aws/readme_en.md)
- [Azure AKS for Vantiq with Terraform](./vantiq-cloud-infra-operations/terraform_azure/readme_en.md)
- [kubernetes (EKS) upgrade](./vantiq-cloud-infra-operations/docs/eng/kubernetes-upgrade.md#eks_upgrade)    
- [kubernetes (AKS) upgrade](./vantiq-cloud-infra-operations/docs/eng/kubernetes-upgrade.md#aks_upgrade)
- [AWS permissions that are required to manage Vantiq](./vantiq-cloud-infra-operations/docs/eng/aws_op_priviliges.md)
- [Considerations for Closed Network Configuration (AWS)](./vantiq-cloud-infra-operations/docs/eng/vantiq-install-closed-network-aws.md)
- [Considerations for Closed Network Configuration (Azure)](./vantiq-cloud-infra-operations/docs/eng/vantiq-install-closed-network-azure.md)
- [Vantiq Cloudwatch Logs](./vantiq-cloud-infra-operations/docs/eng/vantiq-cloudwatch.md)  


### [Vantiq Platform Installation related](./vantiq-platform-operations)
Guides and procedures for the Vantiq Platform Management Team on installing and operating the Vantiq Platform on cloud infrastructure.  
- [Trouble Shooting Guide for Vantiq Cloud operations](./vantiq-platform-operations/docs/eng/vantiq_k8s_troubleshooting.md)
- [Network Configuration Debug Tool](./vantiq-platform-operations/docs/eng/alpine-f.md)
- [Servers Time Synchronization Check Tool](./vantiq-platform-operations/docs/eng/timestamp_ds.md)
- [MongoDB related](./vantiq-platform-operations/docs/eng/mongodb.md)
- [Procedure for generating a CSR for a server certificate](./vantiq-platform-operations/docs/eng/prepare_csr4rsasslcert.md)
- [Migration of Vantiq Organization](./vantiq-platform-operations/docs/eng/vantiq-org-migration.md)
- [Procedure for tearing down Vantiq Private Cloud](./vantiq-platform-operations/docs/eng/vantiq-teardown.md)


## 目的

このリポジトリは、Vantiqに関わるさまざまな技術的なガイドや手順を共有するものです。

### [Vantiqアプリケーション開発関連](./vantiq-apps-development)
Vantiqアプリケーション開発チーム向けのアプリ開発や運用に関するガイドや学習マテリアルです。
- [Vantiqアカウント作成（開発者向け）](./vantiq-apps-development/1-day-workshop/docs/jp/0-01_Prep_for_Account.md)
- [Vantiqアカウント作成（組織管理者向け）](./vantiq-apps-development/1-day-workshop/docs/jp/0-02_Prep_for_Dev_account.md)
- [Vantiq 1-day workshop](./vantiq-apps-development/1-day-workshop/docs/jp/readme.md)
- [実例を通して Vantiq のリソースを理解する](./vantiq-apps-development/vantiq-resources-introduction/docs/jp/Vantiq_resources_introduction.md)
- [VAILの基礎](./vantiq-apps-development/docs/jp/vail_basics.md)
- [デバッグの流れ（デモを通してデバッグの基礎を学ぶ）](./vantiq-apps-development/docs/jp/debug_demo.md)
- [Vantiq Sourceを使った外部へのデータ送信のまとめ](./vantiq-apps-development/docs/jp/data_sending.md)
- [Vantiq Service](./vantiq-apps-development/docs/jp/vantiq-service.md)
- [再利用可能なアプリケーション デザインパターン](./vantiq-apps-development/docs/jp/reusable-design-patterns.md)
- [Vantiqアプリ開発 逆引きリファレンス](./vantiq-apps-development/docs/jp/reverse-lookup.md)
- [Vantiq External Lifecycle Management の設定](./vantiq-apps-development/docs/jp/Vantiq_ExtLifecycleManagement_SetupProcedure.md)

### [Vantiqと外部サービスとの連携](./vantiq-external-services-integration)
Vantiqアプリケーション開発チーム向けのVantiqと外部Webサービス、ブローカー、データベースサービスとの連携に関するガイドや手順です。
- [Amazon MQ](./vantiq-external-services-integration/docs/jp/vantiq-aws-AmazonMQ.md)
- [Amazon DynamoDB](./vantiq-external-services-integration/docs/jp/vantiq-aws-dynamodb.md)
- [Amazon Managed Streaming For Kafka (MSK)](./vantiq-external-services-integration/docs/jp/vantiq-aws-msk.md)
- [AWS IoT Core](./vantiq-external-services-integration/docs/jp/vantiq-aws-iotcore.md)
- [Azure Cosmos DB](./vantiq-external-services-integration/docs/jp/vantiq-azure-CosmosDB.md)
- [Azure Event Hubs](./vantiq-external-services-integration/docs/jp/vantiq-azure-EventHubs.md)
- [GCP Pub/Sub](./vantiq-external-services-integration/docs/jp/vantiq-gcp-PubSub.md)
- [SendGrid](./vantiq-external-services-integration/docs/jp/vantiq-sendgrid.md)
- [API Gatewayと組み合わせたデザインパターン](./vantiq-external-services-integration/docs/jp/vantiq-apigw.md)
- [PostgREST](./vantiq-external-services-integration/docs/jp/vantiq-PostgREST.md)

### [Vantiqとデバイスとの連携](./vantiq-devices-integration)
Vantiqアプリケーション開発チーム向けのVantiqとデバイスを連携させるガイドラインやサンプルコードです。
- [Edge~Vantiq構成 データ連携 ガイドライン](./vantiq-devices-integration/docs/jp/device-to-vantiq.md)
- コネクターサンプル
  - [Python Code](./vantiq-devices-integration/conf/vantiq-restapi-mqtt-amqp-python-sample) / [Vantiq Project](./vantiq-devices-integration/conf/vantiq-restapi-mqtt-amqp-python-sample/vantiq-project-sample.zip)
  - [fluentd](./vantiq-devices-integration/docs/jp/fluentd.md)
- [デバイスの接続サンプル](./vantiq-devices-integration/readme.md#device_sample)


### [クラウドインフラ関連](./vantiq-cloud-infra-operations)
インフラチーム向けのVantiqを稼働させるAWS, AzureのクラウドインフラやKubernetesクラスタに関するガイドや手順です。

- [Terraform を使って AWS EKS を作成](./vantiq-cloud-infra-operations/terraform_aws/readme.md)
- [Terraform を使って Azure AKS を作成](./vantiq-cloud-infra-operations/terraform_azure/readme.md)
- [kubernetes（EKS) バージョンアップ](./vantiq-cloud-infra-operations/docs/jp/kubernetes-upgrade.md#eks_upgrade)    
- [kubernetes（AKS) バージョンアップ](./vantiq-cloud-infra-operations/docs/jp/kubernetes-upgrade.md#aks_upgrade)
- [Vantiq を運用するのに必要な AWS の権限](./vantiq-cloud-infra-operations/docs/jp/aws_op_priviliges.md)
- [閉域網構成における考慮事項 (AWS編)](./vantiq-cloud-infra-operations/docs/jp/vantiq-install-closed-network-aws.md)
- [閉域網構成における考慮事項 (Azure編)](./vantiq-cloud-infra-operations/docs/jp/vantiq-install-closed-network-azure.md)
- [Vantiq Cloudwatch Logs](./vantiq-cloud-infra-operations/docs/jp/vantiq-cloudwatch.md)



### [Vantiqプラットフォームインストール関連](./vantiq-platform-operations)
Vantiqプラットフォーム管理チーム向けのクラウドインフラ上へのVantiq Platformのインストールや運用に関するガイドや手順です。

- [Vantiq Cloud 構築および保守 ](./vantiq-platform-operations/docs/jp/vantiq-install-maintenance.md)
- [deploy.yamlのカスタマイズ構成](./vantiq-platform-operations/docs/jp/deploy_yaml_config.md)
- [Vantiq Cloud 構築および保守におけるトラブルシューティング](./vantiq-platform-operations/docs/jp/vantiq-install-maintenance-troubleshooting.md)
- [Vantiq Cloud 運用におけるトラブルシューティングガイド](./vantiq-platform-operations/docs/jp/vantiq_k8s_troubleshooting.md)
- [ネットワーク構成デバッグツール](./vantiq-platform-operations/docs/jp/alpine-f.md)
- [サーバー間時刻同期確認ツール](./vantiq-platform-operations/docs/jp/timestamp_ds.md)
- [mongodb 関連](./vantiq-platform-operations/docs/jp/mongodb.md)
- [grafana 関連](./vantiq-platform-operations/docs/jp/grafana.md)
- [サーバー証明書用 CSR 作成手順](./vantiq-platform-operations/docs/jp/prepare_csr4rsasslcert.md)
- [Vantiq Organizationのマイグレーション作業](./vantiq-platform-operations/docs/jp/vantiq-org-migration.md)
- [Vantiq Private Cloud解体作業](./vantiq-platform-operations/docs/jp/vantiq-teardown.md)
- [Quay.io の新規アカウント作成手順](./vantiq-platform-operations/docs/jp/create_quay.io_account.md)
- [Vantiq Organization, Namespace, User Role の関係](./vantiq-platform-operations/docs/jp/org_user_management.md)
- [Vantiq Edge Admin タスク](./vantiq-platform-operations/docs/jp/vantiq-edge-admin.md)
