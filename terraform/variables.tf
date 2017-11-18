#------------------------------------------#
# AWS Environment Variables
#------------------------------------------#
variable "access_key" {
  description = "AWS access key"
}

variable "secret_key" {
  description = "AWS secret key"
}

variable "region" {
  default     = "us-east-1"
  description = "The region of AWS for AMI lookups"
}

variable "vpc_id" {
  description = "VPC for EC2 and ELB"
}

variable "ami" {
  default     = "ami-da05a4a0"
  description = "Instance AMI ID"
}

variable "key_name" {
  default     = "dokku-deploy"
  description = "SSH key name in your AWS account for AWS instances"
}

variable "instance_type" {
  default     = "t2.micro"
  description = "AWS Instance type"
}

variable "root_volume_size" {
  default     = "16"
  description = "Size in GB of the root volume for instances"
}

variable "allowed_cidr_blocks" {
  default     = ["0.0.0.0/0"]
  description = "CIDR block to allow incoming traffic for. Defaults to all."
}

variable "subnet_id" {
  description = "Subnet to use for public traffic"
}

variable "key_path" {
  default     = "../.keys/dokku.pem"
  description = "Path to the .pem file to access resources"
}
