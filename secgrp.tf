
#################################
#  ELB Security Group
#################################
resource "aws_security_group" "vprofile_bean_elb_sg" {
  name        = "vprofile-bean-elb-sg"
  description = "Security group for bean-elb"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name      = "vprofile-bean-elb"
    ManagedBy = "Terraform"
    Project   = "Vprofile"
  }
}

resource "aws_vpc_security_group_ingress_rule" "elb_allow_http" {
  security_group_id = aws_security_group.vprofile_bean_elb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "elb_allow_all_out" {
  security_group_id = aws_security_group.vprofile_bean_elb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#################################
#  Bastion Host Security Group
#################################
resource "aws_security_group" "vprofile_bastion_sg" {
  name        = "vprofile-bastion-sg"
  description = "Security group for bastion EC2"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name      = "vprofile-bastion-sg"
    ManagedBy = "Terraform"
    Project   = "Vprofile"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_allow_ssh" {
  security_group_id = aws_security_group.vprofile_bastion_sg.id
  cidr_ipv4         = "0.0.0.0/0" # 🔒 Consider replacing with your IP
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "bastion_allow_all_out" {
  security_group_id = aws_security_group.vprofile_bastion_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#################################
#  App / Beanstalk Security Group
#################################
resource "aws_security_group" "vprofile_app_sg" {
  name        = "vprofile-prod-bean-sg"
  description = "Security group for Beanstalk app instances"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name      = "vprofile-app"
    ManagedBy = "Terraform"
    Project   = "Vprofile"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_allow_http_from_elb" {
  security_group_id            = aws_security_group.vprofile_app_sg.id
  referenced_security_group_id = aws_security_group.vprofile_bean_elb_sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "app_allow_ssh" {
  security_group_id = aws_security_group.vprofile_app_sg.id
  cidr_ipv4         = "0.0.0.0/0" # 🔒 Consider locking down SSH
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_allow_all_out" {
  security_group_id = aws_security_group.vprofile_app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

#################################
#  Backend Security Group
#################################
resource "aws_security_group" "vprofile_backend_sg" {
  name        = "vprofile-backend-sg"
  description = "Security group for RDS, MQ, Elasticache"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name      = "vprofile-backend"
    ManagedBy = "Terraform"
    Project   = "Vprofile"
  }
}

resource "aws_vpc_security_group_ingress_rule" "backend_allow_from_app" {
  security_group_id            = aws_security_group.vprofile_backend_sg.id
  referenced_security_group_id = aws_security_group.vprofile_app_sg.id
  from_port                    = 0
  to_port                      = 65535
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "backend_allow_from_bastion" {
  security_group_id            = aws_security_group.vprofile_backend_sg.id
  referenced_security_group_id = aws_security_group.vprofile_bastion_sg.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "backend_allow_self" {
  security_group_id            = aws_security_group.vprofile_backend_sg.id
  referenced_security_group_id = aws_security_group.vprofile_backend_sg.id
  from_port                    = 0
  to_port                      = 65535
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "backend_allow_all_out" {
  security_group_id = aws_security_group.vprofile_backend_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
