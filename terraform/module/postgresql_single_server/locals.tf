locals {
  resource_group_name = element(coalescelist(data.azurerm_resource_group.existing_resource_group.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.existing_resource_group.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
  tags            = merge(var.mandatory_tags, var.additional_tags)
}