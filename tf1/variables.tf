variable "ami" {
  type        = string
  description = "amazon machine images"
  default     = "ami-0d4a18a6050cef430"
}
variable "region" {
  type        = string
  description = "region"
  default     = "eu-west-1"
}
variable "instance_type" {
  type        = string
  description = "instance_type"
  default     = "t4g.micro"
}
