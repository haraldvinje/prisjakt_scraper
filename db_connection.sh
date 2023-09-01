#!/bin/bash

echo -e "You will need to have the following software installed on your system for this script to work:\n - terraform \n - aws CLI \n - aws-session-manager-plugin \n - jq\n"

set -e
set -o pipefail

cd terraform
[ ! -d ".terraform" ] && terraform init > /dev/null && rm .terraform.lock.hcl
DB_PORT=$(terraform output database_port | tr -d '"')
echo "Creating database connection. Make sure no other processes use port $DB_PORT."

EC2_INSTANCE_ID=$(terraform output bastion_host_id | tr -d '"')
DB_SECRET_ARN=$(terraform output database_credentials_secret_arn | tr -d '"')
DB_USERNAME=postgres
DB_PASSWORD=$(aws secretsmanager get-secret-value --secret-id "$DB_SECRET_ARN" --query SecretString --output text | jq '."password"' | tr -d '"')
DB_ENDPOINT=$(terraform output database_address | tr -d '"')

echo DB_USERNAME=$DB_USERNAME
echo DB_PASSWORD="$DB_PASSWORD"
echo DB_HOST=localhost
echo DB_PORT="$DB_PORT"
echo -e DB_NAME=prisjaktscraperdb'\n'

echo -e 'Creating tunnel to database!\nUse credentials as described above to connect.'
aws ssm start-session --target "$EC2_INSTANCE_ID" --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters host=$DB_ENDPOINT,portNumber="$DB_PORT",localPortNumber="$DB_PORT"