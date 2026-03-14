# launch EC2 in one of the public VPC subnets
resource "aws_instance" "example" {
    ami = "ami-0be9cb9f67c8dabd6" # Amazon Linux AMI
    instance_type = "t3.micro" # instance size
    subnet_id = data.aws_subnets.public.ids[0] # launch EC2 in one of the public VPC subnets
    iam_instance_profile = aws_iam_instance_profile.profile_example.name # attach the instance profile so EC2 can use the IAM role
    associate_public_ip_address = true # give the instance a public IP

    # attach the EC2 security group
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]
    
    # name tag for easier identification
    tags = {
        Name = "${local.name_prefix}-ec2"
        }
}