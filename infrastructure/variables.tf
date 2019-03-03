variable "aws_region" {
  description = "AWS Region where the cluster and services will be created"
}

variable "product_name" {
  description = "The name of the product"
  default     = "plusone"
}

variable "default_tags" {
  description = "Tags to be applied on all resources"

  default = {
    Terraform = "true"
  }
}

variable "database_storage" {
  description = "Size (in GBs) of the database storage"
  default     = 5
}

variable "database_instance_class" {
  description = "The instance type of the RDS instance"
  default     = "db.t2.micro"
}

variable "database_maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'"
  default     = "Mon:00:00-Mon:03:00"
}

variable "database_backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Must not overlap with `database_maintenance_window`"
  default     = "03:00-06:00"
}
