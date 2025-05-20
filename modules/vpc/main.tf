locals {
  vpc_component       = "vpc" # Virtual Private Cloud (VPC)
  flow_logs_component = "vpc-flow-logs"
  s3_bucket_component = "s3"
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

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
  target_bucket = aws_s3_bucket.vpc_flow_logs.bucket
  target_prefix = "${local.s3_bucket_component}/"
  depends_on = [
    aws_s3_bucket.vpc_flow_logs
  ]
}

# Block all public access for VPC Flow Logs bucket
resource "aws_s3_bucket_public_access_block" "vpc_flow_logs" {
  bucket                  = aws_s3_bucket.vpc_flow_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create KMS key for S3 bucket encryption
resource "aws_kms_key" "s3_encryption_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
  
  # Define a proper key policy to address CKV2_AWS_64
  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "key-policy-1",
    Statement = [
      {
        Sid    = "Enable IAM User Permissions",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "Allow VPC Flow Logs to use the key",
        Effect = "Allow",
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })

  tags = merge(
    {
      Component = local.s3_bucket_component
      Name      = join("-", [var.common_tags.purpose, var.common_tags.expire-on, "s3-kms-key"])
    }
  )
}

resource "aws_kms_alias" "s3_encryption_key_alias" {
  name          = "alias/vpc-flow-logs-${aws_vpc.main.id}"
  target_key_id = aws_kms_key.s3_encryption_key.key_id
}

# Apply SSE for the VPC Flow Logs bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "vpc_flow_logs" {
  bucket = aws_s3_bucket.vpc_flow_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_encryption_key.arn
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

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Default SG of the VPC
resource "aws_default_security_group" "restrict_default" {
  # Point at the VPC whose *default* SG you want to lock down
  vpc_id = aws_vpc.main.id

  # When you remove this resource, don’t try to recreate the default rules
  revoke_rules_on_delete = false

  tags = merge(
    {
      Component = local.vpc_component
      Name      = join("-", [var.common_tags.purpose, var.common_tags.expire-on, "default-sg"])
    }
  )
}

