output "ec2_instance_loadbalancer_public_ip" {
  description = "The public IP address assigned to the instance for loadbalancer"
  value = {
    public_ip = module.ec2_instance_loadbalancer.public_ip
    private_dns = module.ec2_instance_loadbalancer.private_dns
  }
}

output "ec2_instance_master_public_ip" {
  description = "The public IP address assigned to the instance for master"
  value = {
    for k, v in module.ec2_instance_master : k => {
      public_ip = v.public_ip
      private_dns = v.private_dns
    }
  }
}

output "ec2_instance_worker_public_ip" {
  description = "The public IP address assigned to the instance for worker"
  value = {
    for k, v in module.ec2_instance_worker : k => {
      public_ip = v.public_ip
      private_dns = v.private_dns
    }
  }
}
