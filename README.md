# Overview

All in one finance infrastructure as code, specific to an environment (Dev, QA, Stage, Prod, etc.)

## Documentation

All documentation for this specific repository

### GitHub Repositories

- [jcorioland/tf-aks-kubenet](https://github.com/jcorioland/tf-aks-kubenet/blob/master/tf/aks.tf) - example of how Kubernetes is deployed to Azure

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
