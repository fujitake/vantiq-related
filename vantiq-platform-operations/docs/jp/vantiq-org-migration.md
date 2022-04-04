# Vantiq Organizationのマイグレーションガイド

この記事は、Vantiqクラウド間でVantiq Organizationをマイグレーションするための手順を説明します。

## シナリオ
Vantiq Cloud（dev.vantiq.co.jp)を開発環境としていたが、自社のクラウド環境にVantiqのプライベート環境を構築し、Organization、ユーザー、開発中のアプリケーション等を移行する。

## 想定
以下のモジュール、リソースは使用していない想定で説明し、手順には含まない。（必要に応じて都度、手順に追記することとする。）

- Vantiq mobile
- Vantiq Calatog
- Node
- 開発者でないEnd User

## 手順

### 組織管理者 (Organization Admin)

1. dev.vantiq.co.jpを使用中のユーザーを特定する。また、そのリストのうち、新環境に移行が必要なユーザーを特定する。
1. dev.vantiq.co.jpを使用中のnamespaceを特定する。また、そのうち新環境に移行が必要なものと、それぞれの移行担当者をアサインする。
1. 移行対象のユーザーとnamespaceについて、管理台帳で完了までステータスをトラックする。
1. 1.で特定されたユーザーに新環境のOrganization Root Namespaceへの招待を送信する。
1. すべてNamespace、リソースの移行が終わったらVantiq Supportへ依頼し、旧環境のOrganizationを削除する。

#### チェックリスト
- [ ] すべての利用ユーザーが洗い出されているか。
   Keycloakに登録しているユーザーのうち、特定のドメインを抽出することをVantiq Supportに依頼する。
- [ ] すべてのNamespaceが洗い出されているか。 (OrganizationのRoot Namespaceにて、メニュー 管理 >> Namespace)

### 移行担当者 (ユーザー)

それぞれのユーザーは以下の実施する：
1. Organization Adminから招待を受け、新環境にアカウントを作成する。

それぞれのnamespaceについて、移行担当者は以下を実施する：
1. 新環境でNamespaceを作成する。
1. 旧環境でプロジェクトをエクスポートする。
1. エクスポートされたプロジェクトの中で、旧環境へのURLの参照があれば更新しておく。
1. 新環境でプロジェクトをインポートする。
1. namespaceでSecretを使用している場合、新環境で再度作成する。
1. 新環境のnamespaceでアクセストークンを生成する。VantiqにREST APIで接続している外部アプリケーションにてVantiqエンドポイントのURLとアクセストークンを再設定する。
1. 新環境にインポートされたアプリケーションの動作テストを行う。
1. 新環境のNamespaceに他のDeveloper, Userを招待する。
1. Namespaceの移行が完了したことをAdminに報告する。

#### チェックリスト
- [ ] Namespace内のすべてプロジェクトをエクスポートしたか。(メニュー Projects >> プロジェクトの管理）
- [ ] 必要なリソースがプロジェクトに含まれているか。（設定 >> すべてのResourcesの表示、 設定 >> 孤立したResourcesの表示」
- [ ] 同じ環境 (dev.vantiq.co.jp) の他のNamespaceのリソースを参照しているものはあるか。（Remote Sourceで Server URIがdev.vantiq.co.jpがあるか。）
- プロジェクトエクスポートに含まれないリソースや設定を参照しているか。
  - [ ] Secret (メニュー >> 管理 >> Advanced >> Secrets )
  - [ ] Access Token (メニュー >> 管理 >> Advanced >> Access Token )
  - [ ] カスタム作成したロール (メニュー >> 管理 >> Advanced >> Profile )
  - [ ] Group (メニュー >> 管理 >> Advanced >> Group )
  - [ ] Catalogを持っているか (メニュー >> 管理 >> Advanced >> Catalog)
  - [ ] 他のNamespaceのCatalogに接続しているか。 (メニュー >> 表示 >> Catalogs)
  - [ ] デプロイを使っていないか。 (メニュー >> デプロイ >> Configuration, Nodes, Node Configurations, Deployment, Environments, Clusters)
  - [ ] 開発用NamespaceをHomeとするユーザーが存在しないか。 (メニュー >> 管理 >> Users)
