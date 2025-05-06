locals {
  vpc_component       = "vpc" # Virtual Private Cloud (VPC)
  flow_logs_component = "vpc-flow-logs"
  s3_bucket_component = "s3"
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Component = local.vpc_component
      Name      = join("-", [var.common_tags.purpose, var.common_tags.expire-on, local.vpc_component])
    }
  )
}

resource "aws_flow_log" "main" {
  count = var.flow_logs ? 1 : 0

  # log_destination      = aws_s3_bucket.vpc_flow_logs[0].arn
  log_destination      = aws_s3_bucket.vpc_flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id

  tags = merge(
    {
      Component = local.flow_logs_component
      Name      = join("-", [var.common_tags.purpose, var.common_tags.expire-on, local.flow_logs_component])
    }
  )
}

# S3 bucket for capturing VPC Flow Logs
resource "aws_s3_bucket" "vpc_flow_logs" {
  # count         = var.flow_logs ? 1 : 0
  bucket        = "vpc-flow-logs-${aws_vpc.main.id}"
  force_destroy = true

  tags = merge(
    {
      Component = local.s3_bucket_component
      Name      = join("-", [var.common_tags.purpose, var.common_tags.expire-on, local.s3_bucket_component])
    }
  )
}

# Specify access logging bucket for Flow Logs bucket
resource "aws_s3_bucket_logging" "vpc_flow_logs" {
  bucket        = aws_s3_bucket.vpc_flow_logs.id
  target_bucket = var.logging_bucket
  target_prefix = "${local.s3_bucket_component}/"
}

# Block all public access for VPC Flow Logs bucket
resource "aws_s3_bucket_public_access_block" "vpc_flow_logs" {
  bucket                  = aws_s3_bucket.vpc_flow_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Apply SSE for the VPC Flow Logs bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # Or "aws:kms" if you want to use KMS
      # Uncomment the line below if you desire to use KMS
      # kms_master_key_id = var.kms_key_id
    }
  }
}

# Enable versioning for VPC Flow Logs bucket
resource "aws_s3_bucket_versioning" "vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable Lifecycle Configuration for object present in the VPC Flow Logs bucket
resource "aws_s3_bucket_lifecycle_configuration" "vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs.id

  rule {
    id      = "expire-old-logs"
    status = "Enabled"

    expiration {
      days = var.log_retention_days
    }
  }
}

# Default SG of the VPC
resource "aws_default_security_group" "restrict_default" {
  # Point at the VPC whose *default* SG you want to lock down
  vpc_id = aws_vpc.main.id

  # When you remove this resource, don’t try to recreate the default rules
  revoke_rules_on_delete = false

  # Deny all inbound on the default SG
  ingress {
    description = "Deny all inbound on default SG"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }

  # Deny all outbound on the default SG
  egress {
    description = "Deny all outbound on default SG"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }
}

