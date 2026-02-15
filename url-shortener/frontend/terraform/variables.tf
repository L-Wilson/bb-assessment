###############################################################################
# General
###############################################################################

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "aws_profile" {
  description = "AWS CLI profile"
  type        = string
  default     = "default"
}

variable "environment" {
  description = "Deployment environment (development, staging, production)"
  type        = string
}

###############################################################################
# CloudFront
###############################################################################

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "custom_domain" {
  description = "Custom domain for CloudFront distribution (optional)"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for custom domain (must be in us-east-1)"
  type        = string
  default     = ""
}

###############################################################################
# WAF
###############################################################################

variable "waf_rate_limit" {
  description = "Maximum requests per 5-minute period per IP"
  type        = number
  default     = 2000
}
