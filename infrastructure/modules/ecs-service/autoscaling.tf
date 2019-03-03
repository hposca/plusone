#############
# AutoScaling
#############

resource "aws_appautoscaling_target" "ecs" {
  count = "${var.enable_autoscaling}"

  min_capacity = "${var.autoscaling_min_tasks}"
  max_capacity = "${var.desired_tasks_number}"

  resource_id = "service/${var.cluster_name}/${aws_ecs_service.main.name}"

  role_arn           = "${aws_iam_role.ecs_autoscaling_assume.arn}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  # https://www.reddit.com/r/Terraform/comments/7lcvdv/on_apply_our_autoscaling_ecs_target_groups_role/#t1_dsf1f29
  lifecycle {
    ignore_changes = ["role_arn"]
  }
}

resource "aws_appautoscaling_scheduled_action" "ecs_out" {
  count = "${var.enable_autoscaling}"

  name               = "${var.service_name}-ecs-autoscalling-out"
  service_namespace  = "${aws_appautoscaling_target.ecs.service_namespace}"
  resource_id        = "${aws_appautoscaling_target.ecs.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.ecs.scalable_dimension}"

  schedule = "${var.autoscaling_scale_out_cron}"

  scalable_target_action {
    min_capacity = "${var.desired_tasks_number}"
    max_capacity = "${var.desired_tasks_number}"
  }
}

resource "aws_appautoscaling_scheduled_action" "ecs_in" {
  count = "${var.enable_autoscaling}"

  name               = "${var.service_name}-ecs-autoscalling-in"
  service_namespace  = "${aws_appautoscaling_target.ecs.service_namespace}"
  resource_id        = "${aws_appautoscaling_target.ecs.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.ecs.scalable_dimension}"
  schedule           = "${var.autoscaling_scale_in_cron}"

  scalable_target_action {
    min_capacity = "${var.autoscaling_min_tasks}"
    max_capacity = "${var.autoscaling_min_tasks}"
  }
}
