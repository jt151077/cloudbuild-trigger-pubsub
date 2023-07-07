#!/bin/bash

echo 'Deploying trigger'

project=$(grep -o '\"project_id\": \"[^\"]*' terraform.tfvars.json | grep -o '[^\"]*$')

terraform init
terraform apply -auto-approve
terraform import google_pubsub_subscription.pubsub-config-trigger projects/$project/subscriptions/gcb-pubsub-trigger
terraform apply -auto-approve