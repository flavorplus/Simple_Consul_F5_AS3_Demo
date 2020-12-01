resource "aws_launch_configuration" "nginx" {
  name_prefix                 = "nginx-${random_pet.name.id}"
  image_id                    = data.aws_ami.base.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true

  security_groups = [aws_security_group.nginx.id]
  key_name        = aws_key_pair.default.id
  user_data       = file("../scripts/nginx.sh")

  iam_instance_profile = aws_iam_instance_profile.server.name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "nginx" {
  name                 = "nginx-${random_pet.name.id}"
  launch_configuration = aws_launch_configuration.nginx.name
  desired_capacity     = 3
  min_size             = 1
  max_size             = 4
  vpc_zone_identifier  = [aws_subnet.default.id]

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = "nginx-${random_pet.name.id}"
      propagate_at_launch = true
    },
    {
      key                 = "owner"
      value               = var.owner
      propagate_at_launch = true
    },
    {
      key                 = "created-by"
      value               = var.created-by
      propagate_at_launch = true
    },
    {
      key                 = "sleep-at-night"
      value               = var.sleep-at-night
      propagate_at_launch = true
    },
    {
      key                 = "TTL"
      value               = var.TTL
      propagate_at_launch = true
    },
    {
      key                 = "consul"
      value               = "true"
      propagate_at_launch = true
    }
  ]
}

resource "aws_security_group" "nginx" {
  name   = "nginx-${random_pet.name.id}"
  vpc_id = aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allow_from]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr]
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
