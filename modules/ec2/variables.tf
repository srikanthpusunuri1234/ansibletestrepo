variable "instance_type" {
  default     = "t2.micro"
}
variable "subnet_ids" {
  type = list(string)
}
variable "ec2_key_name" {
  description = "Key pair name for EC2"
  type        = string
}

variable "security_group_ids" {
  description = "A list of security group IDs to associate with the EC2 instances."
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the target group to attach ASG instances"
  type        = string
}

variable "instance_definitions" {
  type = map(string)
  default = {
    "bastion" = "t2.micro"
  }
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}
