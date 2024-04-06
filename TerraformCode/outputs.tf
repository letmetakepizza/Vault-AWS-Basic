output "instance_public_ips" {
  description = "Public IPs of EC2 instances"

  value = [for instance in aws_instance.vault_host_res : instance.public_ip]
}
