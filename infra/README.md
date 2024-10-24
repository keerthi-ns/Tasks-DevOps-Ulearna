Infrastructure setup Using Terraform
-----------------------------------------

This will help you to setup AWS infrastructure using Terraform. It includes setting up a VPC with public and private subnets, route 53, internet gateway and NAT gateway. It also includes resources like RDS (Postgres), EKS (with fargate for serverless containers), Load balancers, s3 bucket. Also included attaching some IAM policies to the cluster.


Prerequisites
--------------------------------
1. Terrafrom should be installed
2. AWS cli to be installed
3. You need an AWS account to provision your resources with necessary permissions to create and manage all resources.


Steps to get started
--------------------------------
# Step 1: Clone the Repository

# Step 2: Initialize terraform - terraform init

# step 3: Use terraform commands to create the infrastructure

terraform validate

terraform plan

terraform apply -auto-approve

# Step 4: Verify the resources creates using IaC in AWS management console

# Step 5: If you want to delete the resources use terraform destroy command

terraform destroy