provider "aws" {
  region = "${var.aws_region}"
}

module "plusone_repositories" {
  source             = "modules/ecr/"
  repositories_names = ["plusone"]
}

module "plusone_cluster" {
  source       = "modules/ecs-cluster/"
  cluster_name = "plusone"
}

module "plusone_service1" {
  source              = "modules/ecs-service/"
  cluster_id          = "${module.plusone_cluster.cluster_id}"
  cluster_name        = "${module.plusone_cluster.cluster_name}"
  service_name        = "plusone-service1"
  task_definition_arn = "${module.plusone_task1.task_definition_arn}"

  vpc_id          = "${module.vpc.vpc_id}"
  public_subnets  = "${module.vpc.public_subnets}"
  private_subnets = "${module.vpc.private_subnets}"

  # The name of the project this application is part of. This name will be used
  # on keys at the parameter store, which will be fetched by template engines
  # to configure their respective files.
  project = "plusone"

  enable_autoscaling = true

  # Scale-out refers to when we want to increase the number of jobs. So,
  # here we can set the time in which we will increase the number of jobs
  # running. All times are in UTC.
  autoscaling_scale_out_cron = "cron(45 23 * * ? *)"

  # Scale-in refers to when we want to decrease the number of jobs. So,
  # here we can set the time in which we will decrease the number of jobs
  # running. All times are in UTC.
  autoscaling_scale_in_cron = "cron(00 20 * * ? *)"

  # This will set, at the same time, the desired number of tasks to
  # run now and the maximum number of tasks that will be executed
  # when the automatic autoscaling scales up
  desired_tasks_number = 3

  # To keep some tasks running when it scales down automatically, change the
  # 'autoscaling_min_tasks' value. If it is set to 1, one task will always be
  # running:
  autoscaling_min_tasks = 0
}

module "plusone_task1" {
  source = "modules/plusone-task"

  aws_region     = "${var.aws_region}"
  cluster_name   = "${module.plusone_cluster.cluster_name}"
  task_name      = "plusone-task1"
  log_identifier = "plusone-task1"

  max_cpu    = 1024
  max_memory = 2048

  # This is the number of containers that we want to have running at the same
  # time in a single task. Terraform will automatically split the CPU and
  # memory between all the containers.
  # Due to the current architecture please leave this as 1.
  containers_per_task = 1

  main_image_repo = "${module.plusone_repositories.repositories_urls["plusone"]}"
  main_image_tag  = "master-latest"

  database_name     = "${aws_ssm_parameter.database_name.value    }"
  database_address  = "${aws_ssm_parameter.database_address.value }"
  database_port     = "${aws_ssm_parameter.database_port.value    }"
  database_username = "${aws_ssm_parameter.database_username.value}"

  # AWS recently released the use of "secrets" on ECS task-definitions, here is
  # a wonderful place to use it.
  database_password = "${aws_ssm_parameter.database_password.value}"

  # Ports defined by the application
  host_port      = 5000
  container_port = 5000
}
