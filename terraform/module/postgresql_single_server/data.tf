#---------------------------------------------------------
# Resource Group Creation or selection - Default is "false"
#----------------------------------------------------------
data "azurerm_resource_group" "existing_resource_group" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

data "azurerm_log_analytics_workspace" "existing_log_ws" {
  count               = var.deploy_log_analytics_workspace ? 0 : 1
  name                = var.log_analytics_ws_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault" "existing_key_vault" {
  count               = var.deploy_key_vault ? 0 : 1
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_client_config" "current" {

}

data "azurerm_subscription" "current" {
  subscription_id = var.subscription_id
}