output "alb_url" {
  description = "Load balancer URL"
  value       = aws_alb.dev_web.dns_name
}