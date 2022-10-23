[[_TOC_]]

## Repository Scope

This repository consists of:
  - An python script which automatically gets by environment variables the weather for a specific location and moves it to an S3 as html
  - Terraform configuration to build the docker image as null resource, an lambda, an s3 bucket and all necessary dependencies

## Prerequisites

You need to have:
 - the latest terraform binary installed on your PC/MAC from https://www.terraform.io/downloads
 - aws-cli from https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html 
 - python3.9 to be able to test and debug the weathercode/weather.py

## Ways of working

 - Make sure to have the latest version of the repository - `git pull`
 - Before doing the commit , use terraform locally and run: `terraform fmt -write -recursive`, which will do the indentation fixes for terraform files


## Terraform code

The terraform code was done in a non-optimized manner just for PoC and can't be improved as following: `
   
   - use of s3 bucket for backend 
   - use of CloudFront distribution with a domain to point to S3 bucket used for HTML file

The code does deployment of the S3, lambda and all the dependencies.

Files contents:

   - `cloudwatch_event_rule.tf`: programming the Cloudwatch trigger to invoke the lambda function
   - `ecr_repository.tf`: creation of the ECR repo used for the image which contains the python script
   - `iam.tf`: the IAM role of the lambda with least access principle applied using policies and lambda permission for executing from Cloudwatch
   - `lambda.tf`: deployment of lambda itself with dependencies and force update by null-resource
   - `null_resource.tf`: creation of Docker image and push to the ECR repository
   - `s3_bucket_site.tf`: creation of the S3 bucket with all proper rights to be public
   - variables.tf : definition of variables with their default values
   - terraform.tfstate the .backup are the tfstate files generated as I didn't used s3 backend
    

## The python code from file `weathercode/weather.py`

The code is a basic api interogation of openweathermap to get the specific weather data for a location.
Things which can be improved for production ready:
  - error handling
  - maybe more logging

