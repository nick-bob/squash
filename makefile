.PHONY:
docker: ## Build docker container
	cd app && docker build -t nick-bob/squash:latest . && \
	docker save nick-bob/squash:latest | gzip > squash.tgz && \
	mv squash.tgz ../infra/packer

.PHONY:
build_infra: ## Build AWS infra via terraform
	cd infra/terraform/src/base && \
	terraform init && terraform apply -auto-approve && \
	sh export_packer_vars.sh

.PHONY:
ami: docker build_infra ## Build AWS AMI via packer
	cd infra/packer && \
	packer init . && packer build .

.PHONY:
deploy_app: ami ## Deploy Squash App
	cd infra/terraform/src/app && terraform init && terraform apply -auto-approve

.PHONY:
clean: ## Destroy AWS infra via terraform
	cd infra/terraform/src/app && terraform init && terraform destroy -auto-approve && \
	cd ../base && terraform init && terraform destroy -auto-approve

help:           ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'