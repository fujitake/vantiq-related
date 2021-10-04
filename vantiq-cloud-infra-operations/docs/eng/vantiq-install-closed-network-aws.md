# Considerations for Closed Network Configuration（AWS）

## Internal Load Balancer
For EKS, configure Internal LB by adding `annotations` to `nginx.controller.service`.
Specicy `service.beta.kubernetes.io/aws-load-balancer-internal`.

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
As for other `annotations`;
- `service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled` - Specifies whether cross-zone load balancing is enabled for the load balancer
- `service.beta.kubernetes.io/aws-load-balancer-proxy-protocol` - To enable PROXY protocol support for clusters running on AWS
- `service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout` - The time, in seconds, that the connection is allowed to be idle (no data has been sent over the connection) before it is closed by the load balancer

#### References
- https://kubernetes.io/docs/concepts/services-networking/_print/
- https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.2/guide/service/annotations/


## Configure Private Endpoint
The default endpoint for AWS services (S3, RDS, EKS, ECR) is public and cannot be accessed from a closed network. It is required to enable Private Endpoint.

- Enable "DNS hostnames (`enableDnsHostnames`)" and "DNS resolution (`enableDnsSupport`)" for the VPC where the EKS worker node is hosted. -> This allows the Private Endpoint from this PVC to resolve to the IP of the subnet.  
- Create a Private Link with VPC Endpoint menu.  
  - `s3.ap-northeast-1.amazonaws.com`
- Configure a Private Link to s3 in the route table of the subnet where the EKS Worker Node is hosted.  
- Create a Endpoint with VPS Endpoint menu -> Private DNS Zone will be enabled.  
  - `ec2.ap-northeast-1.amazonaws.com`
  - `dkr.ecr.ap-northeast-1.amazonaws.com`
  - `api.ecr.ap-northeast-1.amazonaws.com`
  - EKS endpoints (`ap-northeast-1.eks.amazonaws.com`) and RDS endpoints (`ap-northeast-1.rds.amazonaws.com`) should be able to be resolved as private in the configuration, but make sure to confirm this by nslookup from within the VPC.  

## About the use of Proxy servers
When configuring a Proxy, access to the Proxy is done before DNS resolution. This means that if nothing is done, the DNS resolution of the Private Endpoint will be done on the DNS server.（Reference: https://milestone-of-se.nesuke.com/nw-basic/grasp-nw/proxy/) _(Japanese)_

So, it is necessary to make sure that Private Endpoint is set to `NO_PROXY`.  

#### Reference
- https://aws.amazon.com/premiumsupport/knowledge-center/eks-http-proxy-configuration-automation/?nc1=h_ls

The reference URL is not fully configured and does not cover all Private Endpoints required by Vantiq. Also refer to the following. Replace CIDR `172.X.X.X/XX` and endpoint region `ap-northeast-1` as appropriate for the environment. As for `<cluster certificate key>`, please refer to [here](https://docs.aws.amazon.com/eks/latest/userguide/private-clusters.html).  

- `proxy-environment-variable` Example of ConfigMap;

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

- Example of User Data to be configured on an EKS Worker Node:  
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
