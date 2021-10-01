# 閉域網構成における考慮事項（AWS編）


## Internal Load Balancer
EKSの場合、`nginx.controller.service`に`annotations`を追加することで、でInternal LBを構成する。
`service.beta.kubernetes.io/aws-load-balancer-internal`を指定する。

**deploy.yaml**
```
nginx:
  controller:
    tls:
      cert: xxxxxxxx.cer.pem
      key: xxxxxxxx.key.pem
      selfSigned: false
    service:
      annotations:
        service.beta.kubernetes.io/aws-load-balancer-internal: "0.0.0.0/0"
        service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
        service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: '*'
        service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: '3600'
```
それ以外のannotationについて
- `service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled` - Specifies whether cross-zone load balancing is enabled for the load balancer
- `service.beta.kubernetes.io/aws-load-balancer-proxy-protocol` - To enable PROXY protocol support for clusters running on AWS
- `service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout` - The time, in seconds, that the connection is allowed to be idle (no data has been sent over the connection) before it is closed by the load balancer

#### Reference
- https://kubernetes.io/docs/concepts/services-networking/_print/
- https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/service/annotations/


## Private Endpointの設定
AWSのサービス（S3, RDS, EKS, ECR)のエンドポイントはデフォルトはpublicであり、閉域網からはアクセスできない。Private Endpointを有効にする必要がある。

- EKSワーカーノードがホストされているVPCの「DNSホスト名(`enableDnsHostnames`)」と「DNS解決(`enableDnsSupport`)」を有効にする。 -> これにより、このPVCからPrivate EndpointをsubnetのIPに解決できる。
- VPC endpointメニューでPrivate Linkの作成をする。
  - `s3.ap-northeast-1.amazonaws.com`
- EKSワーカーノードがホストされているサブネットのルートテーブルにs3へのprivate linkを設定する。
- VPC EndpointメニューでEndpointを作成する。 -> Private DNS Zoneが有効になる。
  - `ec2.ap-northeast-1.amazonaws.com`
  - `dkr.ecr.ap-northeast-1.amazonaws.com`
  - `api.ecr.ap-northeast-1.amazonaws.com`
  - EKSのエンドポイント(`ap-northeast-1.eks.amazonaws.com`), RDSのエンドポイント(`ap-northeast-1.rds.amazonaws.com`)は構築の設定でprivateで解決できるようになっているはずだが、念の為VPC内から nslookup 確認をしておくこと。

過去のPowerpointから持ってくる

## Proxyサーバーの利用について
Proxyを設定する場合、ProxyへのアクセスはDNS解決より前に行われる。つまり、何もしないとPrivate EndpointのDNS解決が、DNSサーバー上で行われてしまう。（参考：https://milestone-of-se.nesuke.com/nw-basic/grasp-nw/proxy/)

そのため、Private Endpointを確実に`NO_PROXY`としておく必要がある。

#### 参考
- https://aws.amazon.com/jp/premiumsupport/knowledge-center/eks-http-proxy-configuration-automation/

参考のURLは、設定に不備があり、Vantiqが必要とする全てのPrivate Endpointをカバーしていない。以下も合わせて参考にすること。CIDR`172.X.X.X/XX`とエンドポイントのリージョン`ap-northeast-1`は環境に合わせて適宜置き換えること。
`<cluster certificate key>`については、[こちら](https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/private-clusters.html)を参照。

- `proxy-environment-variable` ConfigMapの例。

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: proxy-environment-variables
  namespace: kube-system
data:
  HTTPS_PROXY: http://<user>:<pass>@<proxy_server_host>:<port>
  HTTP_PROXY: http://<user>:<pass>@<proxy_server_host>:<port>
  NO_PROXY: localhost,127.0.0.1,.cluster.local,.svc,docker-registry,172.20.0.0/16,172.30.0.0/16,10.152.226.0/24,10.152.227.0/24,10.152.233.0/24,10.152.234.0/24,10.152.235.0/24,10.152.236.0/24,169.254.169.254,.internal,ec2.ap-northeast-1.amazonaws.com,.s3.ap-northeast-1.amazonaws.com,.dkr.ecr.ap-northeast-1.amazonaws.com,api.ecr.ap-northeast-1.amazonaws.com,.ap-northeast-1.eks.amazonaws.com,.ap-northeast-1.rds.amazonaws.com
