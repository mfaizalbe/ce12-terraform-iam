# get the VPC by name
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["ce-learner-vpc"]
  }
}

# get all public subnets in the VPC
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

# get all private subnets in the VPC
data "aws_subnets" "private" {
  filter { 
    name = "vpc-id" 
    values = [data.aws_vpc.selected.id] 
  }
  
  filter { 
    name = "map-public-ip-on-launch" 
    values = ["false"]
  }
}

# EC2 security group to allow SSH and internet
resource "aws_security_group" "ec2_sg" {
  name        = "${local.name_prefix}-ec2-sg"
  description = "Allow SSH and outbound"
  vpc_id      = data.aws_vpc.selected.id

  ingress { 
    from_port = 22 
    to_port = 22 
    protocol = "tcp" 
    cidr_blocks = ["0.0.0.0/0"] 
    }

  egress { 
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
    }
}

# RDS security group to allow MySQL from EC2 only
resource "aws_security_group" "rds_sg" {
  name        = "${local.name_prefix}-rds-sg"
  description = "Allow EC2 to connect to RDS"
  vpc_id      = data.aws_vpc.selected.id

  ingress { 
    from_port = 3306 
    to_port = 3306 
    protocol = "tcp" 
    security_groups = [aws_security_group.ec2_sg.id] 
    }

  egress {
    from_port = 0 
    to_port = 0 
    protocol = "-1" 
    cidr_blocks = ["0.0.0.0/0"] 
    }
}

# RDS private subnet group
resource "aws_db_subnet_group" "rds_subnet" {
  name        = "${local.name_prefix}-rds-subnet"
  subnet_ids  = data.aws_subnets.private.ids
  description = "Subnet group for RDS"
}