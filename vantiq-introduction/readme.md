# Vantiq 入門の概要

Vantiq を用いたアプリケーションの開発を行う上で、必要となる知識をワークショップ形式を含め、様々な方法で解説しています。

## 開発環境の準備

Vantiq を利用するための事前準備の方法を解説しています。  
アカウントが既に発行されている場合はこの手順を飛ばしてください。

- [Vantiqアカウント作成（開発者向け）](./apps-development/vantiq-devenv/root_account/root_account.md)
- [Vantiqアカウント作成（組織管理者向け）](./apps-development/vantiq-devenv/dev_account/dev_account.md)

## アプリケーション開発（入門編）

Vantiq アプリケーションの開発方法をワークショップ形式で解説しています。  

### Vantiq の基本

Vantiq の基本的な扱い方を解説しています。  

1. [Vantiq の Namespace と Project について](./apps-development/vantiq-basic/namespace/namespace.md)
1. [Project の管理について](./apps-development/vantiq-basic/project/project.md)
1. [Vantiq で開発する上での基本事項](./apps-development/vantiq-basic/basic-common/basic-common.md)

### アプリケーション開発ワークショップ

実際に Vantiq を使ってアプリケーションを開発していきます。  
表の上から順に実施していただくことを推奨しています。  

#### 旧ワークショップ

|必須|ワークショップ|前提となるワークショップ|
|:-:|-|-|
|-|[荷物仕分けアプリケーション (Beginner)](./apps-development/apps-boxsorter/boxsorter-beginner/readme.md)|なし|

#### 新ワークショップ

|必須|ワークショップ|前提となるワークショップ|
|:-:|-|-|
|◯|[ボックスソーター（入門編・REST API）](./apps-development/apps-boxsorter/rest-api/readme.md)|なし|
|◯|[ボックスソーター（入門編・Transformation）](./apps-development/apps-boxsorter/transform/readme.md)|ボックスソーター（入門編・REST API）|
|◯|[ボックスソーター（入門編・MQTT）](./apps-development/apps-boxsorter/mqtt/readme.md)|ボックスソーター（入門編・Transformation）|
|◯|[VAIL 入門（基礎）](./apps-development/vail-introductory/vail_basic/vail_basic.md)|なし|

> **必須の解説**  
> ◯：必ず実施していただくことを推奨しています。  
> △：追加のワークショップとなるため、余裕がある場合は実施していただくことを推奨しています。  
> ✕：補足的なワークショップになります。

## アプリケーション開発（基本編）

Vantiq アプリケーションの開発方法をワークショップ形式で解説しています。  

### アプリケーション開発ワークショップ

実際に Vantiq を使ってアプリケーションを開発していきます。  
表の上から順に実施していただくことを推奨しています。  

|必須|ワークショップ|前提となるワークショップ|
|:-:|-|-|
|◯|[荷物仕分けアプリケーション (Standard)](./apps-development/apps-boxsorter/boxsorter-standard/readme.md)|荷物仕分けアプリケーション (Beginner)|
|✕|[荷物仕分けアプリケーション (MQTTX)](./apps-development/apps-boxsorter/boxsorter-mqttx/readme.md)|荷物仕分けアプリケーション (Standard)|
|◯|[荷物仕分けアプリケーション (SaveToType)](./apps-development/apps-boxsorter/boxsorter-savetype/readme.md)|荷物仕分けアプリケーション (Standard)|
|◯|[VAIL 入門（Type の操作）](./apps-development/vail-introductory/vail_type/vail_type.md)|なし|
|◯|[VAIL 入門（外部へのデータ送信）](./apps-development/vail-introductory/vail_data/vail_data.md)|なし|
|△|[荷物仕分けアプリケーション (Unwind)](./apps-development/apps-boxsorter/boxsorter-unwind/readme.md)|荷物仕分けアプリケーション (Standard)|
|△|[荷物仕分けアプリケーション (State)](./apps-development/apps-boxsorter/boxsorter-state/readme.md)|荷物仕分けアプリケーション (Standard)|
|◯|[デバッグ方法](./apps-development/debug/readme.md)|なし|

## インフラ／クラウド入門

Vantiq を利用するにあたって必要となるインフラやクラウドに関する解説をしています。  

### Vantiq Edge

- [Vantiq Edge の要件](./infrastructure-cloud/vantiqedge-requirements/readme.md)
- [Windows 端末で Vantiq Edge をインストールする方法](./infrastructure-cloud/vantiqedge-on-windows/readme.md)
