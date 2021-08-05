instance_type    = "t4g.micro"
region           = "eu-west-1"
ami              = "ami-0d4a18a6050cef430"
# ec2 tag, will be added as static file
tag_name         = "Flugel"
# rsa key pair used for ssh
private_key_path = "../../id_rsa"
public_key_path      = "../../id_rsa.pub"