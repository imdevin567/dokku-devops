#!/bin/bash

set -e

cd terraform

echo "Planning terraform build"
tf plan

echo "Applying terraform config"
tf apply

EC2_DNS=$(tf output dokku_dns)
cd ..

echo "Creating dokku app"
ssh -i .keys/dokku.pem ubuntu@$EC2_DNS 'dokku apps:create sample-node-app'

echo "Deploying dokku app"
git remote add dokku dokku@{$EC2_DNS}:sample-node-app
GIT_SSH_COMMAND="ssh -i .keys/dokku.pem" git push dokku master

echo "Setting git user name"
git config user.name $GH_USER_NAME

echo "Setting git user email"
git config user.email $GH_USER_EMAIL

echo "Adding git upstream remote"
git remote add upstream "https://$GH_TOKEN@github.com/$GH_REPO.git"

git checkout master

git add .

NOW=$(TZ=America/Chicago date)

git commit -m "[ci skip] tfstate: $NOW"

echo "Pushing changes to upstream master"
git push upstream master
