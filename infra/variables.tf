variable "domain_name" {
  default    = "example.com"
  type        = string
  description = "Domain name"
}

variable "namespace" {
  default    = "nestapp"
  type        = string
  description = "namespace name"
}

variable "db_username" {
  default = "postgres"
  description = "postgres username"
}

variable "db_password" {
  default = "bvfr45s13s4!!@"
  description = "postgres password"
}