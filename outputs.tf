output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns
}

# output "ec2_ids" {
#  value = module.ec2.instance_ids
# }
