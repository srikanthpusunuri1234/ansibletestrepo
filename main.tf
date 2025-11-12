terraform {
  required_version = "~> 1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.65.0"
    }
  }

  backend "s3" {
    bucket         = "gitlabbucket123321"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}


module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  aws_region          = var.aws_region
  alb_sg_id           = module.alb.alb_sg_id
}

module "ec2" {
  source        = "./modules/ec2"
  instance_type = var.instance_type
  ami_id        = var.ami_id1
  subnet_ids    = module.vpc.public_subnet_ids
  ec2_key_name  = var.ec2_key_name
  target_group_arn   = module.alb.target_group2_arn
  security_group_ids = [module.vpc.asg_sg_id]
}

/*
module "alb" {
  source     = "./modules/alb"
  subnet_ids = module.vpc.public_subnet_ids
  vpc_id        = module.vpc.vpc_id
}

module "asg" {
  source        = "./modules/asg"
  ami_id        = var.ami_id1
  instance_type = var.instance_type
  ec2_key_name  = var.ec2_key_name
  subnet_ids    = module.vpc.private_subnet_ids
  vpc_id        = module.vpc.vpc_id
  target_group_arn = module.alb.target_group_arn
  asg_sg_id        = [module.vpc.asg_sg_id, module.vpc.asg_sg_id2]
  name             = var.name1
  app_version      = var.app_version
}
*/

/*
module "worker_asg" {
  source           = "./modules/asg"
  ami_id           = var.ami_id2
  ec2_key_name     = var.ec2_key_name
  subnet_ids       = module.vpc.private_subnet_ids
  vpc_id           = module.vpc.vpc_id
  max_size         = 2
  min_size         = 1
  desired_capacity = 1
  target_group_arn = module.alb.target_group2_arn    # TG arn of app2
  asg_sg_id        = [module.vpc.asg_sg_id, module.vpc.asg_sg_id2]
  name             = var.name2
  app_version      = var.app_version
  
}
*/



# module "s3" {
#   source = "./modules/s3"
# }

# module "dynamodb" {
#   source = "./modules/dynamodb"
# }
/*
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }
}
*/


