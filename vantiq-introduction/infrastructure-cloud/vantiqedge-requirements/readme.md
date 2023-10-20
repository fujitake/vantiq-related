# Vantiq Edge の要件

Vantiq Edge をインストールするにあたり必要となる要件を解説しています。

- [Vantiq Edge の要件](#vantiq-edge-の要件)
  - [前提条件](#前提条件)
    - [Vantiq Edge のライセンス](#vantiq-edge-のライセンス)
    - [ハードウェアの最小要件](#ハードウェアの最小要件)
    - [ソフトウェアの要件](#ソフトウェアの要件)
    - [Docker 環境](#docker-環境)
  - [ARM プロセッサーについて](#arm-プロセッサーについて)
    - [Vantiq Edge を動かせない理由](#vantiq-edge-を動かせない理由)
  - [参考情報](#参考情報)

## 前提条件

Vantiq Edge を利用するにあたり下記の前提条件が必要になります。

### Vantiq Edge のライセンス

Vantiq Edge の起動に Vantiq ライセンスが必要になります。  
ライセンスは2つのファイルで構成されています。  

- license.key
- public.pem

### ハードウェアの最小要件

- 64ビットx86プロセッサ
- 2GBのメインメモリー
- 16 GBのストレージ（MongoDB用）

### ソフトウェアの要件

- 64ビットオペレーティングシステム
- 最近のバージョンのLinux（UbuntuまたはMacOSを含む）、またはWindows
  - ハードウェア仮想化技術が有効であること(Windows)
- 管理者権限へのアクセス

### Docker 環境

Vantiq Edge を動かすには Docker 環境が必要になります。  
また、 support@vantiq.com に quay.io の ID を登録を依頼し、コンテナリポジトリ quay.io/vantiq/vantiq-edge へにアクセス権が必要になります。

## ARM プロセッサーについて

ARM プロセッサーでは Vantiq Edge を動かすことはできません。（Vantiq Edge r1.37 時点）

### Vantiq Edge を動かせない理由

#### Docker 環境の場合

- Docker Compose が ARM に対応していないため、 Docker 環境が起動できません。

#### 非 Docker 環境の場合

- MongoDB 4.2 が Ubuntu 18.04 LTS までにしか対応していないため、最新の Ubuntu で MongoDB の環境が構築できません。
- Ubuntu 18.04 LTS は、2023年5月31日でサポートが終了しているため、古い Ubuntu の利用は推奨できません。

## 参考情報

- [Vantiq Edgeインストールガイド](https://community.vantiq.com/wp-content/uploads/2022/06/edge-install-ja-2.html)
