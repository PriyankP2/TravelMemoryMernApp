resource "aws_subnet" "public" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "ansible-public-subnet-pp"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "ansible-private-subnet-pp"
  }
}
