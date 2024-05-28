variable "instance_type" {
  description = "value for instance_type"
  type        = string
  nullable    = false
  default     = "t3.micro"
}

variable "tags" {
  description = "value for tags"
  type        = map(string)
  nullable    = false
  default = {
    Name        = "terraform-aws"
    Terraform   = "true"
    Environment = "dev"
  }
}
