output "web_public_ip" {
  value = module.ec2.web_public_ip
}

output "db_private_ip" {
  value = module.ec2.db_private_ip
}