```

- EKSワーカーノードに設定するUser Dataの例:
```sh
#!/bin/bash
set -o xtrace
export MYPROXY="<user>:<pass>@<proxy_server_host>:<port>"
export MYNOPROXY="localhost,127.0.0.1,.cluster.local,.svc,docker-registry,172.20.0.0/16,172.30.0.0/16,10.152.226.0/24,10.152.227.0/24,10.152.233.0/24,169.254.169.254,.internal,ec2.ap-northeast-1.amazonaws.com,.s3.ap-northeast-1.amazonaws.com,.dkr.ecr.ap-northeast-1.amazonaws.com,api.ecr.ap-northeast-1.amazonaws.com,.ap-northeast-1.eks.amazonaws.com,.ap-northeast-1.rds.amazonaws.com"
# set proxy for yum
cat >> /etc/yum.conf <<EOF
proxy=http://$MYPROXY
EOF
# set OS proxy via /etc/profile.d/set-proxy.sh
cat > /etc/profile.d/set-proxy.sh <<'EOF'
export http_proxy=<user>:<pass>@<proxy_server_host>:<port>
export https_proxy=<user>:<pass>@<proxy_server_host>:<port>
export no_proxy=localhost,127.0.0.1,.cluster.local,.svc,docker-registry,172.20.0.0/16,172.30.0.0/16,10.152.226.0/24,10.152.227.0/24,10.152.233.0/24,169.254.169.254,.internal,ec2.ap-northeast-1.amazonaws.com,.s3.ap-northeast-1.amazonaws.com,.dkr.ecr.ap-northeast-1.amazonaws.com,api.ecr.ap-northeast-1.amazonaws.com,.ap-northeast-1.eks.amazonaws.com,.ap-northeast-1.rds.amazonaws.com
EOF
# set OS proxy via /etc/environment.export
cat >> /etc/environment.export <<EOF
export http_proxy=http://$MYPROXY
export HTTP_PROXY=http://$MYPROXY
export https_proxy=http://$MYPROXY
export HTTPS_PROXY=http://$MYPROXY
export no_proxy=$MYNOPROXY
export NO_PROXY=$MYNOPROXY
EOF
# set OS proxy via /etc/environment
cat >> /etc/environment <<EOF
http_proxy=http://$MYPROXY
HTTP_PROXY=http://$MYPROXY
https_proxy=http://$MYPROXY
HTTPS_PROXY=http://$MYPROXY
no_proxy=$MYNOPROXY
NO_PROXY=$MYNOPROXY
EOF
# set Docker settings via /etc/systemd/system/docker.service.d dropin files - proxy & LimitNOFILE
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/http-proxy.conf <<'EOF'
[Service]
EnvironmentFile=/etc/environment
EOF
cat > /etc/systemd/system/docker.service.d/nofiles.conf <<'EOF'
[Service]
LimitNOFILE=200000
EOF
# Make systemd aware of the docker.service.d directory
systemctl daemon-reload
# Restart docker to make sure it is using the new parameters
systemctl stop docker
systemctl start docker
# set kubelet proxy settings
cat > /etc/systemd/system/kubelet.service.d/http-proxy.conf <<'EOF'
[Service]
EnvironmentFile=/etc/environment
EOF
# Set proxy variables before calling bootstrap.sh
source /etc/environment.export
# Re-run yum command that failed before this script was run because proxy was not set yet
yum -t -y --exclude=kernel '--exclude=nvidia*' '--exclude=cuda*' --security --sec-severity=critical --sec-severity=important upgrade
env
/etc/eks/bootstrap.sh ${ClusterName} ${BootstrapArguments} --apiserver-endpoint https://<EKS EndPoint>.ap-northeast-1.eks.amazonaws.com --b64-cluster-ca <cluster certificate key>
```
