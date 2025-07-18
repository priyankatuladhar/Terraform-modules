# Multiple VPCs using count
module "vpc" {
  count  = 3
  source = "../../modules/vpc"

  vpc_name = "vpc-${count.index + 1}"
  vpc_cidr = "10.${count.index}.0.0/16"

  public_subnets  = ["10.${count.index}.1.0/24", "10.${count.index}.2.0/24"]
  private_subnets = ["10.${count.index}.10.0/24", "10.${count.index}.20.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  common_tags = {
    Environment = "dev"
    Project     = "multi-vpc"
    VpcIndex    = count.index
  }
}

# VPCs using for_each
variable "vpc_configs" {
  default = {
    dev = {
      cidr = "10.10.0.0/16"
      public_subnets = ["10.10.1.0/24", "10.10.2.0/24"]
      private_subnets = ["10.10.10.0/24", "10.10.20.0/24"]
    }
    staging = {
      cidr = "10.20.0.0/16"
      public_subnets = ["10.20.1.0/24", "10.20.2.0/24"]
      private_subnets = ["10.20.10.0/24", "10.20.20.0/24"]
    }
  }
}

module "vpc_foreach" {
  for_each = var.vpc_configs
  source   = "../../modules/vpc"

  vpc_name = "${each.key}-vpc"
  vpc_cidr = each.value.cidr

  public_subnets  = each.value.public_subnets
  private_subnets = each.value.private_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  common_tags = {
    Environment = each.key
    Project     = "foreach-vpc"
  }
}