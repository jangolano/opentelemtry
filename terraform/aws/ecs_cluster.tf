resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.app_name}-ecs-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --- Grafana Cloud Secrets ---
resource "aws_ssm_parameter" "grafana_cloud_otlp_endpoint" {
  name  = "/${var.app_name}/grafana-cloud-otlp-endpoint"
  type  = "SecureString"
  value = var.grafana_cloud_otlp_endpoint
}

resource "aws_ssm_parameter" "grafana_cloud_instance_id" {
  name  = "/${var.app_name}/grafana-cloud-instance-id"
  type  = "SecureString"
  value = var.grafana_cloud_instance_id
}

resource "aws_ssm_parameter" "grafana_cloud_api_key" {
  name  = "/${var.app_name}/grafana-cloud-api-key"
  type  = "SecureString"
  value = var.grafana_cloud_api_key
}

resource "aws_iam_role_policy" "ecs_ssm_read" {
  name = "${var.app_name}-ecs-ssm-read"
  role = aws_iam_role.ecs_task_execution.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameters"]
      Resource = [
        aws_ssm_parameter.grafana_cloud_otlp_endpoint.arn,
        aws_ssm_parameter.grafana_cloud_instance_id.arn,
        aws_ssm_parameter.grafana_cloud_api_key.arn,
      ]
    }]
  })
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 7
}
