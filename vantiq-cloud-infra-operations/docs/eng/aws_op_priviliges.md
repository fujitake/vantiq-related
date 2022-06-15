# AWS permissions that are required to manage Vantiq

## IAM
Refining Resources as needed.  
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

## Setting up the Access rights for EKS  
If the creator and the operator of the EKS clusters are different, the creator needs to set up Role Based Access Control for IAM.  

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
Reference: [How do I provide access to other IAM users and roles after cluster creation in Amazon EKS?](https://aws.amazon.com/premiumsupport/knowledge-center/amazon-eks-cluster-access/)
