variable "cidr" {
  type        = string
  description = "VPC's CIDR range ie. 10.0.0.0/16"
}

variable "flow_logs" {
  type        = bool
  description = "Enable VPC flow logs"
  default     = true
}

variable "common_tags" {
  type = object({
    purpose = string
    expire-on     = string
    owner = string
  })
  description = "Default AWS resource's tags"
}

variable "logging_bucket" {
  description = "S3 bucket name to receive access logs"
  type        = string
  default     = "ENTER YOUR LOGGING BUCKET NAME"
}

# Uncomment this if you want to use KMS for S3 bucket encryption
# variable "kms_key_id" {
#   description = "KMS key ARN for default S3 encryption"
#   type        = string
# }

variable "log_retention_days" {
  description = "Days before flow logs expire"
  type        = number
  default     = 90
}

