#################
# ECS Autoscaling
#################

resource "aws_iam_role" "ecs_autoscaling_assume" {
  name = "${lower(var.service_name)}-ecs_autoscaling_assume"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "application-autoscaling.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "autoscaling" {
  name = "${lower(var.service_name)}-ecs_autoscaling_policy"
  role = "${aws_iam_role.ecs_autoscaling_assume.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:DescribeServices",
                "ecs:UpdateService"
            ],
            "Resource": [
                "${aws_ecs_service.main.id}"
            ]
        }
    ]
}

EOF
}
