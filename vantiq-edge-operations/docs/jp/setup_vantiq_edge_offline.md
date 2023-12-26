# はじめに
本ドキュメントはオフラインマシンへのVantiq Edgeインストール手順について記載したものです。  
手順としては以下のような流れとなっています。  
- Docker のインストール
- Vantiq Edgeの起動  

# 前提 
想定として以下の2台のマシンがある環境でのインストール手順について記載しています。
- Vantiq Edgeインストール対象のマシン(Vantiq Edgeマシン)  
  本ドキュメントではCentOS想定で記載しております。別OSの場合はパッケージ管理などをそれぞれのOSに置き換えて実行してください。
- 作業用マシン  
  インターネットにつながり、VantiqEdgeマシンへのSSH接続やファイル転送、Dockerコマンドによるイメージファイルのダウンロードなどを行う

作業用マシンのOSがCentOS/Windowsの場合の2パターンを記載しています。  

Vantiq Edgeのバージョンは1.36.xを前提としています。
以下のファイルを入手しておいて下さい。
- Vantiq Edge ライセンスファイル
- Vantiq Edge / MongoDB のイメージファイル  
- (r1.37でLLMを有効化する場合)qdrant / ai-assistant のイメージファイル


Vantiq Edgeインストールに関するハードウェア要件などに関しては[Vantiq Edgeインストールガイド](https://community.vantiq.com/wp-content/uploads/2022/06/edge-install-ja-2.html)を参照してください。

# 1. Docker のインストール
オフラインのためパッケージファイルをVantiq Edgeマシンのローカルに配置しDockerをインストールする必要が有ります。  
CentOS Linux release 7.9.2009 (Core) でDocker 24.0.7をインストールした際に必要となったrpmパッケージは以下です。
- audit-libs-python-2.8.5-4.el7.x86_64.rpm
- checkpolicy-2.5-8.el7.x86_64.rpm
- container-selinux-2.119.2-1.911c772.el7_8.noarch.rpm
- containerd.io-1.6.25-3.1.el7.x86_64.rpm
- docker-buildx-plugin-0.11.2-1.el7.x86_64.rpm
- docker-ce-24.0.7-1.el7.x86_64.rpm
- docker-ce-cli-24.0.7-1.el7.x86_64.rpm
- docker-ce-rootless-extras-24.0.7-1.el7.x86_64.rpm
- docker-compose-plugin-2.21.0-1.el7.x86_64.rpm
- fuse-overlayfs-0.7.2-6.el7_8.x86_64.rpm
- fuse3-libs-3.6.1-4.el7.x86_64.rpm
- libcgroup-0.41-21.el7.x86_64.rpm
- libseccomp-2.3.1-4.el7.x86_64.rpm
- libsemanage-python-2.5-14.el7.x86_64.rpm
- policycoreutils-python-2.5-34.el7.x86_64.rpm
- python-IPy-0.75-6.el7.noarch.rpm
- setools-libs-3.3.8-4.el7.x86_64.rpm
- slirp4netns-0.4.3-4.el7_8.x86_64.rpm


## 1.1 rpmパッケージファイルのダウンロード(作業用マシンのOSがCentOS)  
※作業用マシンとしてインターネットにつながり、Vantiq Edgeマシンと同様な環境のCentOSのマシンを用意しておきます。  

オフラインマシンのため、rpmファイルをマシンに配置しておきそのファイルから必要なパッケージやDockerをインストールします。  
参照: [docker docs - Install from a package](https://docs.docker.com/engine/install/centos/#install-from-a-package)  

依存関係のパッケージも必要なため、同じOS・環境のインターネットにつながるマシンを別で用意しておき、そのマシン上で`yumdownloader`を利用しrpmファイル一式をダウンロードします。 

```sh
# yumdonwloaderのインストール
$ sudo yum install yum-utils

# Dockerおよび依存関係パッケージのダウンロード
$ sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
$ yumdownloader --resolve docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

```

上記でカレントディレクトリにrpmパッケージファイル一覧がダウンロードされるため、そのファイルをVantiq Edgeマシンに転送しておきます。  

## 1.1 rpmパッケージファイルのダウンロード(作業用マシンのOSがWindows)  
※作業用マシンとしてインターネットにつながるWindowsのマシンを用意しておきます。 
以下のリファレンスに記載してあるリンクから、Vantiq Edgeマシンに適したDocker関連のrpmパッケージをダウンロードしておきます。
[docker docs - Install from a package](https://docs.docker.com/engine/install/centos/#install-from-a-package)  

上記リンク先で以下のrpmパッケージをダウンロードし、Vantiq Edgeマシンに転送しておきます。

- containerd.io
- docker-buildx-plugin
- docker-ce
- docker-ce-cli
- docker-ce-rootless-extras
- docker-compose-plugin

※インストール時に足りない依存関係パッケージはエラーに表示されるため、都度作業用マシンでダウンロード・Vantiq Edgeマシンに転送し再度インストールを実行します。



## 1.2 インストール実行
Vantiq Edgeマシンにアクセスし転送しておいたrpmパッケージファイルが配置されているディレクトリ(本ドキュメントでは仮としてdocker-installディレクトリとします)に移動します。  

```sh
$ cd ~/docker-instlal

$ sudo yum install ./* 

```

パッケージが不足している場合はエラーが発生し、最後に以下のようなメッセージが出力されます。
```log
Error downloading packages:
 xxx(インストールが必要なpackage一覧)
```

作業用マシンで不足しているrpmパッケージファイルを以下のようにダウンロードします。

**CentOS作業用マシンの場合**
```sh
$ sudo yum install --downloadonly --downloaddir=$(pwd) <Package>
# 例: 
# sudo yum install --downloadonly --downloaddir=$(pwd) container-selinux-2.119.2-1.911c772.el7_8.noarch

```

**Windows作業用マシンの場合**
[rpmfind.net](https://rpmfind.net/linux/RPM/)でパッケージを探します。  
Search ボックスにパッケージ名を入力し検索してください。検索後表示される一覧の中から対象のエラーメッセージに表示されているバージョンのrpmをダウンロードします。ダウンロード前にDistributionがVantiq Edgeマシンに一致しているかどうかを確認してください。  


rpmファイルをダウンロードしたら、Vantiq Edgeマシンのdocker-installディレクトリに転送し、再度yum installを実行します。  
上記をDockerがインストールできるまで繰り返します。 

インストール後、docker serviceを有効にします。  
```sh
$ sudo systemctl start docker
```

# 2. Vantiq Edgeの起動

## 2.1 コンテナイメージのload
Vantiq EdgeおよびMongoDBイメージファイル(tar.gz)をVantiq Edgeマシンに転送しておきます。  
Vantiq Edgeマシンで以下のコマンドを実行しコンテナイメージを取り込みます。 

```sh
$ sudo docker load < <Vantiq Edge イメージファイル> 
$ sudo docker load < <MongoDB イメージファイル> 
```

※コンテナイメージファイルはインターネットにつながるマシンでPullしておき、以下のコマンドで作成できます。(要quay.ioリポジトリへのログイン・権限、Dockerコマンド)  

```sh
# Vantiq Edge 1.36.6の例
$ sudo docker save quay.io/vantiq/vantiq-edge:1.36.6 | gzip > vantiqedge_1.36.6.tar.gz

$ sudo docker save bitnami/mongodb:4.2.5 | gzip > mongodb.tar.gz

# Vantiq Edge 1.37.xでai-assistantを有効化する場合以下も必要
$ sudo docker save quay.io/vantiq/ai-assistant:1.37.8 | gzip > ai-assistant_1.37.8.tar.gz

$ sudo docker save qdrant/qdrant | gzip > qdrant.tar.gz
```

## 2.2 Vantiq Edge起動
以下のドキュメントを参照してください。
- r1.36以前  
  [Vantiq Edgeインストールガイド - Docker環境のインストール手順](https://community.vantiq.com/wp-content/uploads/2022/06/edge-install-ja-2.html#docker%E7%92%B0%E5%A2%83%E3%81%AE%E3%82%A4%E3%83%B3%E3%82%B9%E3%83%88%E3%83%BC%E3%83%AB%E6%89%8B%E9%A0%86-a-iddocker_image_installationa)  
- r1.37以降
  [Vantiq Edge R1.37のインストールと大規模言語モデル関連機能の設定ガイド](./setup_vantiq_edge_r137_w_LLM.md)
なおコンテナイメージはファイルでload済みのため、Vantiq Edgeマシンではquay.ioへのログインは不要です。  


 