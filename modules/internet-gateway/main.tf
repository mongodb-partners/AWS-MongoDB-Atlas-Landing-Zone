locals {
  component = "igw" # Internet gateway
  prefix    = join("-", [var.common_tags.purpose, var.common_tags.expire-on])
}

resource "aws_internet_gateway" "main" {
  vpc_id = var.vpc_id

  tags = merge(
    {
      Component = local.component
      Name      = join("-", [local.prefix, local.component])
    }
  )
}
