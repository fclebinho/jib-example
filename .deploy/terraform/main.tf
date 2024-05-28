provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "terraform-aws-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  private_subnet_suffix = "_private"
  public_subnet_suffix  = "_public"

  enable_nat_gateway = true
  enable_vpn_gateway = true
  single_nat_gateway = true

  map_public_ip_on_launch = true

  tags = var.tags
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name = "terraform-aws-alb"

  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  security_groups = [aws_security_group.allow_http_sg.id]

  target_groups = [
    {
      name_prefix      = "tg"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    },
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]

  tags = var.tags
}

resource "aws_instance" "ec2_allow_ssh" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = "laboratory"

  subnet_id       = module.vpc.public_subnets[0]
  security_groups = [aws_security_group.allow_ssh_sg.id]

  tags = var.tags
}

module "ec2_instances" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name = "terraform-aws-ec2-cluster"

  instance_count = 1

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = "laboratory"

  vpc_security_group_ids = [aws_security_group.allow_http_sg.id]
  subnet_id              = module.vpc.private_subnets[0]

  user_data = file("userdata.sh")

  depends_on = [module.vpc.natgw_ids]

  tags = merge(var.tags, { "Name" = "terraform-aws-api" })
}

resource "aws_lb_target_group_attachment" "alb_tg_attachment" {
  target_group_arn = module.alb.target_group_arns[0]
  target_id        = module.ec2_instances.id[0]
  port             = 80
}
