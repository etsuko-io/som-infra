init:
	terraform init -backend-config s3.tfbackend

apply:
	terraform apply -backend-config s3.tfbackend
