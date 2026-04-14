output "alb_dns" {
  value = aws_lb.main.dns_name
}

output "app_url" {
  value = "http://${aws_lb.main.dns_name}:8080/hello"
}
