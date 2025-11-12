variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "name" {
  description = "Prefix for resource naming"
  type        = string
  default     = "osm"
}
