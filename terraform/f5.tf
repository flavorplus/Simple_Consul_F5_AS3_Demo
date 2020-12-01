resource "random_string" "password" {
  length  = 10
  special = false
}

data "aws_ami" "f5_ami" {
  most_recent = true
  owners      = ["679593333241"]

  filter {
    name   = "name"
    values = ["F5 BIGIP-15.1* PAYG-Good 25Mbps-*"]
  }
}

resource "aws_eip" "f5" {
  vpc      = true
  tags = merge(local.common_tags, { Name = "${random_pet.name.id}-f5_public_ip" })
}

resource "aws_eip_association" "f5" {
  instance_id   = aws_instance.f5.id
  allocation_id = aws_eip.f5.id
}

resource "aws_instance" "f5" {
  ami                         = data.aws_ami.f5_ami.id
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.default.id
  vpc_security_group_ids      = [aws_security_group.f5.id]
  user_data                   = data.template_file.f5.rendered
  key_name                    = aws_key_pair.default.id

  tags = merge(local.common_tags, { Name = "${random_pet.name.id}-f5_vm" })
}

data "template_file" "f5" {
  template = file("../scripts/f5.tpl")

  vars = {
    password = random_string.password.result
    f5_public_ip = aws_eip.f5.public_ip
    consul_private_ip = aws_instance.consul.private_ip
    s3_bucket = "bla"
  }
}

resource "aws_security_group" "f5" {
  name        = "f5-${random_pet.name.id}"
  description = "Default security group for the F5."

  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allow_from]
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = [var.allow_from]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allow_from]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
