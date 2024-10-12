terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

# Provider configuration
provider "aws" {
  region = "eu-west-2" # London region
}


# Security Group for Frontend 1
resource "aws_security_group" "frontend1" {
  name        = "frontend1-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow SSH and HTTP traffic for Frontend 1"

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] # Allow SSH from anywhere
    ipv6_cidr_blocks = ["::/0"]      # Allow SSH from anywhere over IPv6
  }

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Security Group for Frontend 2
resource "aws_security_group" "frontend2" {
  name        = "frontend2-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow SSH and HTTP traffic for Frontend 2"

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Security Group for Backend 1
resource "aws_security_group" "backend1" {
  name        = "backend1-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow SSH and HTTP traffic for Backend 1 from Frontend 1 and 2"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    #security_groups = [aws_security_group.frontend1.id, aws_security_group.frontend2.id] # Allow SSH from Frontend groups
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    #security_groups = [aws_security_group.frontend1.id, aws_security_group.frontend2.id] # Allow HTTP from Frontend groups
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Security Group for Backend 2
resource "aws_security_group" "backend2" {
  name        = "backend2-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow SSH and HTTP traffic for Backend 2 from Frontend 1 and 2"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    #security_groups = [aws_security_group.frontend1.id, aws_security_group.frontend2.id] # Allow SSH from Frontend groups
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"#
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    #security_groups = [aws_security_group.frontend1.id, aws_security_group.frontend2.id] # Allow HTTP from Frontend groups
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Security Group for MySQL Database
resource "aws_security_group" "mysql_sg" {
  name        = "mysql-sg"
  vpc_id      = aws_vpc.main.id
  description = "Allow SSH and MySQL traffic for the database from Backend 1 and 2"


  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend1.id, aws_security_group.backend2.id] # Allow MySQL from Backends
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Frontend 1 Instance
resource "aws_instance" "frontend1" {
  ami                         = var.frontend1_ami
  instance_type               = var.frontend1_instance_type #"t2.micro"
  vpc_security_group_ids      = [aws_security_group.frontend1.id]
  subnet_id                   = aws_subnet.subnet1.id
  user_data                   = file("./frontend1-install.sh")
  availability_zone           = var.frontend1_az       #"eu-west-2a"      # Availability Zone 1
  key_name                    = var.frontend1_key_name
  associate_public_ip_address = true

  tags = {
    Name = "frontend1"
  }
}

# Frontend 2 Instance
resource "aws_instance" "frontend2" {
  ami                         = var.frontend2_ami
  instance_type               = var.frontend2_instance_type #"t2.micro"
  vpc_security_group_ids      = [aws_security_group.frontend2.id]
  subnet_id                   = aws_subnet.subnet2.id
  user_data                   = file("./frontend2-install.sh")
  availability_zone           = var.frontend2_az       #"eu-west-2b"    # Availability Zone 2
  key_name                    = var.frontend2_key_name
  associate_public_ip_address = true

  tags = {
    Name = "frontend2"
  }
}

# Backend 1 Instance #I installed MySQL in this instance to be able to connect to the Database from the backend
resource "aws_instance" "backend1" {
  ami                         = var.backend1_ami
  instance_type               = var.backend1_instance_type #"t2.micro"
  vpc_security_group_ids      = [aws_security_group.backend1.id]
  subnet_id                   = aws_subnet.subnet1.id
  user_data                   = file("./backend1-install.sh")
  availability_zone           = var.backend1_az       #"eu-west-2a" # Availability Zone 1
  key_name                    = var.backend1_key_name
  associate_public_ip_address = true

  tags = {
    Name = "backend1"
  }
}

# Backend 2 Instance ###
resource "aws_instance" "backend2" {
  ami                         = var.backend2_ami
  instance_type               = var.backend2_instance_type #"t2.micro"
  vpc_security_group_ids      = [aws_security_group.backend2.id]
  subnet_id                   = aws_subnet.subnet2.id
  user_data                   = file("./backend2-install.sh")
  availability_zone           = var.backend2_az       #"eu-west-2b" # Availability Zone 2
  key_name                    = var.backend2_key_name
  associate_public_ip_address = true

  tags = {
    Name = "backend2"
  }
}

# EC2 Instance for MySQL Database
resource "aws_instance" "mysql_instance" {
  ami                         = "ami-01a00eb6d8687e14b" #My EC2 DB Instance Template AMI
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.mysql_sg.id]
  subnet_id                   = aws_subnet.subnet1.id
  availability_zone           = "eu-west-2a" # Availability Zone 2
  key_name                    = "jonag"
  associate_public_ip_address = true

  tags = {
    Name = "mysql_instance"
  }
}

# MySQL RDS Database Instance

resource "aws_db_instance" "mysql_db" {
  identifier             = "mysql-db"
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t4g.micro" 
  allocated_storage      = 20             
  db_name                = "mydb"         
  username               = "admin"        
  password               = "password123" 
  db_subnet_group_name   = aws_db_subnet_group.my_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.mysql_sg.id]
  availability_zone      = "eu-west-2b" # Availability Zone 2
  skip_final_snapshot    = true         

  tags = {
    Name = "my_mysql_db"
  }
}

# Define a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main_vpc"
  }
}

# Define Subnet 1
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-2a"

  tags = {
    Name = "subnet1"
  }
}

# Define Subnet 2
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-2b"

  tags = {
    Name = "subnet2"
  }
}


# Subnet Group for RDS
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my_db_subnet_group"
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  tags = {
    Name = "my_db_subnet_group"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main_gw"
  }
}

resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "main_route_table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.main_route_table.id
}



