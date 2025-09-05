provider "aws" {
  region = var.region
}

# CloudFront, WAFv2 (scope=CLOUDFRONT) must be configured with a provider in us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}