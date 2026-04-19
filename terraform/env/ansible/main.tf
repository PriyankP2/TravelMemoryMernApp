provider "aws" {
  region = "ap-south-1"
}

# VPC
module "vpc" {
  source = "../../modules/vpc"
}

# Subnets
module "subnet" {
  source = "../../modules/subnet"
  vpc_id = module.vpc.vpc_id
}

# Internet Gateway
module "igw" {
  source = "../../modules/igw"
  vpc_id = module.vpc.vpc_id
}

# NAT Gateway
module "nat" {
  source = "../../modules/nat"
  public_subnet_id = module.subnet.public_subnet_id
}

# Route Tables
module "route_table" {
  source = "../../modules/route_table"

  vpc_id            = module.vpc.vpc_id
  igw_id            = module.igw.igw_id
  nat_id            = module.nat.nat_id
  public_subnet_id  = module.subnet.public_subnet_id
  private_subnet_id = module.subnet.private_subnet_id
}

# Security Groups
module "sg" {
  source = "../../modules/security_group"
  vpc_id = module.vpc.vpc_id
}

# EC2 Instances
module "ec2" {
  source = "../../modules/ec2"

  public_subnet_id  = module.subnet.public_subnet_id
  private_subnet_id = module.subnet.private_subnet_id

  web_sg_id = module.sg.web_sg_id
  db_sg_id  = module.sg.db_sg_id

  key_name = var.key_name
}
