# Create security group to allow web traffic.
# Source: https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "openvpn" {
  name        = "${var.aws_client_tag}-openvpn-as"
  description = "Allow http and https"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 943
    to_port     = 943
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1194
    to_port     = 1194
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create OpenVPN AS instance
# Source: https://www.terraform.io/docs/providers/aws/r/instance.html
resource "aws_instance" "openvpnserver" {
  ami             = "${var.ami}"
  instance_type   = "${var.instance_type}"
  key_name        = "${var.ssh_key_name}"
  security_groups = ["${aws_security_group.openvpn.id}"]
  subnet_id       = "${var.subnet_id}"
  # user_data       = "${data.template_file.userdata.rendered}"

  tags = {
    Name               = "${var.client_name_friendly} OpenVPN AS"
    "user:client"      = "${var.aws_client_tag}"
    "user:stack"       = "${var.aws_stack_tag}"
    "user:application" = "spoke"
  }
}
