# AWS provider and region
provider "aws" {
  region = "ap-southeast-1"
}

# prefix used to name the resources
locals {
  name_prefix = "faizal"
}

# create an IAM role that EC2 can assume
resource "aws_iam_role" "role_example" {

  # role name
  name = "${local.name_prefix}-role-example"

  # allow EC2 service to use this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""

        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# define the permissions for the role
data "aws_iam_policy_document" "policy_example" {

  # allow EC2 to view EC2 information
  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }

  # allow listing of S3 buckets
  statement {
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = ["*"]
  }
}

# create the IAM policy from the document above
resource "aws_iam_policy" "policy_example" {

  name = "${local.name_prefix}-policy-example"

  # convert the policy document into JSON
  policy = data.aws_iam_policy_document.policy_example.json
}

# attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach_example" {

  role       = aws_iam_role.role_example.name
  policy_arn = aws_iam_policy.policy_example.arn
}

# instance profile is needed because EC2 cannot use a role directly
resource "aws_iam_instance_profile" "profile_example" {

  name = "${local.name_prefix}-profile-example"

  role = aws_iam_role.role_example.name
}

# get the VPC by name
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["ce-learner-vpc"]
  }
}

# get the subnets inside the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

# launch the EC2 instance
resource "aws_instance" "example" {

  # Amazon Linux AMI
  ami = "ami-0df7a207adb9748c7"

  # instance size
  instance_type = "t2.micro"

  # launch EC2 in one of the default VPC subnets
  subnet_id = data.aws_subnets.default.ids[0]

  # attach the instance profile so EC2 can use the IAM role
  iam_instance_profile = aws_iam_instance_profile.profile_example.name

  # give the instance a public IP
  associate_public_ip_address = true

  # name tag for easier identification
  tags = {
    Name = "${local.name_prefix}-ec2"
  }
}