resource "aws_iam_role" "exec" {
  name               = "${var.task_family}-ecs-exec"
  assume_role_policy = data.aws_iam_policy_document.principal.json
  inline_policy {
    name   = "inline-base"
    policy = data.aws_iam_policy_document.exec.json
  }
  dynamic "inline_policy" {
    iterator = inline
    for_each = var.task_exec_inline_policies
    content {
      name   = "inline-${inline.value.name}"
      policy = inline.value.policy
    }
  }
}
data "aws_iam_policy_document" "exec" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
}
