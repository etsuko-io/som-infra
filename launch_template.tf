resource "aws_launch_template" "celery_consumer" {
  placement {
    availability_zone = "eu-west-1"
  }
  instance_market_options {
    market_type = "spot"
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.sqs_full_access_profile.name
  }

  instance_type = "t2.micro"
  image_id      = ""
  user_data     = filebase64("${path.module}/example.sh")
}
