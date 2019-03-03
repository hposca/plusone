resource "random_string" "password" {
  length  = 23
  special = false
}

module "database" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.product_name}"

  engine               = "mysql"
  family               = "mysql5.7"
  engine_version       = "5.7.23"
  major_engine_version = "5.7"
  instance_class       = "${var.database_instance_class}"
  allocated_storage    = "${var.database_storage}"

  name     = "${var.product_name}"
  username = "${var.product_name}"
  password = "${random_string.password.result}"
  port     = "3306"

  vpc_security_group_ids = ["${aws_security_group.database.id}"]
  subnet_ids             = "${module.vpc.private_subnets}"

  maintenance_window    = "${var.database_maintenance_window}"
  backup_window         = "${var.database_backup_window}"
  copy_tags_to_snapshot = true

  create_db_option_group = false

  tags = "${merge(map("Name", format("%s", var.product_name), "Environment", format("%s", terraform.workspace)), var.default_tags)}"

  final_snapshot_identifier = "${var.product_name}"
  deletion_protection       = "${terraform.workspace == "production" ? 1 : 0}"
}

# Security Group allowing traffic only from its own service
resource "aws_security_group" "database" {
  name        = "${var.product_name}-database"
  description = "Only allow database traffic from ${var.product_name} service"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "TCP"
    security_groups = ["${module.plusone_service1.service_security_group}"]
  }

  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "TCP"
    security_groups = ["${module.plusone_service1.service_security_group}"]
  }

  tags = "${merge(map("Name", format("%s-database", var.product_name), "Environment", format("%s", terraform.workspace)), var.default_tags)}"
}

#
# Storing important database information on SSM Parameter Store.
# The objective is actually, to provide this information only to its own
# service in a safe and secure way. Even though, other services could discover
# the database information, its access will be forbidden due to the Security
# Group restrictions (which is what we want -> Only the service that owns this
# database have the right to access it).
#
resource "aws_ssm_parameter" "database_name" {
  name        = "/${terraform.workspace}/${var.product_name}/database/name"
  description = "Name of the ${var.product_name} database"
  type        = "String"
  value       = "${module.database.this_db_instance_name}"
  overwrite   = true

  tags = "${merge(map("Service", format("%s", var.product_name), "Environment", format("%s", terraform.workspace)), var.default_tags)}"
}

resource "aws_ssm_parameter" "database_address" {
  name        = "/${terraform.workspace}/${var.product_name}/database/address"
  description = "Address of the ${var.product_name} database"
  type        = "String"
  value       = "${module.database.this_db_instance_address}"
  overwrite   = true

  tags = "${merge(map("Service", format("%s", var.product_name), "Environment", format("%s", terraform.workspace)), var.default_tags)}"
}

resource "aws_ssm_parameter" "database_port" {
  name        = "/${terraform.workspace}/${var.product_name}/database/port"
  description = "Port of the ${var.product_name} database"
  type        = "String"
  value       = "${module.database.this_db_instance_port}"
  overwrite   = true

  tags = "${merge(map("Service", format("%s", var.product_name), "Environment", format("%s", terraform.workspace)), var.default_tags)}"
}

resource "aws_ssm_parameter" "database_username" {
  name        = "/${terraform.workspace}/${var.product_name}/database/username"
  description = "Username of the ${var.product_name} database"
  type        = "String"
  value       = "${module.database.this_db_instance_username}"
  overwrite   = true

  tags = "${merge(map("Service", format("%s", var.product_name), "Environment", format("%s", terraform.workspace)), var.default_tags)}"
}

resource "aws_ssm_parameter" "database_password" {
  name        = "/${terraform.workspace}/${var.product_name}/database/password"
  description = "Password of the ${var.product_name} database"
  type        = "SecureString"
  value       = "${module.database.this_db_instance_password}"
  overwrite   = true

  tags = "${merge(map("Service", format("%s", var.product_name), "Environment", format("%s", terraform.workspace)), var.default_tags)}"
}
