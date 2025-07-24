terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Esto requiere la versión 5.x del proveedor de AWS
                         # o más reciente. La versión 5.x y superior soporta aws_subnets.
    }
  }
  required_version = ">= 1.0" # Asegura que usas una versión reciente de Terraform CLI
}


provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "default" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "minetest_sg" {
  name        = "minetest_sg"
  description = "Allow Minetest port"

  ingress {
    from_port   = 30000
    to_port     = 30000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}

# CAMBIO AQUÍ: Usamos data "aws_subnets" para obtener los IDs de las subredes
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  # Considera añadir un filtro para "default-for-az" si quieres solo las subredes por defecto
  # filter {
  #   name = "default-for-az"
  #   values = ["true"]
  # }
}

resource "aws_launch_template" "minetest_lt" {
  name_prefix   = "minetest-lt-"
  image_id      = var.ubuntu_ami
  instance_type = "t2.micro"
  key_name      = aws_key_pair.default.key_name

  user_data = base64encode(file("user_data.sh"))

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.minetest_sg.id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "MinetestASGInstance"
    }
  }
}

resource "aws_autoscaling_group" "minetest_asg" {
  name                      = "minetest-asg"
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  health_check_type         = "EC2"
  health_check_grace_period = 60
  force_delete              = true
  # CAMBIO AQUÍ: Ahora referenciamos el nuevo data source aws_subnets
  vpc_zone_identifier       = [data.aws_subnets.default.ids[0]]

  launch_template {
    id      = aws_launch_template.minetest_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "MinetestASGInstance"
    propagate_at_launch = true
  }
}

data "aws_instances" "asg_instances" {
  # Filtra por el Auto Scaling Group al que pertenecen las instancias.
  # La clave es 'tag:aws:autoscaling:groupName'
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.minetest_asg.name]
  }

  # Filtra por el estado de la instancia (ej. "running")
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

output "minetest_ip" {
  description = "Public IP address of the Minetest server"
  # Asegúrate de que la lista de IPs no esté vacía antes de acceder al índice [0]
  # Si solo esperas una instancia (min_size=1), esto es seguro después de aplicar.
  value = length(data.aws_instances.asg_instances.public_ips) > 0 ? data.aws_instances.asg_instances.public_ips[0] : "No instance IP found"
}