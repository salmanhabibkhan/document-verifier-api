output "cloudfront_domain_name" {
  value       = module.edge.cloudfront_domain_name
  description = "CloudFront domain serving the app"
}

output "apprunner_service_url" {
  value       = module.apprunner.service_url
  description = "App Runner default service URL (bypasses CloudFront)"
}

output "route53_record_fqdn" {
  value       = module.dns.record_fqdn
  description = "FQDN pointed to CloudFront"
}