data "aws_ami" "ec2_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-2.0.*-arm64-ebs"]
  }
}

resource "aws_spot_instance_request" "spot_instance" {
  availability_zone    = "eu-west-1a"
  iam_instance_profile = aws_iam_instance_profile.celery_access_profile.name
  monitoring           = true
  key_name             = "ec2-spot-ssh"
  instance_type        = "t4g.large"
  ami                  = data.aws_ami.ec2_ami.id
  user_data            = base64encode(local.user_script)
  wait_for_fulfillment = true
}

output "public_ip" {
  value = aws_spot_instance_request.spot_instance.public_ip
}

output "ssh_string" {
  value = "ssh -i ~/.ssh/ec2-spot-ssh.pem ec2-user@${aws_spot_instance_request.spot_instance.public_ip}"
}

locals {
  # yum:
  # -qq:    No output except for errors
  # -y:     Assume answer to all prompts is yes
  #
  # curl:
  # -f      Fail silently on server errors; silent mode, but show if fails;
  # -s      Silent or quiet mode. Don't show progress meter or error messages.
  # -S      When used with -s it makes curl show an error message if it fails.
  # -L      Location
  #
  # bash -  Specifies standard input (instead of an actual file)
  #
  # -o      Output to file instead of stdout
  #
  # uname
  #   -s    Kernel name
  #   -m    Machine (hardware type)
  #
  # docker-compose:
  # -d      Detached mode: Run containers in the background
  private_key = file("${path.module}/private/private_key")
  cloudwatch_config = file("${path.module}/cloudwatch-agent/config.json")
  user_script = <<EOF
    #! /bin/bash
    echo "Starting user script"
    yum update -y -q

    echo "Installing CloudWatch"
    yum install amazon-cloudwatch-agent -y -q
    echo "${local.cloudwatch_config}" > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    echo "Starting CloudWatch"
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s

    echo "Installing git"
    yum -y -q install git

    echo "Installing docker-compose"
    curl -L "https://github.com/docker/compose/releases/download/v2.9.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
    chmod +x /usr/bin/docker-compose

    echo "Adding SSH"
    echo "${local.private_key}" > /root/.ssh/id_rsa
    chmod 600 /root/.ssh/id_rsa
    echo "${var.ssh_public_key}" >> /root/.ssh/authorized_keys
    ssh-keyscan -t rsa github.com >> /root/.ssh/known_hosts

    echo "Adding CELERY_BROKER to env"
    export CELERY_BROKER=sqs://

    echo "Creating project"
    cd /opt
    mkdir project
    cd project
    git clone ${var.git_repo} .

    echo "Launching Docker containers"
    make docker-build-prod
  EOF
}
