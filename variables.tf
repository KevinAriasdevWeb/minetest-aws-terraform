variable "aws_region" {
  default = "us-east-2"
}

variable "key_name" {
  description = "mi-clave-minetest-oregon"
}

variable "public_key_path" {
  description = "Ruta local a tu archivo .pub"
}

variable "ubuntu_ami" {
  description = "AMI ID de Ubuntu"
  type        = string
  #default     = "ami-05f991c49d264708f"
}