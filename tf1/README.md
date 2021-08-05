This module runs with default input varibles:
- Ubuntu 20.04 ami image
- eu-west-1 region
- Instance type t4g.micro

To run on defaults, first initialise it:
```console
terraform init
terraform plan
terrafrom apply
```
Then plan and apply:
```console
terraform plan
terrafrom apply
```
To run on non-defaults use the input.tfvars: 
```console
terraform plan -var-file="input.tfvars"
terrafrom apply -var-file="input.tfvars"
```