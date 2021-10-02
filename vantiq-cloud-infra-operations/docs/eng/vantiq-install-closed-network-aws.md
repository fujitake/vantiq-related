# Considerations for Closed Network Configuration (AWS)

## Internal Load Balancer
For EKS, specify Internal LB in the annotations.  
In addition, add a tag to the Subnet where the LB is to be placed to guide it.
