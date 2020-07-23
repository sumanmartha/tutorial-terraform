
data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
      name   = "name"
      values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

resource "aws_s3_bucket" "dev_tf_course" {
  bucket = "test-20200722"
  acl    = "private"
  
  tags = map (
    "Name", "dev_web",
    "Terraform", "true"
  )
}

resource "aws_security_group" "dev_web" {
  name        = "dev_web"
  description = "Allow http and https in inbound and everything in outbound"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id        = var.vpc_id

  tags = map (
    "Name", "dev_web",
    "Terraform", "true"
  )

}

resource "aws_security_group_rule" "dev_web_https" {
  description       = "Allow https traffic."
  to_port           = 443
  from_port         = 443
  protocol          = "tcp"
  cidr_blocks       = ["${local.workstation-external-cidr}"]
  security_group_id = aws_security_group.dev_web.id
  type              = "ingress"

}

resource "aws_security_group_rule" "dev_web_http" {
  description       = "Allow http traffic."
  to_port           = 80
  from_port         = 80
  protocol          = "tcp"
  cidr_blocks       = [local.workstation-external-cidr]
  security_group_id = aws_security_group.dev_web.id
  type              = "ingress"
}

resource "aws_security_group_rule" "dev_web_ssh" {
  description       = "Allow ssh traffic."
  to_port           = 22
  from_port         = 22
  protocol          = "tcp"
  cidr_blocks       = [local.workstation-external-cidr]
  security_group_id = aws_security_group.dev_web.id
  type              = "ingress"
}

resource "aws_key_pair" "dev_web" {
  key_name   = "smartha"
  public_key = file("smartha.pub")
}

resource "aws_instance" "dev_web" {
  ami                     = data.aws_ami.latest_ubuntu.id
  instance_type           = var.web_instance_type
  key_name                = aws_key_pair.dev_web.key_name
  vpc_security_group_ids  = [aws_security_group.dev_web.id]
  subnet_id               = var.vpc_public_subnets[0]
  user_data               = file("install_nginx.sh")

  tags = map (
    "Name", "dev_web",
    "Terraform", "true"
  )
}