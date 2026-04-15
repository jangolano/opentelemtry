data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                = "${var.app_name}-kv"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Get", "Set", "Delete", "List", "Purge"]
  }
}

resource "azurerm_key_vault_secret" "grafana_cloud_otlp_endpoint" {
  name         = "grafana-cloud-otlp-endpoint"
  value        = var.grafana_cloud_otlp_endpoint
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "grafana_cloud_instance_id" {
  name         = "grafana-cloud-instance-id"
  value        = var.grafana_cloud_instance_id
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "grafana_cloud_api_key" {
  name         = "grafana-cloud-api-key"
  value        = var.grafana_cloud_api_key
  key_vault_id = azurerm_key_vault.main.id
}
