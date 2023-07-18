variable "ssh_key_name" {
    description = "SSH key name"
    type = string
    sensitive = true
}

variable "regiondc" {
    description = "Region DC"
    type = string
    sensitive = true
}

variable "vpc_private_net" {
    description = "VPC private network"
    type = string
    sensitive = true
}

variable "admin_net" {
    description = "Admin network"
    type = list(string)
    sensitive = true
}