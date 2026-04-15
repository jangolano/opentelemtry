variable "location" {
  default = "eastus"
}

variable "app_name" {
  default = "otel-demo"
}

variable "app_image" {
  description = "Docker image for the Spring Boot app (e.g. your ACR URI)"
  type        = string
}

variable "grafana_cloud_otlp_endpoint" {
  description = "Grafana Cloud OTLP endpoint URL"
  type        = string
  sensitive   = true
}

variable "grafana_cloud_instance_id" {
  description = "Grafana Cloud instance ID"
  type        = string
  sensitive   = true
}

variable "grafana_cloud_api_key" {
  description = "Grafana Cloud API key"
  type        = string
  sensitive   = true
}
