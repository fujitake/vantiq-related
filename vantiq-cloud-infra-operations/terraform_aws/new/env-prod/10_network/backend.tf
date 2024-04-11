### Case by use local for terraform backend - start ###
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

### Case by use local for terraform backend - end ###

### Case by use S3 Bucket for terraform backend - start ###
# terraform {
#   backend "s3" {
#     bucket = "<INPUT-YOUR-BUCKET-NAME>"
#     key    = "<INPUT-YOUR-KEY-PREFIX>/network.tfstate"
#     region = "<INPUT-YOUR-BUCKET-REGION>"
#   }
# }
### Case by use S3 Bucket for terraform backend - end ###
