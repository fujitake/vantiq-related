
## Purpose
This repository is for sharing various technical guidance and instructions of Vantiq product.

### [Vantiq Cloud Infrastructure related](./vantiq-cloud-infra-operations)
Guides and instructions on AWS, Azure cloud infrastructure and Kubernetes clusters to run Vantiq.  
- [AWS EKS for Vantiq with Terraform](./vantiq-cloud-infra-operations/terraform_aws/readme_en.md)
- [Azure AKS for Vantiq with Terraform](./vantiq-cloud-infra-operations/terraform_azure/readme_en.md)
- [AWS permissions that are required to manage Vantiq](./vantiq-cloud-infra-operations/docs/eng/aws_op_priviliges.md)
- [Considerations for Closed Network Configuration (AWS)](./vantiq-cloud-infra-operations/docs/eng/vantiq-install-closed-network-aws.md)
- [Considerations for Closed Network Configuration (Azure)](./vantiq-cloud-infra-operations/docs/eng/vantiq-install-closed-network-azure.md)


### [Vantiq Platform related](./vantiq-platform-operations)
Guides and procedures for building and operating the Vantiq Platform.
- [Trouble Shooting Guide for Vantiq Cloud operations](./vantiq-platform-operations/docs/eng/vantiq_k8s_troubleshooting.md)
- [Network Configuration Debug Tool](./vantiq-platform-operations/docs/eng/alpine-f.md)
- [Servers Time Synchronization Check Tool](./vantiq-platform-operations/docs/eng/timestamp_ds.md)
- [MongoDB related](./vantiq-platform-operations/docs/eng/mongodb.md)
- [Procedure for generating a CSR for a server certificate](./vantiq-platform-operations/docs/eng/prepare_csr4rsasslcert.md)
- [Vantiq Cloudwatch Logs](./vantiq-platform-operations/docs/eng/vantiq-cloudwatch.md)


### [Vantiq Application Development related](./vantiq-apps-development)
Guides and learning materials for developing and operating Vantiq Applications.
- [Vantiq 1-day workshop](./vantiq-apps-development/1-day-workshop/docs/eng/readme.md)
- [Set up Vantiq External Lifecycle Management](./vantiq-apps-development/docs/eng/Vantiq_ExtLifecycleManagement_SetupProcedure.md)

### [Vantiq with External Services Integration](./vantiq-external-services-integration/readme_en.md)
Guides and procedures for integrating Vantiq with cloud web services, brokers, and database services.  
- [Amazon MQ](./vantiq-external-services-integration/docs/en/vantiq-aws-AmazonMQ.md)
- [Amazon DynamoDB](./vantiq-external-services-integration/docs/en/vantiq-aws-dynamodb.md)
- [Amazon Managed Streaming For Kafka (MSK)](./vantiq-external-services-integration/docs/en/vantiq-aws-msk.md)
- [Azure Event Hubs](./vantiq-external-services-integration/docs/en/vantiq-azure-EventHubs.md)
- [GCP Pub/Sub](./vantiq-external-services-integration/docs/en/vantiq-gcp-PubSub.md)
- [SendGrid](./vantiq-external-services-integration/docs/en/vantiq-sendgrid.md)


### [Vantiq with Devices Integration](./vantiq-devices-integration/readme_en.md)
Guidelines and sample code for integrating Vantiq with devices.  
- [Edge - Vantiq configuration Data integration Guideline](./vantiq-devices-integration/docs/eng/device-to-vantiq.md)
- Connector samples
  - [Python Code](./vantiq-devices-integration/conf/vantiq-restapi-mqtt-amqp-python-sample) / [Vantiq Project](./vantiq-devices-integration/conf/vantiq-restapi-mqtt-amqp-python-sample/vantiq-project-sample.zip)
  - [fluentd](./vantiq-devices-integration/docs/eng/fluentd.md)
