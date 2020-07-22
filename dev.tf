
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
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks =["${local.workstation-external-cidr}"]
  }
}