resource "aws_service_discovery_private_dns_namespace" "main" {
  name = "${var.app_name}.local"
  vpc  = aws_vpc.main.id
}

resource "aws_service_discovery_service" "otel_collector" {
  name = "otel-collector"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}
