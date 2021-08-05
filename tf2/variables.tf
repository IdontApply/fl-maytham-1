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
  description = "instance type"
  default     = "t4g.micro"
}
variable "public_key_path" {
  type        = string
  description = "ssh public key path"
  default     = "../../id_rsa.pub"
}
variable "private_key_path" {
  type    = string
  description = "ssh privet key path"
  default = "../../id_rsa"
}
variable "key_pair_name" {
  type    = string
  description = "key pair name"
  default = "my-key"
}
variable "tag_name" {
  type    = string
  description = "ec2 Name tag"
  default = "Flugel"
}
