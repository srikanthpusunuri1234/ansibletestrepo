output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns
}

output "primary_ip" {
  value = module.ec2.private_ips["primary_db"]
}

output "replica_ip" {
  value = module.ec2.private_ips["secondary_db"]
}

# output "ec2_ids" {
#  value = module.ec2.instance_ids
# }
