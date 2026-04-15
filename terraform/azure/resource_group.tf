resource "azurerm_resource_group" "main" {
  name     = "${var.app_name}-rg"
  location = var.location
}
