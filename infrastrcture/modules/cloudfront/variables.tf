variable "name_prefix" {
  type = string
}

variable "origin_domain_name" {
  description = "App Runner domain (no scheme), e.g., abc.us-east-1.awsapprunner.com"
  type        = string
}

variable "domain_name" {
  description = "Custom domain to serve (e.g., document-verifier-api.practicedevops.site)"
  type        = string
}

variable "acm_certificate_arn" {
  description = "Existing ACM certificate ARN in us-east-1 for CloudFront"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "waf_web_acl_arn" {
  description = "Optional WAFv2 Web ACL ARN to attach to the distribution"
  type        = string
  default     = ""
}