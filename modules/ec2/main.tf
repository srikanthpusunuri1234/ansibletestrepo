/*
# Latest Ubuntu 22.04 LTS (Jammy) for x86_64 (t2.micro compatible)
data "aws_ami" "ubuntu_x86" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
*/

locals {
  instance_keys = keys(var.instance_definitions)
  subnet_count  = length(var.subnet_ids)
}

# Create 2 EC2 instances in round-robin across subnets
resource "aws_instance" "this" {
  for_each      = var.instance_definitions
  ami           = var.ami_id
  instance_type = each.value  # set this to "t2.micro"
  # Round-robin across subnets using key index
  subnet_id = var.subnet_ids[
    index(local.instance_keys, each.key) % local.subnet_count
  ]
  key_name      = var.ec2_key_name
  vpc_security_group_ids = var.security_group_ids
  user_data_base64 = filebase64("${path.module}/install.sh")

  tags = {
    Name = each.key
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = aws_instance.this

  target_group_arn = var.target_group_arn
  target_id        = each.value.id
  port             = 80
}

output "instance_ids" {
  value = [for instance in aws_instance.this : instance.id]
}
