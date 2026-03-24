variable "private_subnet_count" {
  type    = number
  default = 6

}

variable "public_subnet_count" {
  type    = number
  default = 3

}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]

}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default = [
    "10.99.0.0/24",
    "10.99.1.0/24",
    "10.99.2.0/24",
    "10.99.3.0/24",
    "10.99.4.0/24",
    "10.99.5.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default = [
    "10.99.100.0/24",
    "10.99.105.0/24",
    "10.99.110.0/24",
    "10.99.115.0/24",
    "10.99.120.0/24",
    "10.99.125.0/24"
  ]
}

variable "aurora_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default = [
    "10.99.200.0/24",
    "10.99.210.0/24",
    "10.99.220.0/24",
    "10.99.230.0/24",
    "10.99.240.0/24",
    "10.99.250.0/24"
  ]
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "domain_name" {
  default = "dev.example.com"
}

variable "engine" {
  type        = string
  default     = "aurora-postgresql"
  description = "The engine of the Aurora DB cluster"

  validation {
    condition     = contains(["aurora-postgresql"], var.engine)
    error_message = <<-EOT
        This engine must contain: 'aurora-postgresql'
        EOT
  }
}

variable "db_username" {
  description = "The database username for IAM authentication."
  type        = string
  sensitive   = true
  default     = "DMay12345"
}

variable "db_password" {
  description = "The master password for the database."
  type        = string
  sensitive   = true
  default     = "admin1234$"
}
