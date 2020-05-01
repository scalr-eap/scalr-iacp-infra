provider "aws" {
    region     = var.region
}

locals {
  ssh_private_key_file = "./ssh/id_rsa"
}

# Obtain the AMI for the region. CentOS7 and AWS Linux2 are also acceptable.

data "aws_ami" "the_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

###############################
#
# Scalr Server
#

resource "aws_instance" "iacp_server" {
  ami                     = data.aws_ami.the_ami.id
  instance_type           = var.instance_type
  key_name                = var.ssh_key_name
  vpc_security_group_ids  = [ data.aws_security_group.default_sg.id, aws_security_group.scalr_sg.id ]
  subnet_id               = var.subnet

  tags = {
    Name = "${var.name_prefix}-iacp-server"
  }

}

resource "aws_ebs_volume" "iacp_vol" {
  availability_zone = aws_instance.iacp_server.availability_zone
  type = "gp2"
  size = 50
}

resource "aws_volume_attachment" "iacp_attach" {
  device_name = "/dev/sds"
  instance_id = aws_instance.iacp_server.id
  volume_id   = aws_ebs_volume.iacp_vol.id
}

resource "null_resource" "null_1" {
  depends_on = [aws_instance.iacp_server]

  connection {
        host	= aws_instance.iacp_server.public_ip
        type     = "ssh"
        user     = "ubuntu"
        private_key = file(local.ssh_private_key_file)
        timeout  = "20m"
  }

  provisioner "file" {
      source = "./SCRIPTS/mount_vol.sh"
      destination = "/var/tmp/mount_vol.sh"
  }

  provisioner "remote-exec" {
      inline = [
        "chmod +x /var/tmp/mount_vol.sh",
        "sudo /var/tmp/mount_vol.sh ${aws_volume_attachment.iacp_attach.volume_id}",
      ]
  }
}

# Load Balancer
#

resource "aws_elb" "scalr_lb" {
  name               = "${var.name_prefix}-scalr-lb"

  subnets         = [var.subnet]
  security_groups = [ data.aws_security_group.default_sg.id, aws_security_group.scalr_sg.id]
  instances       = [ aws_instance.iacp_server.id ]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 8080
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 443
    instance_protocol = "http"
    lb_port           = 443
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8080"
    interval            = 30
  }

  tags = {
    Name = "${var.name_prefix}-scalr-elb"
  }
}

output "dns_name" {
  value = aws_elb.scalr_lb.dns_name
}
output "scalr_iacp_server_public_ip" {
  value = aws_instance.iacp_server.public_ip
}
