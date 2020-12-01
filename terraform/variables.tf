//HashiCorp reaper specifick variables
variable "owner" {
  description = "IAM user responsible for lifecycle of cloud resources used for training"
}

variable "created-by" {
  description = "Tag used to identify resources created programmatically by Terraform"
  default     = "Terraform"
}

variable "sleep-at-night" {
  description = "Tag used by reaper to identify resources that can be shutdown at night"
  default     = true
}

variable "TTL" {
  description = "Hours after which resource expires, used by reaper. Do not use any unit. -1 is infinite."
  default     = "240"
}

//Rest of the VARS
variable "ssh_public_key" {
  description = "The SSH public key to be used for authentication to the EC2 instances."
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-central-1"
}

variable "cidr" {
  description = "The subnet address to use for the VPC and subnet"
  default     = "192.168.200.0/24"
}


variable "allow_from" {
  description = "IP Address/Network to allow traffic from (i.e. 192.0.2.11/32)"
  type        = string
  default     = "0.0.0.0/0"
}
