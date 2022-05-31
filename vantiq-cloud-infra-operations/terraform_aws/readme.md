[English Version here](readme_en.md)

# VANTIQ on EKS with Terraform
Vantiq Public Cloudを構成するためのAWS Infrastructureの最もシンプルな構成。

## 構成

![Configuration](imgs/terraform_aws_vantiq_config.png)

```
├── env-dev
│   ├── main.tf
│   ├── basion-instance.tf
│   ├── output.tf
│   └── variables.tf
├── env-prod
│   ├── main.tf
│   ├── basion-instance.tf
│   ├── output.tf
│   └── variables.tf
├── env-template
│   ├── main.tf
│   ├── basion-instance.tf
│   ├── output.tf
│   └── variables.tf
└── modules
    ├── eks
    ├── rds-postgres
    └── vpc
```


各モジュールでは以下のリソースを作成する。

### vpc
- **VPC**
- **Subnet** (Private x 3AZ, Public x 3AZ)
- **Internet Gateway**
- **NAT Gateway** (各Public Subnetへアタッチ)
- **Route Table** (Private x 3AZ, Public x 3AZ)

### eks
- **EKS**
- **Managed Node Group**
- **IAM Role & Policy**  
- **Security Group** -  マネージドノードグループの場合、MasterとWorkerに別々のSecurity Groupの割り当てができないためデフォルトのSecurity Groupを使用する。デフォルト構成ではコメントアウトしている。

### rds-postgres  
- **DB Subnet Group**
- **RDS Instance**
- **Security Group**  
Note: シングル構成のため、RDSの構成は考慮が必要

## 構築手順

### terraformのバージョンについて
各moduleでfor_eachを利用しているためv0.12.6以降であること  
確認済みバージョンはv1.1.8

### クラスタ構築の設定値について
各ディレクトリ(`env-prod`,`env-dev`,`env-template`)で環境ごとの設定値を設定し、クラスタ構築を行う。  
重要な設定値は主に以下の通り

### 事前準備事項(terraform init前までに)
- AWSアカウントの用意する
- aws cliをインストール
- kubectlをインストール
- aws cliの初期設定,Credential(access key と secret key の取得)
- S3 Bucketの作成する(tfstateをS3で管理する場合)
  ```sh
  # S3 Bucketを作成
  aws s3 mb s3://<Bucket名> --region <リージョン名>

  #　S3 Bucketのバージョニングを有効化
  aws s3api put-bucket-versioning \
      --bucket <Bucket名> \
      --versioning-configuration Status=Enabled

  # S3 Bucketのバージョニング設定確認
  aws s3api get-bucket-versioning --bucket <Bucket名>
  ```
- インスタンスアクセス用のSSHキーの作成・登録する
- [このサイト](https://aws.amazon.com/jp/blogs/news/vcpu-based-on-demand-instance-limits-are-now-available-in-amazon-ec2/
)を参考にアカウントで使用できるVCPUのクオータを緩和申請する。2020/06時点では、c5,r5,t3,m5といったインスタンスは「Running On-Demand Standard (A, C, D, H, I, M, R, T, Z) instances」といった形でまとめられているため、必要数に応じて適用されている値からvcpuのクォータを挙げる。

- 使用するVPCのIPを確保する。/22以上のサブネットが望ましい。Production構成だと1 nodeあたり30のIPをとるため、11 nodeの構成だと/24では足りない、またサブネットをPrivate, Public, azごと、と分けるため、ギリギリではない方が望ましい


### パラメータの設定
各tfファイルにて、環境に応じてパラメータを設定する。

#### main.tf  
3つのmoduleを呼び出し、VPC・EKS・RDSのリソースを作成  

- locals  
  - `region`: 作成するリージョン  
  - `worker_access_ssh_key_name`: 事前準備事項で作成したSSHキーの名前を指定(Worker Nodeアクセス用)
  - `basion_access_ssh_key_name`: 事前準備事項で作成したSSHキーの名前を指定(踏み台サーバアクセス用)


- terraform  
  - `backend`: tfstateの管理をS3で行う場合は、事前準備で作成したBucket名を設定  
  ※ localの場合は backend "local" のままで


- module `vpc`  
  - `vpc_cidr_block`: 作成するVPCのcidr  
  - `public_subnet_config`: 作成するPublic Subnetのconfigで、各キーのオブジェクト(az-0など)が1つのSubnet  
  - `private_subnet_config`: public_subnet_configと同様、Private Subnet用config


