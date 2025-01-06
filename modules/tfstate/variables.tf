variable "environment" {
  description = "Environment where resources will be created (dev, prod)"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}
