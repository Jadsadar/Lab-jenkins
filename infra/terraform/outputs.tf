output "instance_id" {
  description = "EC2 instance id; used as the host name in the Ansible inventory"
  value       = aws_instance.taskflow.id
}

output "instance_address" {
  description = "Public IP of the taskflow-api instance"
  value       = aws_instance.taskflow.public_ip
}

output "security_group_id" {
  description = "Security group that opens port 8080"
  value       = aws_security_group.taskflow.id
}
