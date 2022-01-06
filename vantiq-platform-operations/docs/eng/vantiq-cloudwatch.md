# Vantiq Cloudwatch Logs

In this section, it will explain the procedures to output container logs and metrics including Vantiq on the EKS cluster to CloudWatch by following [Set up Fluent Bit as a DaemonSet to send logs to CloudWatch Logs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-logs-FluentBit.html).  

#### Attach a policy to the IAM role of worker nodes
Please refer to "Attaching a policy to the IAM role of your worker nodes" in [Verify prerequisites](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-prerequisites.html).  

#### Create "amazon-cloudwatch" namespace

If no namespace named `amazon-cloudwatch` exists yet, create one by entering the following command.  
```sh
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cloudwatch-namespace.yaml
```

#### Create "fluent-bit-cluster-info" Configmap
Run the following command to create a ConfigMap named `cluster-info` with the cluster name and the Region to logs to send. Replace `cluster-name` and `cluster-region` with the cluster's name and Region.  
```sh
ClusterName=<cluster-name>
RegionName=<cluster-region>
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
kubectl create configmap fluent-bit-cluster-info \
--from-literal=cluster.name=${ClusterName} \
--from-literal=http.server=${FluentBitHttpServer} \
--from-literal=http.port=${FluentBitHttpPort} \
--from-literal=read.head=${FluentBitReadFromHead} \
--from-literal=read.tail=${FluentBitReadFromTail} \
--from-literal=logs.region=${RegionName} -n amazon-cloudwatch
```

#### Deploy the DaemonSet with Fluent Bit optimized configuration
```sh
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit.yaml
```

#### Validate the deployment
```sh
kubectl get pods -n amazon-cloudwatch
NAME               READY   STATUS    RESTARTS   AGE
fluent-bit-48nv6   1/1     Running   0          20s
fluent-bit-4tnbc   1/1     Running   0          20s
fluent-bit-6tnmt   1/1     Running   0          20s
fluent-bit-8v8ks   1/1     Running   0          20s
fluent-bit-bjvkw   1/1     Running   0          20s
fluent-bit-cgzqz   1/1     Running   0          20s
fluent-bit-d6mlw   1/1     Running   0          20s
fluent-bit-dhpmb   1/1     Running   0          20s
fluent-bit-l2wk5   1/1     Running   0          20s
fluent-bit-qkmvc   1/1     Running   0          20s
```

#### Check the log groups are created

![pic1](../../imgs/vantiq-cloudwatch/pic1.png)

Application (Pod) container logs  

![pic2](../../imgs/vantiq-cloudwatch/pic2.png)

Worker nodes logs  

![pic3](../../imgs/vantiq-cloudwatch/pic3.png)


# Vantiq Cloudwatch Metrics

In this section, it will explain the procedures to output the metrics of containers including Vantiq on the EKS cluster to CloudWatch by following [Set up the CloudWatch agent to collect cluster metrics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-metrics.html).  


#### Create a service account for the CloudWatch agent
```sh
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-serviceaccount.yaml
```

####  Check the service account
```sh
kubectl get sa -n amazon-cloudwatch
NAME               SECRETS   AGE
cloudwatch-agent   1         119s
default            1         31m
fluent-bit         1         25m
```

#### Create a ConfigMap for the CloudWatch agent

Download the ConfigMap template
```sh
curl -O https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-configmap.yaml
```

Edit the downloaded template. Replace `cluster_name` with the actual cluster name. 　
```sh
# create configmap for cwagent config
apiVersion: v1
data:
  # Configuration is in Json format. No matter what configure change you make,
  # please keep the Json blob valid.
  cwagentconfig.json: |
    {
      "logs": {
        "metrics_collected": {
          "kubernetes": {
            "cluster_name": "<cluster_name>",
            "metrics_collection_interval": 60
          }
        },
        "force_flush_interval": 5
      }
    }
kind: ConfigMap
metadata:
  name: cwagentconfig
  namespace: amazon-cloudwatch
```

#### Deploy the ConfigMap
```sh
kubectl apply -f cwagent-configmap.yaml
```

#### Deploy the DaemonSet
```sh
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-daemonset.yaml
```

#### Validate the deployment
```sh
kubectl get pods -n amazon-cloudwatch
NAME                     READY   STATUS    RESTARTS   AGE
cloudwatch-agent-4b2x9   1/1     Running   0          14s
cloudwatch-agent-6wkq9   1/1     Running   0          14s
cloudwatch-agent-869nr   1/1     Running   0          14s
cloudwatch-agent-gk52g   1/1     Running   0          14s
cloudwatch-agent-gwf86   1/1     Running   0          14s
cloudwatch-agent-jcl29   1/1     Running   0          14s
cloudwatch-agent-sjhfs   1/1     Running   0          14s
cloudwatch-agent-xt6gq   1/1     Running   0          14s
cloudwatch-agent-zm5ps   1/1     Running   0          14s
cloudwatch-agent-zvkzk   1/1     Running   0          14s
```

#### Check the log groups are created

![pic4](../../imgs/vantiq-cloudwatch/pic4.png)

![pic5](../../imgs/vantiq-cloudwatch/pic5.png)


### Configure the IAM permissions to check logs

In order to check the output logs of Vantiq-related resources in the CloudWatch console as a user, the following permissions are required.  
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "resource-groups:List*",
                "eks:List*",
                "cloudwatch:*",
                "ec2:Describe*",
                "logs:*",
                "events:*",
                "ec2:Get*",
                "ec2:Search*",
                "eks:AccessKubernetesApi",
                "autoscaling:Describe*",
                "synthetics:*",
                "eks:Describe*",
                "elasticloadbalancing:*",
                "applicationinsights:*"
            ],
            "Resource": "*"
        }
    ]
}
```

### Costs
Estimated monthly cost using Vantiq standard configuration - Approximately $210
- 457 metrics - $137
- PutLogEvents 103GB - $72
