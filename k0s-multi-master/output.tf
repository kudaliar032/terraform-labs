output "vpc_id" {
  description = "The ID ofr the VPC"
  value = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value = module.vpc.public_subnets
}

output "ec2_instance_loadbalancer_public_ip" {
  description = "The public IP address assigned to the instance for loadbalancer"
  value = module.ec2_instance_loadbalancer.public_ip
}

output "ec2_instance_master_public_ip" {
  description = "The public IP address assigned to the instance for master"
  value = {
    for k, v in module.ec2_instance_master : k => v.public_ip
  }
}

output "ec2_instance_worker_public_ip" {
  description = "The public IP address assigned to the instance for worker"
  value = {
    for k, v in module.ec2_instance_worker : k => v.public_ip
  }
}
