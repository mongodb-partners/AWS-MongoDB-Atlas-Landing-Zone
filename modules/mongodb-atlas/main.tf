terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.0"
    }
  }
}

locals {
  # Split the string by comma
  split_string = split("-", var.aws_region)

  # Convert each element to uppercase
  uppercase_elements = [for s in local.split_string : upper(s)]

  # Join the elements back together with a delimiter
  atlas_region = join("_", local.uppercase_elements)
}

# MongoDB Atlas provider
provider "mongodbatlas" {
  public_key  = var.atlas_public_key
  private_key = var.atlas_private_key
}

# Create a MongoDB Atlas project
resource "mongodbatlas_project" "project" {
  name   = var.atlas_project_name
  org_id = var.atlas_org_id
}

# Create a MongoDB Atlas cluster
resource "mongodbatlas_cluster" "cluster" {
  project_id   = mongodbatlas_project.project.id
  name         = var.cluster_name
  provider_name = "AWS"
  provider_instance_size_name = var.instance_size
  provider_region_name = local.atlas_region
  mongo_db_major_version = var.database_version
}

# Initiate the private endpoint creation in Atlas
resource "mongodbatlas_privatelink_endpoint" "pe_east" {
  project_id    = mongodbatlas_project.project.id
  provider_name = "AWS"
  region        = var.aws_region
  timeouts {
    create = "20m"
    delete = "20m"
  }
}

# Connect Atlas Private Endpoint to the VPC endpoint in AWS
resource "mongodbatlas_privatelink_endpoint_service" "pe_east_service" {
  project_id          = mongodbatlas_privatelink_endpoint.pe_east.project_id
  private_link_id     = mongodbatlas_privatelink_endpoint.pe_east.id
  endpoint_service_id = aws_vpc_endpoint.vpce_east.id
  provider_name       = "AWS"
}

# Creates a security group
resource "aws_security_group" "my_security_group" {
  name        = "MySecurityGroup"
  description = "Allow SSH access to EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create AWS VPC endpoint
resource "aws_vpc_endpoint" "vpce_east" {
  vpc_id             = var.vpc_id
  service_name       = mongodbatlas_privatelink_endpoint.pe_east.endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [var.subnet_ids[0]]
  security_group_ids = [aws_security_group.my_security_group.id]
}

# resource "mongodbatlas_private_endpoint" "private_endpoint" {
#   project_id = mongodbatlas_project.project.id
#   cluster_name = mongodbatlas_cluster.cluster.name
#   provider_name = "AWS"
#   region = var.aws_region
#   vpc_id = var.vpc_id
# }

# resource "aws_s3_bucket" "atlas_logs" {
#   bucket = var.s3_bucket_name
#   acl    = "private"
# }

# resource "mongodbatlas_cloud_provider_snapshot_backup_policy" "backup_policy" {
#   project_id = mongodbatlas_project.project.id
#   cluster_id = mongodbatlas_cluster.cluster.id
#   reference_hour_of_day = 2
#   reference_minute_of_hour = 0
#   restore_window_days = 7
#   update_snapshots = true
#   policies {
#     id = "default"
#     policy_items {
#       frequency_type = "daily"
#       retention_unit = "days"
#       retention_value = 7
#     }
#   }
# }

# resource "mongodbatlas_cloud_provider_snapshot_export_bucket" "export_bucket" {
#   project_id = mongodbatlas_project.project.id
#   cluster_id = mongodbatlas_cluster.cluster.id
#   bucket_name = aws_s3_bucket.atlas_logs.bucket
#   iam_role_id = var.iam_role_id
# }