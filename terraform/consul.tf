resource "aws_instance" "consul" {
  # private_ip             = "10.0.0.100"
  ami                         = data.aws_ami.base.id
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.default.id
  vpc_security_group_ids      = [aws_security_group.consul.id]
  user_data                   = file("../scripts/consul.sh")
  iam_instance_profile        = aws_iam_instance_profile.server.name
  key_name                    = aws_key_pair.default.id
  
  tags                        = merge(local.common_tags, { Name = "${random_pet.name.id}-consul_server" }, { consul = "true" })
}

resource "aws_security_group" "consul" {
  name        = "consul-${random_pet.name.id}"
  description = "Default security group for Consul."

  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allow_from]
  }

  ingress {
    from_port   = 8500
    to_port     = 8500
    protocol    = "tcp"
    cidr_blocks = [var.cidr, var.allow_from]
  }

  ingress {
    from_port   = 8300
    to_port     = 8300
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }

  ingress {
    from_port   = 8301
    to_port     = 8301
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
