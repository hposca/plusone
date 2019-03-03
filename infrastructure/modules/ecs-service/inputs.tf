variable "service_name" {
  description = "The name of the ECS service."
}

variable "cluster_id" {
  description = "ID of the cluster to connect this service to."
}

variable "cluster_name" {
  description = "Name of the cluster to connect this service to."
}

variable "task_definition_arn" {
  description = "ARN of the task definition registered to this service."
}

variable "vpc_id" {
  description = "VPC to use"
}

variable "public_subnets" {
  description = "Public subnets that will be used"
  type        = "list"
}

variable "private_subnets" {
  description = "Private subnets that will be used"
  type        = "list"
}

variable "project" {
  description = "The name of the project this application is part of. This name will be used on keys at the parameter store, which will be fetched by template engines to configure their respective files."
}

variable "lb_ingress_port" {
  description = "Port that will receive connections on the Load Balancer"
  default     = 80
}

variable "app_port" {
  description = "Port exposed by the docker container to redirect traffic to"
  default     = 5000
}

variable "desired_tasks_number" {
  description = "Desired amount of tasks to run. In total you'll have 'desired_tasks_number * containers_per_task' containers running"
  default     = 3
}

###########################
# AutoScaling configuration
###########################

variable "enable_autoscaling" {
  description = "Set it to true if you want to enable autoscaling"
  default     = true
}

variable "autoscaling_min_tasks" {
  description = "Minimum number of tasks to trigger when scaling out"
  default     = "0"
}

# Info about cron expressions:
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html#CronExpressions

variable "autoscaling_scale_out_cron" {
  description = "Cron STRING that defines when we will scale OUT to `desired_tasks_number` tasks."
  default     = "cron(45 23 * * ? *)"
}

variable "autoscaling_scale_in_cron" {
  description = "Cron STRING that defines when we will scale IN to 0 tasks."
  default     = "cron(00 23 * * ? *)"
}
