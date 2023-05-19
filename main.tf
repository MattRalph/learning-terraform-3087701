data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

# tutorial 3.4
data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  # tutorial 3.4  
  # vpc_security_group_ids = [aws_security_group.blog.id]

  # tutorial 3.7  
  vpc_security_group_ids = [module.blog_sg.security_group_id] # .security_group_id from https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest?tab=outputs

  tags = {
    Name = "Learning Terraform"
  }
}

# tutorial 3.7
module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.17.2"
  name    = "blog_new"

  vpc_id  = data.aws_vpc.default.id

  ingress_rules       = ["http-80-tcp","https-443-tcp"]
  ingress_cird_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cird_blocks = ["0.0.0.0/0"]

}

# tutorial 3.4
resource "aws_security_group" "blog" {
  name        = "blog"
  description = "Allow http and https in. Allow everything else out"
}

# tutorial 3.4
resource "aws_security_group_rule" "blog_http_in" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}

# tutorial 3.4
resource "aws_security_group_rule" "blog_https_in" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}

# tutorial 3.4
resource "aws_security_group_rule" "blog_everything_out" {
  type        = "egress"
  from_port   = 0 # everything
  to_port     = 0 # everything
  protocol    = "-1" # allow all protocols
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}