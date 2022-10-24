variable "main_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "public_cidr_blocks" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_cidr_blocks" {
  type = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

# Change it and don't push to git
variable "aws_access_key" {
  type = string
  default = "AWSXXXXXX0978"
}

# Change it and don't push to git
variable "aws_secret_key" {
  type = string
  default = "AULP0XXXXXXY7US9XXXXOP56JX"
}