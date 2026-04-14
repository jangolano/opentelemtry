variable "region" {
  default = "us-east-1"
}

variable "app_name" {
  default = "otel-demo"
}

variable "app_image" {
  description = "Docker image for the Spring Boot app (e.g. your ECR URI)"
  type        = string
}
