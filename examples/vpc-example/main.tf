# Single VPC
module "vpc" {
  source = "../../modules/vpc"

  vpc_name = "example-vpc"
  vpc_cidr = "10.0.0.0/16"

  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets  = ["10.0.10.0/24", "10.0.20.0/24"]
  database_subnets = ["10.0.100.0/24", "10.0.200.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false

  common_tags = {
    Environment = "dev"
    Project     = "example"
    Owner       = "terraform"
  }
}

# Multiple VPCs with count
module "vpc_count" {
  count  = 2
  source = "../../modules/vpc"

  vpc_name = "vpc-${count.index + 1}"
  vpc_cidr = "10.${count.index + 1}.0.0/16"

  public_subnets  = ["10.${count.index + 1}.1.0/24", "10.${count.index + 1}.2.0/24"]
  private_subnets = ["10.${count.index + 1}.10.0/24", "10.${count.index + 1}.20.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  common_tags = {
    Environment = "dev"
    Project     = "count-example"
    Index       = count.index
  }
}

# Multiple VPCs with for_each
variable "environments" {
  default = {
    dev = { cidr = "10.10.0.0/16" }
    prod = { cidr = "10.20.0.0/16" }
  }
}

module "vpc_foreach" {
  for_each = var.environments
  source   = "../../modules/vpc"

  vpc_name = "${each.key}-vpc"
  vpc_cidr = each.value.cidr

  public_subnets  = [cidrsubnet(each.value.cidr, 8, 1), cidrsubnet(each.value.cidr, 8, 2)]
  private_subnets = [cidrsubnet(each.value.cidr, 8, 10), cidrsubnet(each.value.cidr, 8, 20)]

  enable_nat_gateway = true
  single_nat_gateway = true

  common_tags = {
    Environment = each.key
    Project     = "foreach-example"
  }
}