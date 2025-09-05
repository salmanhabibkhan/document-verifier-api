data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# IAM role that App Runner assumes to pull ECR and read Secrets
data "aws_iam_policy_document" "apprunner_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["build.apprunner.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "apprunner_access" {
  name               = "${var.name_prefix}-apprunner-access"
  assume_role_policy = data.aws_iam_policy_document.apprunner_assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "apprunner_access" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:DescribeImages",
    ]
    resources = ["*"]
  }

  # Allow reading any secret ARNs passed into runtime_environment_secrets
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = length(var.runtime_environment_secrets) > 0 ? values(var.runtime_environment_secrets) : ["arn:aws:secretsmanager:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:secret:*"]
  }

  statement {
    effect = "Allow"
    actions = ["kms:Decrypt"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["secretsmanager.${data.aws_region.current.id}.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "apprunner_access" {
  name   = "${var.name_prefix}-apprunner-access"
  policy = data.aws_iam_policy_document.apprunner_access.json
}

resource "aws_iam_role_policy_attachment" "apprunner_access" {
  role       = aws_iam_role.apprunner_access.name
  policy_arn = aws_iam_policy.apprunner_access.arn
}

# Auto Scaling config
resource "aws_apprunner_auto_scaling_configuration_version" "this" {
  auto_scaling_configuration_name = "${var.name_prefix}-asc"
  max_concurrency                 = 100
  max_size                        = 5
  min_size                        = 1
  tags                            = var.tags
}

# App Runner Service
resource "aws_apprunner_service" "this" {
  service_name = "${var.name_prefix}-svc"

  source_configuration {
    auto_deployments_enabled = true

    image_repository {
      image_identifier      = var.bootstrap_image_identifier
      image_repository_type = "ECR_PUBLIC" # Bootstrap image; pipeline switches to private ECR
      image_configuration {
        port                          = "8000"
        runtime_environment_variables = var.runtime_environment_variables
        runtime_environment_secrets   = var.runtime_environment_secrets
      }
    }

    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_access.arn
    }
  }

  instance_configuration {
    cpu    = "1 vCPU"
    memory = "2 GB"
  }

  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.this.arn

  tags = var.tags

  lifecycle {
    ignore_changes = [
      source_configuration[0].image_repository[0].image_identifier,
      source_configuration[0].image_repository[0].image_repository_type,
      source_configuration[0].auto_deployments_enabled,
    ]
  }
}

output "service_url" {
  value = aws_apprunner_service.this.service_url
}

output "service_domain_name" {
  value = aws_apprunner_service.this.service_url != "" ? replace(aws_apprunner_service.this.service_url, "https://", "") : ""
}

output "service_arn" {
  value = aws_apprunner_service.this.arn
}