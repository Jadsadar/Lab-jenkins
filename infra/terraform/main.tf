# One compute instance for taskflow-api, reachable on 8080 through its security group.
# Hardened after the Lab 08 tfsec/checkov scan: no world-open ports, encrypted disk, IMDSv2 only.

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "taskflow" {
  name        = "taskflow-api"
  description = "taskflow-api: HTTP 8080 from the allowed network only"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "taskflow-api HTTP from the allowed network"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  # HTTPS only (was: every protocol and port), still open to the internet because the host
  # must reach apt mirrors and the container registry
  egress {
    description = "HTTPS out for apt packages and image pulls"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #tfsec:ignore:aws-ec2-no-public-egress-sgr
  }
}

resource "aws_key_pair" "ansible" {
  key_name   = "lab08-ansible"
  public_key = var.ssh_public_key
}

resource "aws_instance" "taskflow" {
  #checkov:skip=CKV2_AWS_41:The host never calls AWS APIs, so it gets no IAM role (least privilege)
  #checkov:skip=CKV_AWS_135:t3 instances are EBS-optimized by default; the flag is redundant here
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ansible.key_name
  vpc_security_group_ids = [aws_security_group.taskflow.id]
  monitoring             = true

  # IMDSv2: metadata requests need a session token, blocking SSRF-style credential theft
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "taskflow-api"
  }
}
