resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = var.task_family
  schedule_expression = var.schedule_expression
  state               = var.schedule_state
}

resource "aws_cloudwatch_event_target" "event_target" {
  rule     = aws_cloudwatch_event_rule.event_rule.name
  arn      = var.ecs_cluster_arn
  role_arn = aws_iam_role.event_target.arn

  # FUTURE USE CASE
  #input    = var.task_container_overrides

  ecs_target {
    enable_execute_command = var.ecs_execute_command_enabled
    launch_type            = "FARGATE"
    platform_version       = var.ecs_platform_version
    task_count             = var.task_count
    task_definition_arn    = aws_ecs_task_definition.task.arn

    network_configuration {
      subnets          = var.subnet_ids
      security_groups  = var.security_group_ids
      assign_public_ip = var.assign_public_ip
    }
  }
}

resource "aws_iam_role" "event_target" {
  name               = "${var.task_family}-event-target"
  assume_role_policy = data.aws_iam_policy_document.principal.json
  inline_policy {
    name   = "inline1"
    policy = data.aws_iam_policy_document.event_target.json
  }
}

data "aws_iam_policy_document" "event_target" {
  statement {
    actions   = ["ecs:RunTask"]
    resources = ["${aws_ecs_task_definition.task.arn_without_revision}:*"]
  }
  statement {
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.task.arn, aws_iam_role.exec.arn]
  }
}
