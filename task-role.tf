resource "aws_iam_role" "task" {
  name               = "${var.task_family}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.principal.json
  inline_policy {
    name   = "inline-base"
    policy = data.aws_iam_policy_document.task.json
  }
  dynamic "inline_policy" {
    iterator = inline
    for_each = var.task_inline_policies
    content {
      name   = "inline-${inline.value.name}"
      policy = inline.value.policy
    }
  }
}
data "aws_iam_policy_document" "task" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:DeleteLogStream",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
    ]
    resources = ["*"]
  }
  dynamic "statement" {
    for_each = var.ecs_execute_command_enabled ? [1] : []
    content {
      actions = [
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel",
      ]
      resources = ["*"]
    }
  }
}

