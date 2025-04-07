DB_HOST ?= localhost
DB_NAME ?= test
DB_USER ?= user
DB_PASSWORD ?= pass
KEY ?= ~/.ssh/id_rsa
IMAGE ?= my-flask-app
DOCKER_USER ?= user
DOCKER_PASS ?= pass

docker-build:
	sudo docker build -t $(IMAGE) .

docker-push:
	echo "$(DOCKER_PASS)" | sudo docker login -u "$(DOCKER_USER)" --password-stdin
	sudo docker push $(IMAGE)

test:
	sudo docker run --rm \
		-e DB_HOST=$(DB_HOST) \
		-e DB_NAME=$(DB_NAME) \
		-e DB_USER=$(DB_USER) \
		-e DB_PASSWORD=$(DB_PASSWORD) \
		$(IMAGE) python -m unittest discover -s tests

generate-tfvars:
	@echo 'ec2_ami = "$(EC2_AMI)"' > terraform/terraform.tfvars
	@echo 'ec2_key_name = "$(EC2_KEY_NAME)"' >> terraform/terraform.tfvars
	@echo 'db_user = "$(DB_USER)"' >> terraform/terraform.tfvars
	@echo 'db_password = "$(DB_PASSWORD)"' >> terraform/terraform.tfvars
	@echo 'db_name = "$(DB_NAME)"' >> terraform/terraform.tfvars
	@echo 'jenkins_ip = "$(JENKINS_IP)"' >> terraform/terraform.tfvars
	@echo 'jenkins_private_ip = "$(JENKINS_PRIVATE_IP)"' >> terraform/terraform.tfvars

infra:
	cd Terraform && terraform init && terraform apply -auto-approve
	cd Terraform && terraform output -raw ec2_public_ip > ../EC2_IP.txt
	cd Terraform && terraform output -raw rds_endpoint > ../RDS_ENDPOINT.txt

configure:
	$(eval EC2_IP=$(shell cat EC2_IP.txt))
	$(eval RDS_HOST=$(shell cat RDS_ENDPOINT.txt))
	cd Ansible && ANSIBLE_HOST_KEY_CHECKING=False \
	ansible-playbook -i $(EC2_IP), playbook.yml \
	--extra-vars "image_name=$(IMAGE) image_tag=latest \
	db_host=$(RDS_HOST) db_name=$(DB_NAME) db_user=$(DB_USER) db_password=$(DB_PASSWORD)" \
	--private-key $(KEY)
