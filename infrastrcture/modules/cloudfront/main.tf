# Use AWS managed cache/headers policies for API
data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_origin_request_policy" "allviewer" {
  name = "Managed-AllViewer"
}

resource "aws_cloudfront_distribution" "this" {
  enabled = true
  comment = "${var.name_prefix} distribution"

  # Use your custom domain if provided. If not, omit aliases to use *.cloudfront.net only.
  aliases = var.domain_name != "" ? [var.domain_name] : null

  origin {
    domain_name = var.origin_domain_name            # e.g., xyz123.us-east-1.awsapprunner.com
    origin_id   = "${var.name_prefix}-apprunner-origin"

    # App Runner is an HTTPS origin; require HTTPS.
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    # IMPORTANT: Do NOT add a custom_header named "Host" (CloudFront forbids it).
  }

  default_cache_behavior {
    target_origin_id       = "${var.name_prefix}-apprunner-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    # Keep managed caching (tune later if needed)
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"  # Managed-CachingOptimized

    # Use our policy that does NOT forward Host
    origin_request_policy_id = aws_cloudfront_origin_request_policy.no_host.id
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # Optional: attach WAF directly here to avoid separate association problems
  web_acl_id = var.waf_web_acl_arn != "" ? var.waf_web_acl_arn : null

  tags = var.tags
}