# Overview

All in one finance infrastructure as code, specific to GitHub

[![Build Status](https://dev.azure.com/gkamacharov/gkama-cicd/_apis/build/status/kamacharovs.aiof-iac?branchName=master)](https://dev.azure.com/gkamacharov/gkama-cicd/_build/latest?definitionId=24&branchName=master)

## How to run it

Below are instructions on how to run the `aiof-iac` terraform scripts for GitHub

### Configuration

Uses `terraform.tfvars` instead of environment variables. The file looks like this

```text
token           = "yourtokenhere"
organization    = "yourorgnamehere"
```

To execute the scripts, first you need to initialize the provider

```ps
terraform init
```

After `terraform init` you can run a plan and apply (if needed)

```ps
terraform plan -out=tfplan
terraform apply tfplan
```
