provider "aws" {
  region = var.region
}

# Just a simple ec2 instance that will run in the default vpc.
resource "aws_instance" "a" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name  = "Flugel",
    Owner = "InfraTeam",
  }

}
# Just a simple privet s3 bucket.
resource "aws_s3_bucket" "a" {
  bucket = "flugel"
  acl    = "private"
  tags = {
    Name  = "Flugel",
    Owner = "InfraTeam",
  }
}
