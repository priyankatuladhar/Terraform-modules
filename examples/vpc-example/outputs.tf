# Single VPC outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

# Count outputs - reference all
output "all_vpc_ids_count" {
  value = module.vpc_count[*].vpc_id
}

output "first_vpc_id_count" {
  value = module.vpc_count[0].vpc_id
}

# For_each outputs - reference all
output "all_vpc_ids_foreach" {
  value = { for k, v in module.vpc_foreach : k => v.vpc_id }
}

output "dev_vpc_id_foreach" {
  value = module.vpc_foreach["dev"].vpc_id
}

# Reference specific subnets
output "dev_public_subnets" {
  value = module.vpc_foreach["dev"].public_subnets
}