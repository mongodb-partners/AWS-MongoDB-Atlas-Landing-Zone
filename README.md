# AWS and MongoDB Atlas Landing Zone

This Terraform script will create a landing zone in AWS and MongoDB Atlas that can act as a starting point for enterprises to consume MongoDB Atlas services in their environment. It will create the following resources:

- Amazon Virtual Private Cloud (VPC)
- NAT Gateways
- Public and private subnets
- Route tables
- Tags for AWS resources
- MongoDB Atlas Project
- MongoDB Atlas Cluster
- Private Endpoint

# What we are creating

![Image](docs/images/LZ%20-%20AWS%20and%20Atlas%20with%20Terraform.png)

## Prerequisites

You _must_ have the following ready

- AWS Access Key ID
- AWS Secret Access Key
- Amazon S3 bucket (used to store the Terraform state)
- At least 2 Elastic IP Address allocation IDs
- MongoDB Atlas Organization ID
- MongoDB Atlas Public and Private Keys

### How to get the Organization ID in MongoDB Atlas

[Sign up](https://www.mongodb.com/cloud/atlas/register) on MongoDB Atlas, if you do not have an Atlas account.
If you already have an Atlas account, follow the [steps](https://www.mongodb.com/docs/atlas/access/orgs-create-view-edit-delete/) to create an organization and you can copy the Organization ID once you successfully it.

### Store the MongoDB Atlas Public & Private keys in AWS Secrets Manager

Follow the [instructions](https://www.mongodb.com/docs/atlas/configure-api-access/#grant-programmatic-access-to-an-organization) at the organization level in MongoDB Atlas to generate API keys. 

Then, [store](https://docs.aws.amazon.com/secretsmanager/latest/userguide/create_secret.html) these keys in AWS Secrets Manager to avoid manual entry during Terraform execution. 

After that, update the secret name in the `modules/mongodb-atlas/main.tf` file (Line No. 12), so Terraform can retrieve the credentials from Secrets Manager during resource deployment.

### How to create AWS Access key ID and Secret Key

To create AWS `Access Key ID` and `Secret Access Key` you can view the instructions in the https://aws.amazon.com/premiumsupport/knowledge-center/create-access-key/ article.

It is a best practice that you should assign the policy with permissions as narrowly as possible. But in this case, we will choose `AdministratorAccess` policy.

After creating the AWS Access Key, please read the best practices for managing AWS access keys guide at https://docs.aws.amazon.com/general/latest/gr/aws-access-keys-best-practices.html.

### How to allocate Elastic IP address

Please follow the instructions on how to allocate Elastic IP addresses at: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-eips.html#allocate-eip.

### How to create S3 bucket

An Amazon S3 bucket is needed to store Terraform [state](https://www.terraform.io/docs/backends/types/s3.html).

Please follow the instructions on how to create S3 bucket at: https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html

#### Sample Bucket information

**Name:** `[bucket-name]` ie. `startup-name-product-terraform`

**Region:** `ap-southeast-1` (Singapore)

**Access:** `Bucket and objects not public`

**Encryption:** `Yes (S3-SSE)`

**Versioning:** `ON`

### Update `backend "s3"` section

After creating the S3 bucket, you must update the S3 bucket information in `environments/[production|development]/main.tf` to match the bucket name and region you just created.

Example

```
terraform {

	...

  backend "s3" {
    bucket = "startup-name-product-terraform"
    key    = "network/dev"
    region = "ap-southeast-1"
  }
}
```

#### The `key` prefix value

In this example, we instruct Terraform to use a key prefix `network/[prod|dev|staging]` to organize the Terraform state file. You can change the value to reflect the environment you wish to create. In this example, we will create a `dev` environment.

For more information on Amazon S3 key prefixes please visit https://docs.aws.amazon.com/AmazonS3/latest/userguide/using-prefixes.html.

## Terraform variables

The sample Landing Zone provides the input variable values by using Terraform's [variable definition files](https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files).

The Terraform variable file is located at `environments/[production|development]/variables.tf`. You can initiate the value of the variables in `environments/[production|development]/terraform.tfvars`.

#### The following are the list of Terraform's variables need to run this script.

`aws_availability_zones`: List of availability zones

For production environment, we recommend at least 3 availability zones.

```
["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
```

For non-production environment, we can start with 2 availability zones.

```
["ap-southeast-1a", "ap-southeast-1b"]
```

`aws_elastic_ip_allocation_ids`: List of Elastic IP allocation ID's and availability zones:

![Image](docs/images/elastic-ip-allocation-id-sample.png?raw=true)

The number of allication IDs must match the number of availability zones above.

```
["eipalloc-abc", "eipalloc-def", "eipalloc-ghi"]
```

`aws_region`: AWS Region i.e. `"ap-southeast-1"`.

`enable_vpc_flow_logs`: Enable VPC Flow logs

`environment`: Environment of this VPC ie `d` (development), `p` (production).

`product`: Product name i.e. `website`

`public_subnet_cidrs`: Map of public subnet's CIDRs and availability zone

```
{
	"ap-southeast-1a" = "10.0.0.0/24"
	"ap-southeast-1b" = "10.0.1.0/24"
	"ap-southeast-1c" = "10.0.2.0/24"
}
```

`private_subnet_cidrs`: Map of private subnet's CIDRs and availability zone

```
{
	"ap-southeast-1a" = "10.0.32.0/19"
	"ap-southeast-1b" = "10.0.64.0/19"
	"ap-southeast-1c" = "10.0.96.0/19"
}
```

`vpc_cidr`: VPC's CIDR ie. `"10.0.0.0/16"`

## Environment variables

If you are running the script locally on your machine you will need to setup the following environment variables. Instructions on how to setup environment variables are available at: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html#envvars-set

`AWS_ACCESS_KEY_ID:` AWS Access Key ID

`AWS_SECRET_ACCESS_KEY:` AWS Secret Access Key

`AWS_DEFAULT_REGION`: AWS Region

`TF_LOG:` Terraform [log level](https://www.terraform.io/docs/internals/debugging.html) i.e. `DEBUG` or `INFO`

## VPC Configurations

### VPC CIDR

| CIDR        | # of hosts |
| ----------- | ---------- |
| 10.0.0.0/16 | 65,535     |

\* 5 IP addresses are reserved for each CIDR range. [More info](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Subnets.html#vpc-sizing-ipv4).

### Public Subnets' CIDR

Example

| Availability Zone | CIDR        | Available hosts |
| ----------------- | ----------- | --------------- |
| ap-southeast-1a   | 10.0.0.0/24 | 250             |
| ap-southeast-1b   | 10.0.1.0/24 | 250             |
| ap-southeast-1c   | 10.0.2.0/24 | 250             |

For AWS best-practices we recommend minimizing the number of AWS services and components available on the public subnet. This will help reduce the attack surface of our network and improve the security posture of the workload. Also the instances launched into public subnet will _not_ be assigned public IP addresses.

We should have the following components on the public subnet:

- Load Balancers
- Bastion hosts (Jump box)
- VPN servers

### Private Subnet's CIDR

Example

| Availability Zone | CIDR         | Available hosts |
| ----------------- | ------------ | --------------- |
| ap-southeast-1a   | 10.0.32.0/19 | 8,187           |
| ap-southeast-1b   | 10.0.64.0/19 | 8,187           |
| ap-southeast-1c   | 10.0.96.0/19 | 8,187           |

This is the area where we should have our compute, applications, databases, caches, etc. It is not directly connect to the Internet. All outgoing traffic will go through a [NAT Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html), in addition components will not have public IP addresses. Communication to AWS services should go through [VPC Endpoints](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-endpoints.html) to improve security, so traffic will not leave the private network.

### NAT Gateways

For the Landing Zone this will create 3 NAT Gateways as part of the infrastructure. One in each public subnet, and attach the Elastic IP address to each. This allows you to give out these IP addresses to third party website or service that required IP addresses for filtering and authorization.

### Routes and Route tables

The Terraform template will create 2 new routes in each subnet's route tables

1. Public Subnet: Traffic going to the Internet `0.0.0.0/0` will go via the Internet Gateway.
2. Private Subnet: Traffic going to the Internet `0.0.0.0/0` will go via the NAT Gateway.

## Resource Taggings

This script will create 4 tags.

1. **owner**
2. **purpose**
3. **expire-on**

Examples

```
"owner"   = "anuj.panchal"
"purpose" = "partner"
"expire-on" = "2025-10-30"
```

You can use these tags to monitor your usage and cost by [Activating User-Defined Cost Allocation Tags](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/activating-tags.html).

## How to run

The main directory to run Terraform is in `environment/development` directory. Once you change directory into it and set the environment variables, you can run the following commmands:

```
cd environment/development
terraform init
terraform plan
terraform apply
```

### What about other environments?

Copy the whole `development` directory to another directory under `environments`, for example, `production` or `staging`. You can then update the `terraform.tfvars` file with the appropriate value.
