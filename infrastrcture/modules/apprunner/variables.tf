variable "name_prefix" {
  type = string
}

variable "ecr_repo_url" {
  type = string
}

variable "bootstrap_image_identifier" {
  description = "Initial image to create App Runner service. Pipeline will update to ECR."
  type        = string
}

variable "runtime_environment_secrets" {
  description = "Map of ENV var name to Secrets Manager ARN"
  type        = map(string)
  default     = {}
}

variable "runtime_environment_variables" {
  description = "Map of plain ENV vars"
  type        = map(string)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}