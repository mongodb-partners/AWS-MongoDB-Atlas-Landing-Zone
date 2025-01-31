variable "aws_availability_zones" {
  type        = list(string)
  description = "List of availability zone in the region"
}

variable "aws_region" {
  type        = string
  description = "AWS region such as 'us-east-2' (Ohio, USA)"
  default     = "us-east-2"
}

variable "aws_elastic_ip_allocation_ids" {
  type        = list(string)
  description = "List of Elastic IP's allocation ID"
}

variable "enable_vpc_flow_logs" {
  type        = bool
  description = "Enable VPC Flow Logs"
  default     = true
}

# variable "environment" {
#   type        = string
#   description = "Environment where AWS resources are deployed"
#   default     = "dev"
# }

# variable "product" {
#   type        = string
#   description = "Product name"
# }

variable "owner" {
  type = string
  description = "Who will be the owner of this resource (Type in your username like 'first_name.last_name')"
}

variable "expire-on" {
  type = string
  default = "2025-10-30"
}

variable "purpose" {
  type = string
  default = "partner"
}

variable "public_subnet_cidrs" {
  type        = map(string)
  description = "List of public subnet's CIDRs"
}

variable "private_subnet_cidrs" {
  type        = map(string)
  description = "List of private subnet's CIDRs"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC's CIDR range ie. 10.0.0.0/16"
}

# MONGODB ATLAS PART
variable "atlas_public_key" {
  description = "MongoDB Atlas Public API Key"
  type        = string
  default     = "wzvstqfl"
}

variable "atlas_private_key" {
  description = "MongoDB Atlas Private API Key"
  type        = string
  default     = "96cf9aa9-96b9-441a-b38d-bc5245263d52"
}

variable "atlas_org_id" {
  description = "ID of the MongoDB Atlas Organization"
  type        = string
  default = "599f016c9f78f769464f5f94"
}

variable "atlas_project_name" {
  description = "Name of the MongoDB Atlas Project"
  type        = string
  default = "anuj-lz-terraform"
}

variable "cluster_name" {
  description = "Name of the MongoDB Atlas Cluster"
  type        = string
  default = "appdb"
}

variable "instance_size" {
  description = "Instance size for the MongoDB Atlas Cluster"
  type        = string
  default = "M10"
}

variable "database_version" {
  description = "Database version for the MongoDB Atlas Cluster"
  type        = string
  default = "7.0"
}

# variable "s3_bucket_name" {
#   description = "Name of the S3 bucket for Atlas logs"
#   type        = string
# }

# variable "iam_role_id" {
#   description = "IAM Role ID for S3 bucket access"
#   type        = string
# }
