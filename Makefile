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
	@echo 'ec2_ami = "$(EC2_AMI)"' > Terraform/prod/ec2/terraform.tfvars
	@echo 'ec2_key_name = "$(EC2_KEY_NAME)"' >> Terraform/prod/ec2/terraform.tfvars
	@echo 'control_ip = "$(CONTROL_IP)"' >> Terraform/prod/ec2/terraform.tfvars
	@echo 'agent_ip = "$(AGENT_IP)"' >> Terraform/prod/ec2/terraform.tfvars

	@echo 'db_user = "$(DB_USER)"' > Terraform/prod/rds/terraform.tfvars
	@echo 'db_password = "$(DB_PASSWORD)"' >> Terraform/prod/rds/terraform.tfvars
	@echo 'db_name = "$(DB_NAME)"' >> Terraform/prod/rds/terraform.tfvars

infra:
	cd Terraform/prod/network && terraform init && terraform apply -auto-approve
	cd Terraform/prod/ec2 && terraform init && terraform apply -auto-approve
	cd Terraform/prod/rds && terraform init && terraform apply -auto-approve
	cd Terraform/prod/security-rules && terraform init && terraform apply -auto-approve

	cd Terraform/prod/ec2 && terraform output -raw ec2_public_ip > ../../../EC2_IP.txt
	cd Terraform/prod/rds && terraform output -raw rds_endpoint > ../../../RDS_ENDPOINT.txt

configure:
	$(eval EC2_IP=$(shell cat EC2_IP.txt))
	$(eval RDS_HOST=$(shell cat RDS_ENDPOINT.txt))

	ansible-galaxy collection install signalfx.splunk_otel_collector
	
	cd Ansible && ANSIBLE_HOST_KEY_CHECKING=False \
	ansible-playbook -i "$(EC2_IP)," playbook.yml -u ubuntu \
	--extra-vars "image_name=$(IMAGE_NAME) image_tag=latest \
	db_host=$(RDS_HOST) db_name=$(DB_NAME) db_user=$(DB_USER) db_password=$(DB_PASSWORD) \
	ec2_ip=$(EC2_IP)" \
	--private-key $(KEY)

clean:
	docker system prune -af --volumes

	rm -rf $(WORKSPACE)/*

	sudo rm -rf /tmp/*