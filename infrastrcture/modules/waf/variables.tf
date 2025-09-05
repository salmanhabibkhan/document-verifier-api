variable "name_prefix" {
  type = string
}
variable "cloudfront_arn" {
  type = string
}
variable "malicious_ip_cidrs" {
  type = list(string)
  default = []
}
variable "tags" {
  type    = map(string)
  default = {}
}