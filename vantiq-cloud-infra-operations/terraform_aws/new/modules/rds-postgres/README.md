## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.keycloak-postgres](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.keycloak](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_security_group.keycloak](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_password.db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS Cluster Name | `string` | `null` | no |
| <a name="input_db_expose_port"></a> [db\_expose\_port](#input\_db\_expose\_port) | keycloak db expose port | `number` | `null` | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | keycloak db instance class | `string` | `null` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | keycloak db name | `string` | `null` | no |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | keycloak db password | `string` | `null` | no |
| <a name="input_db_storage_size"></a> [db\_storage\_size](#input\_db\_storage\_size) | keycloak db storage size | `number` | `null` | no |
| <a name="input_db_storage_type"></a> [db\_storage\_type](#input\_db\_storage\_type) | keycloak db storage type | `string` | `null` | no |
| <a name="input_db_subnet_ids"></a> [db\_subnet\_ids](#input\_db\_subnet\_ids) | VPC subnet ids to allocate keycloak db instance | `list(string)` | `null` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | keycloak db user name | `string` | `null` | no |
| <a name="input_db_vpc_id"></a> [db\_vpc\_id](#input\_db\_vpc\_id) | VPC ID to allocate keycloak db instance | `string` | `null` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | environment to be used in tags | `string` | `null` | no |
| <a name="input_postgres_engine_version"></a> [postgres\_engine\_version](#input\_postgres\_engine\_version) | keycloak db (postgres) engine version | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Region to craete resources | `map(string)` | `null` | no |
| <a name="input_worker_node_sg_id"></a> [worker\_node\_sg\_id](#input\_worker\_node\_sg\_id) | Worker node security group id to allow ssh from basion to worker nodes | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_postgres_admin_password"></a> [postgres\_admin\_password](#output\_postgres\_admin\_password) | n/a |
| <a name="output_postgres_admin_user"></a> [postgres\_admin\_user](#output\_postgres\_admin\_user) | n/a |
| <a name="output_postgres_db_name"></a> [postgres\_db\_name](#output\_postgres\_db\_name) | n/a |
| <a name="output_postgres_endpoint"></a> [postgres\_endpoint](#output\_postgres\_endpoint) | n/a |
