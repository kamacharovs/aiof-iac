# Overview

All in one finance infrastructure as code, specific to an environment (Dev, QA, Stage, Prod, etc.)

[![Build Status](https://dev.azure.com/gkamacharov/gkama-cicd/_apis/build/status/kamacharovs.aiof-iac?branchName=master)](https://dev.azure.com/gkamacharov/gkama-cicd/_build/latest?definitionId=24&branchName=master)

## Documentation

All documentation for this specific repository

### Terraform reference

- [azurerm_resource_group](https://www.terraform.io/docs/providers/azurerm/r/resource_group.html)
- [azurerm_network_security_group](https://www.terraform.io/docs/providers/azurerm/r/network_security_group.html)
- [azurerm_network_security_rule](https://www.terraform.io/docs/providers/azurerm/r/network_security_rule.html)
- [azurerm_virtual_network](https://www.terraform.io/docs/providers/azurerm/r/virtual_network.html)
- [azurerm_subnet](https://www.terraform.io/docs/providers/azurerm/r/subnet.html)
- [azurerm_key_vault](https://www.terraform.io/docs/providers/azurerm/r/key_vault.html)
- [azurerm_application_insights](https://www.terraform.io/docs/providers/azurerm/r/application_insights.html)
- [azurerm_app_service_plan](https://www.terraform.io/docs/providers/azurerm/r/app_service_plan.html)
- [azurerm_app_service](https://www.terraform.io/docs/providers/azurerm/r/app_service.html)

### GitHub Repositories

- [jcorioland/tf-aks-kubenet](https://github.com/jcorioland/tf-aks-kubenet/blob/master/tf/aks.tf) - example of how Kubernetes is deployed to Azure

### Terraform

- [Upgrading to Terraform v0.14](https://www.terraform.io/upgrade-guides/0-14.html)
- [Upgrading to Terraform v0.13](https://www.terraform.io/upgrade-guides/0-13.html)
- [Upgrade Guides](https://www.terraform.io/upgrade-guides/index.html)
- [Older versions of Terraform](https://releases.hashicorp.com/terraform/)
- [Backends Data Source Configuration](https://www.terraform.io/docs/backends/types/azurerm.html#data-source-configuration)

### Versioning

Terraform undergoes a lot of versioning and new updates. In order to keep this updated, we can look at the latest release on their [GitHub](https://github.com/terraform-providers/terraform-provider-azurerm). The current version used is `~> 2.39.0`

### Variables

The sensitive variables for this are stored in a `.tfvars` file locally. Currently, this is what's in there

```terraform
subscription_id = ""
tenant_id = ""
client_id = ""
client_secret = ""
location = "eastus"
environment = "dev"

db_admin_username = ""
db_admin_password = ""
db_admin_start_ip = ""

appsettings_auth_jwt_private_key_value  = ""
appsettings_auth_jwt_public_key_value   = ""
```

### Resources

Networking

- Network security group
- Network security group rules
- DDOS protection plan
- Virtual network
- Subnet: backend

Database

- PostgreSQL server
- PostgreSQL database

Container registry

- Azure Container Registry
