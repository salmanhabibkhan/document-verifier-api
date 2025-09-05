# IPSet for malicious IPs
resource "aws_wafv2_ip_set" "malicious" {
  name               = "${var.name_prefix}-malicious-ips"
  description        = "Blocked IPs"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.malicious_ip_cidrs
  tags               = var.tags
}

# Web ACL
resource "aws_wafv2_web_acl" "this" {
  name        = "${var.name_prefix}-web-acl"
  description = "Web ACL for CloudFront"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "BlockMaliciousIPs"
    priority = 1
    action {
      block {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.malicious.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name_prefix}-block-malicious"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}-waf"
    sampled_requests_enabled   = true
  }

  tags = var.tags
}

# CloudWatch Logs group for WAF request logging
resource "aws_cloudwatch_log_group" "waf" {
  name              = "/aws/waf/${var.name_prefix}"
  retention_in_days = 30
  tags              = var.tags
}

# Allow AWS WAF service to write to the log group
data "aws_iam_policy_document" "waf_logs" {
  statement {
    sid     = "AWSWAFV2LoggingPermissions"
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["waf.amazonaws.com"]
    }
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.waf.arn}:*"
    ]
  }
}

resource "aws_cloudwatch_log_resource_policy" "waf" {
  policy_name     = "${var.name_prefix}-waf-logs"
  policy_document = data.aws_iam_policy_document.waf_logs.json
}

# WAF logging configuration (correct resource type)
resource "aws_wafv2_web_acl_logging_configuration" "this" {
  resource_arn            = aws_wafv2_web_acl.this.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf.arn]

  depends_on = [aws_cloudwatch_log_resource_policy.waf]
}

# Associate with CloudFront
resource "aws_wafv2_web_acl_association" "cf_assoc" {
  resource_arn = var.cloudfront_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}