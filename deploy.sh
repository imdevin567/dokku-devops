#!/bin/bash

set -e

cd terraform

echo "Initializing terraform"
terraform init

echo "Planning terraform build"
terraform plan

echo "Applying terraform config"
terraform apply -auto-approve=true

EC2_DNS=$(terraform output dokku_dns)
ELB_DNS=$(terraform output elb_dns)
cd ..

chmod 400 .keys/dokku.pem

echo "Checking for existence of sample-node-app"
ssh -o StrictHostKeyChecking=no -i .keys/dokku.pem ubuntu@$EC2_DNS 'dokku apps:list --quiet | grep sample-node-app'

if [ $? -ne 0 ]; then
  echo "App does not exist! Creating dokku app"
  ssh -o StrictHostKeyChecking=no -i .keys/dokku.pem ubuntu@$EC2_DNS 'dokku apps:create sample-node-app'
fi

echo "Deploying dokku app"
git remote add dokku dokku@$EC2_DNS:sample-node-app
GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no -i .keys/dokku.pem" git push dokku master

echo "Setting git user name"
git config user.name $GH_USER_NAME

echo "Setting git user email"
git config user.email $GH_USER_EMAIL

echo "Adding git upstream remote"
git remote add upstream "https://$GH_TOKEN@github.com/$GH_REPO.git"

git checkout master

git add terraform/terraform.tfstate

NOW=$(TZ=America/Chicago date)

git commit -m "[ci skip] tfstate: $NOW"

echo "Pushing changes to upstream master"
git push upstream master

echo "Deployment complete! View application at http://$ELB_DNS"
