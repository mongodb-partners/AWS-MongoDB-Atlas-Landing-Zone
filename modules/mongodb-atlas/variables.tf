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