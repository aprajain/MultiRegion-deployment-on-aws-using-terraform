variable "vars" {
    type = map
    default = {
    region = "ap-southeast-2"
    appname = "app1"
    iamrolename = "codedeploy-role-sydney"
    dgname = "app1-dg"
  }
}

provider "aws" {
  region = lookup(var.vars, "region")
}



resource "aws_codedeploy_app" "app1" {
  name  = lookup(var.vars, "appname")
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "example" {
  name               = lookup(var.vars, "iamrolename")
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.example.name
}





resource "aws_codedeploy_deployment_config" "foo" {
  deployment_config_name = "test-deployment-config"

  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 1
  }
}
resource "aws_codedeploy_deployment_group" "app1_dg" {
  app_name              = aws_codedeploy_app.app1.name
  deployment_group_name = lookup(var.vars, "dgname")
  service_role_arn      = aws_iam_role.example.arn



  ec2_tag_set {
   

    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "SERVER01"
    }
    ec2_tag_filter {
      key   = "OS"
      type  = "KEY_AND_VALUE"
      value = "UBUNTU"
    }
    }

  

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  alarm_configuration {
    alarms  = ["my-alarm-name"]
    enabled = true
  }
}