variable "subscription_id" {
  description = "The ID of the Subscription. Changing this forces a new Subscription to be created."
  type        = string
}

variable "create_resource_group" {
  description = "Specifies that wheather you want to create new resource group or not"
  type        = string
  default     = "false"
}
variable "resource_group_name" {
  description = "The name of the resource group in which the CosmosDB Account is created. Changing this forces a new resource to be created."
  type        = string
}
variable "location" {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}

variable "deploy_log_analytics_workspace" {
  description = "This flag will determine if a log analytics workspace will be deployed"
  type        = bool
  default     = false
}

variable "log_analytics_ws_name" {
  description = "Soecifies the log analytics workspace name"
  type        = string
}

variable "sku_log_analytics" {
  description = "Specifies the SKU of the Log Analytics Workspace. Possible values are Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, and PerGB2018 (new SKU as of 2018-04-03). Defaults to PerGB2018."
  type        = string
  default     = "PerGB2018"
}

variable "sku_name" {
  description = "The Name of the SKU used for this Key Vault. Possible values are standard and premium."
  default     = "standard"
  type        = string
}
variable "log_analytics_retentation_in_days" {
  description = "list of subnets to be whitelisted on key vault network rules . Defaults to other service like github actions subnets etc.."
  default     = 30
  type        = number
}

variable "deploy_key_vault" {
  description = "This flag will determine if a key vault will be deployed"
  type        = bool
  default     = false
}
variable "keyvault_name" {
  description = "Specifies keyvault name"
  type        = string
}

variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days."
  default     = 7
  type        = number
}

variable "purge_protection_enabled" {
  description = "Is Purge Protection enabled for this Key Vault?"
  default     = true
  type        = bool
}

variable "public_network_access_enabled" {
  description = "Whether or not public network access is allowed for this CosmosDB account. Defaults to true."
  type        = bool
  default     = true
}
variable "keyvault_ip_rules" {
  description = "Key vault ip rules , Whitelisted on prem ip range"
  type        = list(string)
  default     = []
}

variable "keyvault_subnets" {
  description = "Azure Devops agents subnets to attache to keyvault"
  default     = []
  type        = list(string)
}

variable "cicd_subnet" {
  description = "CI CD Pipeline server subnets list"
  default     = []
  type        = list(string)
}

variable "kv_access_object_ids" {
  description = "The Object ID's of the groups or users to add for key vault access"
  type        = list(string)
  default     = []
}

variable "postgresql_server_name" {

}
variable "admin_username" {

}
variable "sku_postgre" {

}
variable "postgre_version" {

}
variable "storage_mb" {

}
variable "auto_grow_enabled" {

}
variable "backup_retention_days" {

}
variable "geo_redundant_backup_enabled" {

}
variable "infrastructure_encryption_enabled" {

}

variable "ssl_enforcement_enabled" {

}
variable "ssl_minimal_tls_version_enforced" {

}
variable "identity" {
  description = "If you want your SQL Server to have an managed identity. Defaults to false."
  default     = false
}
variable "postgre_database_name" {

}
variable "charset" {

}
variable "collation" {

}

variable "postgresql_configuration" {
  description = "Sets a PostgreSQL Configuration value on a PostgreSQL Server"
  type        = map(string)
  default     = {}
}

variable "firewall_rules" {
  description = "Range of IP addresses to allow firewall connections."
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = null
}

variable "ad_admin_login_name" {
  description = "The login name of the principal to set as the server administrator"
  default     = null
}

variable "mandatory_tags" {
  description = "A mapping of mandatory_tags to assign to the resource."
  type = object({
    product-owner       = string
    application-name    = string
    environment         = string
    cost-center         = string
    
  })
  
}

variable "additional_tags" {
  description = "A mapping of additional_tags to assign to the resource."
  type        = map(string)
}