
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}


resource "aws_vpc" "terraformvpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "FF1-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terraformvpc.id

  tags = {
    Name = "FF1-igw"
  }
}

resource "aws_subnet" "publicsub" {
  vpc_id            = aws_vpc.terraformvpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "FF1-subnet"
  }
}

resource "aws_route_table" "rtable" {
  vpc_id = aws_vpc.terraformvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "FF1-RT"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.publicsub.id
  route_table_id = aws_route_table.rtable.id
}
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.terraformvpc.id

  tags = {
    Name = "Sg-FF1-allow all"
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "web1" {
  ami                         = "ami-0c50b6f7dc3701ddd"
  instance_type               = "t2.micro"
  key_name                    = "Mumbai-key-25"
  security_groups             = [aws_security_group.allow_tls.id]
  subnet_id                   = aws_subnet.publicsub.id
  associate_public_ip_address = true
  count                       = 1
  tags = {
    Name = "FF1-Server.${count.index + 0}"
  }
}
