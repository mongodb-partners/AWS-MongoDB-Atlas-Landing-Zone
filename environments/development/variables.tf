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

variable "logging_bucket" {
  type        = string
  description = "S3 bucket name to receive access logs"
  default     = "NAME OF YOUR LOGGING BUCKET"
}

variable "owner" {
  type = string
  description = "Who will be the owner of this resource"
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
variable "atlas_org_id" {
  description = "ID of the MongoDB Atlas Organization"
  type        = string
  default = "YOUR_ORG_ID"
}

variable "atlas_project_name" {
  description = "Name of the MongoDB Atlas Project"
  type        = string
  default = "YOUR_PROJECT_NAME"
}

variable "cluster_name" {
  description = "Name of the MongoDB Atlas Cluster"
  type        = string
  default = "YOUR_CLUSTER_NAME"
}

variable "instance_size" {
  description = "Instance size for the MongoDB Atlas Cluster"
  type        = string
  default = "DESIRED_INSTANCE_SIZE"
}

variable "database_version" {
  description = "Database version for the MongoDB Atlas Cluster"
  type        = string
  default = "DESIRED_DATABASE_VERSION"
}

