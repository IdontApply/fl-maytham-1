provider "aws" {
  region                  = "eu-west-1"
}
# Create key pair for ssh, uploading public key in aws, to be used by ec2 instances.
resource "aws_key_pair" "a" {
  key_name   = var.key_pair_name
  public_key = file(pathexpand(var.public_key_path))
}

#  Create a VPC to launch our instances into.
resource "aws_vpc" "b" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Project = "flugel"
  }
}
# Create an internet gateway to give our subnet access to the outside world.
resource "aws_internet_gateway" "b" {
  vpc_id = aws_vpc.b.id

  tags = {
    Name = "terraform-example-internet-gateway"
  }
}
# Grant the VPC internet access on its main route table.
resource "aws_route" "route" {
  route_table_id         = aws_vpc.b.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.b.id
}
# Create EIP for NAT GW
resource "aws_eip" "eip_natgw" {
  tags = {
    Project = "flugel"
  }
} # Create NAT gateway
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip_natgw.id
  subnet_id     = aws_subnet.public.id
  
  tags = {
    Project = "flugel"
  }
}
# Create private route table for prv sub
resource "aws_route_table" "prv_sub_rt" {
  vpc_id = aws_vpc.b.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name    = "private subnet route table"
    Project = "flugel"
  }
}
# Create route table association betn prv sub & NAT GW
resource "aws_route_table_association" "pri_sub_to_natgw" {
  count          = "2"
  route_table_id = aws_route_table.prv_sub_rt.id
  subnet_id      = aws_subnet.privet[count.index].id
}

data "aws_availability_zones" "available" {
  state = "available"
}
# Create privet subnets in 3 availability zone, to launch our instances into 2, and 1 to associate the alb with
resource "aws_subnet" "privet" {
  count                   = 3
  vpc_id                  = aws_vpc.b.id
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = false
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Project = "flugel"
  }
}
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.b.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = element(data.aws_availability_zones.available.names, 0)
  map_public_ip_on_launch = true

  tags = {
    Project = "flugel"
  }
}
# Create an application load balancer security group.
resource "aws_security_group" "lb" {
  name        = "terraform_alb_security_group"
  description = "Terraform load balancer security group"
  vpc_id      = aws_vpc.b.id


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Project = "flugel"
  }
}
# Create a web server security group.
resource "aws_security_group" "b" {
  name        = "instance"
  description = "Terraform load balancer security group"
  vpc_id      = aws_vpc.b.id

  # Allow ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "SSH"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = "flugel"
  }
}

# Create a new application load balancer.
resource "aws_alb" "b" {
  name            = "terraform-example-alb"
  security_groups = ["${aws_security_group.lb.id}"]
  internal        = false
  subnets         = [aws_subnet.public.id, aws_subnet.privet[2].id]

  tags = {
    Project = "flugel"
  }
}
# Create a new target group for the application load balancer.
resource "aws_alb_target_group" "b" {
  name     = "terraform-example-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.b.id

  stickiness {
    type = "lb_cookie"
  }

  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/login"
    port = 80
  }

  tags = {
    Project = "flugel"
  }
}
# Create taget group attachment from alb to ec2 instances
resource "aws_lb_target_group_attachment" "b" {
  count            = 2
  target_group_arn = aws_alb_target_group.b.arn
  target_id        = aws_instance.b[count.index].id
  port             = 80
}
# Create a new application load balancer listener for HTTP.
resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.b.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.b.arn
    type             = "forward"
  }
}

# Create ec2 instances running nginx
resource "aws_instance" "b" {
  depends_on = [
    aws_key_pair.a,
  ]

  ami           = var.ami
  instance_type = var.instance_type
  count         = 2

  security_groups             = ["${aws_security_group.b.id}"]
  subnet_id                   = aws_subnet.privet[count.index].id
  associate_public_ip_address = true

  key_name = var.key_pair_name

  tags = {
    Name = "${var.tag_name}"
  }

  # Create connection ssh for remote-exec
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(pathexpand(var.private_key_path))
  }

  # Provisioner shell script that will setup nginx
  provisioner "file" {
    source      = "scripts/nginx.sh"
    destination = "/tmp/nginx.sh"
  }

  # Provisioner nginx configration
  provisioner "file" {
    source      = "scripts/domain"
    destination = "/tmp/domain"
  }

  # Provisioner python script to create the files to be served by nginx
  provisioner "file" {
    source      = "scripts/nginx.py"
    destination = "/tmp/nginx.py"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/nginx.py",
      "chmod +x /tmp/nginx.sh",
      "/tmp/nginx.sh ${var.tag_name}",
      "exit 0",
    ]
  }
}


