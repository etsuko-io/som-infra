data "aws_ami" "ec2_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.*-x86_64-ebs"]
  }
}

resource "aws_launch_template" "celery_consumer" {
  name = "celery-consumer"

  placement {
    availability_zone = "eu-west-1"
  }
  instance_market_options {
    market_type = "spot"
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.sqs_full_access_profile.name
  }
  monitoring {
    enabled = true
  }
  update_default_version = true
  key_name = "ec2-spot-ssh"
  instance_type = "t2.micro"
  image_id      = data.aws_ami.ec2_ami.image_id
  user_data     = base64encode("${local.user_script}")
}

locals {
  git_repo = "https://github.com/geekrohit/celery-sqs-spot.git"
  user_script = <<EOF
    export SQS_URL=${aws_sqs_queue.som_queue.url}
    apt-get update -qq
    apt-get -qq -y install python3 git
    curl -fsSL https://get.docker.com | bash -
    curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    cd /opt
    git clone ${local.git_repo} celery
    cd celery
    docker-compose up -d
  EOF
}
