
resource "aws_s3_bucket" "dev_tf_course" {
  bucket = "test-20200722"
  acl    = "private"
  tags = {
    "Terraform" : "true"
  }
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
  cidr_blocks       = ["${local.workstation-external-cidr}"]
  security_group_id = aws_security_group.dev_web.id
  type              = "ingress"

}