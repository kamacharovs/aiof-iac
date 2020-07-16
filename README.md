# Overview

All in one finance infrastructure as code

## Documentation

All documentation for this specific repository

### Versioning

Terraform undergoes a lot of versioning and new updates. In order to keep this updated, we can look at the latest release on their [GitHub](https://github.com/terraform-providers/terraform-provider-azurerm). The current version used is `~> 2.19.0`

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
```
