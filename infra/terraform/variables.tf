variable "region" {
  description = "AWS region (LocalStack accepts any)"
  type        = string
  default     = "us-east-1"
}

variable "aws_endpoint" {
  description = "LocalStack endpoint as seen from containers on the lab08 Docker network"
  type        = string
  default     = "http://localstack:4566"
}

variable "ami_id" {
  description = "Ubuntu AMI that LocalStack 4.14 ships in its mock image catalog"
  type        = string
  default     = "ami-785db401"
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}

variable "allowed_cidr" {
  description = "Network allowed to reach the API on port 8080"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ssh_public_key" {
  description = "Public half of the key Ansible uses to log in (set via TF_VAR_ssh_public_key)"
  type        = string
}