- [Device connection samples](./vantiq-devices-integration/readme_en.md#device_sample)



## 目的

このリポジトリは、Vantiqに関わるさまざまな技術的なガイドや手順を共有するものです。

### [Vantiqのクラウドインフラ関連](./vantiq-cloud-infra-operations)
Vantiqを稼働させるAWS, AzureのクラウドインフラやKubernetesクラスタに関するガイドや手順です。

- [Terraform を使って AWS EKS を作成](./vantiq-cloud-infra-operations/terraform_aws/readme.md)
- [Terraform を使って Azure AKS を作成](./vantiq-cloud-infra-operations/terraform_azure/readme.md)
- [Vantiq を運用するのに必要な AWS の権限](./vantiq-cloud-infra-operations/docs/jp/aws_op_priviliges.md)
- [閉域網構成における考慮事項 (AWS編)](./vantiq-cloud-infra-operations/docs/jp/vantiq-install-closed-network-aws.md)
- [閉域網構成における考慮事項 (Azure編)](./vantiq-cloud-infra-operations/docs/jp/vantiq-install-closed-network-azure.md)


### [Vantiqプラットフォーム関連](./vantiq-platform-operations)
Vantiq Platformの構築や運用に関するガイドや手順です。

- [Vantiq Cloud 構築における、保守およびトラブルシューティング](./vantiq-platform-operations/docs/jp/vantiq-install-maintenance.md)
- [Vantiq Cloud 運用におけるトラブルシューティングガイド](./vantiq-platform-operations/docs/jp/vantiq_k8s_troubleshooting.md)
- [ネットワーク構成デバッグツール](./vantiq-platform-operations/docs/jp/alpine-f.md)
- [サーバー間時刻同期確認ツール](./vantiq-platform-operations/docs/jp/timestamp_ds.md)
- [mongodb 関連](./vantiq-platform-operations/docs/jp/mongodb.md)
- [サーバー証明書用 CSR 作成手順](./vantiq-platform-operations/docs/jp/prepare_csr4rsasslcert.md)
- [Vantiq Cloudwatch Logs](./vantiq-platform-operations/docs/jp/vantiq-cloudwatch.md)
- [Vantiq Private Cloud解体作業](./vantiq-platform-operations/docs/jp/vantiq-teardown.md)

### [Vantiqアプリケーション開発関連](./vantiq-apps-development)
Vantiqアプリケーションの開発や運用に関するガイドや学習マテリアルです。
- [Vantiq 1-day workshop](./vantiq-apps-development/1-day-workshop/docs/jp/readme.md)
- [Vantiq External Lifecycle Management の設定](./vantiq-apps-development/docs/jp/Vantiq_ExtLifecycleManagement_SetupProcedure.md)

### [Vantiqと外部サービスとの連携](./vantiq-external-services-integration/readme.md)
VantiqとクラウドWebサービス、ブローカー、データベースサービスとの連携に関するガイドや手順です。
- [Amazon MQ](./vantiq-external-services-integration/docs/jp/vantiq-aws-AmazonMQ.md)
- [Amazon DynamoDB](./vantiq-external-services-integration/docs/jp/vantiq-aws-dynamodb.md)
- [Amazon Managed Streaming For Kafka (MSK)](./vantiq-external-services-integration/docs/jp/vantiq-aws-msk.md)
- [Azure Event Hubs](./vantiq-external-services-integration/docs/jp/vantiq-azure-EventHubs.md)
- [GCP Pub/Sub](./vantiq-external-services-integration/docs/jp/vantiq-gcp-PubSub.md)
- [SendGrid](./vantiq-external-services-integration/docs/jp/vantiq-sendgrid.md)


### [Vantiqとデバイスとの連携](./vantiq-devices-integration)
Vantiqとデバイスを連携させるガイドラインやサンプルコードです。
- [Edge~Vantiq構成 データ連携 ガイドライン](./vantiq-devices-integration/docs/jp/device-to-vantiq.md)
- コネクターサンプル
  - [Python Code](./vantiq-devices-integration/conf/vantiq-restapi-mqtt-amqp-python-sample) / [Vantiq Project](./vantiq-devices-integration/conf/vantiq-restapi-mqtt-amqp-python-sample/vantiq-project-sample.zip)
  - [fluentd](./vantiq-devices-integration/docs/jp/fluentd.md)
- [デバイスの接続サンプル](./vantiq-devices-integration/readme.md#device_sample)
