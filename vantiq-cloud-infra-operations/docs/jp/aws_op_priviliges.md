# Vantiqを運用するのに必要なAWSの権限

## IAM
必要に応じてResourceの絞り込みを行う。
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "eks:List*",
                "eks:AccessKubernetesApi",
                "resource-groups:List*",
                "cloudwatch:*",
                "ec2:Describe*",
                "logs:*",
                "events:*",
                "ec2:Get*",
                "applicationinsights:*",
                "elasticloadbalancing:*",
                "eks:Describe*",
                "ec2:Search*",
                "synthetics:*",
                "autoscaling:Describe*",
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": "*"
        }
    ]
}
```
EKS クラスタの作成者と運用者が異なる場合、作成者はIAMのロールベースアクセス制御を設定する必要がある。

aws-auth.yaml

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::<account id>:role/EKS-Worker-NodeInstanceRole-<role id>   
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
  mapUsers: |
    - userarn: arn:aws:iam::<account id>:user/<username>
      username: <username>
      groups:
        - system:masters
```
参考：　[Amazon EKS でクラスターを作成した後、他の IAM ユーザーおよびロールにアクセス権を付与するにはどうすればよいですか?](https://aws.amazon.com/jp/premiumsupport/knowledge-center/amazon-eks-cluster-access/)
