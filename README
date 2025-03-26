# Deploying a Highly available multi-tier web app on AWS using Terraform

Designing and Deploying a custom VPC for a Multi-Tier web application to be hosted on AWS using Terraform

## Prerequisites

Before deploying, ensure you have:
- Terraform installed
- An AWS account
- Configured AWS authentication (via IAM user, AWS CLI profile, or environment variables)

## Resources to be Built
### No-AutoScaling
- Custom VPC
- 4 Subnets, 2 public, 2 private
- IGW attached to VPC 
- 2 NAT GW with eip attached
- 2 EC2s each in each private subnet with user data to install apache
- 2 Security Groups (one for EC2s & one for ALB)
- ALB & Target group for ALB
- IAM Role with SSM Policy attached to reach internet and install apache on each
### AutoScaling
- Add auto-scaling group and Launch Template

## Deployment Steps

### 1. Authenticate with AWS
Terraform requires authentication with AWS. Choose your preferred method:
- **AWS CLI Profile**: `aws configure`
- **Environment Variables**:
  ```sh
  export AWS_ACCESS_KEY_ID="your-access-key"
  export AWS_SECRET_ACCESS_KEY="your-secret-key"
  ```

### 2. Deploy the IaaS Multi-tier web app
a. set all .tf files then run :
```sh
terraform init
terraform plan
```
b. make sure that plan has no issues or problems then run :
```sh
terraform apply -auto-approve
```
c. in case of no-autoscaling deployment, this configuration will set up the whole infrastrcture of the web app, you should be able to check ec2 instances through your browser to make sure that the application is running normally

d. in case of autoscalling deployment, all will be the same but will add both ec2s under autoscalling group defined so that in case of any change in Load or EC2 Failure, another EC2 is launched with the template defined


## Cleanup
To remove the entire infrastructure (excluding the protected server):
```sh
terraform destroy -auto-approve
```
