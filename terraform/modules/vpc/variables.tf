variable "project" {
  default = "osm"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/25", "10.0.2.0/25"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.3.0/25", "10.0.4.0/25"]
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "alb_sg_id" {
  type = string
}