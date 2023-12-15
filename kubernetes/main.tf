# 변수
locals {
  vpc_cidr = "10.0.0.0/16"
  name     = "kubernetes"
}

# 가용영역 불러오기
data "aws_availability_zones" "azs" {}

# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = local.name
  cidr = local.vpc_cidr

  azs             = data.aws_availability_zones.azs.names
  public_subnets  = [for i, v in data.aws_availability_zones.azs.names : cidrsubnet(local.vpc_cidr, 8, i)]
  
  map_public_ip_on_launch = true
}

# EC2
resource "random_password" "this" {
  length  = 8
  special = false
}

resource "aws_security_group" "this" {
  name        = "${local.name}-sg"
  description = "${local.name}-sg"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "cp" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.large"
  root_block_device {
    volume_size = 20
  }
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [
    aws_security_group.this.id
  ]
  user_data = <<EOF
#!/bin/bash
hostnamectl set-hostname cp
echo "root:${random_password.this.result}" | chpasswd
sed 's/PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
sed 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' -i /etc/ssh/sshd_config
systemctl restart sshd
apt update && apt install -y jq
EOF

  tags = {
    Name = "cp"
  }
  
  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_instance" "worker" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.large"
  root_block_device {
    volume_size = 20
  }
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [
    aws_security_group.this.id
  ]
  user_data = <<EOF
#!/bin/bash
hostnamectl set-hostname worker
echo "root:${random_password.this.result}" | chpasswd
sed 's/PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
sed 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' -i /etc/ssh/sshd_config
systemctl restart sshd
EOF

  tags = {
    Name = "worker"
  }
  
  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_instance" "haproxy" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  root_block_device {
    volume_size = 20
  }
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [
    aws_security_group.this.id
  ]
  user_data = <<EOF
#!/bin/bash
hostnamectl set-hostname haproxy
echo "root:${random_password.this.result}" | chpasswd
sed 's/PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
sed 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' -i /etc/ssh/sshd_config
systemctl restart sshd
EOF

  tags = {
    Name = "haproxy"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_instance" "secondcp" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.large"
  root_block_device {
    volume_size = 20
  }
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [
    aws_security_group.this.id
  ]
  user_data = <<EOF
#!/bin/bash
hostnamectl set-hostname secondcp
echo "root:${random_password.this.result}" | chpasswd
sed 's/PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
sed 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' -i /etc/ssh/sshd_config
systemctl restart sshd
EOF

  tags = {
    Name = "secondcp"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_instance" "thirdcp" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.large"
  root_block_device {
    volume_size = 20
  }
  subnet_id = module.vpc.public_subnets[0]
  vpc_security_group_ids = [
    aws_security_group.this.id
  ]
  user_data = <<EOF
#!/bin/bash
hostnamectl set-hostname thirdcp
echo "root:${random_password.this.result}" | chpasswd
sed 's/PasswordAuthentication no/PasswordAuthentication yes/' -i /etc/ssh/sshd_config
sed 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' -i /etc/ssh/sshd_config
systemctl restart sshd
EOF

  tags = {
    Name = "thirdcp"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}