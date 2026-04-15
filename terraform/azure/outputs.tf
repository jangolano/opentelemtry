output "container_fqdn" {
  value = azurerm_container_group.main.fqdn
}

output "app_url" {
  value = "http://${azurerm_container_group.main.fqdn}:8080/hello"
}
