# Information about tearing down the Vantiq cluster
The Vantiq cluster tear down process will be different depending on the configuration when it was built.  

## Configuration Checklist
Check if the infrastructure resource is shared or not. When it is shared, the resource cannot be deleted during the tear down process.  
- [ ] Is not the S3/Azure Blob for backup shared with other systems?  
- [ ] Is not the Kubernetes cluster shared with other systems?  
- [ ] Is not the keycloak server shared with other systems?  
- [ ] Is not the Postgres server shared with other systems?   
- [ ] Is not the Bastion host for working shared with other systems?  
- [ ] Are not multiple Vantiq instances deployed in the same Kubernetes cluster (are they sharing a shared resource)?
- [ ] Are VPC/VNET shared?  
- [ ] Request the signature of confirmation from the customer.

## Backup Checklist
- [ ] Is the mongodb/userdb backup file saved? Or is it unnecessary?  
- [ ] Is the user information of the keycloak server saved? Or is it unnecessary?  
- [ ] Are the necessary Projects exported from Namespace and saved?  
- [ ] Request the signature of confirmation from the customer.  

## Other in advance Checklist
- [ ] Is inter-system integration from systems that depend on the Vantiq stopped?  
- [ ] Is the Heartbeat monitoring finished?   
- [ ] Is the work plan based on the checklists prepared, and are workers assigned?  
- [ ] Is the work plan approved?  

## Procedure to do

Use k8sdeploy_tools, kubectl, AWS/Azure CLI, and Web console for the work. The workers should be involved in configuration and maintenance and should have knowledge of each tool. The persons who have the privilege execute the work. It is desirable to have at least one more person present other than the work person to to make assurance double sure.  

- Delete the Vantiq pod with `undeployVantiq`.  
- Delete PVCs and PVs which are associated with the mongodb and the userdb.  
- Delete the volumes which were Released by PV deletion, from the AWS and the Azure consoles.  
- Delete or save the mongodb backup files.  
- Delete the S3/Azure Storage Account (in case it is not shared).  
- Execute `undeployShared`, `undeployNigix` (in case there are no other Vantiq instances in the same cluster).   
- Delete the realm of the keycloak server. And do export, etc. if necessary.
- Delete the keycloak server (in case it is not shared).  
- Delete the Postgres server (in case it is not shared).  
- Delete PVCa and PVs which are associated with the Influx and the MySQL.  
- Delete the volumes which are Released by PV deletion, from the AWS and the Azure consoles.  
- Delete Kubernetes worker node pools (in case they are not shared).  
- Delete Kubernetes master control plane (in case it is not shared).  
- Delete the resources which are associated with VPC/VNET (in case they are not shared).   

If all of the above are proprietary resources, it is acceptable to execute `terraform destroy` with the terraform definition used at build time. In anticipation of the work to be done during tear down, the followings are encouraged. In Azure, appropriate operation of resource groups, and in AWS, appropriate operation of grouping by tags.  

- Delete or request the deletion of DNS records.  
- Delete the Bastion host for working (in case it is not shared).  
- Update the status of the cluster.  
  - SalesForce Asset Status  
  - k8sdeploy_cluster(_jp)
