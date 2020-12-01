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

resource "aws_instance" "f5" {
  # private_ip                  = "10.0.0.200"
  ami                         = data.aws_ami.f5_ami.id
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.default.id
  vpc_security_group_ids      = [aws_security_group.f5.id]
  user_data                   = data.template_file.f5.rendered
  # iam_instance_profile        = aws_iam_instance_profile.f5.name
  key_name                    = aws_key_pair.default.id

  tags = merge(local.common_tags, { Name = "${random_pet.name.id}-f5_vm" })
}


# resource "aws_s3_bucket" "default" {
#   bucket_prefix = "${random_pet.name.id}-bucket-"
#   tags          = merge(local.common_tags, { Name = "${random_pet.name.id}-bucket" })
# }

# # encrypt password sha512
# resource "null_resource" "admin-shadow" {
#   provisioner "local-exec" {
#     command = "./admin-shadow.sh ${random_string.password.result}"
#   }
# }

# resource "aws_s3_bucket_object" "password" {
#   bucket     = aws_s3_bucket.default.id
#   key        = "admin.shadow"
#   source     = "admin.shadow"
#   depends_on = [null_resource.admin-shadow]
# }

data "template_file" "f5" {
  template = file("../scripts/f5.tpl")

  vars = {
    password = random_string.password.result
    f5_public_ip = aws_instance.f5.public_ip
    consul_private_ip = aws_instance.consul.private_ip
    # s3_bucket = aws_s3_bucket.s3_bucket.id
    s3_bucket = "bla"
  }
}

# # Generate a tfvars file for AS3 installation
# data "template_file" "tfvars" {
#   template = "${file("../as3/terraform.tfvars.example")}"
#   vars = {
#     addr     = "${aws_eip.f5.public_ip}",
#     port     = "8443",
#     username = "admin"
#     pwd      = "${random_string.password.result}"
#   }
# }


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
