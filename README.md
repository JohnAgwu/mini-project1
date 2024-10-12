# mini-project1
New repository for IaC uisng three tier architecture and two different availability zones

## Provider configuration
London region

## Security Group
Accessible to all. Uncomment to restrict access in sg for backend and database

## Steps
- Export Access key and Secret Key
- Run Terraform init
- Run Terraform plan -var-file="project.tfvars"
- Run Terraform apply -var-file="project.tfvars"
- Run telnet public_ip port to test port
- Voilaa Complete!