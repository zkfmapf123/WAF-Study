data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}


resource "aws_security_group" "ins-sg" {
  vpc_id      = aws_vpc.main.id
  name        = "ins-sg"
  description = "description"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.alb-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "default-ins-sg"
  }
}

## Freetier는 cpu 옵션을 사용할수 없습니다.
module "waf-ec2" {
  source = "zkfmapf123/simpleEC2/lee"

  instance_name      = "waf-dvwa-ins"
  instance_region    = "ap-northeast-2a"
  instance_subnet_id = lookup(aws_subnet.public, "ap-northeast-2a").id
  instance_sg_ids    = [aws_security_group.ins-sg.id]

  instance_ami = data.aws_ami.ubuntu.id

  instance_ip_attr = {
    is_public_ip  = true
    is_eip        = true
    is_private_ip = false
    private_ip    = ""
  }

  user_data_file = "./user_data.sh"

  instance_key_attr = {
    is_alloc_key_pair = false
    is_use_key_path   = true
    key_name          = ""
    key_path          = "~/.ssh/id_rsa.pub"
  }

  instance_tags = {
    "Monitoring" : true,
    "MadeBy" : "terraform"
  }
}

output "ec2" {
  value = module.waf-ec2
}
