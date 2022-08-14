resource "aws_iam_instance_profile" "celery_access_profile" {
  name = "sqs-full-access-profile"
  role = aws_iam_role.celery_role_for_ec2.name
}

data "aws_iam_policy" "amazon_sqs_full_access" {
  name = "AmazonSQSFullAccess"
}
data "aws_iam_policy" "amazon_s3_full_access" {
  name = "AmazonS3FullAccess"
}
data "aws_iam_policy" "amazon_cloudwatch_full_access" {
  name = "CloudWatchFullAccess"
}


resource "aws_iam_role" "celery_role_for_ec2" {
  name               = "celery-role-for-ec2"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_policy.json
  managed_policy_arns = [
    data.aws_iam_policy.amazon_sqs_full_access.arn,
    data.aws_iam_policy.amazon_s3_full_access.arn,
    data.aws_iam_policy.amazon_cloudwatch_full_access.arn
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
