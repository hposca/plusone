variable "aws_region" {
  description = "The AWS region to create things in."
}

variable "cluster_name" {
  description = "The name of the cluster this task will belong to"
}

variable "task_name" {
  description = "The task name (family) for the task definition."
}

variable "log_volume" {
  description = "Name of the log volume that should be used by containers on the same task definition"
  default     = "log"
}

variable "logs_directory" {
  description = "Full path directory were the application puts logs"
  default     = "/usr/src/app/log/"
}

variable "log_identifier" {
  description = "Used for better identifying a container on the logs"
}

variable "launch_type" {
  description = "Which Launch Type we shoud use [FARGATE, EC2]"
  default     = "FARGATE"
}

# For CPU and RAM please follow the table provided by AWS itself:
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/create-task-definition.html
#
# |   CPU value    |              Memory value              |
# |----------------|----------------------------------------|
# | 256 (.25 vCPU) |            512MB, 1GB, 2GB             |
# | 512 (.5 vCPU)  |           1GB, 2GB, 3GB, 4GB           |
# | 1024 (1 vCPU)  |   2GB, 3GB, 4GB, 5GB, 6GB, 7GB, 8GB    |
# | 2048 (2 vCPU)  | Between 4GB and 16GB in 1GB increments |
# | 4096 (4 vCPU)  | Between 8GB and 30GB in 1GB increments |
variable "max_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units) for the whole task definition"
  default     = "512"
}

variable "max_memory" {
  description = "Fargate instance memory to provision (in MiB) for the whole task definition"
  default     = "1024"
}

variable "main_image_repo" {
  description = "Docker image repository that should be used for the main application on the ECS Service. Must be created beforehand."
  default     = "adongy/hostname-docker"
}

variable "main_image_tag" {
  description = "Which tag to use with the 'var.image_repo'"
}

variable "containers_per_task" {
  description = "Number of containers, of our main application, to run. Minimum 1, maximum 10. It is an ECS limitation of a maximum of 10 containers (total): https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service_limits.html."
  default     = 2
}

variable "database_password" {
  description = "Database Password"
}

variable "database_name" {
  description = "The database name"
}

variable "database_address" {
  description = "The database address"
}

variable "database_port" {
  description = "The database port"
}

variable "database_username" {
  description = "The database Username"
}

variable "host_port" {
  description = "Port, on the host, that we should attach to"
}

variable "container_port" {
  description = "Port that is exposed by the application container"
}
