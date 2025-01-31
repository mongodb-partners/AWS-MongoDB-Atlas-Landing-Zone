variable "atlas_public_key" {
  description = "MongoDB Atlas Public API Key"
  type        = string
}

variable "atlas_private_key" {
  description = "MongoDB Atlas Private API Key"
  type        = string
}

variable "atlas_org_id" {
  description = "ID of the MongoDB Atlas Organization"
  type        = string
}

variable "atlas_project_name" {
  description = "Name of the MongoDB Atlas Project"
  type        = string
}

variable "cluster_name" {
  description = "Name of the MongoDB Atlas Cluster"
  type        = string
}

variable "instance_size" {
  description = "Instance size for the MongoDB Atlas Cluster"
  type        = string
}

variable "database_version" {
  description = "Database version for the MongoDB Atlas Cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "ID of the AWS VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of AWS subnet IDs"
  type        = list(string)
}

# variable "s3_bucket_name" {
#   description = "Name of the S3 bucket for Atlas logs"
#   type        = string
# }

# variable "iam_role_id" {
#   description = "IAM Role ID for S3 bucket access"
#   type        = string
# }