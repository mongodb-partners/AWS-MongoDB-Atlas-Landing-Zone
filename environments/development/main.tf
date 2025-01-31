terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.0"
    }
  }

  required_version = "~> 1.0"

  # S3 bucket in which the terraform state will be stored
  backend "s3" {
    bucket = "S3_BUCKET_NAME" # Put in your S3 bucket name
    key    = "KEY_NAME" # Put in your key name (it is the path to the state file in the bucket)
    region = "AWS_REGION" # Put in your AWS region 
  }
}

# Locals block describing the tags for your AWS services
locals {
  common_tags = {
    purpose = var.purpose
    expire-on     = var.expire-on
    owner = var.owner
  }
}

provider "aws" {
  region = var.aws_region
  profile = "anuj-dev" # COMMENT THIS PART IF YOU ARE USING AWS CREDENTIALS

  default_tags {
    tags = local.common_tags
  }
}

# VPC module
module "vpc" {
  source = "../../modules/vpc"

  cidr      = var.vpc_cidr
  flow_logs = var.enable_vpc_flow_logs

  common_tags = local.common_tags
}

# Internet Gateway module
module "igw" {
  source = "../../modules/internet-gateway"

  vpc_id = module.vpc.id

  common_tags = local.common_tags
}

# Public subnet module
module "public_subnet" {
  for_each            = toset(var.aws_availability_zones)
  source              = "../../modules/public-subnet"
  availability_zone   = each.key
  cidr_block          = var.public_subnet_cidrs[each.key]
  internet_gateway_id = module.igw.id

  vpc_id = module.vpc.id

  common_tags = local.common_tags
}

# NAT gateway module
module "nat_gateway" {
  for_each          = toset(var.aws_availability_zones)
  source            = "../../modules/nat-gateway"
  availability_zone = each.key
  eip_allocation_id = var.aws_elastic_ip_allocation_ids[index(var.aws_availability_zones, each.key)]
  public_subnet_id  = module.public_subnet[each.key].id

  common_tags = local.common_tags
}

# Private subnet module
module "private_subnet" {
  for_each          = toset(var.aws_availability_zones)
  source            = "../../modules/private-subnet"
  availability_zone = each.key
  cidr_block        = var.private_subnet_cidrs[each.key]
  nat_gateway_id    = module.nat_gateway[each.key].id

  vpc_id = module.vpc.id

  common_tags = local.common_tags
}

# MongoDB Atlas module
module "mongodb_atlas" {
  source = "../../modules/mongodb-atlas"
  atlas_public_key  = var.atlas_public_key
  atlas_org_id = var.atlas_org_id
  atlas_private_key = var.atlas_private_key
  atlas_project_name = var.atlas_project_name
  cluster_name      = var.cluster_name
  instance_size     = var.instance_size
  database_version  = var.database_version
  aws_region        = var.aws_region
  vpc_id            = module.vpc.id
  subnet_ids        = values(module.private_subnet)[*].id
}

# module "mongodb_atlas" {
#   source = "../../modules/mongodb-atlas"

#   atlas_public_key  = var.atlas_public_key
#   atlas_private_key = var.atlas_private_key
#   atlas_project_name = var.atlas_project_name
#   cluster_name      = var.cluster_name
#   instance_size     = var.instance_size
#   database_version  = var.database_version
#   aws_region        = var.aws_region
#   vpc_id            = module.vpc.id
#   s3_bucket_name    = var.s3_bucket_name
#   iam_role_id       = var.iam_role_id
# }

# module "s3" {
#   source  = "terraform-mongodbatlas-modules/push-based-log-export/mongodbatlas//modules/s3-bucket"
#   project_id = module.mongodb_atlas.project_id
#   bucket_name = module.mongodb_atlas.s3_bucket_name
#   iam_role_name = "push-log-role"
#   iam_role_policy_name = "push-log-policy"
#   force_destroy = false
# }
