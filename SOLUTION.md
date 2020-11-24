[![Build Status][circleci-badge]][circleci]

[circleci-badge]: https://circleci.com/gh/quintok/TechChallengeApp.svg?style=shield&circle-token=8dfd03c6c2a5dc5555e2f1a84c36e33bc58ad0aa
[circleci]: https://circleci.com/gh/quintok/TechChallengeApp
# Solution Overview

## Pre-requisites
1. Empty AWS Account
   1. Necessary service link roles created (RDS & ECS, ELB exist however)
2. CircleCI Account
3. Terraform installed `Terraform v0.13.5` on the machine doing the deployment
4. AWS Credentials for a user to run terraform as the default AWS profile on the machine running terraform.
5. AWS CLI installed on the machine executing terraform

## Architecture
### In AWS
1. Multi-AZ Deployment, 3 network tiers.  Public, Private and DB.
   1. DB does not have NAT nor route to public/internet 
   2. Private has NAT and route to public
2. Aurora Regional cluster for HA
3. Use secret manager to pass the database master credentials to the application.
   1. This should not be the master creds
   2. It should be rotating - hard to do without app modifications
   3. The retention window for the secret makes `terraform destroy && terraform apply` fail.
4. Use an ecs task independently to run updatedb

### CI/CD
1. Continue to use CircleCI for CI
2. Use dockerhub for container deployment

## Steps to provision
1. Create an access key to docker hub for the user you'd like to deploy via.
2. Provide access key and user of dockerhub to circleci in project settings -> environment as `DOCKER_USER` and `DOCKER_PASSWORD`
3. Run a build from circleCI to build the application and publish it to dockerhub
4. Change the variable defaults to match the new docker container location in variables.tf inside `/infra`
5. run `terraform init` && `terraform apply` from `infra/`
6. run the `update-db-command` command that is an output from terraform

# Commentary
## Choices
1. 2 AZ network design - enough to show HA without being excessive
2. NAT - this could be done without NAT and rely on service endpoints but that over-engineers the networking config.
3. No KMS used for encryption - price can be a good reason here but also would overcomplicate the solution
4. Not to refactor to DynamoDB for cost - not a bad idea if this was to be hosted longer term as Aurora can eat up $$ for this size app.  Would simplify how to apply the schema.
5. Not use Aurora Serverless - the approximate 1 minute spin-up time is too much for the app without changes.
6. Use local tfstate as there is too much messing around with remote state for this.
7. Can't think of a good way to seed database automatically.
   1. on Startup of the container is a problem if the container cycles as all tasks are lost
   2. on infra build is a problem as there is no guarantee the container exists yet & all tasks are lost
   3. Changing the application to simplify this is too time expensive
   4. It is unlikely we need to run this >1 per environment which means doing it manually is not labour intensive