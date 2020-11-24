[![Build Status][circleci-badge]][circleci]

[circleci-badge]: https://circleci.com/gh/quintok/TechChallengeApp.svg?style=shield&circle-token=8dfd03c6c2a5dc5555e2f1a84c36e33bc58ad0aa
[circleci]: https://circleci.com/gh/quintok/TechChallengeApp
# Solution Overview

## Pre-requisites
3. Empty AWS Account
4. CircleCI Account
5. Terraform installed `Terraform v0.13.5` on the machine doing the deployment

## Architecture
### In AWS
...

### CI/CD
1. Continue to use CircleCI for CI
2. Use dockerhub for container deployment

## Steps to provision
1. Create an access key to docker hub for the user you'd like to deploy via.
2. Provide access key and user of dockerhub to circleci in project settings -> environment as `DOCKER_USER` and `DOCKER_PASSWORD`