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

s# | 項目名                            | 説明                                                                                                                            | 適切なタイミング                                                | 準備期間の目安 | 更新時のサービス停止 | 作業者
---|-----------------------------------|---------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------|----------------|----------------------|-------------------
1  | [Vantiqライセンス更新](./docs/jp/vantiq-install-maintenance.md#renew_license_files)              | Vantiqクラスタが参照するライセンスファイル。**ライセンスが有効出ない場合、Vantiqサービスが停止される。**                        | PO発行後、ライセンス期限前                             | 1 week         | 必要なし             | Vantiqサポート
2  | [SSL証明書更新](./docs/jp/vantiq-install-maintenance.md#renew_ssl_certificate)                     | Vantiqクラスタで使用するSSL証明書。<br />**有効期限が切れると、Vantiq IDEにログインや、HTTPS RESTでサービス接続ができなくなる。**     | 証明書の有効期限前                                     | 2 weeks        | 必要なし             | Vantiqサポート
3  | [Vantiqマイナーバージョンアップ](./docs/jp/vantiq-install-maintenance.md#minor_version_upgrade))    | Vantiqの機能追加を伴うバージョンアップを行う。                                                                                  | 概ね4ヶ月に一度（年3回）                                            | 1 week         | 必要                 | Vantiqサポート
4  | [Vantiqパッチバージョンアップ](./docs/jp/vantiq-install-maintenance.md#patch_version_upgrade)      | Vantiqの現行バージョンの不具合修正を行うバージョンアップを行う。                                                                | 随時。運用上支障がある不具合修正のリリース時。                  | 2 days         | 必要なし             | Vantiqサポート
5  | service principalアカウントの更新 | （AzureでInternal Load Balancerを構成する場合のみ）<br />VantiqをPrivate構成にするため、AKSに権限を持つService Principalを使用している。<br />**有効期限切れ後サービスが停止する可能性ある。** | Service Principalの有効期限前。                                 | 1 week         | 必要                 | Vantiqサポート


# Vantiq Platform related
Guides and procedures for building and operating the Vantiq Platform.

- [Trouble Shooting Guide for Vantiq Cloud operations](./docs/eng/vantiq_k8s_troubleshooting.md)
- [Network Configuration Debug Tool](.//docs/eng/alpine-f.md)
- [Servers Time Synchronization Check Tool](./docs/eng/timestamp_ds.md)
- [MongoDB related](./docs/eng/mongodb.md)
- [Procedure for generating a CSR for a server certificate](./docs/eng/prepare_csr4rsasslcert.md)
- [Vantiq Cloudwatch Logs](./docs/eng/vantiq-cloudwatch.md)  
- [Procedure for tearing down Vantiq Private Cloud](./docs/eng/vantiq-teardown.md)
