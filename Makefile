include .env

cloudformation-deploy-stack:
	aws cloudformation deploy \
		--stack-name $(STACK_NAME) \
		--region $(AWS_REGION) \
		--profile $(CLOUDFORMATION_AWS_PROFILE) \
		--template-file $(CLOUDFORMATION_TEMPLATE_PATH) \
		--parameter-overrides \
			TerraformStateBucketName=$(TF_STATE_BUCKET_NAME) \
			TerraformStateLockTableName=$(TF_STATE_LOCK_TABLE_NAME) \
		--capabilities CAPABILITY_NAMED_IAM

cloudformation-destroy-stack:
	aws cloudformation delete-stack \
		--stack-name $(STACK_NAME) \
		--region $(AWS_REGION) \
		--profile $(CLOUDFORMATION_AWS_PROFILE)

cloudformation-validate-template:
	aws cloudformation validate-template \
		--region $(AWS_REGION) \
		--profile $(CLOUDFORMATION_AWS_PROFILE) \
		--template-body $(CLOUDFORMATION_TEMPLATE_PATH)

cloudformation-get-terraform-access-key-id:
	aws cloudformation describe-stacks \
      --stack-name $(STACK_NAME) \
      --region $(AWS_REGION) \
      --profile $(CLOUDFORMATION_AWS_PROFILE) \
      --query "Stacks[0].Outputs[?OutputKey=='AccessKeyId'].OutputValue" \
      --output text

cloudformation-get-terraform-secret-access-key:
	aws cloudformation describe-stacks \
	  --stack-name $(STACK_NAME) \
	  --region $(AWS_REGION) \
	  --profile $(CLOUDFORMATION_AWS_PROFILE) \
	  --query "Stacks[0].Outputs[?OutputKey=='SecretAccessKey'].OutputValue" \
	  --output text

cloudformation-get-terraform-execution-role-arn:
	aws cloudformation describe-stacks \
	  --stack-name $(STACK_NAME) \
	  --region $(AWS_REGION) \
	  --profile $(CLOUDFORMATION_AWS_PROFILE) \
	  --query "Stacks[0].Outputs[?OutputKey=='TerraformExecutionRoleArn'].OutputValue" \
	  --output text

assume-terraform-execution-role:
	AWS_ACCESS_KEY_ID=$(TERRAFORM_USER_ACCESS_KEY_ID) \
	AWS_SECRET_ACCESS_KEY=$(TERRAFORM_USER_SECRET_ACCESS_KEY) \
	aws sts assume-role \
		--role-arn $(TERRAFORM_EXECUTION_ROLE_ARN) \
		--role-session-name terraform \
		--query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \

terraform-init:
	AWS_ACCESS_KEY_ID=$(TERRAFORM_EXECUTION_ROLE_ACCESS_KEY_ID) \
    AWS_SECRET_ACCESS_KEY=$(TERRAFORM_EXECUTION_ROLE_SECRET_ACCESS_KEY) \
    AWS_SESSION_TOKEN=$(TERRAFORM_EXECUTION_ROLE_SESSION_TOKEN) \
	terraform -chdir=terraform init \
	  -backend-config="bucket=$(TF_STATE_BUCKET_NAME)" \
	  -backend-config="key=terraform.tfstate" \
	  -backend-config="region=$(AWS_REGION)" \
	  -backend-config="dynamodb_table=$(TF_STATE_LOCK_TABLE_NAME)" \

terraform-deploy-resources:
	TF_VAR_aws_region=$(AWS_REGION) \
	AWS_ACCESS_KEY_ID=$(TERRAFORM_EXECUTION_ROLE_ACCESS_KEY_ID) \
    AWS_SECRET_ACCESS_KEY=$(TERRAFORM_EXECUTION_ROLE_SECRET_ACCESS_KEY) \
    AWS_SESSION_TOKEN=$(TERRAFORM_EXECUTION_ROLE_SESSION_TOKEN) \
	terraform -chdir=terraform apply

terraform-destroy-resources:
	TF_VAR_aws_region=$(AWS_REGION) \
	AWS_ACCESS_KEY_ID=$(TERRAFORM_EXECUTION_ROLE_ACCESS_KEY_ID) \
    AWS_SECRET_ACCESS_KEY=$(TERRAFORM_EXECUTION_ROLE_SECRET_ACCESS_KEY) \
    AWS_SESSION_TOKEN=$(TERRAFORM_EXECUTION_ROLE_SESSION_TOKEN) \
	terraform -chdir=terraform destroy

terraform-list-resources:
	TF_VAR_aws_region=$(AWS_REGION) \
	AWS_ACCESS_KEY_ID=$(TERRAFORM_EXECUTION_ROLE_ACCESS_KEY_ID) \
    AWS_SECRET_ACCESS_KEY=$(TERRAFORM_EXECUTION_ROLE_SECRET_ACCESS_KEY) \
    AWS_SESSION_TOKEN=$(TERRAFORM_EXECUTION_ROLE_SESSION_TOKEN) \
	terraform -chdir=terraform show
