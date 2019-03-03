output "cluster_id" {
  value       = "${aws_ecs_cluster.main.id}"
  description = "The id of the cluster created by this module."
}

output "cluster_name" {
  value       = "${aws_ecs_cluster.main.name}"
  description = "The name of the cluster created by this module."
}
