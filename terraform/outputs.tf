output "F5_Password" {
  value = "${random_string.password.result}"
}

output "F5_UI" {
  value = "https://${aws_instance.f5.public_ip}:8443"
}

output "Consul_UI" {
  value = "http://${aws_instance.consul.public_ip}:8500"
}

output "F5_service" {
  value = "http://${aws_instance.f5.public_ip}:8080"
}