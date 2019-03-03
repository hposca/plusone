output "service_name" {
  value = "${aws_ecs_service.main.name}"
}

output "service_security_group" {
  value = "${aws_security_group.ecs_tasks.id}"
}

output "alb_dns_name" {
  value = "${aws_alb.main.dns_name}"
}
