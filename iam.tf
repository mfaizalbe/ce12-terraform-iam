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

  # allow listing all DynamoDB table
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:ListTables"]
    resources = ["*"]
  }

  # allow EC2 scan only this DynamoDB table
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:Scan"]
    resources = [aws_dynamodb_table.book_inventory.arn]
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

# create instance profile because EC2 cannot use a role directly
resource "aws_iam_instance_profile" "profile_example" {

  name = "${local.name_prefix}-profile-example"

  role = aws_iam_role.role_example.name
}