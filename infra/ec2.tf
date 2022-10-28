# The last part here is the EC2 instances that will be provisioned when terraform runs the ec2.tf file. 
# This will create 2 instances in the public subnets, and will have the security group that allows 
# http traffic attached to them

data "aws_ami" "amazon_linux_2" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_caller_identity" "current" {}

# Provides an IAM instance profile
resource "aws_iam_instance_profile" "ec2_ecr_connection" {
  name = "ec2_ecr_connection"
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = "allow_ec2_access_ecr"
  path = "/"

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

# Provides an IAM role inline policy
resource "aws_iam_role_policy_attachment" "access_ecr_policy" {
  name = "allow_ec2_access_ecr"
  role = aws_iam_role.test_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# Provides an EC2 launch template resource. Can be used to create instances or auto scaling groups.
resource "aws_launch_template" "presentation_tier" {
  name = "presentation_tier"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 8
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ecr_connection.name
  }

  instance_type = "t2.nano"
  image_id      = data.aws_ami.amazon_linux_2.id

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.presentation_tier.id]
  }

  user_data = base64encode(templatefile("./../user-data/user-data-presentation-tier.sh", {
    application_load_balancer = aws_lb.application_tier.dns_name,
    ecr_url                   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com"
    ecr_repo_name             = var.ecr_presentation_tier,
    region                    = var.region
  }))

  depends_on = [
    aws_lb.application_tier
  ]
}
