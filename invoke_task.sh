#!/bin/bash

set -e
set -o pipefail

echo -e "You will need to have the following software installed on your system for this script to work:\n - terraform\n - aws CLI\n - jq\n"

cd terraform
[ ! -d ".terraform" ] && terraform init > /dev/null && rm .terraform.lock.hcl
ECS_CLUSTER_NAME=$(terraform output ecs_cluster_name | tr -d '"')
ECS_TASK_DEFINITION_ARN=$(terraform output ecs_task_definition_arn | tr -d '"')
SUBNET=$(terraform output -json scheduler_network_configuration | jq -r '.[0].subnets[0]')
SECURITY_GROUP=$(terraform output -json scheduler_network_configuration | jq -r '.[0].security_groups[0]')
ASSIGN_PUBLIC_IP=$([[ $(terraform output -json scheduler_network_configuration | jq -r '.[0].assign_public_ip') == "true" ]] && echo "ENABLED" || echo "DISABLED")

NETWORK_CONFIGURATION=awsvpcConfiguration={subnets=[$SUBNET],securityGroups=[$SECURITY_GROUP],assignPublicIp=$ASSIGN_PUBLIC_IP}

aws ecs run-task \
    --launch-type FARGATE \
    --cluster "$ECS_CLUSTER_NAME" \
    --task-definition "$ECS_TASK_DEFINITION_ARN" \
    --network-configuration $NETWORK_CONFIGURATION > /dev/null &&  echo "Task successfully invoked" || echo "Task invocation failed"