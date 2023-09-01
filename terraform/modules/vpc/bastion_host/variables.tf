variable "vpc_id" {
  type        = string
  description = "Id of the VPC"
}

variable "public_subnet_id" {
  type        = string
  description = "Id of the public subnet"
}

variable "allowed_ip_cidrs" {
  default = ["0.0.0.0/0"]
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC. Used for tags"
}
