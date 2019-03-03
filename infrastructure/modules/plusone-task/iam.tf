#################
# ECS Tasks Roles
#################

data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${lower(var.task_name)}-ecs_task_execution_role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task_assume.json}"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_task_execution_policy" {
  name = "${lower(var.task_name)}-ecs_task_execution_policy"

  policy = "${data.aws_iam_policy_document.ecs_task_execution.json}"
}

resource "aws_iam_role_policy_attachment" "attach_task_execution" {
  role       = "${aws_iam_role.ecs_task_execution_role.name}"
  policy_arn = "${aws_iam_policy.ecs_task_execution_policy.arn}"
}

data "aws_iam_policy_document" "ecs_task_role_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "${lower(var.task_name)}-ecs_task_role"
  assume_role_policy = "${data.aws_iam_policy_document.ecs_task_role_assume.json}"
}

data "aws_iam_policy_document" "ecs_task_role" {
  statement {
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_task_policy" {
  name   = "${lower(var.task_name)}-ecs_task_role_policy"
  policy = "${data.aws_iam_policy_document.ecs_task_role.json}"
}

resource "aws_iam_role_policy_attachment" "attach_task_policy" {
  role       = "${aws_iam_role.ecs_task_role.id}"
  policy_arn = "${aws_iam_policy.ecs_task_policy.arn}"
}
