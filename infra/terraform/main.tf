# One compute instance for taskflow-api, reachable on 8080 through its security group.

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "taskflow" {
  name   = "taskflow-api"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "ansible" {
  key_name   = "lab08-ansible"
  public_key = var.ssh_public_key
}

resource "aws_instance" "taskflow" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ansible.key_name
  vpc_security_group_ids = [aws_security_group.taskflow.id]

  tags = {
    Name = "taskflow-api"
  }
}
