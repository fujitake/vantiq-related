## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.bastion-access-ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_instance.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_security_group.bastion-ssh-allow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [template_file.bastion](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_access_public_key_name"></a> [bastion\_access\_public\_key\_name](#input\_bastion\_access\_public\_key\_name) | Public key for registering bastion instance | `string` | `null` | no |
| <a name="input_bastion_instance_type"></a> [bastion\_instance\_type](#input\_bastion\_instance\_type) | bastion EC2 instance type | `string` | `null` | no |
| <a name="input_bastion_jdk_version"></a> [bastion\_jdk\_version](#input\_bastion\_jdk\_version) | install jdk version | `string` | `"11"` | no |
| <a name="input_bastion_kubectl_version"></a> [bastion\_kubectl\_version](#input\_bastion\_kubectl\_version) | install kubectl version | `string` | `"$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)"` | no |
| <a name="input_bastion_subnet_id"></a> [bastion\_subnet\_id](#input\_bastion\_subnet\_id) | VPC subnet id to allocate bastion instance | `string` | `null` | no |
| <a name="input_bastion_vpc_id"></a> [bastion\_vpc\_id](#input\_bastion\_vpc\_id) | VPC ID | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS Cluster Name | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | bastion ec2 instance create flag | `bool` | `true` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | environment to be used in tags | `string` | `null` | no |
| <a name="input_worker_access_private_key"></a> [worker\_access\_private\_key](#input\_worker\_access\_private\_key) | Private key for access eks worker node | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | bastion instance public ip |
| <a name="output_bastion_ssh_allow_sg_id"></a> [bastion\_ssh\_allow\_sg\_id](#output\_bastion\_ssh\_allow\_sg\_id) | Security Group ID attached bastion instance |
| <a name="output_bastion_userdata"></a> [bastion\_userdata](#output\_bastion\_userdata) | bastion instance user data |
