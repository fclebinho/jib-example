# resource "aws_instance" "bastion" {
#   ami           = lookup(var.amis, var.region)
#   instance_type = var.instance_type
#   # key_name      = aws_key_pair.terraform-lab.key_name
#   # iam_instance_profile        = aws_iam_instance_profile.session-manager.id
#   security_groups = [aws_security_group.allow_http_sg.id]
#   subnet_id       = module.vpc.private_subnets[0]
#   depends_on      = [module.vpc.natgw_ids]
#   tags            = merge(var.tags, { Name = "bastion" })
# }


resource "aws_launch_configuration" "ec2" {
  name            = "${var.ec2_instance_name}-instances-lc"
  image_id        = lookup(var.amis, var.region)
  instance_type   = var.instance_type
  security_groups = [aws_security_group.ec2.id]
  user_data       = <<-EOF
  #!/bin/bash -xe

  sudo yum update -y
  sudo yum -y install docker
  sudo service docker start
  sudo usermod -a -G docker ec2-user
  sudo chmod 666 /var/run/docker.sock
  sudo docker pull fclebinho/jib-example:2024.5.28.23.3.5
  sudo docker run -d -p 80:8080 fclebinho/jib-example:2024.5.28.23.3.5
  EOF

  depends_on = [module.vpc.natgw_ids]
}
