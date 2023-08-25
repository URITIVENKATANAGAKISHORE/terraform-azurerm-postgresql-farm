terraform {
  required_version = ">=1.4.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.55.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.5.1"
    }
    # template = {
    #   source  = "hashicrop/template"
    #   version = "2.2.0"
    # }
  }
}

# provider "template" {

# }

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
    template_deployment {
      delete_nested_items_during_deletion = true
    }
  }
  subscription_id = var.subscription_id
}

# terraform {
#   backend "azurerm" {
#     container_name       = "sample-container"
#     resource_group_name  = "terraform"
#     storage_account_name = "sample-sa"
#     subscription_id      = "d5b99805-1959-44bb-a779-"
#     tenant_id            = "087d8eaa--4f9a-9440-"
#   }
# }