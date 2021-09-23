provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu_focal" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
      name = "virtualization-type"
      values = ["hvm"]
  }

  owners = ["099720109477"]
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.cluster_name}-vpc"
  cidr = "192.168.0.0/16"

  azs = var.aws_azs
  private_subnets = ["192.168.1.0/24", "192.168.2.0/24", "192.168.3.0/24"]
  public_subnets = ["192.168.11.0/24", "192.168.12.0/24", "192.168.13.0/24"]

  enable_nat_gateway = false
}

module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name = "${var.cluster_name}-sg"
  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  ingress_rules = ["all-all"]
  ingress_with_cidr_blocks = [
    {
      from_port = 6443
      to_port = 6443
      protocol = "tcp"
      description = "for Kubernetes API"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 8132
      to_port = 8132
      protocol = "tcp"
      description = "for Konnectivity"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 9443
      to_port = 9443
      protocol = "tcp"
      description = "for controller join API"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port = 9000
      to_port = 9000
      protocol = "tcp"
      description = "for HAProxy Admin"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name = "${var.cluster_name}-key-pair"
  public_key = var.ssh_public_key
}

module "ec2_instance_loadbalancer" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.cluster_name}-instance-loadbalancer"

  ami = data.aws_ami.ubuntu_focal.id
  instance_type = var.aws_machine_type
  key_name = module.key_pair.key_pair_key_name
  vpc_security_group_ids = [module.sg.security_group_id]
  subnet_id = module.vpc.public_subnets[0]
}

module "ec2_instance_master" {
  source = "terraform-aws-modules/ec2-instance/aws"

  count = 3

  name = "${var.cluster_name}-instance-master${count.index}"

  ami = data.aws_ami.ubuntu_focal.id
  instance_type = var.aws_machine_type
  key_name = module.key_pair.key_pair_key_name
  vpc_security_group_ids = [module.sg.security_group_id]
  subnet_id = module.vpc.public_subnets[count.index]
}

module "ec2_instance_worker" {
  source = "terraform-aws-modules/ec2-instance/aws"

  count = 3

  name = "${var.cluster_name}-instance-worker${count.index}"

  ami = data.aws_ami.ubuntu_focal.id
  instance_type = var.aws_machine_type
  key_name = module.key_pair.key_pair_key_name
  vpc_security_group_ids = [module.sg.security_group_id]
  subnet_id = module.vpc.public_subnets[count.index]
}
