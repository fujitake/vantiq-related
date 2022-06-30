# Vantiq Organization のマイグレーションガイド

この記事は、Vantiq クラウド間で Vantiq Organization をマイグレーションするための手順を説明します。

## シナリオ
Vantiq Cloud (dev.vantiq.co.jp) を開発環境としていたが、自社のクラウド環境に Vantiq のプライベート環境を構築し、Organization、ユーザー、開発中のアプリケーション等を移行する。

## 想定
以下のモジュール、Resource は使用していない想定で説明し、手順には含まない (必要に応じて都度、手順に追記することとする)。

- Vantiq mobile
- Vantiq Calatog
- ノード (デプロイ機能)  
- Assembly  

## 手順

### 組織管理者 (Organization Admin)

旧環境にて以下を行う。
1. dev.vantiq.co.jp を使用中のユーザーを特定する。また、そのリストのうち、新環境に移行が必要なユーザーを特定する。
1. dev.vantiq.co.jp の対象の Organizationg 配下で使用中の Namespace を特定する。また、そのうち新環境に移行が必要なものを特定し、それぞれに移行担当者 (Developer) をアサインする。
1. 移行対象のユーザーと Namespace について、移行ステータスをトラックする。ユーザーと Namespace の移行がすべて完了したら、旧環境の Organization の削除を Vantiq Support に依頼する。

新環境にて以下を行う。
1. Organization Admin として、Organization Root Namespace への招待を受け、System Admin と Keycloak Admin の権限を取得する。    
1. Organization Namespace と Keycloak のセキュリティ ポリシーを設定する。
1. 対象ユーザーに、`User (Developer)`として Organization Root Namespace への招待を送信する。

#### チェックリスト
- [ ] すべての利用ユーザーが洗い出されていて、新しい Namespace に移行しているか。  
     - Keycloak に登録しているユーザーのうち、旧環境の Namespace のユーザーで特定のドメインに所属しているユーザーを抽出する。  
     - 旧環境の Namespace からユーザーを抽出する (注: Developer に所属しているユーザーがいるかもしれない)。  
- [ ] すべての Namespace とその所有ユーザーが洗い出されていて、移行完了のステータスがトラックされているか (Organization の Root Namespace において、メニュー 管理 >> Namespace)。

### 移行担当者 (Developer)

それぞれのユーザーは以下を実施する：
1. Organization Admin から招待を受け、新環境にアカウントを作成する。

それぞれの Namespace について、移行担当者は以下を実施する：
1. 新環境で Namespace を作成する。
1. 旧環境で Project とデータをエクスポートする (Source を非アクティブ化した上で)。
1. エクスポートされた Resource の中で、旧環境への URL の参照があれば、新環境への参照に更新しておく。
1. 新環境の Namespace において、Project をインポートする。
1. Namespace で Secret を使用している場合は再設定する。
1. Namespace でカスタム Profile を使用している場合、新環境で再度作成する (アクセストークン作成時とユーザー招待時に必要になる)。
1. 新環境の Namespace でアクセストークンを再度生成する。Vantiq に REST API で接続している外部アプリケーションにて Vantiq エンドポイントの URL とアクセストークンを再設定する。
1. 新環境にインポートされたアプリケーションの動作テストを行う (Source をアクティブ化した上で)。
1. 新環境の Namespace に他の Developer、User を招待する。
1. Namespace の移行が完了したことを Organization Admin に報告する。

#### チェックリスト
- [ ] Namespace 内の Project をすべてエクスポートしたか (メニュー Projects >> Project の管理)
- [ ] 必要な Resource が Project に含まれているか (設定 >> すべての Resources の表示、設定 >> 孤立した Resources の表示)
- Project エクスポートに含まれない Reource や設定を参照しているか。
  - [ ] Secrets (メニュー >> 管理 >> Advanced >> Secrets )
  - [ ] Access Token (メニュー >> 管理 >> Advanced >> Access Tokens )
  - [ ] カスタム作成したロール (メニュー >> 管理 >> Advanced >> Profile )
  - [ ] Groups (メニュー >> 管理 >> Advanced >> Groups )
  - [ ] Catalog を持っているか (メニュー >> 管理 >> Advanced >> Catalog)
  - [ ] デプロイを使っていないか (メニュー >> デプロイ >> Configurations、Nodes、Node Configurations、Deployments、 Environments、Clusters)
  - [ ] 開発用 Namespace を Home とするユーザーが存在しないか (メニュー >> 管理 >> Users)
