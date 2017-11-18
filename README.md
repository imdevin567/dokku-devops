# DevOps

### Steps to Run

1. `cd terraform && tf apply`
2. Answer terraform questions
3. Create dokku application:

  `ssh -i .keys/dokku.pem ubuntu@{TERRAFORM_EC2_DNS_OUTPUT} 'dokku apps:create sample-node-app'`

4. Add dokku git remote:

  `git remote add dokku dokku@{TERRAFORM_EC2_DNS_OUTPUT}:sample-node-app`

5. Deploy dokku application:

  `GIT_SSH_COMMAND="ssh -i .keys/dokku.pem" git push dokku master`

6. Access application at http://{TERRAFORM_ELB_DNS_OUTPUT} (may take a few minutes to spin up due to ELB health checks)
