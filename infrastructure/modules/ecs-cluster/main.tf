resource "aws_ecs_cluster" "main" {
  name = "${lower(var.cluster_name)}"
}