- module `eks`  
  - PublicアクセスポイントのEKSを作成  
  - `cluster_version`: EKSのバージョンを指定  
  - `managed_node_group_config`: マネージドノードグループの設定で、各キーのオブジェクト(VNATIQなど)が1つのマネージドノードグループ  


- module `keycloak-db`  
  - PrivateエンドポイントのDBインスタンスを作成(Private Subnet内のいずれかのAZへシングル構成で作成)  
  - `db_instance_class`: DBインスタンスのインスタンスサイズ  
  - `db_storage_size`: DBインスタンスのディスクサイズ  
  - `db_storage_type`: DBインスタンスのディスク種類  
  - `postgres_engine_version`: PostgreSQLのバージョン  

  ** DBのパスワードは「Passw0rd」で作成されるので、作成後変更**


#### basion-instance.tf  
踏み台サーバ用EC2インスタンスを作成する。
事前準備事項で作成したSSHキーを利用したアクセスを許可を設定する。
また、マネージドノードグループのWorker Nodeは踏み台サーバからのSSHのみ許可される。

- data `aws_ami` `ubuntu`  
踏み台サーバに利用するAMIを取得  


- resource `aws_instance` `basion`  
  - `instance_type`: 踏み台サーバのインスタンスタイプ



### 構築/削除の実行
各environmentのディレクトリに移動し、コマンドを実行する。

**注意！ `env-prod`は本番向けで11台のサーバーで構成するため、多額（月額20万以上）の費用が発生します。お試しであれば、`env-dev`開発向け4台構成をお勧めします。**

```bash
# 初期化
$ terraform init  \
  -var 'access_key=<YOUR-AWS-ACCESS_KEY>' \
  -var 'secret_key=<YOUR-AWS-SECRET_KEY>'

# tfstateの差分算出
$ terraform plan \
  -var 'access_key=<YOUR-AWS-ACCESS_KEY>' \
  -var 'secret_key=<YOUR-AWS-SECRET_KEY>'

# tfstateとの差分を適用(クラウドリソースの作成)
$ terraform apply \
  -var 'access_key=<YOUR-AWS-ACCESS_KEY>' \
  -var 'secret_key=<YOUR-AWS-SECRET_KEY>'

# 構成を削除(クラウドリソースの削除)
$ terraform destroy \
  -var 'access_key=<YOUR-AWS-ACCESS_KEY>' \
  -var 'secret_key=<YOUR-AWS-SECRET_KEY>'

```

### 構築後作業
- keycloak DB(PostgreSQL)インスタンスのパスワード変更する。
- 踏み台サーバへSCPなどを利用し、登録したSSHキーを転送し適切なディレクトリに置き、パーミッションの設定を行う。

踏み台サーバにVantiqのインストールに必要なツールをインストールする際のサンプルスクリプトが「basion-setup-sample.sh」  
実行する場合は踏み台サーバにスクリプトを転送し以下を実行  

```sh
$ chmod +x ./basion-setup-sample.sh
$ sudo ./basion-setup-sample.sh
```

### Vantiqプラットフォームインストール作業への引き継ぎ
以下の設定を実施、および情報を後続の作業に引き継ぐ。

- EKSクラスタ名
- [EKSクラスタへのアクセス権の設定](../docs/jp/aws_op_priviliges.md#EKSへのアクセス権の設定)（terraformの実行したIAMユーザー以外がVantiqプラットフォーム インストール作業を行う場合のみ）
- S3 Storageのエンドポイント
- keycloak DBのエンドポイント、および資格情報
- 踏み台サーバのIPアドレス
- 踏み台サーバへアクセスするためのユーザー名、ssh秘密鍵

```bash
# 構成情報の出力
$ terraform output
```
- Terraform 0.15以降を使用するう場合、password項目をoutputするためには明示的にsensitive属性が必要です。
```tf
"keycloak-db-admin-password" {
...
  sensitive = true
}
```

```bash
# 構成情報のうち、sensitiveな情報の出力
terraform output -json | jq '"keycloak-db-admin-password:" + .keycloak-db-admin-password.value'
```


## Reference
- [eks_configuration_for_VANTIQ_20200622.pptx](https://vantiq.sharepoint.com/:p:/s/jp-tech/ETzg5rfj5D9Hrjc71v5d5DYB3YS23pcvzh_9fy0lnQYMww?e=FKiAhG)
