# DevOps

### Steps to Run

1. Fork this repo
2. Enable Travis CI builds for the repo on [https://travis-ci-org](https://travis-ci-org)
3. Create a personal access token at [https://github.com/settings/tokens](https://github.com/settings/tokens) with the "repo" scope
4. Enter required environment variables in Travis:

| Variable | Description | Display Value in Build Log |
|----------|-------|----------|
| GH_REPO  | Repo name in Github (username/repo) | yes |
| GH_USER_NAME | Github username | yes |
| GH_USER_EMAIL | Github email address | yes |
| GH_TOKEN | Github personal access token created in step 3 | no |
| TF_VAR_access_key | AWS access key | no |
| TF_VAR_secret_key | AWS secret key | no |
| TF_VAR_subnet_id | Subnet to deploy to | yes |
| TF_VAR_vpc_id | VPC to deploy to | yes |

5. Push repo to Github
6. ELB DNS will output at the end of the deployment script. The app may take a minute to show up due to ELB health checks.
