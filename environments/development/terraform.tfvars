# Terraform variables file for development environment
# You can modify this file as per your requirements
aws_availability_zones        = ["us-east-2a", "us-east-2b"] # Optional "us-east-2c"
aws_elastic_ip_allocation_ids = ["YOUR_ELASTIC_IP_ALLOCATION_ADDRESS_1", "YOUR_ELASTIC_IP_ALLOCATION_ADDRESS_2"]
aws_region                    = "us-east-2"
enable_vpc_flow_logs          = true

# You can modify this section as per the tags that you 
# desire for your AWS services
owner = "anuj.panchal" 
purpose = "partner"
expire-on = "2025-12-31"

public_subnet_cidrs = {
  "us-east-2a" = "10.0.0.0/24"
  "us-east-2b" = "10.0.1.0/24"

  # Optional
  # "us-east-2c" = "10.0.2.0/24"
}
private_subnet_cidrs = {
  "us-east-2a" = "10.0.32.0/19"
  "us-east-2b" = "10.0.64.0/19"

  # Optional
  # "us-east-2c" = "10.0.96.0/19"
}
vpc_cidr = "10.0.0.0/16"
