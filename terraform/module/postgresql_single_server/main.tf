resource "azurerm_resource_group" "postgresql_resource_group" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.postgresql_server_name}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
  depends_on = [ azurerm_resource_group.postgresql_resource_group ]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "${var.postgresql_server_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.postgresql_server_name}-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.Storage"]

  delegation {
    name = "fs"

    service_delegation {
      name = ["Microsoft.DBforPostgreSQL/singleServers"]

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "nsga" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_private_dns_zone" "postgre_single_server_private_dns" {
  name                = "${var.postgresql_server_name}-ls.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  depends_on = [azurerm_subnet_network_security_group_association.nsga]
  tags = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgre_single_server_private_dns_net_link" {
  name                  = "${var.postgresql_server_name}-pdzvnetlink.com"
  private_dns_zone_name = azurerm_private_dns_zone.postgre_single_server_private_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = var.resource_group_name
  tags = local.tags
}

resource "random_password" "postgresqladmin_password" {
  length           = 16
  lower = true
  min_lower = 3
  upper = true
  min_upper = 3
  numeric = true
  min_numeric = 3
  special          = true
  min_special = 3
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_log_analytics_workspace" "log_analytics" {
  count               = var.deploy_log_analytics_workspace ? 1 : 0
  name                = var.log_analytics_ws_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku_log_analytics
  retention_in_days   = var.log_analytics_retentation_in_days
  tags                = local.tags
}

resource "azurerm_key_vault" "key_vault" {
  count                         = var.deploy_key_vault ? 1 : 0
  name                          = var.keyvault_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tags                          = local.tags
  tenant_id                     = data.azurerm_subscription.current.tenant_id
  sku_name                      = var.sku_name
  soft_delete_retention_days    = var.soft_delete_retention_days
  purge_protection_enabled      = var.purge_protection_enabled
  public_network_access_enabled = var.public_network_access_enabled

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureService"
    ip_rules                   = toset(concat(var.keyvault_ip_rules, ["192.192.0.0/16"]))
    virtual_network_subnet_ids = toset(concat(var.keyvault_subnets, var.cicd_subnet))
  }
}
resource "azurerm_key_vault_access_policy" "key_vault_add_access_policy_sp" {
  count        = var.deploy_key_vault ? 1 : 0
  key_vault_id = azurerm_key_vault.key_vault[0].id
  tenant_id    = data.azurerm_subscription.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  secret_permissions = [
    "Get", "Backup", "Delete", "List", "Recover", "Restore", "Set", "Purge",
  ]
  depends_on = [azurerm_key_vault.key_vault, azurerm_resource_group.postgresql_resource_group]
}

resource "azurerm_key_vault_access_policy" "key_vault_add_access_policy" {
  count        = var.deploy_key_vault ? length(var.kv_access_object_ids) : 0
  key_vault_id = azurerm_key_vault.key_vault[0].id
  tenant_id    = data.azurerm_subscription.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  secret_permissions = [
    "Get", "Backup", "Delete", "List", "Recover", "Restore", "Set", "Purge",
  ]
  depends_on = [azurerm_key_vault.key_vault]
}

resource "azurerm_key_vault_secret" "postgre_single_server_admin_password" {
  name         = "${var.postgre_single_server_name}-admin-password"
  key_vault_id = var.deploy_key_vault ? azurerm_key_vault.key_vault[0].id : data.azurerm_key_vault.existing_key_vault[0].id
  value = random_password.postgresqladmin_password.result
  depends_on   = [azurerm_key_vault.key_vault, azurerm_key_vault_access_policy.key_vault_add_access_policy_sp, azurerm_key_vault_access_policy.key_vault_add_access_policy, random_password.postgresqladmin_password]

}

resource "azurerm_postgresql_server" "postgre_single_server" {
  name                              = var.postgresql_server_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  administrator_login               = var.admin_username == null ? "postgresadmin" : var.admin_username
  administrator_login_password      = azurerm_key_vault_secret.postgre_single_server_admin_password.value
  sku_name                          = var.sku_postgre
  version                           = var.postgre_version
  storage_mb                        = var.storage_mb
  auto_grow_enabled                 = var.auto_grow_enabled
  backup_retention_days             = var.backup_retention_days
  geo_redundant_backup_enabled      = var.geo_redundant_backup_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  public_network_access_enabled     = var.public_network_access_enabled
  ssl_enforcement_enabled           = var.ssl_enforcement_enabled
  ssl_minimal_tls_version_enforced  = var.ssl_minimal_tls_version_enforced
  tags                              = local.tags

  dynamic "identity" {
    for_each = var.identity == true ? [1] : [0]
    content {
      type = "SystemAssigned"
    }
  }
  depends_on = [ azurerm_resource_group.postgresql_resource_group, azurerm_key_vault.key_vault ]
}

resource "azurerm_postgresql_database" "postgre_single_server_db" {
  name                = var.postgre_database_name
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.postgre_single_server.name
  charset             = var.charset
  collation           = var.collation
  depends_on = [ azurerm_postgresql_server.postgre_single_server ]
}

resource "azurerm_postgresql_configuration" "postgre_db_configuration" {
  for_each            = var.postgresql_configuration != null ? { for k, v in var.postgresql_configuration : k => v if v != null } : {}
  name                = each.key
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.postgre_single_server.name
  value               = each.value
}

resource "azurerm_postgresql_server_key" "name" {
  count            = var.key_vault_key_id != null ? 1 : 0
  server_id        = azurerm_postgresql_server.postgre_single_server.id
  key_vault_key_id = azurerm_key_vault.key_vault[0].id
}

resource "azurerm_postgresql_virtual_network_rule" "name" {
  count                                = var.subnet_id != null ? 1 : 0
  name                                 = var.postgresql_server_name
  resource_group_name                  = var.resource_group_name
  server_name                          = azurerm_postgresql_server.postgre_single_server.name
  subnet_id                            = var.subnet_id
  ignore_missing_vnet_service_endpoint = var.ignore_missing_vnet_service_endpoint
}

resource "azurerm_postgresql_firewall_rule" "name" {
  for_each            = var.firewall_rules != null ? { for k, v in var.firewall_rules : k => v if v != null } : {}
  name                = format("%s", each.key)
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_server.postgre_single_server.name
  start_ip_address    = each.value["start_ip_address"]
  end_ip_address      = each.value["end_ip_address"]
}

resource "azurerm_postgresql_active_directory_administrator" "name" {
  count               = var.ad_admin_login_name != null ? 1 : 0
  server_name         = azurerm_postgresql_server.postgre_single_server.name
  resource_group_name = var.resource_group_name
  login               = var.ad_admin_login_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
}

resource "azurerm_private_endpoint" "post" {
  name                = "example-endpoint"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.endpoint.id

  private_service_connection {
    name                           = "example-privateserviceconnection"
    private_connection_resource_id = azurerm_private_link_service.example.id
    is_manual_connection           = false
  }
}