variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id1" {
  description = "Custom AMI ID"
  default = "ami-0ecb62995f68bb549"
}

variable "ami_id2" {
  description = "Custom AMI ID"
  default = "ami-0ecb62995f68bb549"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ec2_key_name" {
  description = "Existing EC2 key pair name"
  type        = string
  default     = "newkey"
}

variable "name1" {
  description = "Prefix for resource naming"
  type        = string
  default     = "osm-green"
}

variable "name2" {
  description = "Prefix for resource naming"
  type        = string
  default     = "osm-blue"
}

variable "app_version" {
  type        = string
  default     = "v1"
}
