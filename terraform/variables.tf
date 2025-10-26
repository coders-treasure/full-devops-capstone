variable "key_name" {
  description = "The name of the SSH key pair in AWS."
  type        = string
}
variable "instance_type" {
  description = "The EC2 instance size to use."
  type        = string
  default     = "t2.micro" 
}