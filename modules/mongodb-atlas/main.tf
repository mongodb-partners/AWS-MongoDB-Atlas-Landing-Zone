terraform {
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.0"
    }
  }
}

# Fetching the MongoDB Atlas API keys from AWS Secrets Manager
data "aws_secretsmanager_secret" "mongodb_atlas" {
  name = "YOUR_SECRET_NAME"  # Replace with your secret's name
}

# Fetching the secret string from the secret
data "aws_secretsmanager_secret_version" "mongodb_atlas" {
  secret_id = data.aws_secretsmanager_secret.mongodb_atlas.id
}

locals {
  # Split the string by comma
  split_string = split("-", var.aws_region)

  # Convert each element to uppercase
  uppercase_elements = [for s in local.split_string : upper(s)]

  # Join the elements back together with a delimiter
  atlas_region = join("_", local.uppercase_elements)

  # Parse the JSON string to get the API keys from the Secrets Manager
  secrets = jsondecode(data.aws_secretsmanager_secret_version.mongodb_atlas.secret_string)
}

# MongoDB Atlas provider
provider "mongodbatlas" {
  public_key  = local.secrets.public_key
  private_key = local.secrets.private_key
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
    cidr_blocks = ["ADD_IP_RANGE"] # Replace with your actual IP range(s) eg: 0.0.0.0/0
    description = "Allow SSH access from specified IP range(s)"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["ADD_IP_RANGE"] # Replace with your actual IP range(s) eg: 0.0.0.0/0
    description = "Allow all outbound traffic" # Consider restricting this further as per your choice
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