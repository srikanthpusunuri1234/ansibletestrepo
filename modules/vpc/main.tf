resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project}-igw"
  }
}

resource "aws_security_group" "asg_servers_sg" {
  name        = "asg-servers-security-group1"
  description = "Allows traffic from the ALB and SSH access"
  vpc_id      = aws_vpc.this.id # Replace with your VPC ID or a variable
  
  # Allow SSH access for administration (from a specific IP or CIDR)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # IMPORTANT: Change this! 
  }

  # Allow inbound HTTP traffic from the ALB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }
  #for testing remove it in production
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # Source is anywhere on the internet
    cidr_blocks = ["0.0.0.0/0"] 
  }

  # Allow inbound HTTPS traffic from the ALB
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  # Allow all outbound traffic from the servers
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-asg-servers-security-group"
  }
}

resource "aws_security_group" "monitor_sg" {
  name        = "asg-servers-monitor-security-group"
  description = "Allows traffic from the monitoring server"
  vpc_id      = aws_vpc.this.id # Replace with your VPC ID or a variable
  
  # Allow Prometheus (monitoring server) to scrape Node Exporter
  ingress {
    description = "Allow Prometheus to scrape Node Exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # change to monitoring SG
  }

  # Allow Promtail HTTP endpoint (Loki push or metrics)
  ingress {
    description = "Allow Promtail metrics or log forwarding"
    from_port   = 9080
    to_port     = 9080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # change to monitoring SG
  }

  # Allow all outbound traffic from the servers
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "${var.project}-asg-servers-security-group-monitor"
  }

}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-public-${count.index + 1}"
  }
}


# Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.project}-private-${count.index + 1}"
  }
}


# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  tags = {
    Name = "${var.project}-nat-eip"
  }
}

# NAT Gateway (in first public subnet)
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.project}-natgw"
  }

  depends_on = [aws_internet_gateway.this]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.project}-public-rt"
  }
}

# Associate Public Subnets with Public RT
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.project}-private-rt"
  }
}

# Associate Private Subnets with Private RT
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}



# S3 VPC Endpoint
resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.private.id]
  tags = {
    Name = "${var.project}-s3-vpce"
  }
}

# DynamoDB VPC Endpoint
resource "aws_vpc_endpoint" "dynamodb_gateway_endpoint" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.private.id]
  tags = {
    Name = "${var.project}-dynamodb-vpce"
  }
}


# Outputs
output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "asg_sg_id" {
  value = aws_security_group.asg_servers_sg.id
}

output "asg_sg_id2" {
  value = aws_security_group.monitor_sg.id
}
