include .env

CLOUDFORMATION_TEMPLATE_PATH ?= ./templates/main.yaml

cloudformation-deploy-stack:
	aws cloudformation deploy \
		--stack-name $(STACK_NAME) \
		--region $(AWS_REGION) \
		--profile $(AWS_PROFILE) \
		--template-file $(CLOUDFORMATION_TEMPLATE_PATH) \
		--capabilities CAPABILITY_NAMED_IAM

cloudformation-destroy-stack:
	aws cloudformation delete-stack \
		--stack-name $(STACK_NAME) \
		--region $(AWS_REGION) \
		--profile $(AWS_PROFILE)

cloudformation-validate-template:
	aws cloudformation validate-template \
		--region $(AWS_REGION) \
		--profile $(AWS_PROFILE) \
		--template-body $(CLOUDFORMATION_TEMPLATE_PATH)
