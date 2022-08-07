resource "aws_iam_instance_profile" "sqs_full_access_profile" {
  name = "sqs-full-access-profile"
  role = aws_iam_role.sqs_full_access_role.name
}

data "aws_iam_policy" "amazon_sqs_full_access" {
  name = "AmazonSQSFullAccess"
}
data "aws_iam_policy" "amazon_s3_full_access" {
  name = "AmazonS3FullAccess"
}


resource "aws_iam_role" "sqs_full_access_role" {
  name               = "sqs-full-access-for-ec2"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_policy.json
  managed_policy_arns = [
    data.aws_iam_policy.amazon_sqs_full_access.arn,
    data.aws_iam_policy.amazon_s3_full_access.arn
  ]
}


data "aws_iam_policy_document" "ec2_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}
