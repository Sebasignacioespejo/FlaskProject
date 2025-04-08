DB_HOST ?= localhost
DB_NAME ?= test
DB_USER ?= user
DB_PASSWORD ?= pass

docker-build:
	docker build -t $(IMAGE_NAME) .

docker-push:
	echo "$(DOCKER_PASS)" | docker login -u "$(DOCKER_USER)" --password-stdin
	docker push $(IMAGE_NAME)

test:
	docker run --rm \
		-e DB_HOST=$(DB_HOST) \
		-e DB_NAME=$(DB_NAME) \
		-e DB_USER=$(DB_USER) \
		-e DB_PASSWORD=$(DB_PASSWORD) \
		$(IMAGE_NAME) python -m unittest discover -s tests

generate-tfvars:
	@echo 'ec2_ami = "$(EC2_AMI)"' > Terraform/terraform.tfvars
	@echo 'ec2_key_name = "$(EC2_KEY_NAME)"' >> Terraform/terraform.tfvars
	@echo 'db_user = "$(DB_USER)"' >> Terraform/terraform.tfvars
	@echo 'db_password = "$(DB_PASSWORD)"' >> Terraform/terraform.tfvars
	@echo 'db_name = "$(DB_NAME)"' >> Terraform/terraform.tfvars
	@echo 'control_ip = "$(CONTROL_IP)"' >> Terraform/terraform.tfvars
	@echo 'agent_ip = "$(AGENT_IP)"' >> Terraform/terraform.tfvars

infra:
	cd Terraform && terraform init && terraform apply -auto-approve
	cd Terraform && terraform output -raw ec2_public_ip > ../EC2_IP.txt
	cd Terraform && terraform output -raw rds_endpoint > ../RDS_ENDPOINT.txt

configure:
	$(eval EC2_IP=$(shell cat EC2_IP.txt))
	$(eval RDS_HOST=$(shell cat RDS_ENDPOINT.txt))
	cd Ansible && ANSIBLE_HOST_KEY_CHECKING=False \
	ansible-playbook -i $(EC2_IP), playbook.yml -u ubuntu \
	--extra-vars "image_name=$(IMAGE_NAME) image_tag=latest \
	db_host=$(RDS_HOST) db_name=$(DB_NAME) db_user=$(DB_USER) db_password=$(DB_PASSWORD)" \
	--private-key $(KEY)
