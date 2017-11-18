# Configure the AWS provider
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# Creates the key pair
resource "aws_key_pair" "dokku" {
  key_name   = "${var.key_name}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCc9d2qOzMDQgTV3tBfzx+o+YIz1hP6NI3G9tPNV8FLz5IVYvXw6ywFAnBF1i0okTHDgxZ4wIQawAov8VPMokP5l7sO5pyrXJCkSd+XZwb+MzDd+xTRWNxtZM2teRL94MmXj5YKcwaanyNqs5LsJ72kSQ8NJbeYYNJPEo8LBY28GoK6LToausAR3I86RFkAFfVT6N3sRcPyuNoe1uEhtN6cEiRSxC1MjurOgOWFdMyYFWwt/BZrw5Euy7rT4lzuCGGDVjhf3sGlyw5ufiHsL3dXVt6ARLYlBKRv6DkE/vb9cU1HfezBNPrA1d/Yre60OYGBpuPxzwkKDb0ohjCyCujN"
}

# Security group for ELB to enable ports:
# 80 - Allows HTTP access to applications
resource "aws_security_group" "elb_sg" {
  description = "ELB ports for Dokku access"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${var.allowed_cidr_blocks}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for dokku server to enable ports:
# 22 - Allows git access over SSH
# 80 - Allows HTTP access to application
resource "aws_security_group" "dokku_sg" {
  description = "Dokku server ports"
  vpc_id      = "${var.vpc_id}"

  ingress {
    security_groups = ["${aws_security_group.elb_sg.id}"]
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = "${var.allowed_cidr_blocks}"
  }

  ingress {
    security_groups = ["${aws_security_group.elb_sg.id}"]
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creates dokku EC2 instance as t2.micro because I'm cheap.
# (Though you can change the instance type in the .tfvars file)
# In a production environment, this would ideally create a cluster of
# m4.xlarge instances or something.
#
# This provisions the Ubuntu 16.04 instance via cloud-config in
# the template file below.
resource "aws_instance" "dokku" {
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  associate_public_ip_address = true
  key_name                    = "${var.key_name}"
  subnet_id                   = "${var.subnet_id}"
  vpc_security_group_ids      = [
    "${aws_security_group.dokku_sg.id}"
  ]

  root_block_device {
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = true
  }

  tags {
    Name = "dokku-server"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${file("${var.key_path}")}"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/init-dokku.sh"
    destination = "/home/ubuntu/init-dokku.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/init-dokku.sh",
      "sudo /home/ubuntu/init-dokku.sh"
    ]
  }
}

# ELB created to access dokku
resource "aws_elb" "elb_dokku" {
  name            = "elb-dokku"
  subnets         = ["${var.subnet_id}"]
  security_groups = ["${aws_security_group.elb_sg.id}"]

  tags {
    Name = "elb-dokku"
  }

  listener {
    instance_port     = 3000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:3000/"
    interval            = 30
  }

  instances = ["${aws_instance.dokku.id}"]

  depends_on = ["aws_instance.dokku"]
}
