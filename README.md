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
   
   - separate s3 code to another file
   - separate the lambda deployment code in another file
   - use of variables
   - use of s3 bucket for backend 
   - use of CloudFront distribution with a domain to point to S3 bucket used for HTML file
   - use a separate script to create and push image

The code does deployment of the S3, lambda and all the dependencies.

## The python code from file `weathercode/weather.py`

The code is a basic api interogation of openweathermap to get the specific weather data for a location.
Things which can be improved for production ready:
  - error handling
  - maybe more logging

