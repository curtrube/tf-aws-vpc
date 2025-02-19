variable "name" {
  type        = string
  default     = "app-dev"
  description = "Name of the VPC."
}

variable "cidr_block" {
  type        = string
  default     = "192.168.1.0/24"
  description = "IPv4 CIDR address assigned to the VPC"
}

variable "enable_dns_support" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable DNS support in the VPC."
}

variable "enable_dns_hostnames" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
}

variable "az_count" {
  type        = number
  default     = 2
  description = "The number of `Availability Zones` in which subnets will be created. This cannot be greater than the number of AZ's for the region."
}

variable "enable_public" {
  type        = bool
  default     = true
  description = "Whether to create public subnets."
}

variable "enable_private" {
  type        = bool
  default     = true
  description = "Whether to create private subnets."
}

variable "enable_isolated" {
  type        = bool
  default     = true
  description = "Whether to create isolated subnets."
}

