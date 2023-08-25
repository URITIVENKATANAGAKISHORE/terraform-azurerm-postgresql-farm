module "postgresql_single_server" {
  source = "./terraform/module/postgresql_single_server"
  
  subscription_id = var.subscription_id
  create_resource_group = var.create_resource_group
  resource_group_name = var.resource_group_name
  location = var.location
  deploy_log_analytics_workspace = var.deploy_log_analytics_workspace
  log_analytics_ws_name = var.log_analytics_ws_name
  sku_log_analytics = var.sku_log_analytics
  sku_name = var.sku_name
  log_analytics_retentation_in_days = var.log_analytics_retentation_in_days
  deploy_key_vault = var.deploy_key_vault
  keyvault_name = var.keyvault_name
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled = var.purge_protection_enabled
  public_network_access_enabled = var.public_network_access_enabled
  keyvault_ip_rules = var.keyvault_ip_rules
  keyvault_subnets = var.keyvault_subnets
  cicd_subnet = var.cicd_subnet
  kv_access_object_ids = var.kv_access_object_ids
  postgresql_server_name = var.postgresql_server_name
  admin_username = var.admin_username
  sku_postgre = var.sku_postgre
  postgre_version = var.postgre_version
  storage_mb = var.storage_mb
  auto_grow_enabled = var.auto_grow_enabled
  backup_retention_days = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  ssl_enforcement_enabled = var.ssl_enforcement_enabled
  ssl_minimal_tls_version_enforced = var.ssl_minimal_tls_version_enforced
  identity =  var.identity
  postgre_database_name = var.postgre_database_name
  charset = var.charset
  collation = var. collation
  postgresql_configuration = var.postgresql_configuration
  firewall_rules = var.firewall_rules
  ad_admin_login_name =  var.ad_admin_login_name
  mandatory_tags = var.mandatory_tags
  additional_tags = var.additional_tags
}

# module "postgresql_flex_server" {
#   source = "./terraform/module/postgresql_flex_server"
# }


