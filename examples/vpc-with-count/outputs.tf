# Count outputs
output "vpc_ids_count" {
  value = module.vpc[*].vpc_id
}

output "public_subnets_count" {
  value = module.vpc[*].public_subnets
}

# For_each outputs
output "vpc_ids_foreach" {
  value = { for k, v in module.vpc_foreach : k => v.vpc_id }
}

output "public_subnets_foreach" {
  value = { for k, v in module.vpc_foreach : k => v.public_subnets }
}