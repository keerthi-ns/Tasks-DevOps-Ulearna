# Infrastructure setup Using Terraform

This will help you to setup AWS infrastructure using Terraform. It includes setting up a VPC with public and private subnets, route 53, internet gateway and NAT gateway. It also includes resources like RDS (Postgres), EKS (with fargate for serverless containers), Load balancers, s3 bucket. Also included attaching some IAM policies to the cluster.


# Prerequisites

1. Terrafrom should be installed
2. AWS cli to be installed
3. You need an AWS account to provision your resources with necessary permissions to create and manage all resources.


# Steps to get started

Step 1: Clone the Repository
_____________________________________
Step 2: Initialize terraform 

__terraform init__
_________________________________________
step 3: Use terraform commands to create the infrastructure

__terraform validate__

__terraform plan__

__terraform apply -auto-approve__
___________________________________________
Step 4: Verify the resources creates using IaC in AWS management console
______________________________
Step 5: If you want to delete the resources use terraform destroy command

__terraform destroy__
_____________________________