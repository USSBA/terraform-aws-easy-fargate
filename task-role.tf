resource "aws_iam_role" "task" {
  name               = "${var.task_family}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.principal.json
}
resource "aws_iam_role_policy" "task" {
  name   = "inline1"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task.json
}
resource "aws_iam_role_policy" "task_inline" {
  count = length(var.task_inline_policies)

  name   = "inline-${var.task_inline_policies[count.index].name}"
  role   = aws_iam_role.task.id
  policy = var.task_inline_policies[count.index].policy
}
resource "aws_iam_role_policies_exclusive" "task_inline" {
  role_name    = aws_iam_role.task.name
  policy_names = concat([aws_iam_role_policy.task.name], aws_iam_role_policy.task_inline.*.name)
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

