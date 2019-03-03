resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.cluster_name}/${var.task_name}"
  retention_in_days = 30

  tags {
    Name = "${lower(var.task_name)}-cwlg-ecs"
  }
}

data "template_file" "container_partials" {
  count    = "${var.containers_per_task}"
  template = "${file("${path.module}/container-definitions/main_partial.json.tpl")}"

  vars {
    APP_ENVIRONMENT      = "${terraform.workspace}"
    AWS_REGION           = "${var.aws_region}"
    CLOUDWATCH_LOG_GROUP = "${aws_cloudwatch_log_group.ecs.name}"
    CONTAINER_ID         = "${count.index + 1}"
    CONTAINER_PORT       = "${var.container_port}"
    DATABASE_NAME        = "${var.database_name}"
    DATABASE_ADDRESS     = "${var.database_address}"
    DATABASE_PORT        = "${var.database_port}"
    DATABASE_USERNAME    = "${var.database_username}"
    DATABASE_PASSWORD    = "${var.database_password}"
    HOST_PORT            = "${var.host_port}"
    LOGS_DIRECTORY       = "${var.logs_directory}"
    LOG_IDENTIFIER       = "${var.log_identifier}"
    LOG_VOLUME           = "${var.log_volume}"
    MAIN_CPU             = "${(var.max_cpu)/(var.containers_per_task)}"
    MAIN_IMAGE_REPO      = "${var.main_image_repo}"
    MAIN_IMAGE_TAG       = "${var.main_image_tag}"
    MAIN_MEMORY          = "${(var.max_memory)/(var.containers_per_task)}"
    TASK_NAME            = "${var.task_name}"
  }
}

data "template_file" "container_definition" {
  template = "${file("${path.module}/container-definitions/full_definition.json.tpl")}"

  vars = {
    container_partials = "${join(",", data.template_file.container_partials.*.rendered)}"
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${lower(var.task_name)}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["${var.launch_type}"]
  cpu                      = "${var.max_cpu}"
  memory                   = "${var.max_memory}"

  volume {
    name = "${var.log_volume}"
  }

  execution_role_arn    = "${aws_iam_role.ecs_task_execution_role.arn}"
  task_role_arn         = "${aws_iam_role.ecs_task_role.arn}"
  container_definitions = "${data.template_file.container_definition.rendered}"
}
