After creation with `terraform apply`, take the output (public_ip)

Use SSH to access the instance:

    ssh -i ~/.ssh/ec2-spot-ssh.pem ec2-user@<public_ip>

Inspect the logs on the EC2 instance:

    sudo cat /var/log/cloud-init-output.log


To check the containers:

    docker ps


The startup script in this repository is found in `som-infra/spot.tf`

The location of the project on the server is /opt/project

