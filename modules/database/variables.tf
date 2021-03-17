variable "env" {
  type        = string
  description = "Environment based on current workspace"
}

variable "env_tags" {
  type        = map(string)
  description = "Environment tags"
}

variable "location" {
  type        = string
  description = "Resources location"
}

variable "rg" {
  type        = any
  description = "Resource group"
}

variable "db_admin_username" {
  type        = string
  description = "Database admin username"
}

variable "db_admin_password" {
  type        = string
  description = "Database admin password"
}

variable "db_admin_start_ip" {
  type        = string
  description = "Database admin IP address"
}

variable "postgresql_sku_name" {
  type        = string
  description = "PostgreSQL Sku Name"
  default     = "B_Gen5_2"
}

variable "postgresql_version" {
  type        = string
  description = "PostgreSQL version"
  default     = "11"
}