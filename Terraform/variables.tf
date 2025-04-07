variable "ec2_ami" {
  description = "AMI ID for EC2"
  type        = string
}

variable "ec2_key_name" {
  description = "EC2 SSH key name"
  type        = string
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_name" {
  type = string
}

variable "jenkins_ip" {
  type = string
}

variable "jenkins_private_ip" {
  type = string
}
