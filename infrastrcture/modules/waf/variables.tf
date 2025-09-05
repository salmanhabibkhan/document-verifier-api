variable "name_prefix" {
  type = string
}

variable "cloudfront_arn" {
  description = "Full CloudFront distribution ARN (use the exact ARN returned by CloudFront)."
  type        = string
  default = ""
}

variable "malicious_ip_cidrs" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "enable_logging" {
  description = "Enable WAF request logging (Firehose -> S3)."
  type        = bool
  default     = false
}
