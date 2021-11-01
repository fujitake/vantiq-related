# Vantiqプラットフォーム関連
Vantiq Platformの構築や運用に関するガイドや手順です。

- [Vantiq Cloud 構築における、保守およびトラブルシューティング](./docs/jp/vantiq-install-maintenance.md)
- [Vantiq Cloud 運用におけるトラブルシューティングガイド](./docs/jp/vantiq_k8s_troubleshooting.md)
- [ネットワーク構成デバッグツール](./docs/jp/alpine-f.md)
- [サーバー間時刻同期確認ツール](./docs/jp/timestamp_ds.md)
- [mongodb 関連](./docs/jp/mongodb.md)
- [サーバー証明書用 CSR 作成手順](./docs/jp/prepare_csr4rsasslcert.md)
- [Vantiq Cloudwatch Logs](./docs/jp/vantiq-cloudwatch.md)
- [Vantiq Private Cloud解体作業](./docs/jp/vantiq-teardown.md)


## Vantiqプラットフォームに関する保守項目一覧

\# | 項目名                            | 説明                                                                                                                            | 適切なタイミング                                                | 準備期間の目安 | 更新時のサービス停止 | 作業者
---|-----------------------------------|---------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------|----------------|----------------------|-------------------
1  | [Vantiq ライセンス更新](./docs/jp/vantiq-install-maintenance.md#renew_license_files)              | Vantiq クラスタが参照するライセンスファイル。**ライセンスが有効でない場合、Vantiq サービスが停止される。**                        | PO 発行後、ライセンス期限前                             | 1 week         | 必要なし             | Vantiq サポート
2  | [SSL 証明書更新](./docs/jp/vantiq-install-maintenance.md#renew_ssl_certificate)                     | Vantiq クラスタで使用する SSL 証明書。<br />**有効期限が切れると、Vantiq IDE にログインや、HTTPS REST でサービス接続ができなくなる。**     | 証明書の有効期限前                                     | 2 weeks        | 必要なし             | Vantiq サポート
3  | [Vantiq マイナーバージョンアップ](./docs/jp/vantiq-install-maintenance.md#minor_version_upgrade))    | Vantiq の機能追加を伴うバージョンアップを行う。                                                                                  | 概ね 4ヶ月に一度（年3回）                                            | 1 week         | 必要                 | Vantiq サポート
4  | [Vantiq パッチバージョンアップ](./docs/jp/vantiq-install-maintenance.md#patch_version_upgrade)      | Vantiq の現行バージョンの不具合修正を行うバージョンアップを行う。                                                                | 随時。運用上支障がある不具合修正のリリース時。                  | 2 days         | 必要なし             | Vantiq サポート
5  | service principal アカウントの更新 | （AzureでInternal Load Balancerを構成する場合のみ）<br />Vantiq を Private 構成にするため、AKS に権限を持つ Service Principal を使用している。<br />**有効期限切れ後サービスが停止する可能性ある。** | Service Principal の有効期限前。                                 | 1 week         | 必要                 | Vantiq サポート


# Vantiq Platform related
Guides and procedures for building and operating the Vantiq Platform.

- [Trouble Shooting Guide for Vantiq Cloud operations](./docs/eng/vantiq_k8s_troubleshooting.md)
- [Network Configuration Debug Tool](.//docs/eng/alpine-f.md)
- [Servers Time Synchronization Check Tool](./docs/eng/timestamp_ds.md)
- [MongoDB related](./docs/eng/mongodb.md)
- [Procedure for generating a CSR for a server certificate](./docs/eng/prepare_csr4rsasslcert.md)
- [Vantiq Cloudwatch Logs](./docs/eng/vantiq-cloudwatch.md)  
- [Procedure for tearing down Vantiq Private Cloud](./docs/eng/vantiq-teardown.md)


## List of maintenance items for the Vantiq platform

|# | Items  | Description | Appropriate timing | Standard preparation time | Service outage on update | Operator|
|---|----|-------|------|----------------|----------------------|----------|
|1  | Vantiq License Renewal  | The license file referenced by the Vantiq cluster. **If the license is not valid, the Vantiq service will stop.**| From after the PO is issued to before the license expires.   | 1 week         | Not required| Vantiq Support|
|2  | SSL Certificate Renewal  | SSL certificate to be used by the Vantiq cluster.<br />**When it expires, it will not possible to log in to the Vantiq IDE or connect to the service via HTTPS REST.** | Before the certificate expires.  | 2 weeks        | Not required | Vantiq Support|
|3  | Vantiq Minor Upgrade   | Version upgrade of Vantiq with the addition of features. | About once every four months (three times a year).   | 1 week         | Required   | Vantiq Support|
|4  | Vantiq Patch Upgrade | Version upgrade of the Vantiq to fix issues of the current version.  | At any time. At the time of release of fixing issues that interfere with operations. | 2 days | Not required  | Vantiq Support|
|5  | Service Principal Account Update | (Only when configuring Internal Load Balancer in Azure)<br />Service Principal that has authority on AKS is used in order to configure Vantiq as Private.<br />**The service may stop after the expiration date.** | Before the Service Principal expires. | 1 week         | Required  | Vantiq Support|
