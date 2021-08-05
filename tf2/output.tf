# url for alb
output "aws_alb_dns" {
  value = aws_alb.b.dns_name
}
