data "aws_availability_zones" "available" {}

# Our current infrastructure will consist of a vpc resource named naim 
# that is declared with a cidr block of "10.0.0.0/16"
resource "aws_vpc" "main" {
    cidr_block = var.main_cidr_block
    
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "main"
    }
}

# We will have 2 public subnets in different availability zones (to achieve a highly available architecture)
# we are looping over the number of subnets we have and creating public subnets accordingly
resource "aws_subnet" "public_subnets" {
  count = length(var.public_cidr_blocks)
  vpc_id = aws_vpc.main.id
  cidr_block = var.public_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_${count.index + 1}"
  }
}

# We need need to create a security group that allows HTTP traffic in and out of instances
resource "aws_security_group" "main_sg" {
  name = "allow_connection"
  description = "Allow HTTP"
  vpc_id = aws_vpc.main.id

  # Ingress is traffic that enters the boundary of a network
  ingress {
    description = "HTTP from anywhere"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Egress in the world of networking implies traffic that exits an entity or a network boundary
  egress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

# Since our VPC will need to connect to the internet, we will need to create an 
# Internet Gateway and attache it to our freshly created VPC as follows
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

# We will also create a route table and attach our public subnets to it, 
# so we will have a route from these subnets to the internet
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public_route"
  }
}

# we are creating two associations one for each subnet
resource "aws_route_table_association" "public_route_association" {
  count = length(var.public_cidr_blocks)
  subnet_id = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route.id
}
