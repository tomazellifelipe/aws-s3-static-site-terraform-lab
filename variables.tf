variable "access_key" {
  type        = string
  description = "aws access key"
  sensitive   = true
}
variable "secret_key" {
  type        = string
  description = "aws secret key"
  sensitive   = true
}
variable "name" {
  type        = string
  description = "Default name for resources"
  default     = "terraform-lab"
}