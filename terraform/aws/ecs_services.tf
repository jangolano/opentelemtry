# --- OTel Collector ---
resource "aws_ecs_task_definition" "otel_collector" {
  family                   = "${var.app_name}-otel-collector"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = "otel-collector"
    image     = "otel/opentelemetry-collector-contrib:0.98.0"
    essential = true
    command   = ["--config=env:OTEL_COLLECTOR_CONFIG"]
    portMappings = [
      { containerPort = 4317, protocol = "tcp" },
      { containerPort = 4318, protocol = "tcp" }
    ]
    environment = [{
      name  = "OTEL_COLLECTOR_CONFIG"
      value = file("${path.module}/otel-collector-config.yaml")
    }]
    secrets = [
      {
        name      = "GRAFANA_CLOUD_OTLP_ENDPOINT"
        valueFrom = aws_ssm_parameter.grafana_cloud_otlp_endpoint.arn
      },
      {
        name      = "GRAFANA_CLOUD_INSTANCE_ID"
        valueFrom = aws_ssm_parameter.grafana_cloud_instance_id.arn
      },
      {
        name      = "GRAFANA_CLOUD_API_KEY"
        valueFrom = aws_ssm_parameter.grafana_cloud_api_key.arn
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "otel-collector"
      }
    }
  }])
}

resource "aws_ecs_service" "otel_collector" {
  name            = "${var.app_name}-otel-collector"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.otel_collector.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.otel_collector.arn
  }
}

# --- Spring Boot App ---
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.app_name}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([{
    name      = "app"
    image     = var.app_image
    essential = true
    portMappings = [{ containerPort = 8080, protocol = "tcp" }]
    environment = [
      {
        name  = "MANAGEMENT_OTLP_METRICS_EXPORT_URL"
        value = "http://otel-collector.${var.app_name}.local:4318/v1/metrics"
      },
      {
        name  = "MANAGEMENT_OPENTELEMETRY_TRACING_EXPORT_OTLP_ENDPOINT"
        value = "http://otel-collector.${var.app_name}.local:4318/v1/traces"
      },
      {
        name  = "MANAGEMENT_OPENTELEMETRY_LOGGING_EXPORT_OTLP_ENDPOINT"
        value = "http://otel-collector.${var.app_name}.local:4318/v1/logs"
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = "app"
      }
    }
  }])
}

resource "aws_ecs_service" "app" {
  name            = "${var.app_name}-app"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = 8080
  }

  depends_on = [aws_ecs_service.otel_collector]
}
