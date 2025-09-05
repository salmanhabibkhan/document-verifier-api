# For App Runner: do NOT forward Host. Optionally whitelist only the headers you need.
# By default, forwards no headers. If you need Authorization, set origin_forward_headers = ["Authorization"] in the root.
resource "aws_cloudfront_origin_request_policy" "no_host" {
  name    = "${var.name_prefix}-no-host"
  comment = "Do not forward Host header so CloudFront sends origin Host (App Runner FQDN)"

  headers_config {
    header_behavior = length(var.origin_forward_headers) > 0 ? "whitelist" : "none"
    headers {
      items = var.origin_forward_headers
    }
  }

  cookies_config {
    cookie_behavior = "none"
  }

  # Forward all query strings (adjust if you prefer none or whitelist)
  query_strings_config {
    query_string_behavior = "all"
  }
}