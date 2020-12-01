resource "aws_iam_role_policy" "server" {
  name = "server-${random_pet.name.id}"
  role = aws_iam_role.server.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeTags",
        "autoscaling:DescribeAutoScalingGroups"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "server" {
  name = "server-${random_pet.name.id}"

  tags = merge(local.common_tags, {Name = "${random_pet.name.id}-server_role"})

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "server" {
  name = "server-${random_pet.name.id}"
  role = aws_iam_role.server.name
}

# resource "aws_iam_role_policy" "f5" {
#   name = "f5-${random_pet.name.id}"
#   role = aws_iam_role.f5.id

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "s3:GetObject",
#         "s3:DeleteObject"	
#       ],
#       "Effect": "Allow",
#       "Resource": "arn:aws:s3:::${aws_s3_bucket.default.id}/admin.shadow"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role" "f5" {
#   name = "f5-${random_pet.name.id}"

#   tags = merge(local.common_tags, {Name = "${random_pet.name.id}-f5_role"})

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_instance_profile" "f5" {
#   name = "f5-${random_pet.name.id}"
#   role = aws_iam_role.f5.name
# }
