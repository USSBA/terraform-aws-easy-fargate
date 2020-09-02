data "aws_vpc" "default" {
  count   = local.subnet_ids_provided ? 0 : 1
  default = true
}
data "aws_subnet_ids" "default" {
  count  = local.subnet_ids_provided ? 0 : 1
  vpc_id = data.aws_vpc.default[0].id
}

# Fetch a data resource of a provided subnet [if provided]
data "aws_subnet" "subnet_for_vpc_reference" {
  count = local.subnet_ids_provided ? 1 : 0
  id    = var.subnet_ids[0]
}

locals {
  create_schedule             = var.schedule_expression != ""
  create_schedule_count       = local.create_schedule ? 1 : 0
  security_group_ids_provided = length(var.security_group_ids) > 0
  security_group_ids          = local.security_group_ids_provided ? var.security_group_ids : [aws_security_group.allow_outbound_traffic[0].id]
  subnet_ids_provided         = length(var.subnet_ids) > 0
  subnet_ids                  = local.subnet_ids_provided ? var.subnet_ids : data.aws_subnet_ids.default[0].ids
  # If subnet_ids are provided, look up the VPC id associated with them.  If not, use the default VPC
  vpc_id = local.subnet_ids_provided ? data.aws_subnet.subnet_for_vpc_reference[0].vpc_id : data.aws_vpc.default[0].id

  task_def_arn_wildcard = format("%s:*", regex("(.*):[^:]+$", aws_ecs_task_definition.this[0].arn)[0])
}
resource "aws_security_group" "allow_outbound_traffic" {
  # Only create if no security_group_ids were provided
  count       = local.security_group_ids_provided ? 0 : 1
  name_prefix = "${var.name}-allow-outbound"
  description = "${var.name} Allow outbound traffic"
  vpc_id      = local.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_event_rule" "schedule_rule" {
  count               = local.create_schedule_count
  name                = var.name
  schedule_expression = var.schedule_expression
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "fargate_scheduled_task" {
  count    = local.create_schedule_count
  rule     = aws_cloudwatch_event_rule.schedule_rule[0].name
  arn      = var.ecs_cluster_arn
  role_arn = aws_iam_role.schedule_role[0].arn

  ecs_target {
    task_definition_arn = aws_ecs_task_definition.this[0].arn
    task_count          = 1
    launch_type         = "FARGATE"

    network_configuration {
      subnets          = local.subnet_ids
      security_groups  = local.security_group_ids
      assign_public_ip = var.assign_public_ip
    }
  }
}

resource "aws_iam_role_policy" "schedule_role_policy" {
  count  = local.create_schedule_count
  name   = "${var.name}_schedule_policy"
  role   = aws_iam_role.schedule_role[0].id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecs:RunTask"
            ],
            "Resource": [
                "${local.task_def_arn_wildcard}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
            ],
            "Resource": [
                "${aws_iam_role.this[0].arn}",
                "${aws_iam_role.ecs_task_execution_role[0].arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "schedule_role" {
  count = local.create_schedule_count
  name  = "${var.name}_schedule_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}
