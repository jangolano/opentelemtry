resource "azurerm_container_group" "main" {
  name                = "${var.app_name}-cg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  ip_address_type     = "Public"
  dns_name_label      = var.app_name

  # --- OTel Collector ---
  container {
    name   = "otel-collector"
    image  = "otel/opentelemetry-collector-contrib:0.98.0"
    cpu    = "0.25"
    memory = "0.5"

    commands = ["--config=env:OTEL_COLLECTOR_CONFIG"]

    ports {
      port     = 4317
      protocol = "TCP"
    }
    ports {
      port     = 4318
      protocol = "TCP"
    }

    environment_variables = {
      OTEL_COLLECTOR_CONFIG = file("${path.module}/otel-collector-config.yaml")
    }

    secure_environment_variables = {
      GRAFANA_CLOUD_OTLP_ENDPOINT = var.grafana_cloud_otlp_endpoint
      GRAFANA_CLOUD_INSTANCE_ID   = var.grafana_cloud_instance_id
      GRAFANA_CLOUD_API_KEY       = var.grafana_cloud_api_key
    }
  }

  # --- Spring Boot App ---
  container {
    name   = "app"
    image  = var.app_image
    cpu    = "0.5"
    memory = "1.0"

    ports {
      port     = 8080
      protocol = "TCP"
    }

    environment_variables = {
      MANAGEMENT_OTLP_METRICS_EXPORT_URL                     = "http://localhost:4318/v1/metrics"
      MANAGEMENT_OPENTELEMETRY_TRACING_EXPORT_OTLP_ENDPOINT  = "http://localhost:4318/v1/traces"
      MANAGEMENT_OPENTELEMETRY_LOGGING_EXPORT_OTLP_ENDPOINT  = "http://localhost:4318/v1/logs"
    }
  }

  exposed_port {
    port     = 8080
    protocol = "TCP"
  }
}
