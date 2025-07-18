# VPC Terraform Module

A highly configurable and reusable Terraform module for creating AWS VPC infrastructure.

## Features

- Dynamic subnet creation (public, private, database)
- Configurable NAT Gateway (single or per AZ)
- Internet Gateway with optional creation
- Route tables and associations
- DNS support configuration
- Flexible tagging

## Usage

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name    = "my-vpc"
  vpc_cidr    = "10.0.0.0/16"
  
  public_subnets   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets  = ["10.0.10.0/24", "10.0.20.0/24"]
  database_subnets = ["10.0.100.0/24", "10.0.200.0/24"]
  
  enable_nat_gateway = true
  single_nat_gateway = false
  
  common_tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vpc_name | Name of the VPC | `string` | n/a | yes |
| vpc_cidr | CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |
| public_subnets | List of public subnet CIDR blocks | `list(string)` | `[]` | no |
| private_subnets | List of private subnet CIDR blocks | `list(string)` | `[]` | no |
| database_subnets | List of database subnet CIDR blocks | `list(string)` | `[]` | no |
| enable_nat_gateway | Enable NAT Gateway for private subnets | `bool` | `true` | no |
| single_nat_gateway | Use a single shared NAT Gateway | `bool` | `false` | no |
| common_tags | Common tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| public_subnets | List of IDs of the public subnets |
| private_subnets | List of IDs of the private subnets |
| database_subnets | List of IDs of the database subnets |
| nat_gateway_ids | List of IDs of the NAT Gateways |