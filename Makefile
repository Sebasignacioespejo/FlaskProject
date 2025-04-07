DB_HOST ?= localhost
DB_NAME ?= test
DB_USER ?= user
DB_PASSWORD ?= pass
KEY ?= ~/.ssh/id_rsa
IMAGE ?= my-flask-app
DOCKER_USER ?= user
DOCKER_PASS ?= pass

docker-build:
	docker build -t $(IMAGE) .

docker-push:
	echo "$(DOCKER_PASS)" | docker login -u "$(DOCKER_USER)" --password-stdin
	docker push $(IMAGE)

test:
	docker run --rm \
		-e DB_HOST=$(DB_HOST) \
		-e DB_NAME=$(DB_NAME) \
		-e DB_USER=$(DB_USER) \
		-e DB_PASSWORD=$(DB_PASSWORD) \
		$(IMAGE) python -m unittest discover -s tests

infra:
	cd terraform && terraform init && terraform apply -auto-approve

configure:
	cd ansible && ANSIBLE_HOST_KEY_CHECKING=False \
	ansible-playbook -i inventory.yml playbook.yml \
	--extra-vars "docker_image=$(IMAGE)" \
	--private-key $(KEY)
